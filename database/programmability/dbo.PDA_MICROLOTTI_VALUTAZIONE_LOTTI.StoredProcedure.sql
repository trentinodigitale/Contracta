USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[PDA_MICROLOTTI_VALUTAZIONE_LOTTI]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO











CREATE proc [dbo].[PDA_MICROLOTTI_VALUTAZIONE_LOTTI] ( @IdDoc int ) 
as
begin

	--declare @IdDoc as Int 
	--set @IdDoc=1187--<ID_DOC> 
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
	declare @TipoDocBando as varchar(500)

	
	--------------------------------------------------------------------------------------
	--- ATTENZIONE. 
	--  SE SI MODIFICANO I RAGIONAMENTI IN QUESTA STORED VEDERE SE E' NECESSARIO MODIFICARE ANCHE LA STORED
	--	PDA_MICROLOTTI_RIAMMISSIONE_OFFERTA 
	--	UTILIZZATA NELLA RIAMMISSIONE DI UN OFFERTA 
	--------------------------------------------------------------------------------------

	declare @i int
	declare @Last int
	
	set @Divisione_lotti  = ''
	set @idxVoceZero = 0 

	-- determino il criterio di aggiudicazione della gara
	if exists( select id from ctl_doc with (nolock) where id = @IdDoc and isnull( jumpcheck , '' ) <> '' )
	begin

		select @Criterio = CriterioAggiudicazioneGara , @Divisione_lotti = Divisione_lotti , @Conformita = Conformita , @importoBaseAsta2 = importoBaseAsta2 , 
			 @IdBando = P.LinkedDoc  , @TipoDocBando = B.TipoDoc
			 from Document_Bando  with (nolock)
				inner join CTL_DOC P with (nolock) on P.LinkedDoc = idheader
				inner join ctl_doc B with (nolock) on B.id=idheader										
				where P.id = @IdDoc

	end
	else
	begin

		select @Criterio = CriterioAggiudicazioneGara , @importoBaseAsta2 = importoBaseAsta2  , @IdBando = LinkedDoc 
			 from TAB_MESSAGGI_FIELDS with (nolock)
				inner join CTL_DOC with (nolock) on LinkedDoc = idMsg
				where id = @IdDoc
	
		set @TipoDocBando='55;167'					   

	end


	
	---------------------------------------------------
	-- determino gli idmsg dei messaggi in partenza
	---------------------------------------------------
	if exists( select * from ctl_doc with (nolock) where isnull(JumpCheck , '') = '' and id = @idDoc )
	begin
		select min( mfidmsg ) as idOffertaPartenza , max( mfidmsg ) as idOffertaArrivo  
			into #TempOfferte
			from MessageFields with (nolock)
			where 
					mfFieldName = 'IdDoc'
					and mfFieldValue in (
						select mfFieldValue from MessageFields with (nolock)
								where 
									mfFieldName = 'IdDoc'
									and mfidmsg in ( select  idmsg  
														from Document_PDA_OFFERTE_VIEW 
														where idheader = @IdDoc 
															and StatoPDA in (  '2' ,'22' , '222' , '9' )
													)
					)
			group by mfFieldValue

		-- aggiorno sul documento l'id di partenza
		update Document_PDA_OFFERTE set IdMsgFornitore = idOffertaPartenza
			from Document_PDA_OFFERTE
				inner join #TempOfferte on idOffertaArrivo = IdMsg
			where idheader = @IdDoc

	end
	else
	begin
		update Document_PDA_OFFERTE set IdMsgFornitore = IdMsg
			from Document_PDA_OFFERTE 
			where idheader = @IdDoc
	end


	--------------------------------------------------------------------------------------------------
	-- se la pda è ancora nella fase amministrativa allora è necessario creare i dati per consentire la valutazione
	--------------------------------------------------------------------------------------------------
	if exists( select * from ctl_doc  with (nolock) where StatoFunzionale = 'VERIFICA_AMMINISTRATIVA' and id = @idDoc )
	begin


		-- ricopio i dati dei lotti per la PDA
		--insert into Document_MicroLotti_Dettagli ( IdHeader, TipoDoc, Graduatoria, Posizione, Aggiudicata, Exequo, StatoRiga, EsitoRiga, ValoreOfferta, NumeroLotto, Descrizione, Qty, PrezzoUnitario, CauzioneMicrolotto, CIG, CodiceATC, PrincipioAttivo, FormaFarmaceutica, Dosaggio, Somministrazione, UnitadiMisura, Quantita, ImportoBaseAstaUnitaria, ImportoAnnuoLotto, ImportoTriennaleLotto, NoteLotto, CodiceAIC, QuantitaConfezione, ClasseRimborsoMedicinale, PrezzoVenditaConfezione, AliquotaIva, ScontoUlteriore, EstremiGURI, PrezzoUnitarioOfferta, PrezzoUnitarioRiferimento, TotaleOffertaUnitario, ScorporoIVA, PrezzoVenditaConfezioneIvaEsclusa, PrezzoVenditaUnitario, ScontoOffertoUnitario, ScontoObbligatorioUnitario, DenominazioneProdotto, RagSocProduttore, CodiceProdotto, MarcaturaCE, NumeroRepertorio, NumeroCampioni, Versamento, PrezzoInLettere ,ImportoBaseAsta
		--											,CampoTesto_1,CampoTesto_2,CampoTesto_3,CampoTesto_4,CampoTesto_5,CampoTesto_6,CampoTesto_7,CampoTesto_8,CampoTesto_9,CampoTesto_10,
		--											CampoNumerico_1,CampoNumerico_2,CampoNumerico_3,CampoNumerico_4,CampoNumerico_5,CampoNumerico_6,CampoNumerico_7,CampoNumerico_8,CampoNumerico_9,CampoNumerico_10
		--											, Voce, idHeaderLotto, CampoAllegato_1, CampoAllegato_2, CampoAllegato_3, CampoAllegato_4, CampoAllegato_5, NumeroRiga, PunteggioTecnico
		--											)
		--select p.id as IdHeader, 'PDA_MICROLOTTI' as TipoDoc, Graduatoria, Posizione, Aggiudicata, Exequo, 'daValutare' as StatoRiga,'' as EsitoRiga, ValoreOfferta, NumeroLotto, Descrizione, Qty, PrezzoUnitario, CauzioneMicrolotto, CIG, CodiceATC, PrincipioAttivo, FormaFarmaceutica, Dosaggio, Somministrazione, UnitadiMisura, Quantita, ImportoBaseAstaUnitaria, ImportoAnnuoLotto, ImportoTriennaleLotto, NoteLotto, CodiceAIC, QuantitaConfezione, ClasseRimborsoMedicinale, PrezzoVenditaConfezione, AliquotaIva, ScontoUlteriore, EstremiGURI, PrezzoUnitarioOfferta, PrezzoUnitarioRiferimento, TotaleOffertaUnitario, ScorporoIVA, PrezzoVenditaConfezioneIvaEsclusa, PrezzoVenditaUnitario, ScontoOffertoUnitario, ScontoObbligatorioUnitario, DenominazioneProdotto, RagSocProduttore, CodiceProdotto, MarcaturaCE, NumeroRepertorio, NumeroCampioni, Versamento, PrezzoInLettere ,ImportoBaseAsta
		--											,CampoTesto_1,CampoTesto_2,CampoTesto_3,CampoTesto_4,CampoTesto_5,CampoTesto_6,CampoTesto_7,CampoTesto_8,CampoTesto_9,CampoTesto_10,
		--											CampoNumerico_1,CampoNumerico_2,CampoNumerico_3,CampoNumerico_4,CampoNumerico_5,CampoNumerico_6,CampoNumerico_7,CampoNumerico_8,CampoNumerico_9,CampoNumerico_10
		--											, Voce, idHeaderLotto, CampoAllegato_1, CampoAllegato_2, CampoAllegato_3, CampoAllegato_4, CampoAllegato_5, NumeroRiga, PunteggioTecnico
		--	from Document_MicroLotti_Dettagli m
		--		inner join ctl_doc p on  idheader = LinkedDoc and m.TipoDoc = case when isnull(JumpCheck , '')  = '' then '55;167' else JumpCheck end 
		--	where p.id  = @idDoc
		--		order by m.id


		--------------------------------------------------------------------------------------------------
		-- per le procedure monolotto è necessario generare la riga con Voce 0 per creare virtualmente un lotto a cui legare tutte le righe
		--------------------------------------------------------------------------------------------------
		if @Divisione_lotti = '0' and  not exists( select * from ctl_doc_value  with (nolock) where idheader = @IdBando and DSE_ID = 'TESTATA_PRODOTTI' and DZT_Name = 'RigaZero' and Value = '1' )
		begin
			-- PDA
			INSERT into Document_MicroLotti_Dettagli ( IdHeader,TipoDoc,StatoRiga ,NumeroRiga , NumeroLotto , Voce , ValoreImportoLotto )
				select @idDoc , 'PDA_MICROLOTTI' as TipoDoc,'daValutare' as StatoRiga , 0 , '1' , 0 , @importoBaseAsta2
				
			set @idxVoceZero = @@identity
			update Document_MicroLotti_Dettagli
				set idHeaderLotto = @idxVoceZero
					where id = @idxVoceZero
		

			-- OFFERTE
			INSERT into Document_MicroLotti_Dettagli ( IdHeader,TipoDoc,StatoRiga ,NumeroRiga , NumeroLotto , Voce , EsitoRiga)
				select o.IdRow , 'PDA_OFFERTE' as TipoDoc,'daValutare' as StatoRiga , 0 , '1' , 0 ,'' as EsitoRiga
						from Document_PDA_OFFERTE o  with (nolock)
						where o.idheader = @idDoc and StatoPDA in (  '2' ,'22' , '222' , '9' )
						order by o.idrow 
		end

			  

		/*--VECCHIO MODO DI CREARE I RECORD DELLA PDA 2017-12-11 Enrico														 
		--copia i lotti dal bando alla PDA
		--declare @IdHeader INT
		--declare @IdRow1 INT
		--declare @idr INT	
  								  
		--declare CurProg Cursor Static for 
		
		
		--select  p.id as IdHeader, m.id as IdRow1, m.NumeroLotto
		--		from Document_MicroLotti_Dettagli m
		--		inner join ctl_doc p on  idheader = LinkedDoc and m.TipoDoc = case when isnull(JumpCheck , '')  = '' then '55;167' else JumpCheck end 
		--	where p.id  = @idDoc
		--		order by m.id

		--open CurProg

		--FETCH NEXT FROM CurProg 
		--INTO @IdHeader,@IdRow1,@NumeroLotto
		--	WHILE @@FETCH_STATUS = 0
		--		BEGIN
					
		--			--se il lotto non è revocato sul bando
		--			if not exists (select * from Document_MicroLotti_Dettagli where idheader=@IdBando and voce=0 and numerolotto=@NumeroLotto and statoriga='Revocato')
		--			begin

		--				INSERT into Document_MicroLotti_Dettagli ( IdHeader,TipoDoc,StatoRiga )
		--					select @IdHeader , 'PDA_MICROLOTTI' as TipoDoc,'daValutare' as StatoRiga
		--				set @idr = @@identity				
		 
		--				-- ricopio tutti i valori
		--				exec COPY_RECORD  'Document_MicroLotti_Dettagli'  ,@IdRow1  , @idr , ',Id,IdHeader,TipoDoc,StatoRiga,'			 

		--			end

		--			 FETCH NEXT FROM CurProg 
		--		   INTO @IdHeader,@IdRow1,@NumeroLotto

		--		 END 

		--CLOSE CurProg
		--DEALLOCATE CurProg
		*/
		
		
		
		
		declare @Filter as nvarchar(max)
		set @Filter = ' Tipodoc=''' + @TipoDocBando + ''' and numerolotto not in (select numerolotto from Document_MicroLotti_Dettagli with (nolock) where tipodoc=''' + @TipoDocBando + ''' and idheader=' + cast(@IdBando as varchar(50)) + ' and voce=0 and statoriga=''Revocato'' )'	
																																											
		exec INSERT_RECORD_NEW 'Document_MicroLotti_Dettagli', @IdBando, @idDoc, 'IdHeader', 'Id,IdHeader,TipoDoc,StatoRiga,Valore', @Filter, 'TipoDoc,StatoRiga', '''PDA_MICROLOTTI'' as TipoDoc,''daValutare'' as StatoRiga', 'id'																											  

		-- ricopio i dati dei lotti per le offerte 
		--insert into Document_MicroLotti_Dettagli ( IdHeader, TipoDoc, Graduatoria, Posizione, Aggiudicata, Exequo, StatoRiga, EsitoRiga, ValoreOfferta, NumeroLotto, Descrizione, Qty, PrezzoUnitario, CauzioneMicrolotto, CIG, CodiceATC, PrincipioAttivo, FormaFarmaceutica, Dosaggio, Somministrazione, UnitadiMisura, Quantita, ImportoBaseAstaUnitaria, ImportoAnnuoLotto, ImportoTriennaleLotto, NoteLotto, CodiceAIC, QuantitaConfezione, ClasseRimborsoMedicinale, PrezzoVenditaConfezione, AliquotaIva, ScontoUlteriore, EstremiGURI, PrezzoUnitarioOfferta, PrezzoUnitarioRiferimento, TotaleOffertaUnitario, ScorporoIVA, PrezzoVenditaConfezioneIvaEsclusa, PrezzoVenditaUnitario, ScontoOffertoUnitario, ScontoObbligatorioUnitario, DenominazioneProdotto, RagSocProduttore, CodiceProdotto, MarcaturaCE, NumeroRepertorio, NumeroCampioni, Versamento, PrezzoInLettere ,ImportoBaseAsta
		--											,CampoTesto_1,CampoTesto_2,CampoTesto_3,CampoTesto_4,CampoTesto_5,CampoTesto_6,CampoTesto_7,CampoTesto_8,CampoTesto_9,CampoTesto_10,
		--											CampoNumerico_1,CampoNumerico_2,CampoNumerico_3,CampoNumerico_4,CampoNumerico_5,CampoNumerico_6,CampoNumerico_7,CampoNumerico_8,CampoNumerico_9,CampoNumerico_10
		--											, Voce, idHeaderLotto, CampoAllegato_1, CampoAllegato_2, CampoAllegato_3, CampoAllegato_4, CampoAllegato_5, NumeroRiga, PunteggioTecnico
		--											)
		--select o.IdRow as IdHeader, 'PDA_OFFERTE' as TipoDoc, Graduatoria, Posizione, Aggiudicata, Exequo, 'daValutare' as StatoRiga, '' as EsitoRiga, ValoreOfferta, NumeroLotto, Descrizione, Qty, PrezzoUnitario, CauzioneMicrolotto, CIG, CodiceATC, PrincipioAttivo, FormaFarmaceutica, Dosaggio, Somministrazione, UnitadiMisura, Quantita, ImportoBaseAstaUnitaria, ImportoAnnuoLotto, ImportoTriennaleLotto, NoteLotto, CodiceAIC, QuantitaConfezione, ClasseRimborsoMedicinale, PrezzoVenditaConfezione, AliquotaIva, ScontoUlteriore, EstremiGURI, PrezzoUnitarioOfferta, PrezzoUnitarioRiferimento, TotaleOffertaUnitario, ScorporoIVA, PrezzoVenditaConfezioneIvaEsclusa, PrezzoVenditaUnitario, ScontoOffertoUnitario, ScontoObbligatorioUnitario, DenominazioneProdotto, RagSocProduttore, CodiceProdotto, MarcaturaCE, NumeroRepertorio, NumeroCampioni, Versamento, PrezzoInLettere ,ImportoBaseAsta
		--											,CampoTesto_1,CampoTesto_2,CampoTesto_3,CampoTesto_4,CampoTesto_5,CampoTesto_6,CampoTesto_7,CampoTesto_8,CampoTesto_9,CampoTesto_10,
		--											CampoNumerico_1,CampoNumerico_2,CampoNumerico_3,CampoNumerico_4,CampoNumerico_5,CampoNumerico_6,CampoNumerico_7,CampoNumerico_8,CampoNumerico_9,CampoNumerico_10
		--											, Voce, idHeaderLotto, CampoAllegato_1, CampoAllegato_2, CampoAllegato_3, CampoAllegato_4, CampoAllegato_5, NumeroRiga, PunteggioTecnico
		--	from Document_PDA_OFFERTE o
		--			inner join  Document_MicroLotti_Dettagli d on d.TipoDoc = case when isnull(o.TipoDoc , '') = '' then '55;186' else o.TipoDoc end  and d.IdHeader = o.IdMsgFornitore
		--			inner join CTL_DOC p on p.id = o.IdHeader 
		--	where o.idheader = @idDoc and StatoPDA = '2' 
		--	order by o.idrow , d.Id

		--nel caso del 	BANDO_CONCORSO	basta l'unica riga con voce 0	con tipodoc='PDA_OFFERTE' creata sopra perchè divisione_lotti=0																																					   
		if @TipoDocBando <> 'BANDO_CONCORSO'
		begin

			--creo le righe con TIPODOC=PDA_OFFERTE sulla Document_MicroLotti_Dettagli
			declare @TipoDocOfferta as varchar(200)								 
			declare @IdHeader2 INT
			declare @IdRow2 INT
			declare CurProg2 Cursor Static for 
	  
			select  o.IdRow as IdHeader2, o.IdMsgFornitore, case when isnull(o.TipoDoc , '') = '' then '55;186' else o.TipoDoc end AS TipoDocOfferta --d.id as IdRow2
					from Document_PDA_OFFERTE o  with (nolock)
						--inner join  Document_MicroLotti_Dettagli d on d.TipoDoc = case when isnull(o.TipoDoc , '') = '' then '55;186' else o.TipoDoc end  and d.IdHeader = o.IdMsgFornitore
						inner join CTL_DOC p  with (nolock) on p.id = o.IdHeader 
					where o.idheader = @idDoc and StatoPDA in (  '2' ,'22' , '222' , '9' )
					order by o.idrow-- , d.Id

			open CurProg2
  
		
			FETCH NEXT FROM CurProg2 INTO @IdHeader2,@IdRow2,@TipoDocOfferta
		
			WHILE @@FETCH_STATUS = 0
			BEGIN
				
				 --INSERT into Document_MicroLotti_Dettagli ( IdHeader,TipoDoc,StatoRiga,EsitoRiga )
				 --	select @IdHeader2 , 'PDA_OFFERTE' as TipoDoc,'daValutare' as StatoRiga,'' as EsitoRiga
				 --set @idr = @@identity				
				 ---- ricopio tutti i valori
				 --exec COPY_RECORD  'Document_MicroLotti_Dettagli'  ,@IdRow2  , @idr , ',Id,IdHeader,TipoDoc,StatoRiga,EsitoRiga,ValoreImportoLotto'			 
					
				 set @Filter = ' Tipodoc=''' + @TipoDocOfferta + ''' '
				 exec INSERT_RECORD_NEW 'Document_MicroLotti_Dettagli', @IdRow2, @IdHeader2, 'IdHeader', 'Id,IdHeader,TipoDoc,StatoRiga,EsitoRiga,ValoreImportoLotto', @Filter, 'TipoDoc,StatoRiga,EsitoRiga', '''PDA_OFFERTE'' as TipoDoc,''daValutare'' as StatoRiga,'''' as Esitoriga', 'id'
			 					
			 		 
				 FETCH NEXT FROM CurProg2 INTO @IdHeader2,@IdRow2,@TipoDocOfferta
					
			END 

			CLOSE CurProg2
			DEALLOCATE CurProg2


		end

		-- Per le gare monolotto avendo generato la voce 0 occorre rettificareidheader lotto
		if @Divisione_lotti = '0'
		begin
		

			-- OFFERTE
			update Document_MicroLotti_Dettagli
				set idHeaderLotto = idx
				from Document_MicroLotti_Dettagli  with (nolock)
					inner join ( select d.idheader as idhead, d.id as idx 
									from Document_MicroLotti_Dettagli d  with (nolock)
										inner join Document_PDA_OFFERTE o  with (nolock) on o.idrow = d.idheader and d.TipoDoc = 'PDA_OFFERTE' and Voce = 0
										where o.idheader = @IdDoc
								) as a on a.idhead = idheader and TipoDoc = 'PDA_OFFERTE' 

			-- OFFERTE aggiorno il lotto e la voce
			update Document_MicroLotti_Dettagli
				set NumeroLotto = '1' ,  Voce = NumeroRiga 
				from Document_MicroLotti_Dettagli d  with (nolock)
					inner join Document_PDA_OFFERTE o  with (nolock) on o.idrow = d.idheader 
					where o.idheader = @IdDoc and /*isnull( d.Voce , -1 ) <> 0 and */ d.TipoDoc = 'PDA_OFFERTE' 

			-- PDA aggiorno il lotto e la voce
			update Document_MicroLotti_Dettagli
				set NumeroLotto = '1' ,  Voce = NumeroRiga 
				from Document_MicroLotti_Dettagli d  with (nolock)
					where d.idheader = @IdDoc and /* isnull( d.Voce , -1 ) <> 0 and */ d.TipoDoc = 'PDA_MICROLOTTI' 
				
				
		end

	end






	--elimino le righe dei lotti per cui non ho ricevuto i campioni
	--faccio andare avanti anche i lotti per cui non ho ricevuto il campione
	--delete 
	--	Document_MicroLotti_Dettagli 
	--	where 
	--		tipodoc='PDA_OFFERTE' 
	--		and	cast(idheader as varchar) + '-' + numerolotto in 
	--				(select 
	--					cast(o.idrow as varchar) + '-' + numerolotto
	--					from document_pda_offerte O inner join ctl_doc C on C.linkeddoc=O.idmsg and C.iddoc=@IdDoc and C.tipodoc='RICEZIONE_CAMPIONI' and c.Statofunzionale = 'Confermato'
	--							inner join document_pda_ricezione_Campioni CD on Cd.idheader=C.id
	--					where O.idheader=@IdDoc
	--						  and CD.CampioneRicevuto='0')

	--elimino le righe dei lotti che ho escluso con il documento escludi_lotti
	delete 
		Document_MicroLotti_Dettagli 
		where 
			tipodoc='PDA_OFFERTE' 
			and	cast(idheader as varchar) + '-' + numerolotto in 
					(select 
						cast(o.idrow as varchar) + '-' + numerolotto
						from document_pda_offerte O  with (nolock) inner join ctl_doc C  with (nolock) on C.linkeddoc=O.idmsg and C.iddoc=@IdDoc and C.tipodoc='ESCLUDI_LOTTI' and c.Statofunzionale = 'Confermato'
								inner join Document_Pda_Escludi_Lotti CD  with (nolock) on Cd.idheader=C.id
						where O.idheader=@IdDoc
							  and CD.StatoLotto='escluso')

--		and numerolotto in 
--				(select 
--					numerolotto
--					from document_pda_offerte O inner join ctl_doc C on C.linkeddoc=O.idmsg and C.iddoc=@IdDoc and C.tipodoc='RICEZIONE_CAMPIONI'
--							inner join document_pda_ricezione_Campioni CD on Cd.idheader=C.id
--					where O.idheader=@IdDoc
--						  and CD.CampioneRicevuto='0')
					
	--------------------------------------------------------
	-- svuoto le colonne utilizzate per le graduatorie
	--------------------------------------------------------
	update Document_MicroLotti_Dettagli 
		set Graduatoria = 0 ,  Aggiudicata = 0 , Exequo = 0
		from Document_MicroLotti_Dettagli d  with (nolock)
			inner join Document_PDA_OFFERTE o  with (nolock) on d.TipoDoc = 'PDA_OFFERTE' and d.IdHeader = o.IdRow
		where o.IdHeader = @idDoc 

	update Document_MicroLotti_Dettagli 
		set  Posizione = '' 
		from Document_MicroLotti_Dettagli d  with (nolock)
			inner join Document_PDA_OFFERTE o  with (nolock) on d.TipoDoc = 'PDA_OFFERTE' and d.IdHeader = o.IdRow
		where o.IdHeader = @idDoc and Posizione <> 'Escluso'




	-- per ogni microlotto del bando
	declare crs cursor static for 
		select NumeroLotto from CTL_DOC d  with (nolock)
				inner join Document_MicroLotti_Dettagli m  with (nolock) on m.idheader = d.id and m.tipodoc = 'PDA_MICROLOTTI'
			where d.id = @idDoc and Voce = 0 
			order by cast( NumeroLotto as int )

	open crs 
	fetch next from crs into @NumeroLotto 
	while @@fetch_status=0 
	begin 

		set @Indice = 1
		set @ColonnaSort = 0
		set @Graduatoria = 1
		set @Exequo = 0

		-- si crea la struttura per la valutazione tecnica
		exec PDA_VALUTAZIONE_TEC_LOTTO @idDoc , @NumeroLotto 
		

									   

		fetch next from crs into @NumeroLotto
	end 
	close crs 
	deallocate crs



	-- aggiorno sulle righe dei microlotti del bando i messaggi che si sono aggiudicati i lotti
	declare @SQL varchar(4000)
	set @SQL = '
		select idMsg , m.id 
		from Document_MicroLotti_Dettagli m  with (nolock)
			inner join (
				select NumeroLotto as NumLot
						, id as idMsg
						from Document_MicroLotti_Dettagli  with (nolock)
						where IdHeader in ( select idrow from Document_PDA_OFFERTE  with (nolock)  where IdHeader = ' + cast ( @idDoc as varchar ) + ' ) 
							and Aggiudicata > 0
							and TipoDoc = ''PDA_OFFERTE''
				) as  a on  NumeroLotto = NumLot
		where IdHeader = ' + cast( @idDoc  as varchar ) + ' and TipoDoc = ''PDA_MICROLOTTI'' 
	'
	exec COPY_DETTAGLI_MICROLOTTI @sql , ',ValoreImportoLotto'


	-- aggiorno sulle righe dei microlotti del bando i messaggi che si sono aggiudicati i lotti
	update Document_MicroLotti_Dettagli  
		set Aggiudicata = idMsg , TotaleOffertaUnitario = tou  , ScontoOffertoUnitario = SOU , Exequo = ex
		from Document_MicroLotti_Dettagli m   with (nolock)
			inner join (
				select NumeroLotto as NumLot
						, Aggiudicata as idMsg
					    , TotaleOffertaUnitario as tou
						, ScontoOffertoUnitario as SOU
						, Exequo as ex

					from Document_MicroLotti_Dettagli  with (nolock)
						where IdHeader in ( select idrow from Document_PDA_OFFERTE   with (nolock) where IdHeader = @idDoc ) --select idOffertaPartenza from #TempOfferte )
							and Aggiudicata > 0
							and TipoDoc = 'PDA_OFFERTE'
				) as  a on  NumeroLotto = NumLot
			--inner join CTL_DOC d on LinkedDoc = m.idHeader
		where IdHeader = @idDoc  and TipoDoc = 'PDA_MICROLOTTI' --d.id = @idDoc
			


	---- se la gara non è economicamente vantaggiosa opp costo fisso aggiorno lo stato della riga daValutare a Valutato
	--if ( @Criterio <> '15532' and isnull( @Conformita , 'No' ) <> 'Ex-Ante' ) 
	if @Divisione_lotti <> '0'
	begin

		update Document_MicroLotti_Dettagli  
			set StatoRiga = 'Valutato'
			from Document_MicroLotti_Dettagli    with (nolock)
				inner join BANDO_GARA_CRITERI_VALUTAZIONE_PER_LOTTO on idBando =  @IdBando and N_Lotto = NumeroLotto and  CriterioAggiudicazioneGara <> '15532' and CriterioAggiudicazioneGara <> '25532'  and isnull( Conformita , 'No' ) <> 'Ex-Ante'
				where IdHeader = @idDoc  and TipoDoc = 'PDA_MICROLOTTI' and StatoRiga  = 'daValutare'
			
		update Document_MicroLotti_Dettagli  
			set StatoRiga = 'Valutato'
			where id in 
				( 
					select id 
						from Document_PDA_OFFERTE o  with (nolock)
							inner join Document_MicroLotti_Dettagli d  with (nolock) on o.IdRow = d.idheader  and d.TipoDoc = 'PDA_OFFERTE' and d.StatoRiga  = 'daValutare'
							inner join BANDO_GARA_CRITERI_VALUTAZIONE_PER_LOTTO on idBando =  @IdBando and N_Lotto = NumeroLotto and  CriterioAggiudicazioneGara <> '15532' and CriterioAggiudicazioneGara <> '25532' and isnull( Conformita , 'No' ) <> 'Ex-Ante'
						where o.IdHeader = @idDoc  
				)



	end

	-- nel caso del monolotto non essendoci il lotto lo script superiore non ha effetto
	if @Divisione_lotti = '0' and  @Criterio <> '15532' and @Criterio <> '25532' and isnull( @Conformita , 'No' ) <> 'Ex-Ante' 
	begin

		update Document_MicroLotti_Dettagli  
			set StatoRiga = 'Valutato'
			from Document_MicroLotti_Dettagli    with (nolock)
			where IdHeader = @idDoc  and TipoDoc = 'PDA_MICROLOTTI' and StatoRiga  = 'daValutare'
			
		update Document_MicroLotti_Dettagli  
			set StatoRiga = 'Valutato'
			where id in 
				( 
					select id 
						from Document_PDA_OFFERTE o  with (nolock)
							inner join Document_MicroLotti_Dettagli d  with (nolock) on o.IdRow = d.idheader  and d.TipoDoc = 'PDA_OFFERTE' and d.StatoRiga  = 'daValutare'
						where o.IdHeader = @idDoc  
				)



	end

end













GO
