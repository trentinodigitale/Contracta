USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[BANDO_REVOCA_LOTTO_CREATE_FROM_BANDO]    Script Date: 5/16/2024 2:38:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--exec BANDO_REVOCA_LOTTO_CREATE_FROM_BANDO 411506, 42727

CREATE  PROCEDURE [dbo].[BANDO_REVOCA_LOTTO_CREATE_FROM_BANDO] 
	( @idDoc int , @IdUser int  )
AS
BEGIN
	SET NOCOUNT ON;

	declare @Id as INT
	declare @Role varchar(50)
	declare @Errore as nvarchar(2000)
	declare @IdPfu as INT
	declare @StrIdSource as nvarchar(max)
	declare @strTipoDoc as varchar(1000)

	set @Id=0
	set @Errore = ''

	select @strTipoDoc=tipodoc from ctl_doc  with (nolock) where id = @idDoc

	-- controllo se esiste una modifica in corso
	select @Id=id from CTL_DOC where linkedDoc = @idDoc and Tipodoc='BANDO_REVOCA_LOTTO' and StatoFunzionale = 'InLavorazione' and deleted=0

	if ( @id IS NULL or @id=0 )
	begin 
		
		Insert into CTL_DOC (idpfu,Titolo,idPfuInCharge,tipodoc,Body,LinkedDoc,ProtocolloRiferimento,VersioneLinkedDoc,Note,Fascicolo)
			Select  
				@IdUser as idpfu ,'Revoca Lotto', value ,'BANDO_REVOCA_LOTTO',Body,@idDoc  as LinkedDoc,Protocollo,tipodoc,'',fascicolo	
				from 
					CTL_DOC with (nolock)
						inner join ctl_doc_value with (nolock) on id=idheader and dse_id='InfoTec_comune' and dzt_name='UserRUP' 
				where id=@idDoc and deleted=0

	    set @id = SCOPE_IDENTITY()

		--inserisco la cronologia
		set @Role = null
		
		select top 1 @Role = attvalue 
			from profiliutenteattrib with (nolock)
			where idpfu = @IdUser and dztnome = 'UserRoleDefault'

		insert into CTL_ApprovalSteps ( APS_Doc_Type , APS_ID_DOC    , APS_State     , APS_Note    , APS_IdPfu , APS_UserProfile , APS_IsOld , APS_Date ) 
		values( 'BANDO_REVOCA_LOTTO' , @id  , 'Compiled' , '', @IdUser     , @Role       , 1         , getdate() )
		
		----travaso sul documento le righe del bando con voce=0 (i lotti) e non ancora revocate
		--insert into  Document_MicroLotti_Dettagli
		-- (IdHeader, TipoDoc, Graduatoria, Sorteggio, Posizione, Aggiudicata, Exequo, StatoRiga, EsitoRiga, ValoreOfferta, NumeroLotto, Descrizione, Qty, PrezzoUnitario, CauzioneMicrolotto, CIG, CodiceATC, PrincipioAttivo, FormaFarmaceutica, Dosaggio, Somministrazione, UnitadiMisura, Quantita, ImportoBaseAstaUnitaria, ImportoAnnuoLotto, ImportoTriennaleLotto, NoteLotto, CodiceAIC, QuantitaConfezione, ClasseRimborsoMedicinale, PrezzoVenditaConfezione, AliquotaIva, ScontoUlteriore, EstremiGURI, PrezzoUnitarioOfferta, PrezzoUnitarioRiferimento, TotaleOffertaUnitario, ScorporoIVA, PrezzoVenditaConfezioneIvaEsclusa, PrezzoVenditaUnitario, ScontoOffertoUnitario, ScontoObbligatorioUnitario, DenominazioneProdotto, RagSocProduttore, CodiceProdotto, MarcaturaCE, NumeroRepertorio, NumeroCampioni, Versamento, PrezzoInLettere, importoBaseAsta, CampoTesto_1, CampoTesto_2, CampoTesto_3, CampoTesto_4, CampoTesto_5, CampoTesto_6, CampoTesto_7, CampoTesto_8, CampoTesto_9, CampoTesto_10, CampoNumerico_1, CampoNumerico_2, CampoNumerico_3, CampoNumerico_4, CampoNumerico_5, CampoNumerico_6, CampoNumerico_7, CampoNumerico_8, CampoNumerico_9, CampoNumerico_10, Voce, idHeaderLotto, CampoAllegato_1, CampoAllegato_2, CampoAllegato_3, CampoAllegato_4, CampoAllegato_5, NumeroRiga, PunteggioTecnico, ValoreEconomico, PesoVoce, ValoreImportoLotto, Variante, CONTRATTO, CODICE_AZIENDA_SANITARIA, CODICE_REGIONALE, DESCRIZIONE_CODICE_REGIONALE, TARGET, MATERIALE, LATEX_FREE, MISURE, VOLUME, ALTRE_CARATTERISTICHE, CONFEZIONAMENTO_PRIMARIO, PESO_CONFEZIONE, DIMENSIONI_CONFEZIONE, TEMPERATURA_CONSERVAZIONE, QUANTITA_PRODOTTO_SINGOLO_PEZZO, UM_QUANTITA_PRODOTTO_SINGOLO_PEZZO, UM_DOSAGGIO, PARTITA_IVA_FORNITORE, RAGIONE_SOCIALE_FORNITORE, CODICE_ARTICOLO_FORNITORE, DENOMINAZIONE_ARTICOLO_FORNITORE, DATA_INIZIO_PERIODO_VALIDITA, DATA_FINE_PERIODO_VALIDITA, RIFERIMENTO_TEMPORALE_FABBISOGNO, FABBISOGNO_PREVISTO, PREZZO_OFFERTO_PER_UM, CONTENUTO_DI_UM_CONFEZIONE, PREZZO_CONFEZIONE_IVA_ESCLUSA, PREZZO_PEZZO, SCHEDA_PRODOTTO, CODICE_CND, DESCRIZIONE_CND, CODICE_CPV, DESCRIZIONE_CODICE_CPV, LIVELLO, CERTIFICAZIONI, CARATTERISTICHE_SOCIALI_AMBIENTALI, PREZZO_BASE_ASTA_UM_IVA_ESCLUSA, VALORE_BASE_ASTA_IVA_ESCLUSA, RAGIONE_SOCIALE_ATTUALE_FORNITORE, PREZZO_UM_IVA_ESCLUSA_ATTUALE_FORNITORE, DATA_ULTIMO_CONTRATTO, UM_UNITA_POSOLOGICA_CONTENUTA_INTERNO_DEL_BANCALE, VALORE_COMPLESSIVO_OFFERTA, NOTE_ENTI_STRUTTURE_AMMINISTRAZIONI, NOTE_OPERATORE_ECONOMICO, ONERI_SICUREZZA, PARTITA_IVA_DEPOSITARIO, RAGIONE_SOCIALE_DEPOSITARIO, IDENTIFICATIVO_OGGETTO_INIZIATIVA, AREA_MERCEOLOGICA, PERC_SCONTO_FISSATA_PER_LEGGE, ULTERIORE_PERC_DI_SCONTO_FISSATA_DA_AIFA1, ULTERIORE_PERC_DI_SCONTO_FISSATA_DA_AIFA2, ADESIONE_PAYBACK, DescrizioneAIC, ValoreAccessorioTecnico, TipoAcquisto, Subordinato, ArticoliPrimari)
		--	select 
		--		@id, 'BANDO_REVOCA_LOTTO', Graduatoria, Sorteggio, Posizione, Aggiudicata, Exequo, StatoRiga, EsitoRiga, ValoreOfferta, NumeroLotto, Descrizione, Qty, PrezzoUnitario, CauzioneMicrolotto, CIG, CodiceATC, PrincipioAttivo, FormaFarmaceutica, Dosaggio, Somministrazione, UnitadiMisura, Quantita, ImportoBaseAstaUnitaria, ImportoAnnuoLotto, ImportoTriennaleLotto, NoteLotto, CodiceAIC, QuantitaConfezione, ClasseRimborsoMedicinale, PrezzoVenditaConfezione, AliquotaIva, ScontoUlteriore, EstremiGURI, PrezzoUnitarioOfferta, PrezzoUnitarioRiferimento, TotaleOffertaUnitario, ScorporoIVA, PrezzoVenditaConfezioneIvaEsclusa, PrezzoVenditaUnitario, ScontoOffertoUnitario, ScontoObbligatorioUnitario, DenominazioneProdotto, RagSocProduttore, CodiceProdotto, MarcaturaCE, NumeroRepertorio, NumeroCampioni, Versamento, PrezzoInLettere, importoBaseAsta, CampoTesto_1, CampoTesto_2, CampoTesto_3, CampoTesto_4, CampoTesto_5, CampoTesto_6, CampoTesto_7, CampoTesto_8, CampoTesto_9, CampoTesto_10, CampoNumerico_1, CampoNumerico_2, CampoNumerico_3, CampoNumerico_4, CampoNumerico_5, CampoNumerico_6, CampoNumerico_7, CampoNumerico_8, CampoNumerico_9, CampoNumerico_10, Voce, idHeaderLotto, CampoAllegato_1, CampoAllegato_2, CampoAllegato_3, CampoAllegato_4, CampoAllegato_5, NumeroRiga, PunteggioTecnico, ValoreEconomico, PesoVoce, ValoreImportoLotto, Variante, CONTRATTO, CODICE_AZIENDA_SANITARIA, CODICE_REGIONALE, DESCRIZIONE_CODICE_REGIONALE, TARGET, MATERIALE, LATEX_FREE, MISURE, VOLUME, ALTRE_CARATTERISTICHE, CONFEZIONAMENTO_PRIMARIO, PESO_CONFEZIONE, DIMENSIONI_CONFEZIONE, TEMPERATURA_CONSERVAZIONE, QUANTITA_PRODOTTO_SINGOLO_PEZZO, UM_QUANTITA_PRODOTTO_SINGOLO_PEZZO, UM_DOSAGGIO, PARTITA_IVA_FORNITORE, RAGIONE_SOCIALE_FORNITORE, CODICE_ARTICOLO_FORNITORE, DENOMINAZIONE_ARTICOLO_FORNITORE, DATA_INIZIO_PERIODO_VALIDITA, DATA_FINE_PERIODO_VALIDITA, RIFERIMENTO_TEMPORALE_FABBISOGNO, FABBISOGNO_PREVISTO, PREZZO_OFFERTO_PER_UM, CONTENUTO_DI_UM_CONFEZIONE, PREZZO_CONFEZIONE_IVA_ESCLUSA, PREZZO_PEZZO, SCHEDA_PRODOTTO, CODICE_CND, DESCRIZIONE_CND, CODICE_CPV, DESCRIZIONE_CODICE_CPV, LIVELLO, CERTIFICAZIONI, CARATTERISTICHE_SOCIALI_AMBIENTALI, PREZZO_BASE_ASTA_UM_IVA_ESCLUSA, VALORE_BASE_ASTA_IVA_ESCLUSA, RAGIONE_SOCIALE_ATTUALE_FORNITORE, PREZZO_UM_IVA_ESCLUSA_ATTUALE_FORNITORE, DATA_ULTIMO_CONTRATTO, UM_UNITA_POSOLOGICA_CONTENUTA_INTERNO_DEL_BANCALE, VALORE_COMPLESSIVO_OFFERTA, NOTE_ENTI_STRUTTURE_AMMINISTRAZIONI, NOTE_OPERATORE_ECONOMICO, ONERI_SICUREZZA, PARTITA_IVA_DEPOSITARIO, RAGIONE_SOCIALE_DEPOSITARIO, IDENTIFICATIVO_OGGETTO_INIZIATIVA, AREA_MERCEOLOGICA, PERC_SCONTO_FISSATA_PER_LEGGE, ULTERIORE_PERC_DI_SCONTO_FISSATA_DA_AIFA1, ULTERIORE_PERC_DI_SCONTO_FISSATA_DA_AIFA2, ADESIONE_PAYBACK, DescrizioneAIC, ValoreAccessorioTecnico, TipoAcquisto, Subordinato, ArticoliPrimari
		--	from 
		--		Document_MicroLotti_Dettagli where idheader=@idDoc and voce=0 and StatoRiga<>'Revocato'



		--declare @idRow INT
		--declare @NewIdRow INT

		--declare CurProg Cursor Static for 
				
		--		select id as idrow from Document_MicroLotti_Dettagli where idheader=@idDoc and voce=0 and StatoRiga<>'Revocato' order by cast(NumeroLotto as int) asc

		--open CurProg

		--FETCH NEXT FROM CurProg INTO @idrow

		--WHILE @@FETCH_STATUS = 0
		--BEGIN
			
		--	INSERT into Document_MicroLotti_Dettagli ( IdHeader,TipoDoc )
		--			select @id , 'BANDO_REVOCA_LOTTO' as TipoDoc

		--	set @NewIdRow=scope_identity()
				
		--	-- ricopio tutti i valori
		--	exec COPY_RECORD  'Document_MicroLotti_Dettagli'  ,@idrow  , @NewIdRow, ',Id,IdHeader,TipoDoc'


		--	FETCH NEXT FROM CurProg INTO @idrow

		--END 

		--CLOSE CurProg
		--DEALLOCATE CurProg	

		
		--recupero gli id da ribaltare sul nuovo documento di revoca
		set @StrIdSource=''
		select @StrIdSource =   @StrIdSource + cast(id  as varchar(50)) + ','
			from Document_MicroLotti_Dettagli with (nolock)
			where idheader=@idDoc and tipodoc=@strTipoDoc and voce=0 and StatoRiga<>'Revocato' order by cast(NumeroLotto as int) asc
		
		if @StrIdSource <> ''
			set @StrIdSource = left(@StrIdSource,len(@StrIdSource)-1)

		declare @Filter as nvarchar(max)
		declare @DestListField as varchar(500)

		set @Filter = ' id in (' + @StrIdSource + ') '
		set @DestListField = ' ''BANDO_REVOCA_LOTTO'' as TipoDoc '
		  
		if @StrIdSource <> ''
		begin
			exec INSERT_RECORD_NEW 'Document_MicroLotti_Dettagli',@idDoc , @id, 'IdHeader', 
											' Id,IdHeader,TipoDoc ', 
											@Filter, 
											' TipoDoc ', 
											@DestListField,
											' id '
		end
	

	end

   
	if @Errore = ''
	begin
		
		select @Id as id
	
	end
	else
	begin
		-- rirorna l'errore
		select 'Errore' as id , @Errore as Errore
	end
END
















GO
