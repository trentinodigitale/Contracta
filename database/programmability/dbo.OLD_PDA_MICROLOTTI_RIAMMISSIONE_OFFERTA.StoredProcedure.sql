USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_PDA_MICROLOTTI_RIAMMISSIONE_OFFERTA]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE proc [dbo].[OLD_PDA_MICROLOTTI_RIAMMISSIONE_OFFERTA] ( @idPDA int , @idrowOffertaDaRiammettere int, @idPDARiammissione int) 
as
begin


	declare @IdBando as Int 
	declare @pfuIdLng as Int 
	declare @idRow  as int
	declare @Indice  as int
	declare @Criterio as varchar(100)

	declare @ColonnaSort as float
	declare @NumeroLotto as Varchar(255) 
	declare @ColonnaSortCur as float
	declare @Graduatoria as int
	declare @Exequo int
	declare @Posizione varchar(50)
	declare @Divisione_lotti varchar(5)
	declare @idxVoceZero int
	declare @Conformita varchar(100)
	declare @importoBaseAsta2 float

	declare @i int
	declare @Last int
	
	set @Divisione_lotti  = ''
	set @idxVoceZero = 0 

	-- determino il criterio di aggiudicazione della gara
	if exists( select id from ctl_doc where id = @idPDA and isnull( jumpcheck , '' ) <> '' )
	begin

		select @Criterio = CriterioAggiudicazioneGara , @Divisione_lotti = Divisione_lotti , @Conformita = Conformita , @importoBaseAsta2 = importoBaseAsta2 , @IdBando = LinkedDoc 
			 from Document_Bando with(nolock)
				inner join CTL_DOC with(nolock) on LinkedDoc = idheader
				where id = @idPDA
		
	end
	else
	begin

		select @Criterio = CriterioAggiudicazioneGara , @importoBaseAsta2 = importoBaseAsta2  , @IdBando = LinkedDoc 
			 from TAB_MESSAGGI_FIELDS with(nolock)
				inner join CTL_DOC with(nolock) on LinkedDoc = idMsg
				where id = @idPDA

	end


	-- travaso i lotti su cui lavorare in una tabella temporanea
	select a.value as numero_lotto into #lotti 
		from ctl_doc_value a with(nolock) 
				inner join ctl_doc_value b with(nolock) ON b.IdHeader = a.IdHeader and b.row = a.row and b.DSE_ID = a.DSE_ID and b.DZT_Name = 'SelRow'	
		where a.idheader = @idPDARiammissione and a.dse_id = 'LOTTI_RIAMMESSI' and a.DZT_Name = 'NumeroLotto' and b.value = '1'
	
	
	---------------------------------------------------
	-- determino gli idmsg dei messaggi in partenza
	---------------------------------------------------
	if exists( select * from ctl_doc where isnull(JumpCheck , '') = '' and id = @idPDA )
	begin

		select min( mfidmsg ) as idOffertaPartenza , max( mfidmsg ) as idOffertaArrivo  
			into #TempOfferte
			from MessageFields
			where 
					mfFieldName = 'IdDoc'
					and mfFieldValue in (
						select mfFieldValue from MessageFields
								where 
									mfFieldName = 'IdDoc'
									and mfidmsg in ( select  idmsg  
														from Document_PDA_OFFERTE_VIEW 
														where idheader = @idPDA 
															and StatoPDA in (  '2' ,'22' , '222' , '9' ) and IdRow = @idrowOffertaDaRiammettere
													)
					)
			group by mfFieldValue

		-- aggiorno sul documento l'id di partenza
		update Document_PDA_OFFERTE set IdMsgFornitore = idOffertaPartenza
			from Document_PDA_OFFERTE
				inner join #TempOfferte on idOffertaArrivo = IdMsg
			where idheader = @idPDA and idrow = @idrowOffertaDaRiammettere

	end
	else
	begin

		update Document_PDA_OFFERTE set IdMsgFornitore = IdMsg
			from Document_PDA_OFFERTE
			where idheader = @idPDA and idrow = @idrowOffertaDaRiammettere

	end


	--------------------------------------------------------------------------------------------------
	-- se la pda è ancora nella fase amministrativa allora è necessario creare i dati per consentire la valutazione
	--------------------------------------------------------------------------------------------------
	--if exists( select * from ctl_doc where StatoFunzionale = 'VERIFICA_AMMINISTRATIVA' and id = @idPDA )
	--begin

		--------------------------------------------------------------------------------------------------
		-- per le procedure monolotto è necessario generare la riga con Voce 0 per creare virtualmente un lotto a cui legare tutte le righe
		--------------------------------------------------------------------------------------------------
		if @Divisione_lotti = '0' and  not exists( select * from ctl_doc_value where idheader = @IdBando and DSE_ID = 'TESTATA_PRODOTTI' and DZT_Name = 'RigaZero' and Value = '1' )
		begin

			-- aggiungo il record per l'offerta da riammettere
			INSERT into Document_MicroLotti_Dettagli ( IdHeader,TipoDoc,StatoRiga ,NumeroRiga , NumeroLotto , Voce , EsitoRiga)
				select o.IdRow , 'PDA_OFFERTE' as TipoDoc,'daValutare' as StatoRiga , 0 , '1' , 0 ,'' as EsitoRiga
						from Document_PDA_OFFERTE o with(nolock)

							-- solo se non esiste già nella PDA
							left join Document_MicroLotti_Dettagli l with(nolock) on l.idheader = o.IdRow and l.TipoDoc = 'PDA_OFFERTE' and l.voce = 0 and l.NumeroLotto = '1'
				where o.idrow = @idrowOffertaDaRiammettere and l.id is null

		end


		declare @IdRow1 INT
		declare @IdRow2 INT
		declare @idr INT
		
		declare @IdHeader2 INT
		declare CurProg2 Cursor Static for 
			select  o.IdRow as IdHeader2, d.id as IdRow2
				from Document_PDA_OFFERTE o with(nolock)
					inner join  Document_MicroLotti_Dettagli d with(nolock) on d.TipoDoc = case when isnull(o.TipoDoc , '') = '' then '55;186' else o.TipoDoc end  and d.IdHeader = o.IdMsgFornitore
					inner join CTL_DOC p with(nolock) on p.id = o.IdHeader 

					-- solo se non esiste già nella PDA
					left join Document_MicroLotti_Dettagli l with(nolock) on l.idheader = o.IdRow and l.TipoDoc = 'PDA_OFFERTE'  and l.voce = 0 and l.NumeroLotto = d.NumeroLotto

				where o.idheader = @idPDA and o.idrow = @idrowOffertaDaRiammettere and d.NumeroLotto in ( select numero_lotto from #lotti )
					and l.id is null
				order by o.idrow , d.Id

		open CurProg2

		FETCH NEXT FROM CurProg2 INTO @IdHeader2,@IdRow2

		WHILE @@FETCH_STATUS = 0
		BEGIN

			INSERT into Document_MicroLotti_Dettagli ( IdHeader,TipoDoc,StatoRiga,EsitoRiga )
				select @IdHeader2 , 'PDA_OFFERTE' as TipoDoc,'daValutare' as StatoRiga,'' as EsitoRiga

			set @idr = SCOPE_IDENTITY()
								
			-- ricopio tutti i valori
			exec COPY_RECORD  'Document_MicroLotti_Dettagli'  ,@IdRow2  , @idr , ',Id,IdHeader,TipoDoc,StatoRiga,EsitoRiga,ValoreImportoLotto'	
							 
			FETCH NEXT FROM CurProg2 INTO @IdHeader2,@IdRow2

		END 

		CLOSE CurProg2
		DEALLOCATE CurProg2


		-- Per le gare monolotto avendo generato la voce 0 occorre rettificare idheader lotto
		if @Divisione_lotti = '0'
		begin
		

			-- OFFERTE
			update Document_MicroLotti_Dettagli
				set idHeaderLotto = idx
				from Document_MicroLotti_Dettagli
					inner join ( select d.idheader as idhead, d.id as idx 
									from Document_MicroLotti_Dettagli d with(nolock)
											inner join Document_PDA_OFFERTE o with(nolock) on o.idrow = d.idheader and d.TipoDoc = 'PDA_OFFERTE' and Voce = 0
										where o.idheader = @idPDA and o.IdRow = @idrowOffertaDaRiammettere
								) as a on a.idhead = idheader and TipoDoc = 'PDA_OFFERTE' 

			-- OFFERTE aggiorno il lotto e la voce
			update Document_MicroLotti_Dettagli
				set NumeroLotto = '1' ,  Voce = NumeroRiga 
				from Document_MicroLotti_Dettagli d
					inner join Document_PDA_OFFERTE o on o.idrow = d.idheader 
				where o.idheader = @idPDA and d.TipoDoc = 'PDA_OFFERTE' and o.IdRow = @idrowOffertaDaRiammettere

		end

	--end

				
	--------------------------------------------------------
	-- svuoto le colonne utilizzate per le graduatorie
	--------------------------------------------------------
	update Document_MicroLotti_Dettagli 
		set Graduatoria = 0 ,  Aggiudicata = 0 , Exequo = 0 , StatoRiga = 'daValutare' 
		from Document_MicroLotti_Dettagli d
			inner join Document_PDA_OFFERTE o on d.TipoDoc = 'PDA_OFFERTE' and d.IdHeader = o.IdRow

			-- solo per i lotti previsti nella riamissione
			 inner join #lotti l on l.numero_lotto = d.NumeroLotto

		where o.IdHeader = @idPDA and o.IdRow = @idrowOffertaDaRiammettere

	update Document_MicroLotti_Dettagli 
		set  Posizione = '' 
		from Document_MicroLotti_Dettagli d
			inner join Document_PDA_OFFERTE o on d.TipoDoc = 'PDA_OFFERTE' and d.IdHeader = o.IdRow

			-- solo per i lotti previsti nella riamissione
			 inner join #lotti l on l.numero_lotto = d.NumeroLotto

		where o.IdHeader = @idPDA and Posizione <> 'Escluso' and o.IdRow = @idrowOffertaDaRiammettere


	-- per ogni microlotto del bando dove è richiesto di riammettere le offerte
	declare crs cursor static for 
		select numero_lotto from #lotti order by numero_lotto


	open crs 
	fetch next from crs into @NumeroLotto 
	while @@fetch_status=0 
	begin 

		set @Indice = 1
		set @ColonnaSort = 0
		set @Graduatoria = 1
		set @Exequo = 0

		-- nel caso in cui per il lotto risulta esclusione o nella fase tecnica o nella fase economica deve essere annullata l'esclusione
		update E set StatoFunzionale = 'Annullato'
			from document_microlotti_dettagli L 
				inner join CTL_DOC E on L.id = E.LinkedDoc and E.StatoFunzionale = 'Confermato' and E.TipoDoc  in ( 'DECADENZA' , 'ESITO_LOTTO_ESCLUSA' , 'ESITO_ECO_LOTTO_ESCLUSA' ) and E.deleted = 0 
			where L.idheader = @idrowOffertaDaRiammettere and L.TipoDoc = 'PDA_OFFERTE' and L.numerolotto = @NumeroLotto

		-- si crea la struttura per la valutazione tecnica se mancante
		EXEC PDA_VALUTAZIONE_TEC_LOTTO_RIAMMESSO @idPDA , @NumeroLotto , @idrowOffertaDaRiammettere 

		fetch next from crs into @NumeroLotto

	end 
	close crs 
	deallocate crs



	-- aggiorno sulle righe dei microlotti del bando i messaggi che si sono aggiudicati i lotti
	--update Document_MicroLotti_Dettagli  
	--	set Aggiudicata = idMsg , TotaleOffertaUnitario = tou  , ScontoOffertoUnitario = SOU , Exequo = ex
	--	from Document_MicroLotti_Dettagli m 
	--		inner join (
	--			select NumeroLotto as NumLot
	--					, Aggiudicata as idMsg
	--				    , TotaleOffertaUnitario as tou
	--					, ScontoOffertoUnitario as SOU
	--					, Exequo as ex

	--				from Document_MicroLotti_Dettagli with(nolock)
	--					where IdHeader in ( select idrow from Document_PDA_OFFERTE with(nolock) where IdHeader = @idPDA and idrow = @idrowOffertaDaRiammettere ) 
	--						and Aggiudicata > 0
	--						and TipoDoc = 'PDA_OFFERTE'
	--			) as  a on  NumeroLotto = NumLot
	--	where IdHeader = @idPDA  and TipoDoc = 'PDA_MICROLOTTI'
			

	---------------------------------------------------------------------------------
	--- SE NON C'E LA BUSTA TECNICA FACCIO PASSARE IN AUTOMATICO LE RIGHE DELL'OFFERTA RIAMMESSA A VALUTATO PER POTER PASSARE DIRETTAMENTE
	--- ALLA VALUTAZIONE ECONOMICA
	---------------------------------------------------------------------------------

	if @Divisione_lotti <> '0'
	begin

		update Document_MicroLotti_Dettagli  
			set StatoRiga = 'Valutato'
			where id in 
				( 
					select id 
						from Document_PDA_OFFERTE o with(nolock)
							inner join Document_MicroLotti_Dettagli d with(nolock) on o.IdRow = d.idheader  and d.TipoDoc = 'PDA_OFFERTE' and d.StatoRiga  = 'daValutare'
							inner join BANDO_GARA_CRITERI_VALUTAZIONE_PER_LOTTO on idBando =  @IdBando and N_Lotto = NumeroLotto and  CriterioAggiudicazioneGara <> '15532' and CriterioAggiudicazioneGara <> '25532'  and isnull( Conformita , 'No' ) <> 'Ex-Ante'
						where o.IdHeader = @idPDA  and o.idrow = @idrowOffertaDaRiammettere
				)
				-- dei lotti riammessi

	end

	-- nel caso del monolotto non essendoci il lotto lo script superiore non ha effetto
	if @Divisione_lotti = '0' and  @Criterio <> '15532' and @Criterio <> '25532' and isnull( @Conformita , 'No' ) <> 'Ex-Ante' 
	begin

		update Document_MicroLotti_Dettagli  
			set StatoRiga = 'Valutato'
			where id in 
				( 
					select id 
						from Document_PDA_OFFERTE o with(nolock)
							inner join Document_MicroLotti_Dettagli d with(nolock) on o.IdRow = d.idheader  and d.TipoDoc = 'PDA_OFFERTE' and d.StatoRiga  = 'daValutare'
						where o.IdHeader = @idPDA  and o.idrow = @idrowOffertaDaRiammettere
				)



	end

end






GO
