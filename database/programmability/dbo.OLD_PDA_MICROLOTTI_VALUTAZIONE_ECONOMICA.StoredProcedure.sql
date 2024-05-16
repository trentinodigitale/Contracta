USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_PDA_MICROLOTTI_VALUTAZIONE_ECONOMICA]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE  proc [dbo].[OLD_PDA_MICROLOTTI_VALUTAZIONE_ECONOMICA] ( @IdDoc int , @idPFU int  ) 
AS
BEGIN

	SET NOCOUNT ON

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
	declare @ListaModelliMicrolotti varchar(250)
	declare @FormulaEconomica varchar(4000)
	declare @StrSql varchar(4000)
	declare @Divisione_lotti varchar(5)
	declare @idxVoceZero int
	declare @TipoSceltaContraente as varchar(100)

	declare @i int
	declare @Last int

	set @Divisione_lotti  = ''

	-- determino il criterio di aggiudicazione della gara
	IF exists( select id from ctl_doc where isnull( jumpcheck , '' ) <> '' and id = @IdDoc)
	BEGIN
		select @Criterio = criterioformulazioneofferte , @ListaModelliMicrolotti = TipoBando , @Divisione_lotti = Divisione_lotti 
			 from Document_Bando 
					inner join CTL_DOC on LinkedDoc = idheader
			where id = @IdDoc
	END
	ELSE
	BEGIN

		select @Criterio = criterioformulazioneofferte , @ListaModelliMicrolotti = ListaModelliMicrolotti
			 from TAB_MESSAGGI_FIELDS 
						inner join CTL_DOC on LinkedDoc = idMsg
			where id = @IdDoc
	END

	select @IdBando = LinkedDoc from ctl_doc with(nolock) where id = @IdDoc

	--recupero tiposceltacontraente
	select @TipoSceltaContraente=isnull(TipoSceltaContraente,'') from document_bando with(nolock) where idheader=@IdBando
	

	if exists( select id from ctl_doc with(nolock) where isnull(JumpCheck , '') = '' and id = @idDoc )
	begin

		-- determino gli idmsg dei messaggi in partenza
		select 
			 min( mf2.mfidmsg ) as idOffertaPartenza , p.idmsg  as idOffertaArrivo 
			into #TempOfferte
		from Document_PDA_OFFERTE_VIEW p
				inner join MessageFields mf1 on mf1.mfFieldName = 'IdDoc' and mf1.mfidmsg = p.idmsg
				inner join MessageFields mf2 on mf2.mfFieldName = 'IdDoc' and mf1.mfFieldValue = mf2.mfFieldValue
			where p.idheader = @IdDoc and p.StatoPDA in (  '2' ,'22' , '222' , '9' )
			group by p.idmsg
			order by idOffertaArrivo

		-- aggiorno sul documento l'id di partenza
		update Document_PDA_OFFERTE 
				set IdMsgFornitore = idOffertaPartenza
			from Document_PDA_OFFERTE with(nolock)
					inner join #TempOfferte on idOffertaArrivo = IdMsg
			where idheader = @IdDoc

	end
	else
	begin
		update Document_PDA_OFFERTE 
				set IdMsgFornitore = IdMsg
			from Document_PDA_OFFERTE with(nolock)
			where idheader = @IdDoc
	end

	if exists( select id from ctl_doc with(nolock) where StatoFunzionale = 'VERIFICA_AMMINISTRATIVA' and id = @idDoc )
	begin

        -- sgancio i precedenti record se presenti
        update Document_MicroLotti_Dettagli set idheader = - idheader where idheader = @idDoc and TipoDoc = 'PDA_MICROLOTTI'
        update Document_MicroLotti_Dettagli set idheader = - idheader 
                where  TipoDoc = 'PDA_OFFERTE' 
                        and idheader in ( select  o.IdRow
                                            from Document_PDA_OFFERTE o
                                            where o.idheader = @idDoc 
                                            )


		--------------------------------------------------------------------------------------------------
		-- per le procedure monolotto è necessario generare la riga con Voce 0 per creare virtualmente un lotto a cui legare tutte le righe
		-- ma solo se la gara non la prevedeva
		--------------------------------------------------------------------------------------------------
		set @idxVoceZero = -1
		if @Divisione_lotti = '0'
			 and not exists( select idrow from ctl_doc_value with(nolock) where idheader = @idBando and DSE_ID = 'TESTATA_PRODOTTI' and DZT_Name = 'RigaZero' and Value = '1' )
		begin

			-- PDA
			INSERT into Document_MicroLotti_Dettagli ( IdHeader,TipoDoc,StatoRiga ,NumeroRiga , NumeroLotto , Voce )
				select @idDoc , 'PDA_MICROLOTTI' as TipoDoc,'Saved' as StatoRiga , 0 , '1' , 0 
				
			set @idxVoceZero = @@identity
			update Document_MicroLotti_Dettagli
					set idHeaderLotto = @idxVoceZero
				where id = @idxVoceZero
		

			-- OFFERTE
			INSERT into Document_MicroLotti_Dettagli ( IdHeader,TipoDoc,StatoRiga ,NumeroRiga , NumeroLotto , Voce , EsitoRiga)
				select o.IdRow , 'PDA_OFFERTE' as TipoDoc,'Saved' as StatoRiga , 0 , '1' , 0 ,'' as EsitoRiga
						from Document_PDA_OFFERTE o with(nolock)
						where o.idheader = @idDoc and StatoPDA in (  '2' ,'22' ,'222' , '9' )
						order by o.idrow 
		end

		declare @IdHeader INT
		declare @IdRow1 INT
		declare @idr INT

		declare CurProg Cursor Static for 
			select  p.id as IdHeader, m.id as IdRow1
					from Document_MicroLotti_Dettagli m with(nolock)
							inner join ctl_doc p with(nolock) on  idheader = LinkedDoc and m.TipoDoc = case when isnull(JumpCheck , '')  = '' then '55;167' else JumpCheck end 
				where p.id  = @idDoc
				order by m.id

		open CurProg

		FETCH NEXT FROM CurProg INTO @IdHeader,@IdRow1

		WHILE @@FETCH_STATUS = 0
		BEGIN

			INSERT into Document_MicroLotti_Dettagli ( IdHeader,TipoDoc,StatoRiga,EsitoRiga )
				select @IdHeader , 'PDA_MICROLOTTI' as TipoDoc,'' as StatoRiga,'' as EsitoRiga

			set @idr = SCOPE_IDENTITY()

			-- ricopio tutti i valori
			exec COPY_RECORD  'Document_MicroLotti_Dettagli'  ,@IdRow1  , @idr , ',Id,IdHeader,TipoDoc,EsitoRiga '			 

			FETCH NEXT FROM CurProg INTO @IdHeader,@IdRow1

		END 

		CLOSE CurProg
		DEALLOCATE CurProg



		declare @IdHeader2 INT
		declare @IdRow2 INT
		declare CurProg2 Cursor Static for 
		select  o.IdRow as IdHeader2, d.id as IdRow2
				from Document_PDA_OFFERTE o with(nolock)
					inner join  Document_MicroLotti_Dettagli d with(nolock) on d.TipoDoc = case when isnull(o.TipoDoc , '') = '' then '55;186' else o.TipoDoc end  and d.IdHeader = o.IdMsgFornitore
					inner join CTL_DOC p with(nolock) on p.id = o.IdHeader 
			where o.idheader = @idDoc and StatoPDA in (  '2' ,'22' , '222' ,'9' )
			order by o.idrow , d.Id

		open CurProg2

		FETCH NEXT FROM CurProg2 INTO @IdHeader2,@IdRow2
		WHILE @@FETCH_STATUS = 0
		BEGIN

			INSERT into Document_MicroLotti_Dettagli ( IdHeader,TipoDoc,StatoRiga,EsitoRiga )
				select @IdHeader2 , 'PDA_OFFERTE' as TipoDoc,'' as StatoRiga,'' as EsitoRiga

			set @idr = SCOPE_IDENTITY()

			-- ricopio tutti i valori
			exec COPY_RECORD  'Document_MicroLotti_Dettagli'  ,@IdRow2  , @idr , ',Id,IdHeader,TipoDoc,EsitoRiga '			 

			FETCH NEXT FROM CurProg2 INTO @IdHeader2,@IdRow2
		END 

		CLOSE CurProg2
		DEALLOCATE CurProg2
		
		-- Per le gare monolotto avendo generato la voce 0 occorre rettificareidheader lotto
		if @Divisione_lotti = '0'
		begin
		

			-- OFFERTE
			update Document_MicroLotti_Dettagli
				set idHeaderLotto = idx
				from Document_MicroLotti_Dettagli
					inner join ( select d.idheader as idhead, d.id as idx 
									from Document_MicroLotti_Dettagli d
										inner join Document_PDA_OFFERTE o on o.idrow = d.idheader and d.TipoDoc = 'PDA_OFFERTE' 
										where o.idheader = @IdDoc and d.voce = 0
								) as a on a.idhead = idheader and TipoDoc = 'PDA_OFFERTE' 

			-- OFFERTE aggiorno il lotto e la voce
			update Document_MicroLotti_Dettagli
				set NumeroLotto = '1' ,  Voce = NumeroRiga 
				from Document_MicroLotti_Dettagli d
					inner join Document_PDA_OFFERTE o on o.idrow = d.idheader 
				where o.idheader = @IdDoc and /*isnull( d.Voce , -1 ) <> 0 and */ d.TipoDoc = 'PDA_OFFERTE' 

			-- PDA aggiorno il lotto e la voce
			update Document_MicroLotti_Dettagli
				set NumeroLotto = '1' ,  Voce = NumeroRiga 
				from Document_MicroLotti_Dettagli d
				where d.idheader = @IdDoc and /*isnull( d.Voce , -1 ) <> 0 and */ d.TipoDoc = 'PDA_MICROLOTTI' 
				
				
		end
		


		--elimino le righe dei lotti per cui non ho ricevuto i campioni
		delete Document_MicroLotti_Dettagli 
		where tipodoc='PDA_OFFERTE' 
			and	cast(idheader as varchar) + '-' + numerolotto in 
					(select 
						cast(o.idrow as varchar) + '-' + numerolotto
						from document_pda_offerte O with(nolock)
							inner join ctl_doc C with(nolock) on C.linkeddoc=O.idmsg and C.iddoc=@IdDoc and C.tipodoc='RICEZIONE_CAMPIONI'
							inner join document_pda_ricezione_Campioni CD with(nolock) on Cd.idheader=C.id
						where O.idheader=@IdDoc
								and CD.CampioneRicevuto='0')

		--elimino le righe dei lotti che ho escluso con il documento escludi_lotti
		delete Document_MicroLotti_Dettagli 
			where tipodoc='PDA_OFFERTE' 
				and	cast(idheader as varchar) + '-' + numerolotto in 
					(select 
						cast(o.idrow as varchar) + '-' + numerolotto
						from document_pda_offerte O 
							inner join ctl_doc C on C.linkeddoc=O.idmsg and C.iddoc=@IdDoc and C.tipodoc='ESCLUDI_LOTTI' and c.Statofunzionale = 'Confermato'
							inner join Document_Pda_Escludi_Lotti CD on Cd.idheader=C.id
						where O.idheader=@IdDoc
								and CD.StatoLotto='escluso')

	end

	-- se lo stato funzionale è verifica exequo recupero le offerte migliorative e le sostituisco alle precedenti offerte
	if exists( select id from ctl_doc with(nolock) where StatoFunzionale = 'VALUTAZIONE_EXEQUO' and id = @idDoc )
	begin
		update d 
			set 
				--NumeroLotto, 
				--Descrizione, 
				ValoreOfferta									= rd.ValoreOfferta,
				Qty												= rd.Qty, 
				PrezzoUnitario									= rd.PrezzoUnitario, 
				CauzioneMicrolotto								= rd.CauzioneMicrolotto, 
				CIG												= rd.CIG, 
				CodiceATC										= rd.CodiceATC, 
				PrincipioAttivo									= rd.PrincipioAttivo, 
				FormaFarmaceutica								= rd.FormaFarmaceutica, 
				Dosaggio										= rd.Dosaggio, 
				Somministrazione								= rd.Somministrazione, 
				UnitadiMisura									= rd.UnitadiMisura, 
				Quantita										= rd.Quantita, 
				ImportoBaseAstaUnitaria							= rd.ImportoBaseAstaUnitaria, 
				ImportoAnnuoLotto								= rd.ImportoAnnuoLotto, 
				ImportoTriennaleLotto							= rd.ImportoTriennaleLotto, 
				NoteLotto										= rd.NoteLotto, 
				CodiceAIC										= rd.CodiceAIC, 
				QuantitaConfezione								= rd.QuantitaConfezione, 
				ClasseRimborsoMedicinale						= rd.ClasseRimborsoMedicinale, 
				PrezzoVenditaConfezione							= rd.PrezzoVenditaConfezione, 
				AliquotaIva										= rd.AliquotaIva, 
				ScontoUlteriore									= rd.ScontoUlteriore, 
				EstremiGURI										= rd.EstremiGURI, 
				PrezzoUnitarioOfferta							= rd.PrezzoUnitarioOfferta, 
				PrezzoUnitarioRiferimento						= rd.PrezzoUnitarioRiferimento, 
				TotaleOffertaUnitario							= rd.TotaleOffertaUnitario, 
				ScorporoIVA										= rd.ScorporoIVA, 
				PrezzoVenditaConfezioneIvaEsclusa				= rd.PrezzoVenditaConfezioneIvaEsclusa, 
				PrezzoVenditaUnitario							= rd.PrezzoVenditaUnitario, 
				ScontoOffertoUnitario							= rd.ScontoOffertoUnitario, 
				ScontoObbligatorioUnitario						= rd.ScontoObbligatorioUnitario, 
				DenominazioneProdotto							= rd.DenominazioneProdotto, 
				RagSocProduttore								= rd.RagSocProduttore, 
				CodiceProdotto									= rd.CodiceProdotto, 
				MarcaturaCE										= rd.MarcaturaCE, 
				NumeroRepertorio								= rd.NumeroRepertorio, 
				NumeroCampioni									= rd.NumeroCampioni, 
				Versamento										= rd.Versamento, 
				PrezzoInLettere									= rd.PrezzoInLettere,
				ImportoBaseAsta									= rd.ImportoBaseAsta,

				CampoTesto_1									= rd.CampoTesto_1,
				CampoTesto_2									= rd.CampoTesto_2,
				CampoTesto_3									= rd.CampoTesto_3,
				CampoTesto_4									= rd.CampoTesto_4,
				CampoTesto_5									= rd.CampoTesto_5,
				CampoTesto_6									= rd.CampoTesto_6,
				CampoTesto_7									= rd.CampoTesto_7,
				CampoTesto_8									= rd.CampoTesto_8,
				CampoTesto_9									= rd.CampoTesto_9,
				CampoTesto_10									= rd.CampoTesto_10,

				CampoNumerico_1									= rd.CampoNumerico_1,
				CampoNumerico_2									= rd.CampoNumerico_2,
				CampoNumerico_3									= rd.CampoNumerico_3,
				CampoNumerico_4									= rd.CampoNumerico_4,
				CampoNumerico_5									= rd.CampoNumerico_5,
				CampoNumerico_6									= rd.CampoNumerico_6,
				CampoNumerico_7									= rd.CampoNumerico_7,
				CampoNumerico_8									= rd.CampoNumerico_8,
				CampoNumerico_9									= rd.CampoNumerico_9,
				CampoNumerico_10								= rd.CampoNumerico_10,

				Voce 											= rd.Voce,
				--idHeaderLotto									= rd.idHeaderLotto,
				CampoAllegato_1 								= rd.CampoAllegato_1,
				CampoAllegato_2 								= rd.CampoAllegato_2,
				CampoAllegato_3 								= rd.CampoAllegato_3,
				CampoAllegato_4 								= rd.CampoAllegato_4,
				CampoAllegato_5 								= rd.CampoAllegato_5,
				NumeroRiga 										= rd.NumeroRiga,
				PunteggioTecnico 								= rd.PunteggioTecnico,
				ValoreEconomico 								= rd.ValoreEconomico , 

				-- tutt le colonne aggiunte nel tempo alla tabella
				PesoVoce = rd.PesoVoce,
				ValoreImportoLotto = rd.ValoreImportoLotto,
				Variante = rd.Variante,
				CONTRATTO = rd.CONTRATTO,
				CODICE_AZIENDA_SANITARIA = rd.CODICE_AZIENDA_SANITARIA,
				CODICE_REGIONALE = rd.CODICE_REGIONALE,
				DESCRIZIONE_CODICE_REGIONALE = rd.DESCRIZIONE_CODICE_REGIONALE,
				TARGET = rd.TARGET,
				MATERIALE = rd.MATERIALE,
				LATEX_FREE = rd.LATEX_FREE,
				MISURE = rd.MISURE,
				VOLUME = rd.VOLUME,
				ALTRE_CARATTERISTICHE = rd.ALTRE_CARATTERISTICHE,
				CONFEZIONAMENTO_PRIMARIO = rd.CONFEZIONAMENTO_PRIMARIO,
				PESO_CONFEZIONE = rd.PESO_CONFEZIONE,
				DIMENSIONI_CONFEZIONE = rd.DIMENSIONI_CONFEZIONE,
				TEMPERATURA_CONSERVAZIONE = rd.TEMPERATURA_CONSERVAZIONE,
				QUANTITA_PRODOTTO_SINGOLO_PEZZO = rd.QUANTITA_PRODOTTO_SINGOLO_PEZZO,
				UM_QUANTITA_PRODOTTO_SINGOLO_PEZZO = rd.UM_QUANTITA_PRODOTTO_SINGOLO_PEZZO,
				UM_DOSAGGIO = rd.UM_DOSAGGIO,
				PARTITA_IVA_FORNITORE = rd.PARTITA_IVA_FORNITORE,
				RAGIONE_SOCIALE_FORNITORE = rd.RAGIONE_SOCIALE_FORNITORE,
				CODICE_ARTICOLO_FORNITORE = rd.CODICE_ARTICOLO_FORNITORE,
				DENOMINAZIONE_ARTICOLO_FORNITORE = rd.DENOMINAZIONE_ARTICOLO_FORNITORE,
				DATA_INIZIO_PERIODO_VALIDITA = rd.DATA_INIZIO_PERIODO_VALIDITA,
				DATA_FINE_PERIODO_VALIDITA = rd.DATA_FINE_PERIODO_VALIDITA,
				RIFERIMENTO_TEMPORALE_FABBISOGNO = rd.RIFERIMENTO_TEMPORALE_FABBISOGNO,
				FABBISOGNO_PREVISTO = rd.FABBISOGNO_PREVISTO,
				PREZZO_OFFERTO_PER_UM = rd.PREZZO_OFFERTO_PER_UM,
				CONTENUTO_DI_UM_CONFEZIONE = rd.CONTENUTO_DI_UM_CONFEZIONE,
				PREZZO_CONFEZIONE_IVA_ESCLUSA = rd.PREZZO_CONFEZIONE_IVA_ESCLUSA,
				PREZZO_PEZZO = rd.PREZZO_PEZZO,
				SCHEDA_PRODOTTO = rd.SCHEDA_PRODOTTO,
				CODICE_CND = rd.CODICE_CND,
				DESCRIZIONE_CND = rd.DESCRIZIONE_CND,
				CODICE_CPV = rd.CODICE_CPV,
				DESCRIZIONE_CODICE_CPV = rd.DESCRIZIONE_CODICE_CPV,
				LIVELLO = rd.LIVELLO,
				CERTIFICAZIONI = rd.CERTIFICAZIONI,
				CARATTERISTICHE_SOCIALI_AMBIENTALI = rd.CARATTERISTICHE_SOCIALI_AMBIENTALI,
				PREZZO_BASE_ASTA_UM_IVA_ESCLUSA = rd.PREZZO_BASE_ASTA_UM_IVA_ESCLUSA,
				VALORE_BASE_ASTA_IVA_ESCLUSA = rd.VALORE_BASE_ASTA_IVA_ESCLUSA,
				RAGIONE_SOCIALE_ATTUALE_FORNITORE = rd.RAGIONE_SOCIALE_ATTUALE_FORNITORE,
				PREZZO_UM_IVA_ESCLUSA_ATTUALE_FORNITORE = rd.PREZZO_UM_IVA_ESCLUSA_ATTUALE_FORNITORE,
				DATA_ULTIMO_CONTRATTO = rd.DATA_ULTIMO_CONTRATTO,
				UM_UNITA_POSOLOGICA_CONTENUTA_INTERNO_DEL_BANCALE = rd.UM_UNITA_POSOLOGICA_CONTENUTA_INTERNO_DEL_BANCALE,
				VALORE_COMPLESSIVO_OFFERTA = rd.VALORE_COMPLESSIVO_OFFERTA,
				NOTE_ENTI_STRUTTURE_AMMINISTRAZIONI = rd.NOTE_ENTI_STRUTTURE_AMMINISTRAZIONI,
				NOTE_OPERATORE_ECONOMICO = rd.NOTE_OPERATORE_ECONOMICO,
				ONERI_SICUREZZA = rd.ONERI_SICUREZZA,
				PARTITA_IVA_DEPOSITARIO = rd.PARTITA_IVA_DEPOSITARIO,
				RAGIONE_SOCIALE_DEPOSITARIO = rd.RAGIONE_SOCIALE_DEPOSITARIO,
				IDENTIFICATIVO_OGGETTO_INIZIATIVA = rd.IDENTIFICATIVO_OGGETTO_INIZIATIVA,
				AREA_MERCEOLOGICA = rd.AREA_MERCEOLOGICA,
				PERC_SCONTO_FISSATA_PER_LEGGE = rd.PERC_SCONTO_FISSATA_PER_LEGGE,
				ULTERIORE_PERC_DI_SCONTO_FISSATA_DA_AIFA1 = rd.ULTERIORE_PERC_DI_SCONTO_FISSATA_DA_AIFA1,
				ULTERIORE_PERC_DI_SCONTO_FISSATA_DA_AIFA2 = rd.ULTERIORE_PERC_DI_SCONTO_FISSATA_DA_AIFA2,
				ADESIONE_PAYBACK = rd.ADESIONE_PAYBACK,
				DescrizioneAIC = rd.DescrizioneAIC

			from Document_MicroLotti_Dettagli d
				inner join Document_PDA_OFFERTE o on d.TipoDoc = 'PDA_OFFERTE' and d.IdHeader = o.IdRow
				
				-- comunicazione 
				inner join CTL_DOC c on c.LinkedDoc = o.idheader 
									and c.StatoDoc = 'Sended' 
									and c.deleted = 0
									and c.TipoDoc = 'PDA_COMUNICAZIONE'
									and c.JumpCheck = '1-OFFERTA'

				-- Richiesta offerta migliorativa 
				inner join CTL_DOC m on m.LinkedDoc = c.id
									and m.StatoDoc = 'Sended' 
									and m.deleted = 0
									and m.TipoDoc = 'PDA_COMUNICAZIONE_OFFERTA'

				-- offerte ricevute
				inner join CTL_DOC r on r.LinkedDoc = m.id
									and r.StatoDoc = 'Sended' 
									and r.deleted = 0
									and r.TipoDoc = 'PDA_COMUNICAZIONE_OFFERTA_RISP'
									and r.JumpCheck = '0-PDA_COMUNICAZIONE_OFFERTA_RISP'
									and r.Azienda = o.idAziPartecipante

				-- offerta migliorativa
				inner join Document_MicroLotti_Dettagli rd on rd.tipodoc = 'PDA_COMUNICAZIONE_OFFERTA_RISP'
									and rd.IdHeader = r.id
									and rd.NumeroLotto = d.NumeroLotto
									and rd.Voce = d.voce

			where o.IdHeader = @idDoc
		
		-- segno le offerte migliorative per evitare di aggiornarle nuovamente nel caso di giri multipli
		update r 
				set JumpCheck = '0-PDA_COMUNICAZIONE_OFFERTA_RISP-VALUTATA'
			from CTL_DOC d 		with(nolock)	
				-- comunicazione 
				inner join CTL_DOC c with(nolock) on c.LinkedDoc = d.id
									and c.StatoDoc = 'Sended' 
									and c.deleted = 0
									and c.TipoDoc = 'PDA_COMUNICAZIONE'
									and c.JumpCheck = '1-OFFERTA'

				-- Richiesta offerta migliorativa 
				inner join CTL_DOC m with(nolock) on m.LinkedDoc = c.id
									and m.StatoDoc = 'Sended' 
									and m.deleted = 0
									and m.TipoDoc = 'PDA_COMUNICAZIONE_OFFERTA'

				-- offerte ricevute
				inner join CTL_DOC r with(nolock) on r.LinkedDoc = m.id
									and r.StatoDoc = 'Sended' 
									and r.deleted = 0
									and r.TipoDoc = 'PDA_COMUNICAZIONE_OFFERTA_RISP'
									and r.JumpCheck = '0-PDA_COMUNICAZIONE_OFFERTA_RISP'
			where d.id = @idDoc
	end

	--------------------------------------------------------
	-- inserisco il record che identifica la busta come aperta
	--------------------------------------------------------
	insert into MessageStatus ( IdMsg, IdSource, SectionName, Status ) 
		select o.IdMsgFornitore, @IdBando as IdSource, 'MicroLotti'  as SectionName, 1 as Status
			from Document_PDA_OFFERTE o with(nolock)
				left outer join MessageStatus eco with(nolock) on o.idMsg = eco.idmsg and eco.SectionName = 'MicroLotti' 
			where  idheader = @IdDoc and  eco.idmsg is null and o.IdMsgFornitore is not null and isnull( TipoDoc , '' ) = ''


	insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
		select   o.idMsg , 'BUSTA_ECONOMICA' , 0 , 'LettaBusta' , '1' 
			from Document_PDA_OFFERTE o with(nolock)
				left outer join CTL_DOC_Value eco with(nolock) on o.idMsg = eco.idheader  and eco.DSE_ID = 'BUSTA_ECONOMICA'  and eco.DZT_Name = 'LettaBusta'  and eco.Value = '1'
			where  o.idheader = @IdDoc and  eco.idheader is null and o.IdMsgFornitore is not null and isnull( TipoDoc , '' ) <> ''

	--------------------------------------------------------
	-- svuoto le colonne utilizzate per le graduatorie
	--------------------------------------------------------
	update Document_MicroLotti_Dettagli 
		set Graduatoria = 0 ,  Aggiudicata = 0 , Exequo = 0
		from Document_MicroLotti_Dettagli d with(nolock)
			inner join Document_PDA_OFFERTE o with(nolock) on d.TipoDoc = 'PDA_OFFERTE' and d.IdHeader = o.IdRow
		where o.IdHeader = @idDoc 

	update Document_MicroLotti_Dettagli 
		set  Posizione = '' 
		from Document_MicroLotti_Dettagli d with(nolock)
			inner join Document_PDA_OFFERTE o with(nolock) on d.TipoDoc = 'PDA_OFFERTE' and d.IdHeader = o.IdRow
		where o.IdHeader = @idDoc and Posizione <> 'Escluso'


	--------------------------------------------------------
	-- aggiorno il campo ValoreOfferta con la formula indicata
	--------------------------------------------------------
	select @FormulaEconomica = FormulaEconomica 
		from Document_Modelli_MicroLotti_Formula with(nolock)
		where @Criterio = CriterioFormulazioneOfferte
			and @ListaModelliMicrolotti = Codice

	update Document_MicroLotti_Dettagli 
		set Graduatoria = 0 ,  Aggiudicata = 0 , Exequo = 0
		from Document_MicroLotti_Dettagli d with(nolock)
			inner join Document_PDA_OFFERTE o with(nolock) on d.TipoDoc = 'PDA_OFFERTE' and d.IdHeader = o.IdRow
		where o.IdHeader = @idDoc 


	-- recupera l'informazione se la gara è economicamente vantaggiosa
	declare @CriterioAggiudicazioneGara varchar(50)
	declare @idLotto					int
	select  @CriterioAggiudicazioneGara = CriterioAggiudicazioneGara from dbo.Document_PDA_TESTATA where idheader = @idDoc
	

	-- per ogni microlotto del bando
	declare crsVO cursor static for 
		select NumeroLotto , m.id
			from CTL_DOC d with(nolock)
				inner join Document_MicroLotti_Dettagli m with(nolock) on m.idheader = d.id and m.tipodoc = 'PDA_MICROLOTTI'
		where d.id = @idDoc and Voce = 0
		order by cast( NumeroLotto as int )

	open crsVO 
	fetch next from crsVO into @NumeroLotto ,@idLotto
	while @@fetch_status=0 
	begin 



		if @CriterioAggiudicazioneGara = 15532 or @CriterioAggiudicazioneGara = 25532
		begin

			-- economicamente più vantaggiosa o costo fisso
			exec PDA_MICROLOTTI_VALUTAZIONE_ECONOMICA_LOTTO_ECO_VANTAGGIOSA  @idLotto  , @IdPFU  

		end
		else
		begin

			exec PDA_MICROLOTTI_VALUTAZIONE_ECONOMICA_LOTTO @idLotto
		end

		-- si determina la graduatoria e si evince il primo e secondo classificato
		--exec PDA_GRADUATORIA_LOTTO @idDoc , @NumeroLotto 


		fetch next from crsVO into @NumeroLotto , @idLotto
	end 
	close crsVO 
	deallocate crsVO


	--E.P: condividere con Sabato
	if @TipoSceltaContraente <> 'ACCORDOQUADRO'
	begin

		-- aggiorno sulle righe dei microlotti del bando i messaggi che si sono aggiudicati i lotti
		declare @SQL varchar(4000)
		set @SQL = '
			select idMsg , m.id 
			from Document_MicroLotti_Dettagli m 
				inner join (
					select NumeroLotto as NumLot
							, id as idMsg
							from Document_MicroLotti_Dettagli
							where IdHeader in ( select idrow from Document_PDA_OFFERTE  where IdHeader = ' + cast ( @idDoc as varchar ) + ' ) 
								and Aggiudicata > 0
								and TipoDoc = ''PDA_OFFERTE'' and Voce = 0
					) as  a on  NumeroLotto = NumLot
			where IdHeader = ' + cast( @idDoc  as varchar ) + ' and TipoDoc = ''PDA_MICROLOTTI'' and Voce = 0
		'
		exec COPY_DETTAGLI_MICROLOTTI @sql


		-- aggiorno sulle righe dei microlotti del bando i messaggi che si sono aggiudicati i lotti
		update Document_MicroLotti_Dettagli  
			set Aggiudicata = idMsg , TotaleOffertaUnitario = tou  , ScontoOffertoUnitario = SOU , Exequo = ex
			from Document_MicroLotti_Dettagli m  with(nolock)
				inner join (
					select NumeroLotto as NumLot
							, Aggiudicata as idMsg
							, TotaleOffertaUnitario as tou
							, ScontoOffertoUnitario as SOU
							, Exequo as ex

						from Document_MicroLotti_Dettagli with(nolock)
							where IdHeader in ( select idrow from Document_PDA_OFFERTE with(nolock) where IdHeader = @idDoc ) --select idOffertaPartenza from #TempOfferte )
								and Aggiudicata > 0
								and TipoDoc = 'PDA_OFFERTE'
					) as  a on  NumeroLotto = NumLot
				--inner join CTL_DOC d on LinkedDoc = m.idHeader
			where IdHeader = @idDoc  and TipoDoc = 'PDA_MICROLOTTI' --d.id = @idDoc
			
	END

	IF EXISTS ( select id from lib_dictionary where dzt_name = 'SYS_ATTIVA_PROTOCOLLO_GENERALE' and dzt_valuedef = 'YES' )
	BEGIN

		declare @idPfuMitt INT --l'idpfu mittente dell'offerta. utile per chiamare la stored ProtGenInsert
		declare @idDaProtocollare INT

		DECLARE crsProt CURSOR STATIC FOR 
				select dof.id as idDaProtocollare, d.IdMittente 
					from Document_MicroLotti_Dettagli P WITH(NOLOCK) 
							INNER JOIN Document_PDA_OFFERTE d WITH(NOLOCK) on d.idheader = p.idheader and d.Tipodoc = 'OFFERTA'

							-- recupero l'offerta del fornitore
							INNER JOIN Document_MicroLotti_Dettagli O WITH(NOLOCK) on O.idheader = d.idRow and O.TipoDoc = 'PDA_OFFERTE' 
													and O.NumeroLotto = P.NumeroLotto and o.Voce = 0 --and O.statoRiga not in ( '' , 'Saved','InValutazione','daValutare','escluso','esclusoEco','inVerifica' ) 

							-- prendo il dettaglio offerto dal fornitore
							LEFT JOIN Document_MicroLotti_Dettagli dof with(nolock) on dof.idheader = d.IdMsgFornitore and 
													dof.TipoDoc ='OFFERTA' and dof.Voce = 0 and dof.NumeroLotto = p.NumeroLotto

							-- recupera l'evidenza di lettura economica del documento
							LEFT JOIN CTL_DOC_VALUE BD with(nolock) on BD.idHeader = d.IdMsg and BD.DSE_ID = 'OFFERTA_BUSTA_ECO' and BD.DZT_Name = 'LettaBusta' and dof.id = BD.row
							LEFT JOIN CTL_DOC_VALUE v1 with(nolock) on v1.idHeader = D.IdMsg and v1.DSE_ID = 'BUSTA_ECONOMICA' and v1.DZT_Name = 'LettaBusta'

					where P.ID = @IdDoc and ( BD.IdRow is not null or v1.idrow is not null  ) -- prendiamo solo quelle la cui busta economica è stata 'aperta'/decifrata

		OPEN crsProt
		FETCH NEXT FROM CrsProt into @idDaProtocollare,@idPfuMitt
		WHILE @@fetch_status=0
		BEGIN

			-- SIA PER LE MULTILOTTO CHE PER LE MONOLOTTO PASSIAMO COME ID LA RIGA DELLA Document_MicroLotti_Dettagli TIPODOC 'OFFERTA'
			EXEC ProtGenInsert @idDaProtocollare,@idPfuMitt, 'OFFERTA_BE'
				
			FETCH NEXT FROM crsProt INTO @idDaProtocollare,@idPfuMitt

		END
		CLOSE crsProt
		DEALLOCATE crsProt

	END

END


GO
