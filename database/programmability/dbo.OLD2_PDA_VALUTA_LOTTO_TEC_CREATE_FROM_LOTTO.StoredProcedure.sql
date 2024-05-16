USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_PDA_VALUTA_LOTTO_TEC_CREATE_FROM_LOTTO]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








CREATE PROCEDURE [dbo].[OLD2_PDA_VALUTA_LOTTO_TEC_CREATE_FROM_LOTTO] 
	( @idDoc int -- rappresenta l'id dela riga del lotto, legato all'offerta della PDA, sul quale si fa la valutazione
	, @IdUser int  )
AS
BEGIN
	SET NOCOUNT ON;

	declare @Id as INT
	declare @idBando as int
	declare @ProtocolloRiferimento as varchar(40)
	declare @Errore as nvarchar(2000)

	declare @azienda as varchar(50)
	declare @StrutturaAziendale as varchar(150)
	declare @ProtocolloGenerale as varchar(50)
	declare @Fascicolo as varchar(50)
	declare @DataProtocolloGenerale as datetime
	declare @DataScadenza as datetime
	declare @IdPfu as INT
	declare @AttDZT_NAME  as varchar(200)
	
	declare @StatoRiga as varchar(100)
	declare @bReadDocumentazione as varchar(10)

	declare @ModAttribPunteggio varchar(50)
	declare @NumeroLotto varchar(50)

	set @StatoRiga=''
	set @bReadDocumentazione=''


	select  
		@StatoRiga=do.StatoRiga , 
		@bReadDocumentazione = case when ( isnull( BD.Value ,0) = 1 or isnull( v1.Value ,0) = 1 )  and isnull( dof.StatoRiga , '' )  <> '99' then '0' else '1' end 
	
		from Document_MicroLotti_Dettagli do with (nolock) 
				
				inner join Document_PDA_OFFERTE o  with (nolock)  on do.idheader  = o.idrow 
				
				-- prendo il dettaglio offerto dal fornitore
				left outer join Document_MicroLotti_Dettagli dof with (nolock) on o.IdMsgFornitore = dof.idheader and 
												( (dof.TipoDoc ='OFFERTA' and o.TipoDoc = 'OFFERTA') or ( dof.TipoDoc ='55;186' and isnull(o.TipoDoc , '' ) = '' ) )
													and dof.Voce = 0 and dof.NumeroLotto = do.NumeroLotto


				-- recupera l'evidenza di lettura del documento
				left outer join CTL_DOC_VALUE BD with(nolock) on o.Tipodoc = 'OFFERTA' and o.idMsg = BD.idHeader and BD.DSE_ID = 'OFFERTA_BUSTA_TEC' and BD.DZT_Name = 'LettaBusta' and dof.id = BD.row
				left outer join CTL_DOC_VALUE v1 with(nolock) on o.Tipodoc = 'OFFERTA' and o.idMsg = v1.idHeader and v1.DSE_ID = 'BUSTA_TECNICA' and v1.DZT_Name = 'LettaBusta' 

		where do.Id=@idDoc



	set @Errore = ''
	-- cerco una versione precedente del documento confermato
	set @id = null
	select @id = id from CTL_DOC with (nolock) where LinkedDoc = @idDoc and deleted = 0 and TipoDoc in ( 'PDA_VALUTA_LOTTO_TEC' ) and statofunzionale in (  'Confermato' )

	--if exists( select IdRow from PDA_LST_BUSTE_TEC_OFFERTE_VIEW where IdRow = @idDoc and bReadDocumentazione = '1' )
	if @bReadDocumentazione='1'
	begin
		set @Errore = 'Per effettuare la valutazione tecnica e'' necessario prima aprire la relativa busta tecnica' 
	end

	--if exists( select IdRow from PDA_LST_BUSTE_TEC_OFFERTE_VIEW where IdRow = @idDoc and StatoRiga = 'escluso' )
	if @StatoRiga = 'escluso'
	begin

		if @id is null
		begin
			set @Errore = 'Non e'' possibile la valutazione tecnica se il lotto e'' stato escluso' 
		end

	end

	--if exists( select IdRow from PDA_LST_BUSTE_TEC_OFFERTE_VIEW where IdRow = @idDoc and StatoRiga not in ( 'inVerifica' , 'daValutare' , 'Valutato') )
	if @StatoRiga <> 'inVerifica' and @StatoRiga <> 'daValutare' and  @StatoRiga = 'Valutato'
	begin
	
		if @id is null
		begin
			set @Errore = 'Lo stato del lotto non consente la valutazione' 
		end
	end


	if @Errore = '' 
	begin

		-- cerco una versione precedente del documento , in futuro potrebbe essere discriminata per utente
		set @id = null
		select @id = id from CTL_DOC with (nolock) where LinkedDoc = @idDoc and deleted = 0 and TipoDoc in ( 'PDA_VALUTA_LOTTO_TEC' ) and statofunzionale in (  'Confermato' , 'InLavorazione' )

		if @id is null
		begin
			   -- altrimenti lo creo

				INSERT into CTL_DOC (
					IdPfu,  TipoDoc, 
					Titolo, Body, Azienda,  
					ProtocolloRiferimento, Fascicolo, LinkedDoc )
				select 
					@IdUser as idpfu , 'PDA_VALUTA_LOTTO_TEC' as TipoDoc ,  
					'Valutazione Lotto' as Titolo, '' Body, idAziPartecipante as  Azienda,  
					ProtocolloRiferimento, Fascicolo, d.id as LinkedDoc
		
					from 
						Document_MicroLotti_Dettagli d  with (nolock)
						inner join Document_PDA_OFFERTE o with (nolock) on o.IdRow = d.idHeader
						inner join Document_PDA_TESTATA t with (nolock) on o.idHeader = t.idHeader
						inner join CTL_DOC b with (nolock) on o.idHeader = b.id
					where d.id = @idDoc


				set @id = SCOPE_IDENTITY()--@@identity

				-- cerco una versione precedente se esiste
				declare @idPrev int
				set @idPrev = null
				select @idPrev = max(id) from CTL_DOC with (nolock) where LinkedDoc = @idDoc and deleted = 0 and TipoDoc in ( 'PDA_VALUTA_LOTTO_TEC' ) and statofunzionale in (  'Annullato' )

				if @idPrev is not null
				begin

					-- se esiste una versione precedente ricopiamo le note per la compilazione
					insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
						select @id as IdHeader, DSE_ID, Row, DZT_Name, Value 
							from CTL_DOC_Value with (nolock)
							--where idheader = @idPrev and dzt_name = 'Note'
							where idheader = @idPrev and dzt_name in ( 'Note' , 'GiudizioTecnico', 'GiudizioTecnicoHidden', 'Value')

				end
				
				--else
				
				begin

					declare @CriterioValutazione varchar(20)
					declare @DescrizioneCriterio nvarchar(255)
					declare @Modello nvarchar(255)
					declare @PunteggioMax varchar(50)
					declare @Punteggio varchar(50)
					declare @Formula  nvarchar(4000)
					declare @AttributoCriterio nvarchar(255)
					declare @GiudizioTecnico float

					declare @idRow int 
					declare @Row int 
					set @Row = 0




					-- recupero il modello di input del fornitore
					select @Modello = 'MODELLI_LOTTI_' + TipoBando  + '_MOD_OffertaINPUT'
							, @idBando = ba.idHeader 
							, @NumeroLotto = d.NumeroLotto
						from Document_MicroLotti_Dettagli d with (nolock)
							inner join Document_PDA_OFFERTE o with (nolock)on o.IdRow = d.idHeader
							inner join Document_PDA_TESTATA t with (nolock)on o.idHeader = t.idHeader
							inner join CTL_DOC b with (nolock)on o.idHeader = b.id
							inner join Document_Bando ba with (nolock) on ba.idHeader = b.LinkedDoc
						where d.id = @idDoc

					-- recupero @ModAttribPunteggio dal lotto per determinare quale colonna gestire in edit, se coefficiente o punteggio
					select @ModAttribPunteggio = ModAttribPunteggio from BANDO_GARA_CRITERI_VALUTAZIONE_PER_LOTTO where idBando = @idBando and N_Lotto = @NumeroLotto
					
					--recupero le desc degli attributi criterio
					select MA_DZT_Name , isnull( ML_Description , MA_DescML ) as MA_DescML into #t
						from CTL_ModelAttributes	with (nolock)
							left outer join  LIB_Multilinguismo with (nolock) on ML_KEY = MA_DescML and ML_LNG = 'I'
						where MA_MOD_ID = @Modello --and  @AttDZT_NAME = MA_DZT_Name
					

					declare crsOf cursor static for 
						select  
							p.idRow , CriterioValutazione, DescrizioneCriterio, PunteggioMax, Formula, AttributoCriterio , Punteggio , Giudizio
							from Document_MicroLotti_Dettagli d with (nolock)
								inner join Document_Microlotto_PunteggioLotto p with (nolock)on p.idHeaderLottoOff = d.id
								inner join Document_Microlotto_Valutazione v with (nolock) on p.idRowValutazione = v.idRow
							where d.id = @idDoc

								order by p.idRow

					open crsOf 
					fetch next from crsOf into  @idRow , @CriterioValutazione, @DescrizioneCriterio, @PunteggioMax, @Formula, @AttributoCriterio , @Punteggio , @GiudizioTecnico

					while @@fetch_status=0 
					begin 
					
						insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
							values(  @id , 'PDA_VALUTA_LOTTO_TEC' , @Row, 'CriterioValutazione' , @CriterioValutazione )

						insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
							values(  @id , 'PDA_VALUTA_LOTTO_TEC' , @Row, 'DescrizioneCriterio' , @DescrizioneCriterio )

						insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
							values(  @id , 'PDA_VALUTA_LOTTO_TEC' , @Row, 'PunteggioMax' , @PunteggioMax )

						insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
							values(  @id , 'PDA_VALUTA_LOTTO_TEC' , @Row, 'Formula' , @Formula )

						insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
							values(  @id , 'PDA_VALUTA_LOTTO_TEC' , @Row, 'AttributoCriterio' , @AttributoCriterio )


						set @AttDZT_NAME = dbo.GetPos(@AttributoCriterio, '.', 2 )
						insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
							select top 1 @id , 'PDA_VALUTA_LOTTO_TEC' , @Row, 'Descrizione' , dbo.StripHTML( MA_DescML )
								from #t 
								where  @AttDZT_NAME = MA_DZT_Name
						

						insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
							values(  @id , 'PDA_VALUTA_LOTTO_TEC' , @Row, 'idRow' , @idRow )

						insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
							values(  @id , 'PDA_VALUTA_LOTTO_TEC' , @Row, 'NotEditable' , case when @CriterioValutazione <> 'soggettivo' 
																								then ' GiudizioTecnico Note Value ' 
																								else 
																									case when @ModAttribPunteggio = 'punteggio'
																										then ' GiudizioTecnico '
																										else ' Value '
																										end 
																								end )

						if @idPrev is null
						begin
						    
						    insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
								values(  @id , 'PDA_VALUTA_LOTTO_TEC' , @Row, 'Value' , @Punteggio )
							 	 
						    insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
								values(  @id , 'PDA_VALUTA_LOTTO_TEC' , @Row, 'GiudizioTecnico' , @GiudizioTecnico )
						
						    insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
								values(  @id , 'PDA_VALUTA_LOTTO_TEC' , @Row, 'GiudizioTecnicoHidden' , @GiudizioTecnico )
						
						end  
						set @Row = @Row + 1 

						fetch next from crsOf into  @idRow , @CriterioValutazione, @DescrizioneCriterio, @PunteggioMax, @Formula, @AttributoCriterio , @Punteggio ,@GiudizioTecnico
					end 
					close crsOf 
					deallocate crsOf

				end





		end
	end
		
	



	if @Errore = ''
	begin

		-- verifico se alla valutazione è stata associata la sezione per la visualizzazsione dei dati offerti
		if not exists ( select [IdRow] from CTL_DOC_SECTION_MODEL with (nolock) where [IdHeader] = @Id and DSE_ID = 'PDA_OFFERTA_BUSTA_TEC' )
		begin


			insert into CTL_DOC_SECTION_MODEL ( IdHeader , DSE_ID , MOD_Name ) 
				
				select @Id , 'PDA_OFFERTA_BUSTA_TEC' ,  'MODELLI_LOTTI_' + TipoBando + '_MOD_OffertaTec' 
					from Document_MicroLotti_Dettagli d with (nolock)
						inner join Document_PDA_OFFERTE o with (nolock)on o.IdRow = d.idHeader
						inner join CTL_DOC p with (nolock)on o.idHeader = p.id
						inner join document_bando b with (nolock) on p.LinkedDoc = b.idHeader
					where d.id = @idDoc

		end



		-- rirorna l'id della nuova comunicazione appena creata
		select @Id as id
	
	end
	else
	begin
		-- rirorna l'errore
		select 'Errore' as id , @Errore as Errore
	end
END













GO
