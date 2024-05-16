USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_Avcp_Popola_da_DOC_STEP]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--use aflink_pa_dev



CREATE PROCEDURE [dbo].[OLD2_Avcp_Popola_da_DOC_STEP] 
( 
	@idDoc int	
	,@idRow int
)
AS
BEGIN
	declare @X int
	declare @StartTime datetime
	set nocount on

	if @idRow = 0 
	begin

		exec Avcp_Popola_da_DOC_START @idDoc

	end 
	else
	begin
		
		set @StartTime = getdate()
		set @X = 1

		-- se c'è uno step non elaborato procedo se non sono trascorsi X secondi
		while exists( select top 1 idrow  from [dbo].[document_AVCP_lotti] with(nolock) where idheader = @idDoc  and [StatoElaborazione] = 0 )
				and datediff( second , @StartTime , getdate() ) < @X
		begin
			
			select top 1 @idRow = idrow  from [dbo].[document_AVCP_lotti] with(nolock) where idheader = @idDoc  and [StatoElaborazione] = 0 order by idrow

			declare @NewDoc int

			declare @PrevDoc int

			-- X > 0 - mi ritorna l'id del precedente solo esiste ed è diverso da quello corrente 
			-- X = 0 non esiste occorre inserirlo
			-- X < 0 esiste ed è uguale NON INSERIRE UNA NUOVA VERSIONE
			set @PrevDoc = dbo.AVCP_GetPrevDoc( @idRow )



			-- verifichiamo se il lotto / cig esiste
			if @PrevDoc >= 0 
			begin


				if @PrevDoc > 0 
					update [document_AVCP_lotti] set Note = 'Aggiornata rispetto alla versione precedente' where idrow = @idrow
				else
					update [document_AVCP_lotti] set Note = 'Nuova' where idrow = @idrow


				-- inserisco la gara / il lotto
				INSERT INTO ctl_doc (tipodoc,statoFunzionale,deleted,JumpCheck,data ,PrevDoc,Fascicolo,Versione,LinkedDoc,Note,idpfu,Azienda,IdDoc)
				
						select 
							case when R.NumeroLotto = 'GARA' then 'AVCP_GARA' else 'AVCP_LOTTO' end as tipodoc,
							'Pubblicato' as statoFunzionale,
							0 as deleted,
							--D.JumpCheck,
							'' as JumpCheck ,
							--isnull( DataScadenzaOfferta ,DataScadenzaOffIndicativa) AS  data ,
							getdate() as data,
							@PrevDoc as PrevDoc,
							null as Fascicolo,
							null as Versione,
							null as LinkedDoc,
							'' as Note,
							-20 as idpfu,
							isnull( D.Azienda , g.AziendaMittente ) as Azienda ,
							R.idRow as  IdDoc

							from [dbo].[document_AVCP_lotti] R with(nolock) 
								left join CTL_DOC D with(nolock) on D.id = R.idBando
								left join Document_Bando B with(nolock) on b.idheader = R.idBando
								left join avcp_bandidocgen G on G.IdDoc = r.GUIDBandoGen
							where R.idrow = @idRow
		
				set @NewDoc = SCOPE_IDENTITY()



				declare @NumeroGara varchar(100)
				declare @idRowGara int
				declare @LinkedDoc int

				set @NumeroGara = null


				----------------------------------------------------
				-- correggo i collegamenti fra documenti se necessario
				----------------------------------------------------
				if @PrevDoc = 0 -- documento nuovo
				begin
					select @NumeroGara = G.CIG , @idRowGara = G.idRow
						from [dbo].[document_AVCP_lotti] R with(nolock) 
							inner join [dbo].[document_AVCP_lotti] G with(nolock) on R.idheader = G.idheader and R.idBando = G.idBando and G.NumeroLotto = 'GARA' 
						where R.idrow = @idRow and R.NumeroLotto <> 'GARA'  
		
					-- se il lotto è legato ad una gara devo recuperare il riferimento
					if @NumeroGara is not null
					begin

						select @LinkedDoc = Versione 
							from CTL_DOC D with(nolock) 
								--inner join [document_AVCP_lotti] R with(nolock) on D.id = R.idheader
							where D.TipoDoc = 'AVCP_GARA' and D.StatoFunzionale = 'Pubblicato' and D.idPfu = -20 and D.idDoc = @idRowGara --  @R.CIG = @NumeroGara

						update CTL_DOC set fascicolo = 'AVCP-' + cast(@NewDoc as varchar ) , Versione = id  , LinkedDoc = @LinkedDoc where id = @NewDoc


					end
					else -- atrimenti è una gara senza lotti
					begin

						update CTL_DOC set fascicolo = 'AVCP-' + cast(@NewDoc as varchar ) , Versione = id  where id = @NewDoc

					end

				end
				else  -- documento in sostituzione
				begin
					
					update 
						D set fascicolo = s.fascicolo , Versione = s.Versione   , linkeddoc = S.linkeddoc 
						from CTL_DOC D
							inner join CTL_DOC S on S.id = @PrevDoc
						where D.id = @NewDoc


				end

				---------------------------------------------------------------
				-- recupero dal precedente documento eventuali importi inseriti
				---------------------------------------------------------------
				if @PrevDoc > 0
				begin

					insert into [document_AVCP_Importi]( [IdHeader], [DataInizio], [DataFine], [DataLiquidazione], [Importo] ) 
						select @NewDoc as [IdHeader], [DataInizio], [DataFine], [DataLiquidazione], [Importo] 
							from [document_AVCP_Importi]
							where [IdHeader] = @PrevDoc
							order by [Idrow]


				end 



				--------------------------------------------------------
				-- in caso sia presente una aggiudicazione la recupero
				--------------------------------------------------------
				declare @ImportoAggiudicazione float


				select @ImportoAggiudicazione = L.ValoreImportoLotto
					from [document_AVCP_lotti] R with(nolock) 
						inner join CTL_DOC P with(nolock ) on P.TipoDoc = 'PDA_MICROLOTTI' and P.deleted = 0 and P.linkeddoc = R.idBando
						inner join document_pda_offerte O with(nolock) on O.idheader = P.Id
						inner join document_microlotti_dettagli A with(nolock,index([icx_Document_MicroLotti_Dettagli_idHeaderTipoDoc])) on A.idheader = P.Id and A.TipoDoc = 'PDA_MICROLOTTI' and A.Voce = 0 and A.NumeroLotto = R.NumeroLotto and A.StatoRiga in ( 'AggiudicazioneDef' ) -- Lotti aggiudicati
						inner join document_microlotti_dettagli L with(nolock,index([icx_Document_MicroLotti_Dettagli_idHeaderTipoDoc])) on L.idheader = O.idrow and  L.TipoDoc = 'PDA_OFFERTE' and L.Voce = 0 and L.posizione in ( 'Idoneo definitivo' , 'Aggiudicatario definitivo' ) and L.NumeroLotto = R.NumeroLotto-- Lotti aggiudicati
					where R.Idrow = @idRow


				--------------------------------------------------------
				-- inserisco i dettagli del lotto/ gara
				--------------------------------------------------------
				insert into [dbo].[document_AVCP_lotti]
					( [idheader], [Anno], [Cig], [CFprop], [Denominazione], [Scelta_contraente], [ImportoAggiudicazione], [DataInizio], [Datafine], [ImportoSommeLiquidate], [Oggetto], [DataPubblicazione], [Warning] ) 
			
					select @NewDoc as [idheader], [Anno], [Cig], [CFprop], [Denominazione], [Scelta_contraente], @ImportoAggiudicazione, [DataInizio], [Datafine], [ImportoSommeLiquidate], [Oggetto], [DataPubblicazione], [Warning] 
						from [document_AVCP_lotti] with(nolock)
						where Idrow = @idRow



				if @PrevDoc > 0
				begin			
					
					update ctl_doc set Deleted = 1 , StatoFunzionale = 'Variato' where id = @PrevDoc 
					
					exec AVCP_LOTTO_MakeDifference @NewDoc , @PrevDoc

				end



			
			end
			else
			begin

				-- per aggiornare i partecipanti utilizzo il precedente documento
				set @NewDoc = -@PrevDoc

				update [document_AVCP_lotti] set Note = 'Non ha subito modifiche' where idrow = @idrow

			end




			-------------------------------------------
			-- partendo dal lotto SI PRENDONO Tutti i partecipanti
			-------------------------------------------
			if exists( select Idrow from [document_AVCP_lotti] with(nolock) where Idrow = @idRow and NumeroLotto <> 'GARA' )
				exec Avcp_Popola_da_DOC_STEP_Partecipanti  @idRow , @NewDoc


			
			-----------------------------------------------------------------
			-- esegue un controllo formale dei dati caricati se ho effettuato modifiche sul lotto
			-----------------------------------------------------------------
			if exists( select idrow from [document_AVCP_lotti] with(nolock) where idrow = @idrow and Note <> 'Non ha subito modifiche'  )
				EXEC AVCP_CONTROLLI_DOCUMENT_AVCP @NewDoc




			update document_AVCP_lotti set StatoElaborazione = 1 where idrow = @idRow  

		end


	end



	----------------------------------------
	-- Aggiorno avanzamento del caricamento
	----------------------------------------

	declare @Result nvarchar(max)
	declare @TotRow int
	declare @RowElab int
	declare @NextRow int

	declare @NumeroGare varchar(10)
	declare @NumeroLotti varchar(10)
	declare @NumeroLottiInseriti varchar(10)
	declare @NumeroLottiVariati varchar(10)
	declare @NumeroLottiNonAggiornati varchar(10)


	select @TotRow = count(*) from document_AVCP_lotti with(nolock) where idheader = @idDoc
	select @RowElab = count(*) from document_AVCP_lotti with(nolock) where idheader = @idDoc and [StatoElaborazione] = 0
	select top 1 @NextRow = idRow from document_AVCP_lotti with(nolock) where idheader = @idDoc and [StatoElaborazione] = 0 order by Idrow
	set @NextRow = isnull( @NextRow , 0 )

	if  @RowElab = 0 
	begin

		-- numero Gare
		select @NumeroGare = count(* ) from document_avcp_lotti where idheader = @idDoc and NumeroLotto = '1'

		-- numero lotti
		select @NumeroLotti = count(* ) from document_avcp_lotti where idheader = @idDoc and NumeroLotto <> 'GARA'

		-- numero lotti inseriti
		select @NumeroLottiInseriti = count(* ) from document_avcp_lotti where idheader = @idDoc and NumeroLotto <> 'GARA' and Note = 'Nuova'

		-- numero lotti Variati
		select @NumeroLottiVariati = count(* ) from document_avcp_lotti where idheader = @idDoc and NumeroLotto <> 'GARA' and Note = 'Aggiornata rispetto alla versione precedente'

		-- numero lotti non aggiornati
		select @NumeroLottiNonAggiornati = count(* ) from document_avcp_lotti where idheader = @idDoc and NumeroLotto <> 'GARA' and Note = 'Non ha subito modifiche'

	end
	else
	begin
		set @NumeroGare = '0' 
		set @NumeroLotti  = '0' 
		set @NumeroLottiInseriti = '0'
		set @NumeroLottiVariati = '0' 
		set @NumeroLottiNonAggiornati = '0' 
	end


	declare @Body varchar(max)
	
	set @Body = '{ "TotRow":"' + cast ( @TotRow as varchar ) + '","RowElab":"' + cast( @RowElab as varchar) + '","NextRow":"' + cast( @NextRow as varchar ) + '","NumeroGare":"' + @NumeroGare + '","NumeroLotti":"' + @NumeroLotti + '","NumeroLottiInseriti":"' + @NumeroLottiInseriti + '","NumeroLottiVariati":"' + @NumeroLottiVariati + '","NumeroLottiNonAggiornati":"' + @NumeroLottiNonAggiornati + '" }' 		


	update CTL_DOC 
		set Body = @Body
			, StatoFunzionale = case when @RowElab = 0 then 'Completato' else 'InCorso' end
		where id = @idDoc and StatoFunzionale <> 'Completato'

	select @Body as Result

end

GO
