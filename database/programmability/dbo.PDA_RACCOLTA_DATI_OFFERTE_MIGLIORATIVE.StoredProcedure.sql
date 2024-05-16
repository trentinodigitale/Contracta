USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[PDA_RACCOLTA_DATI_OFFERTE_MIGLIORATIVE]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE proc [dbo].[PDA_RACCOLTA_DATI_OFFERTE_MIGLIORATIVE] ( @iddoc int , @idPfu int ,@tipodoc varchar(200))
as
BEGIN
--declare @tipodoc varchar(200)
declare @id_PDA_COMUNICAZIONE int
declare @id_PDA int
declare @id_off_migliorativa as int
declare @numero_lotto as int
declare @query as nvarchar(MAX)
declare @ColToExclud as nvarchar(MAX)
declare @Allegato nvarchar(4000)
set @Allegato=''
--Recupero il tipodoc del documento ---se vengo dal riepilogo del lotto non trova il doc nella CTL_DOC e rimane PDA_RIEPILOGO_LOTTO
--set @tipodoc='PDA_RIEPILOGO_LOTTO'
--select @tipodoc=tipodoc from ctl_doc where id=@iddoc

    --se sono su un bando MONOLOTTO
    if @tipodoc = 'PDA_MICROLOTTI'
    BEGIN
	   select @id_PDA_COMUNICAZIONE=id,@id_PDA=@iddoc from ctl_doc where linkeddoc=@iddoc and tipodoc='PDA_COMUNICAZIONE' and StatoFunzionale in ( 'Inviato' , 'Inviata Risposta')  and JumpCheck='1-OFFERTA'
	   set @numero_lotto=1
    END
    --se sono su una gara multilotto
    if @tipodoc = 'PDA_RIEPILOGO_LOTTO'
    BEGIN
	   select @id_PDA_COMUNICAZIONE=id,@id_PDA=LinkedDoc from ctl_doc where versionelinkeddoc=cast( @iddoc as varchar(500) ) and tipodoc='PDA_COMUNICAZIONE' and StatoFunzionale in ( 'Inviato' , 'Inviata Risposta') and JumpCheck='1-OFFERTA'
	   select top 1 @numero_lotto=numerolotto from Document_MicroLotti_Dettagli where Id=@iddoc
    END
	--lo fa nella stored dietro l'apertura delle buste
	/*
	-- per ogni Offerta Migliorativa per cui è stata inviata la risposta sblocco i dati e li riporto 
	declare crsVO cursor static for 
		select d3.id as id_off_migliorativa
			from CTL_DOC d
				inner join ctl_doc d2 on d2.LinkedDoc=d.id and d2.tipodoc='PDA_COMUNICAZIONE_OFFERTA' and d2.StatoFunzionale='Inviata Risposta'
				inner join ctl_doc d3 on d3.LinkedDoc=d2.id and d3.tipodoc='PDA_COMUNICAZIONE_OFFERTA_RISP' and d3.StatoFunzionale='Inviato'
			where d.id = @id_PDA_COMUNICAZIONE 
		

	open crsVO 
	fetch next from crsVO into @id_off_migliorativa
	while @@fetch_status=0 
	begin 
		 ---per ogni offerta migliorativa DECIFRA l'allegato inserito dal fornitore
		 select @Allegato = SIGN_ATTACH from CTL_DOC where id = @id_off_migliorativa
		 exec AFS_DECRYPT_ATTACH  @idPfu ,    @Allegato , @id_off_migliorativa
		 
		 
		 --per ogni offerta migliorativa inviata sblocco i dati
		 exec  START_PDA_COMUNICAZIONE_OFFERTA_RISP_CHECK_PRODUCT @id_off_migliorativa ,  @idPfu  

		 --update d 
			--set 
			--	--NumeroLotto, 
			--	--Descrizione, 
			--	ValoreOfferta									= rd.ValoreOfferta,
			--	Qty												= rd.Qty, 
			--	PrezzoUnitario									= rd.PrezzoUnitario, 
			--	CauzioneMicrolotto								= rd.CauzioneMicrolotto, 
			--	CIG												= rd.CIG, 
			--	CodiceATC										= rd.CodiceATC, 
			--	PrincipioAttivo									= rd.PrincipioAttivo, 
			--	FormaFarmaceutica								= rd.FormaFarmaceutica, 
			--	Dosaggio										= rd.Dosaggio, 
			--	Somministrazione								= rd.Somministrazione, 
			--	UnitadiMisura									= rd.UnitadiMisura, 
			--	Quantita										= rd.Quantita, 
			--	ImportoBaseAstaUnitaria							= rd.ImportoBaseAstaUnitaria, 
			--	ImportoAnnuoLotto								= rd.ImportoAnnuoLotto, 
			--	ImportoTriennaleLotto							= rd.ImportoTriennaleLotto, 
			--	NoteLotto										= rd.NoteLotto, 
			--	CodiceAIC										= rd.CodiceAIC, 
			--	QuantitaConfezione								= rd.QuantitaConfezione, 
			--	ClasseRimborsoMedicinale						= rd.ClasseRimborsoMedicinale, 
			--	PrezzoVenditaConfezione							= rd.PrezzoVenditaConfezione, 
			--	AliquotaIva										= rd.AliquotaIva, 
			--	ScontoUlteriore									= rd.ScontoUlteriore, 
			--	EstremiGURI										= rd.EstremiGURI, 
			--	PrezzoUnitarioOfferta							= rd.PrezzoUnitarioOfferta, 
			--	PrezzoUnitarioRiferimento						= rd.PrezzoUnitarioRiferimento, 
			--	TotaleOffertaUnitario							= rd.TotaleOffertaUnitario, 
			--	ScorporoIVA										= rd.ScorporoIVA, 
			--	PrezzoVenditaConfezioneIvaEsclusa				= rd.PrezzoVenditaConfezioneIvaEsclusa, 
			--	PrezzoVenditaUnitario							= rd.PrezzoVenditaUnitario, 
			--	ScontoOffertoUnitario							= rd.ScontoOffertoUnitario, 
			--	ScontoObbligatorioUnitario						= rd.ScontoObbligatorioUnitario, 
			--	DenominazioneProdotto							= rd.DenominazioneProdotto, 
			--	RagSocProduttore								= rd.RagSocProduttore, 
			--	CodiceProdotto									= rd.CodiceProdotto, 
			--	MarcaturaCE										= rd.MarcaturaCE, 
			--	NumeroRepertorio								= rd.NumeroRepertorio, 
			--	NumeroCampioni									= rd.NumeroCampioni, 
			--	Versamento										= rd.Versamento, 
			--	PrezzoInLettere									= rd.PrezzoInLettere,
			--	ImportoBaseAsta									= rd.ImportoBaseAsta,

			--	CampoTesto_1									= rd.CampoTesto_1,
			--	CampoTesto_2									= rd.CampoTesto_2,
			--	CampoTesto_3									= rd.CampoTesto_3,
			--	CampoTesto_4									= rd.CampoTesto_4,
			--	CampoTesto_5									= rd.CampoTesto_5,
			--	CampoTesto_6									= rd.CampoTesto_6,
			--	CampoTesto_7									= rd.CampoTesto_7,
			--	CampoTesto_8									= rd.CampoTesto_8,
			--	CampoTesto_9									= rd.CampoTesto_9,
			--	CampoTesto_10									= rd.CampoTesto_10,

			--	CampoNumerico_1									= rd.CampoNumerico_1,
			--	CampoNumerico_2									= rd.CampoNumerico_2,
			--	CampoNumerico_3									= rd.CampoNumerico_3,
			--	CampoNumerico_4									= rd.CampoNumerico_4,
			--	CampoNumerico_5									= rd.CampoNumerico_5,
			--	CampoNumerico_6									= rd.CampoNumerico_6,
			--	CampoNumerico_7									= rd.CampoNumerico_7,
			--	CampoNumerico_8									= rd.CampoNumerico_8,
			--	CampoNumerico_9									= rd.CampoNumerico_9,
			--	CampoNumerico_10								= rd.CampoNumerico_10,

			--	Voce 											= rd.Voce,
			--	--idHeaderLotto									= rd.idHeaderLotto,
			--	CampoAllegato_1 								= rd.CampoAllegato_1,
			--	CampoAllegato_2 								= rd.CampoAllegato_2,
			--	CampoAllegato_3 								= rd.CampoAllegato_3,
			--	CampoAllegato_4 								= rd.CampoAllegato_4,
			--	CampoAllegato_5 								= rd.CampoAllegato_5,
			--	NumeroRiga 										= rd.NumeroRiga,
			--	PunteggioTecnico 								= rd.PunteggioTecnico,
			--	ValoreEconomico 								= rd.ValoreEconomico , 

			--	-- tutt le colonne aggiunte nel tempo alla tabella
			--	PesoVoce = rd.PesoVoce,
			--	ValoreImportoLotto = rd.ValoreImportoLotto,
			--	Variante = rd.Variante,
			--	CONTRATTO = rd.CONTRATTO,
			--	CODICE_AZIENDA_SANITARIA = rd.CODICE_AZIENDA_SANITARIA,
			--	CODICE_REGIONALE = rd.CODICE_REGIONALE,
			--	DESCRIZIONE_CODICE_REGIONALE = rd.DESCRIZIONE_CODICE_REGIONALE,
			--	TARGET = rd.TARGET,
			--	MATERIALE = rd.MATERIALE,
			--	LATEX_FREE = rd.LATEX_FREE,
			--	MISURE = rd.MISURE,
			--	VOLUME = rd.VOLUME,
			--	ALTRE_CARATTERISTICHE = rd.ALTRE_CARATTERISTICHE,
			--	CONFEZIONAMENTO_PRIMARIO = rd.CONFEZIONAMENTO_PRIMARIO,
			--	PESO_CONFEZIONE = rd.PESO_CONFEZIONE,
			--	DIMENSIONI_CONFEZIONE = rd.DIMENSIONI_CONFEZIONE,
			--	TEMPERATURA_CONSERVAZIONE = rd.TEMPERATURA_CONSERVAZIONE,
			--	QUANTITA_PRODOTTO_SINGOLO_PEZZO = rd.QUANTITA_PRODOTTO_SINGOLO_PEZZO,
			--	UM_QUANTITA_PRODOTTO_SINGOLO_PEZZO = rd.UM_QUANTITA_PRODOTTO_SINGOLO_PEZZO,
			--	UM_DOSAGGIO = rd.UM_DOSAGGIO,
			--	PARTITA_IVA_FORNITORE = rd.PARTITA_IVA_FORNITORE,
			--	RAGIONE_SOCIALE_FORNITORE = rd.RAGIONE_SOCIALE_FORNITORE,
			--	CODICE_ARTICOLO_FORNITORE = rd.CODICE_ARTICOLO_FORNITORE,
			--	DENOMINAZIONE_ARTICOLO_FORNITORE = rd.DENOMINAZIONE_ARTICOLO_FORNITORE,
			--	DATA_INIZIO_PERIODO_VALIDITA = rd.DATA_INIZIO_PERIODO_VALIDITA,
			--	DATA_FINE_PERIODO_VALIDITA = rd.DATA_FINE_PERIODO_VALIDITA,
			--	RIFERIMENTO_TEMPORALE_FABBISOGNO = rd.RIFERIMENTO_TEMPORALE_FABBISOGNO,
			--	FABBISOGNO_PREVISTO = rd.FABBISOGNO_PREVISTO,
			--	PREZZO_OFFERTO_PER_UM = rd.PREZZO_OFFERTO_PER_UM,
			--	CONTENUTO_DI_UM_CONFEZIONE = rd.CONTENUTO_DI_UM_CONFEZIONE,
			--	PREZZO_CONFEZIONE_IVA_ESCLUSA = rd.PREZZO_CONFEZIONE_IVA_ESCLUSA,
			--	PREZZO_PEZZO = rd.PREZZO_PEZZO,
			--	SCHEDA_PRODOTTO = rd.SCHEDA_PRODOTTO,
			--	CODICE_CND = rd.CODICE_CND,
			--	DESCRIZIONE_CND = rd.DESCRIZIONE_CND,
			--	CODICE_CPV = rd.CODICE_CPV,
			--	DESCRIZIONE_CODICE_CPV = rd.DESCRIZIONE_CODICE_CPV,
			--	LIVELLO = rd.LIVELLO,
			--	CERTIFICAZIONI = rd.CERTIFICAZIONI,
			--	CARATTERISTICHE_SOCIALI_AMBIENTALI = rd.CARATTERISTICHE_SOCIALI_AMBIENTALI,
			--	PREZZO_BASE_ASTA_UM_IVA_ESCLUSA = rd.PREZZO_BASE_ASTA_UM_IVA_ESCLUSA,
			--	VALORE_BASE_ASTA_IVA_ESCLUSA = rd.VALORE_BASE_ASTA_IVA_ESCLUSA,
			--	RAGIONE_SOCIALE_ATTUALE_FORNITORE = rd.RAGIONE_SOCIALE_ATTUALE_FORNITORE,
			--	PREZZO_UM_IVA_ESCLUSA_ATTUALE_FORNITORE = rd.PREZZO_UM_IVA_ESCLUSA_ATTUALE_FORNITORE,
			--	DATA_ULTIMO_CONTRATTO = rd.DATA_ULTIMO_CONTRATTO,
			--	UM_UNITA_POSOLOGICA_CONTENUTA_INTERNO_DEL_BANCALE = rd.UM_UNITA_POSOLOGICA_CONTENUTA_INTERNO_DEL_BANCALE,
			--	VALORE_COMPLESSIVO_OFFERTA = rd.VALORE_COMPLESSIVO_OFFERTA,
			--	NOTE_ENTI_STRUTTURE_AMMINISTRAZIONI = rd.NOTE_ENTI_STRUTTURE_AMMINISTRAZIONI,
			--	NOTE_OPERATORE_ECONOMICO = rd.NOTE_OPERATORE_ECONOMICO,
			--	ONERI_SICUREZZA = rd.ONERI_SICUREZZA,
			--	PARTITA_IVA_DEPOSITARIO = rd.PARTITA_IVA_DEPOSITARIO,
			--	RAGIONE_SOCIALE_DEPOSITARIO = rd.RAGIONE_SOCIALE_DEPOSITARIO,
			--	IDENTIFICATIVO_OGGETTO_INIZIATIVA = rd.IDENTIFICATIVO_OGGETTO_INIZIATIVA,
			--	AREA_MERCEOLOGICA = rd.AREA_MERCEOLOGICA,
			--	PERC_SCONTO_FISSATA_PER_LEGGE = rd.PERC_SCONTO_FISSATA_PER_LEGGE,
			--	ULTERIORE_PERC_DI_SCONTO_FISSATA_DA_AIFA1 = rd.ULTERIORE_PERC_DI_SCONTO_FISSATA_DA_AIFA1,
			--	ULTERIORE_PERC_DI_SCONTO_FISSATA_DA_AIFA2 = rd.ULTERIORE_PERC_DI_SCONTO_FISSATA_DA_AIFA2,
			--	ADESIONE_PAYBACK = rd.ADESIONE_PAYBACK,
			--	DescrizioneAIC = rd.DescrizioneAIC



			set @Query = 'select rd.id , d.id 
			from Document_MicroLotti_Dettagli d
				inner join Document_PDA_OFFERTE o on d.TipoDoc = ''PDA_OFFERTE'' and d.IdHeader = o.IdRow
				
				-- comunicazione 
				inner join CTL_DOC c on c.LinkedDoc = o.idheader 
									and c.StatoFunzionale in ( ''Inviato'' ,''Inviata Risposta'' )
									and c.deleted = 0
									and c.TipoDoc = ''PDA_COMUNICAZIONE''
									and c.JumpCheck = ''1-OFFERTA''

				-- Richiesta offerta migliorativa 
				inner join CTL_DOC m on m.LinkedDoc = c.id
									and m.StatoDoc = ''Sended'' 
									and m.deleted = 0
									and m.TipoDoc = ''PDA_COMUNICAZIONE_OFFERTA''

				-- offerte ricevute
				inner join CTL_DOC r on r.LinkedDoc = m.id
									and r.StatoDoc = ''Sended'' 
									and r.deleted = 0
									and r.TipoDoc = ''PDA_COMUNICAZIONE_OFFERTA_RISP''
									and r.JumpCheck = ''0-PDA_COMUNICAZIONE_OFFERTA_RISP''
									and r.Destinatario_Azi = o.idAziPartecipante

				-- offerta migliorativa
				inner join Document_MicroLotti_Dettagli rd on rd.tipodoc = ''PDA_COMUNICAZIONE_OFFERTA_RISP''
									and rd.IdHeader = r.id
									and rd.NumeroLotto = d.NumeroLotto
									and rd.Voce = d.voce

			where o.IdHeader = ' + cast(@id_PDA as varchar(200)) + ' and d.NumeroLotto= ' + cast(@numero_lotto as varchar(200))
			set @ColToExclud=' ''Id'',''IdHeader''	,''TipoDoc'',''Graduatoria'',''Sorteggio'',''Posizione'',''Aggiudicata'',''Exequo''	,''StatoRiga'',''EsitoRiga'',''ValoreOfferta'',''NumeroLotto'',''CIG'',''ValoreAccessorioTecnico'',''TipoAcquisto'',''Subordinato'',''ArticoliPrimari'',''SelRow'',''Erosione'',''Variante'',''PesoVoce'',''NumeroRiga'',''ValoreEconomico'',''PunteggioTecnico'',''ValoreImportoLotto'',''idHeaderLotto'',''Voce'',''ValoreSconto'',''ValoreRibasso'',''PunteggioTecnicoAssegnato'',''PunteggioTecnicoRiparCriterio'',''PunteggioTecnicoRiparTotale'' '
			exec COPY_DETTAGLI_MICROLOTTI  @query ,@ColToExclud 

		fetch next from crsVO into @id_off_migliorativa
	end 
	close crsVO 
	deallocate crsVO


	*/


 --Mette la comunicazione PADRE di Offerta Migliorativa a Completato
 update ctl_doc set StatoFunzionale='Completato' where id=@id_PDA_COMUNICAZIONE

 
    


END










GO
