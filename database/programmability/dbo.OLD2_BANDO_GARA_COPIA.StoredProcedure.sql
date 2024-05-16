USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_BANDO_GARA_COPIA]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE PROCEDURE [dbo].[OLD2_BANDO_GARA_COPIA] ( @idDoc int , @IdUser int ,@IdNewDoc int = 0 output, @RIFIUTA_PROSEGUI int = 0 )
AS
BEGIN
    
	SET NOCOUNT ON

	--@RIFIUTA_PROSEGUI quando uguale 0 significa che provengo da una copia altrimenti vengo da un rifiuta prosegui sull'approvazione
	--DECLARE @IdNewDoc as int
	DECLARE @Id as int
	DECLARE @IdNewRicerca as int
	DECLARE @IdOldRicerca as int
	DECLARE @IdNewMod as int
	DECLARE @IdNewModMicrolotto as int
	DECLARE @IdOLDModMicrolotto as int
	DECLARE @tipoDoc varchar(500)
	declare @NuovoRilancio int
	declare @LinkedDoc int
	declare @IdNuovoRilancio int
	declare @Idazi as int
	declare @TipoProceduraCaratteristica as varchar(100)
	declare @ProceduraGara as varchar(100)
	declare @TipoBandoGara as varchar(100)
	declare @prefissoTitolo nvarchar(4000)
	declare @Lista_Enti_abilitati_RCig as varchar (4000)
	

	set @id = -1
	set @idNewRicerca = -1
	set @idOldRicerca = -1
	set @IdNewMod = -1
	set @IdNewModMicrolotto = -1
	set @IdOLDModMicrolotto = -1

	set @NuovoRilancio = 0

	select @tipoDoc = a.TipoDoc , @LinkedDoc = LinkedDoc
		from ctl_doc a with(nolock) 
		where id = @idDoc
	
	select @TipoProceduraCaratteristica = ISNULL(TipoProceduraCaratteristica,''),@ProceduraGara=ISNULL(ProceduraGara,'') ,
			@TipoBandoGara=ISNULL(TipoBandoGara,'')
	from document_bando with(nolock) where idHeader = @idDoc

    -- recupero idazi utente collegato
	select @Idazi = pfuidazi from ProfiliUtente where IdPfu= @IdUser

	-- Se sto eseguendo un comando di copia modifico il titolo
	-- altrimenti se provengo da un comando come 'rifiuta e prosegui' lascio inalterato il titolo originale
	IF @RIFIUTA_PROSEGUI = 0
		SET @prefissoTitolo = 'Copia di '
	ELSE
		SET @prefissoTitolo = ''


	-- Verifico se la copia serve a generare un Rilancio Competitivo
	if @tipoDoc = 'NUOVO_RILANCIO_COMPETITIVO'
	begin
		set @IdNuovoRilancio = @idDoc
		set @NuovoRilancio = 1
		set @idDoc = @LinkedDoc
		set @tipoDoc = 'BANDO_GARA'
		set @RIFIUTA_PROSEGUI = 0
		set @prefissoTitolo = 'Rilancio Competitivo - '
	end



	--copio sezione DOCUMENT
	insert into CTL_DOC	(IdPfu, IdDoc, TipoDoc, StatoDoc, Data, Protocollo, PrevDoc, Deleted, Titolo, Body, Azienda, StrutturaAziendale, DataInvio, DataScadenza, ProtocolloRiferimento, ProtocolloGenerale, Fascicolo, Note, DataProtocolloGenerale, LinkedDoc, SIGN_HASH, SIGN_ATTACH, SIGN_LOCK, JumpCheck, StatoFunzionale, Destinatario_User, Destinatario_Azi, RichiestaFirma, NumeroDocumento, DataDocumento, Versione, VersioneLinkedDoc, idPfuInCharge, CanaleNotifica, URL_CLIENT, Caption)
		select @IdUser, IdDoc, TipoDoc, 'Saved', getdate(), '', 0, 0, dbo.Normalizza_COL_TABLE('CTL_DOC','titolo', @prefissoTitolo + Titolo ) , 
				Body, @Idazi, StrutturaAziendale, null, null, ProtocolloRiferimento, null, '', Note, null, LinkedDoc, '', '', 0, JumpCheck, 
				case when @TipoProceduraCaratteristica = 'AffidamentoSemplificato' then 'InLavorazioneCreaModello' else 'InLavorazione' end , 
				Destinatario_User, Destinatario_Azi, RichiestaFirma, NumeroDocumento, DataDocumento, '2', VersioneLinkedDoc, idPfuInCharge, 
				CanaleNotifica, URL_CLIENT, Caption
			from ctl_doc with(nolock) 
			where id=@idDoc

	set @IdNewDoc = scope_identity()	

	--copio sezione TESTATA
	IF @RIFIUTA_PROSEGUI = 0
	BEGIN

		INSERT INTO DOCUMENT_BANDO ( idHeader, SoggettiAmmessi, ImportoBando, MaxNumeroIniziative, MaxFinanziabile, dataCreazione, DataEstenzioneInizio, DataEstenzioneFine, FAX, DataRiferimentoInizio, DataRiferimentoFine, DataPresentazioneRisposte, StatoBando, Ufficio, NumeroBUR, DataBUR, dgrN, dgrDel, TipoBando, TipoAppalto, RichiestaQuesito, ReceivedQuesiti, RecivedIstanze, MotivoEstensionePeriodo, ClasseIscriz, RichiediProdotti, ProceduraGara, TipoBandoGara, CriterioAggiudicazioneGara, ImportoBaseAsta, Iva, ImportoBaseAsta2, Oneri, CriterioFormulazioneOfferte, OffAnomale, NumeroIndizione, DataIndizione, gg_QuesitiScadenza, DataTermineQuesiti, ClausolaFideiussoria, VisualizzaNotifiche, CUP, CIG, GG_OffIndicativa, HH_OffIndicativa, MM_OffIndicativa, DataScadenzaOffIndicativa, GG_Offerta, HH_Offerta, MM_Offerta, DataScadenzaOfferta, GG_PrimaSeduta, HH_PrimaSeduta, MM_PrimaSeduta, DataAperturaOfferte, TipoAppaltoGara, ProtocolloBando, DataRevoca, Conformita, Divisione_lotti, NumDec, DirezioneEspletante, DataProtocolloBando, ModalitadiPartecipazione, TipoIVA, EvidenzaPubblica ,Complex,RichiestaCampionatura,TipoGiudizioTecnico,TipoProceduraCaratteristica,GeneraConvenzione,TipoSceltaContraente,TipoAccordoQuadro,TipoAggiudicazione,RegoleAggiudicatari,ListaAlbi,TipologiaDiAcquisto,Appalto_Verde,Acquisto_Sociale,Motivazione_Appalto_Verde,Motivazione_Acquisto_Sociale,Riferimento_Gazzetta,Data_Pubblicazione_Gazzetta,BaseAstaUnitaria,IdentificativoIniziativa, DataTermineRispostaQuesiti, Merceologia,CPV, ModalitaAnomalia_ECO, ModalitaAnomalia_TEC, Opzioni,Richiesta_terna_subappalto,Concessione,TipoSedutaGara,RichiestaCigSimog,EnteProponente,RupProponente,Visualizzazione_Offerta_Tecnica,Accordo_di_Servizio,AppaltoInEmergenza,MotivazioneDiEmergenza,
					Appalto_PNRR_PNC, Appalto_PNRR, Appalto_PNC, Motivazione_Appalto_PNRR, Motivazione_Appalto_PNC, ID_MOTIVO_DEROGA, FLAG_MISURE_PREMIALI,
					ID_MISURA_PREMIALE, FLAG_PREVISIONE_QUOTA, QUOTA_FEMMINILE, QUOTA_GIOVANILE,GenderEquality,GenderEqualityMotivazione,DataPrevistaAvvioSecondaFase,FaseConcorso,Importo_Altri_Concorrenti,Importo_Progettazione_Succ,Importo_Opera,TipoSoglia, CATEGORIE_MERC, pcp_UlterioriSommeNoRibasso, pcp_SommeRipetizioni, RegimeAllegerito,pcp_CodiceCentroDiCostoProponente,SocietaInHouse)
			select @IdNewDoc, SoggettiAmmessi, ImportoBando, MaxNumeroIniziative, MaxFinanziabile, getdate(), DataEstenzioneInizio, DataEstenzioneFine, FAX, NULL, NULL, NULL, 'InPreparazione', Ufficio, NumeroBUR, DataBUR, dgrN, dgrDel, TipoBando, TipoAppalto, RichiestaQuesito, 0, 0, MotivoEstensionePeriodo, ClasseIscriz, RichiediProdotti, ProceduraGara, TipoBandoGara, CriterioAggiudicazioneGara, ImportoBaseAsta, Iva, ImportoBaseAsta2, Oneri, CriterioFormulazioneOfferte, OffAnomale, NumeroIndizione, DataIndizione, gg_QuesitiScadenza, NULL, ClausolaFideiussoria, VisualizzaNotifiche, CUP, '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,NULL,NULL, NULL, NULL, TipoAppaltoGara, '', NULL, Conformita, Divisione_lotti, NumDec, DirezioneEspletante, null, ModalitadiPartecipazione, TipoIVA, EvidenzaPubblica,Complex,RichiestaCampionatura,TipoGiudizioTecnico,TipoProceduraCaratteristica,GeneraConvenzione,TipoSceltaContraente,TipoAccordoQuadro,TipoAggiudicazione,RegoleAggiudicatari,ListaAlbi,TipologiaDiAcquisto,Appalto_Verde,Acquisto_Sociale,Motivazione_Appalto_Verde,Motivazione_Acquisto_Sociale,Riferimento_Gazzetta,Data_Pubblicazione_Gazzetta,BaseAstaUnitaria,IdentificativoIniziativa, NULL, Merceologia,CPV, ModalitaAnomalia_ECO, ModalitaAnomalia_TEC,Opzioni,Richiesta_terna_subappalto,Concessione,TipoSedutaGara,RichiestaCigSimog,EnteProponente,RupProponente,Visualizzazione_Offerta_Tecnica,Accordo_di_Servizio,AppaltoInEmergenza,MotivazioneDiEmergenza,
					Appalto_PNRR_PNC, Appalto_PNRR, Appalto_PNC, Motivazione_Appalto_PNRR, Motivazione_Appalto_PNC, ID_MOTIVO_DEROGA, FLAG_MISURE_PREMIALI, 
					ID_MISURA_PREMIALE, FLAG_PREVISIONE_QUOTA, QUOTA_FEMMINILE, QUOTA_GIOVANILE,GenderEquality,GenderEqualityMotivazione,DataPrevistaAvvioSecondaFase,FaseConcorso,Importo_Altri_Concorrenti,Importo_Progettazione_Succ,Importo_Opera,TipoSoglia, CATEGORIE_MERC, pcp_UlterioriSommeNoRibasso, pcp_SommeRipetizioni, RegimeAllegerito ,pcp_CodiceCentroDiCostoProponente,SocietaInHouse
				from Document_Bando with(nolock) 
				where idheader=@idDoc

	END
	ELSE
	BEGIN

		INSERT INTO DOCUMENT_BANDO ( idHeader, SoggettiAmmessi, ImportoBando, MaxNumeroIniziative, MaxFinanziabile, dataCreazione, DataEstenzioneInizio, DataEstenzioneFine, FAX, DataRiferimentoInizio, DataRiferimentoFine, DataPresentazioneRisposte, StatoBando, Ufficio, NumeroBUR, DataBUR, dgrN, dgrDel, TipoBando, TipoAppalto, RichiestaQuesito, ReceivedQuesiti, RecivedIstanze, MotivoEstensionePeriodo, ClasseIscriz, RichiediProdotti, ProceduraGara, TipoBandoGara, CriterioAggiudicazioneGara, ImportoBaseAsta, Iva, ImportoBaseAsta2, Oneri, CriterioFormulazioneOfferte, OffAnomale, NumeroIndizione, DataIndizione, gg_QuesitiScadenza, DataTermineQuesiti, ClausolaFideiussoria, VisualizzaNotifiche, CUP, CIG, GG_OffIndicativa, HH_OffIndicativa, MM_OffIndicativa, DataScadenzaOffIndicativa, GG_Offerta, HH_Offerta, MM_Offerta, DataScadenzaOfferta, GG_PrimaSeduta, HH_PrimaSeduta, MM_PrimaSeduta, DataAperturaOfferte, TipoAppaltoGara, ProtocolloBando, DataRevoca, Conformita, Divisione_lotti, NumDec, DirezioneEspletante, DataProtocolloBando, ModalitadiPartecipazione, TipoIVA, EvidenzaPubblica ,Complex,RichiestaCampionatura,TipoGiudizioTecnico,TipoProceduraCaratteristica,GeneraConvenzione,TipoSceltaContraente,TipoAccordoQuadro,TipoAggiudicazione,RegoleAggiudicatari,ListaAlbi,TipologiaDiAcquisto,Appalto_Verde,Acquisto_Sociale,Motivazione_Appalto_Verde,Motivazione_Acquisto_Sociale,Riferimento_Gazzetta,Data_Pubblicazione_Gazzetta,BaseAstaUnitaria,IdentificativoIniziativa, DataTermineRispostaQuesiti, Merceologia,CPV, ModalitaAnomalia_ECO, ModalitaAnomalia_TEC, Opzioni,Richiesta_terna_subappalto,Concessione,TipoSedutaGara,RichiestaCigSimog,EnteProponente,RupProponente,Visualizzazione_Offerta_Tecnica,Accordo_di_Servizio,AppaltoInEmergenza,MotivazioneDiEmergenza,DataPrevistaAvvioSecondaFase,FaseConcorso,Importo_Altri_Concorrenti,Importo_Progettazione_Succ,Importo_Opera,TipoSoglia,CalcoloAnomalia, CATEGORIE_MERC, pcp_UlterioriSommeNoRibasso, pcp_SommeRipetizioni, RegimeAllegerito,pcp_CodiceCentroDiCostoProponente,SocietaInHouse)
			select @IdNewDoc, SoggettiAmmessi, ImportoBando, MaxNumeroIniziative, MaxFinanziabile, getdate(), DataEstenzioneInizio, DataEstenzioneFine, FAX, DataRiferimentoInizio, DataRiferimentoFine, DataPresentazioneRisposte, StatoBando, Ufficio, NumeroBUR, DataBUR, dgrN, dgrDel, TipoBando, TipoAppalto, RichiestaQuesito, 0, 0, MotivoEstensionePeriodo, ClasseIscriz, RichiediProdotti, ProceduraGara, TipoBandoGara, CriterioAggiudicazioneGara, ImportoBaseAsta, Iva, ImportoBaseAsta2, Oneri, CriterioFormulazioneOfferte, OffAnomale, NumeroIndizione, DataIndizione, gg_QuesitiScadenza, DataTermineQuesiti, ClausolaFideiussoria, VisualizzaNotifiche, CUP, CIG, GG_OffIndicativa, HH_OffIndicativa, MM_OffIndicativa, DataScadenzaOffIndicativa, GG_Offerta, HH_Offerta, MM_Offerta, DataScadenzaOfferta, GG_PrimaSeduta, HH_PrimaSeduta, MM_PrimaSeduta, DataAperturaOfferte, TipoAppaltoGara, NULL, DataRevoca, Conformita, Divisione_lotti, NumDec, DirezioneEspletante, null, ModalitadiPartecipazione, TipoIVA, EvidenzaPubblica,Complex,RichiestaCampionatura,TipoGiudizioTecnico,TipoProceduraCaratteristica,GeneraConvenzione,TipoSceltaContraente,TipoAccordoQuadro,TipoAggiudicazione,RegoleAggiudicatari,ListaAlbi,TipologiaDiAcquisto,Appalto_Verde,Acquisto_Sociale,Motivazione_Appalto_Verde,Motivazione_Acquisto_Sociale,Riferimento_Gazzetta,Data_Pubblicazione_Gazzetta,BaseAstaUnitaria,IdentificativoIniziativa, DataTermineRispostaQuesiti, Merceologia,CPV, ModalitaAnomalia_ECO, ModalitaAnomalia_TEC, Opzioni,Richiesta_terna_subappalto,Concessione,TipoSedutaGara,RichiestaCigSimog,EnteProponente,RupProponente,Visualizzazione_Offerta_Tecnica,Accordo_di_Servizio,AppaltoInEmergenza,MotivazioneDiEmergenza,DataPrevistaAvvioSecondaFase,FaseConcorso,Importo_Altri_Concorrenti,Importo_Progettazione_Succ,Importo_Opera,TipoSoglia,CalcoloAnomalia, CATEGORIE_MERC, pcp_UlterioriSommeNoRibasso, pcp_SommeRipetizioni, RegimeAllegerito,pcp_CodiceCentroDiCostoProponente,SocietaInHouse
				from Document_Bando with(nolock) 
				where idheader = @idDoc

		--spostiamo tutti i documenti di RICHIESTA_CIG e RICHIESTA_SMART_CIG sul nuovo documento gara
		update ctl_doc set linkeddoc = @IdNewDoc where linkeddoc = @idDoc and tipodoc in ('RICHIESTA_CIG','RICHIESTA_SMART_CIG')

		
		if exists (SELECT * FROM sys.objects  WHERE name='Document_E_FORM_PAYLOADS' and type='U' )
		BEGIN	
			-- per la copia NON travasiamo i dati della Document_E_FORM_PAYLOADS, mentre per il rifiuta e prosegui si. Altrimenti ci perderemmo gli xml generati
			INSERT INTO Document_E_FORM_PAYLOADS( [idHeader], [operationDate], [operationType], [idpfu], [payload] )
					select @IdNewDoc, [operationDate], [operationType], [idpfu], [payload]
						from Document_E_FORM_PAYLOADS with(nolock)
						where idheader = @idDoc
		END		

	END

	
	IF exists (SELECT * FROM sys.objects  WHERE name='Document_E_FORM_CONTRACT_NOTICE' and type='U' )
	BEGIN

		-- Copiamo i dati della nuova tabella Document_E_FORM_CONTRACT_NOTICE
		INSERT INTO Document_E_FORM_CONTRACT_NOTICE( [idHeader], [cn16_AuctionConstraintIndicator], [cn16_ContractingSystemTypeCode_framework], [cn16_FundingProgramCode_eu_funded], [cn16_FinancingIdentifier], [cn16_FundingProgramCode_eu_programme], [cn16_Funding_Description], [cn16_TendererRequirementTypeCode_reserved_proc], [cn16_ExecutionRequirementCode_reserved_execution], [cn16_CallForTendersDocumentReference_DocumentType], [cn16_CallForTendersDocumentReference_ExternalRef], 
														cn16_codice_appalto, 
														cn16_Funding_FinancingIdentifier
													)
				select @IdNewDoc, [cn16_AuctionConstraintIndicator], [cn16_ContractingSystemTypeCode_framework], [cn16_FundingProgramCode_eu_funded], [cn16_FinancingIdentifier], [cn16_FundingProgramCode_eu_programme], [cn16_Funding_Description], [cn16_TendererRequirementTypeCode_reserved_proc], [cn16_ExecutionRequirementCode_reserved_execution], [cn16_CallForTendersDocumentReference_DocumentType], [cn16_CallForTendersDocumentReference_ExternalRef], 
														case when @RIFIUTA_PROSEGUI = 1 then cn16_codice_appalto else '' end,  -- il codice dell'appalto non deve essere riportato nella copia. è specifico per procedura
														cn16_Funding_FinancingIdentifier
					from Document_E_FORM_CONTRACT_NOTICE with(nolock)
					where idheader = @idDoc


		--retrocompatibile per installare questa stored anche senza la tabella Document_Organismo_Ricorso
		IF exists (SELECT * FROM sys.objects  WHERE name='Document_Organismo_Ricorso' and type='U' )
		BEGIN	

			------------------------------------
			-- GESTIONE ORGANISMO DI RICORSO  --
			------------------------------------
			-- 1. Cerco i dati dell'org di ricorso per l'ente che ha creato la gara
			-- 2. In assenza dei dati specifici dell'ente passo a cercarli per l'aziMaster
			-- 3. In assenza anche di questi lasciamo i campi vuoti così da farli imputare tutti all'utente

			DECLARE @cn16_OrgRicorso_Name NVARCHAR(2000) = null
			DECLARE @cn16_OrgRicorso_CompanyID varchar(100) = null
			DECLARE @cn16_OrgRicorso_CityName nvarchar(1000) = null
			DECLARE @cn16_OrgRicorso_countryCode varchar(10) = null
			DECLARE @cn16_OrgRicorso_ElectronicMail nvarchar(1000) = null
			DECLARE @cn16_OrgRicorso_Telephone varchar(200) = null
			DECLARE @cn16_OrgRicorso_cap varchar(200) = null
			DECLARE @cn16_OrgRicorso_nuts varchar(200) = null

			SELECT  @cn16_OrgRicorso_Name = [Name],
					@cn16_OrgRicorso_CompanyID = CompanyID,
					@cn16_OrgRicorso_CityName = CityName,
					@cn16_OrgRicorso_countryCode = countryCode,
					@cn16_OrgRicorso_ElectronicMail = ElectronicMail,
					@cn16_OrgRicorso_Telephone = Telephone,
					@cn16_OrgRicorso_cap = postalCode,
					@cn16_OrgRicorso_nuts = codNuts
				FROM Document_Organismo_Ricorso WITH(NOLOCK)
				WHERE idazi = @Idazi and bDeleted = 0

			--se non c'è il record per l'idazi della gara provo con l'azimaster
			IF isnull(@cn16_OrgRicorso_CompanyID,'') = ''
			BEGIN

				SELECT  @cn16_OrgRicorso_Name = [Name],
						@cn16_OrgRicorso_CompanyID = CompanyID,
						@cn16_OrgRicorso_CityName = CityName,
						@cn16_OrgRicorso_countryCode = countryCode,
						@cn16_OrgRicorso_ElectronicMail = ElectronicMail,
						@cn16_OrgRicorso_Telephone = Telephone,
						@cn16_OrgRicorso_cap = postalCode,
						@cn16_OrgRicorso_nuts = codNuts
					FROM Document_Organismo_Ricorso WITH(NOLOCK)
					WHERE idazi = 35152001 and bDeleted = 0

			END

			-- in assenza dei dati di ricorso sia per l'ente collegato che per l'azi master
			--	prendo in copia quelli della procedura "precedente"
			IF isnull(@cn16_OrgRicorso_CompanyID,'') = ''
			BEGIN

				SELECT  @cn16_OrgRicorso_Name = cn16_OrgRicorso_Name,
						@cn16_OrgRicorso_CompanyID = cn16_OrgRicorso_CompanyID,
						@cn16_OrgRicorso_CityName = cn16_OrgRicorso_CityName,
						@cn16_OrgRicorso_countryCode = cn16_OrgRicorso_countryCode,
						@cn16_OrgRicorso_ElectronicMail = cn16_OrgRicorso_ElectronicMail,
						@cn16_OrgRicorso_Telephone = cn16_OrgRicorso_Telephone,
						@cn16_OrgRicorso_cap = cn16_OrgRicorso_cap,
						@cn16_OrgRicorso_nuts = cn16_OrgRicorso_codnuts
					from Document_E_FORM_CONTRACT_NOTICE with(nolock)
					where idheader = @idDoc

			END
		
			UPDATE Document_E_FORM_CONTRACT_NOTICE
					SET cn16_OrgRicorso_CityName = @cn16_OrgRicorso_CityName,
						cn16_OrgRicorso_CompanyID = @cn16_OrgRicorso_CompanyID,
						cn16_OrgRicorso_countryCode = @cn16_OrgRicorso_countryCode,
						cn16_OrgRicorso_ElectronicMail = @cn16_OrgRicorso_ElectronicMail,
						cn16_OrgRicorso_Name = @cn16_OrgRicorso_Name,
						cn16_OrgRicorso_Telephone = @cn16_OrgRicorso_Telephone,
						cn16_OrgRicorso_cap = @cn16_OrgRicorso_cap,
						cn16_OrgRicorso_codnuts = @cn16_OrgRicorso_nuts
				WHERE idHeader = @IdNewDoc

		END --IF exists (SELECT * FROM sys.objects  WHERE name='Document_Organismo_Ricorso' and type='U' )


	END 

	IF exists (SELECT * FROM sys.objects  WHERE name='Document_PCP_Appalto' and type='U' )
	BEGIN

			--UTILIZZO UNA QUERY DINAMICA PER COPIARE TUTTI I CAMPI DI Document_PCP_Appalto MODIFICANDO solo l'idHeader e svuotando pcp_CodiceAppalto
		    DECLARE @Campi_Document_PCP_Appalto NVARCHAR(MAX)
			DECLARE @Copia_Document_PCP_Appalto NVARCHAR(MAX)

			SELECT @Campi_Document_PCP_Appalto = STUFF((
				SELECT ', ' + COLUMN_NAME
				FROM INFORMATION_SCHEMA.COLUMNS
				WHERE TABLE_NAME = 'Document_PCP_Appalto'
				AND COLUMN_NAME NOT IN ('idRow', 'idHeader', 'pcp_CodiceAppalto')
				FOR XML PATH(''), TYPE
			).value('.', 'NVARCHAR(MAX)'), 1, 2, '')



			--SELECT @Campi_Document_PCP_Appalto = STRING_AGG(COLUMN_NAME, ', ')
			--FROM INFORMATION_SCHEMA.COLUMNS
			--WHERE TABLE_NAME = 'Document_PCP_Appalto' AND COLUMN_NAME NOT IN ('idRow','idHeader', 'pcp_CodiceAppalto')

			-- Costruisco la query
			SET @Copia_Document_PCP_Appalto = '	INSERT INTO Document_PCP_Appalto (idHeader, pcp_CodiceAppalto, ' + @Campi_Document_PCP_Appalto + ') 
												SELECT ' + CAST( @IdNewDoc AS NVARCHAR)+ ',' +QUOTENAME('', '''')+ ',' + @Campi_Document_PCP_Appalto + ' 
												FROM Document_PCP_Appalto with(nolock) WHERE idHeader = ' + CAST( @idDoc AS NVARCHAR)
			
			-- Esegui la query
			EXEC sp_executesql @Copia_Document_PCP_Appalto

		--genero un nuovo codice uuid
		DECLARE @CONTRACT_FOLDER_ID nvarchar(500) = ''
		SET @CONTRACT_FOLDER_ID = lower(newid())

			update Document_E_FORM_CONTRACT_NOTICE
					set CN16_CODICE_APPALTO = @CONTRACT_FOLDER_ID
				where idHeader = @IdNewDoc
		



	END


	--se azienda corrente non è tra gli enti abilitati setto @richiestaCIG a no sul nuovo bando
	select  @Lista_Enti_abilitati_RCig= dbo.PARAMETRI('GROUP_SIMOG','ENTI_ABILITATI','DefaultValue','',-1)
	if @Lista_Enti_abilitati_RCig <> '' and CHARINDEX (',' + cast(@Idazi as varchar(20)) + ',', ',' + @Lista_Enti_abilitati_RCig + ',') = 0
		update Document_Bando set RichiestaCigSimog='no' where idHeader = @IdNewDoc


	if @NuovoRilancio = 0 
	begin

		--copio sezione DOCUMENTAZIONE
		insert into	CTL_DOC_ALLEGATI (idHeader, Descrizione, Allegato, Obbligatorio, AnagDoc, DataEmissione, Interno, Modified, NotEditable, TipoFile, DataScadenza,DSE_ID, EvidenzaPubblica, TemplateAllegato)
			select @IdNewDoc, Descrizione, Allegato, Obbligatorio, AnagDoc, DataEmissione, Interno, Modified, NotEditable, TipoFile, DataScadenza, DSE_ID,EvidenzaPubblica, TemplateAllegato
				from CTL_DOC_ALLEGATI with(nolock) 
				where idheader=@idDoc	
				order by idrow

		
		--copio sezione CRITERI
		insert into Document_Microlotto_Valutazione	(idHeader, TipoDoc, CriterioValutazione, DescrizioneCriterio, PunteggioMax, Formula, AttributoCriterio,PunteggioMin,Allegati_da_oscurare)
			select @IdNewDoc, TipoDoc, CriterioValutazione, DescrizioneCriterio, PunteggioMax, Formula, replace(AttributoCriterio,@idDoc,@IdNewDoc),PunteggioMin,Allegati_da_oscurare
				from Document_Microlotto_Valutazione with(nolock) 
				where idheader=@idDoc and TipoDoc= @tipoDoc 
				order by idrow
	
		insert into Document_Microlotto_Valutazione_eco	(idHeader, TipoDoc, DescrizioneCriterio, PunteggioMax, AttributoBase, AttributoValore, Coefficiente_X, FormulaEcoSDA, FormulaEconomica, CriterioFormulazioneOfferte,Alfa)
			select @IdNewDoc, TipoDoc, DescrizioneCriterio, PunteggioMax, replace(AttributoBase,@idDoc,@IdNewDoc), replace(AttributoValore,@idDoc,@IdNewDoc), Coefficiente_X, FormulaEcoSDA, FormulaEconomica, CriterioFormulazioneOfferte,Alfa
				from Document_Microlotto_Valutazione_eco with(nolock)
				where idheader = @idDoc and TipoDoc= @tipoDoc 
				order by idRow

		--copio sezione DOCUMENTAZIONE_RICHIESTA  
		insert into Document_Bando_DocumentazioneRichiesta (idHeader, TipoInterventoDocumentazione, LineaDocumentazione, DescrizioneRichiesta, AllegatoRichiesto, Obbligatorio, TipoFile, AnagDoc, NotEditable, RichiediFirma, DSE_ID)
			select @IdNewDoc, TipoInterventoDocumentazione, LineaDocumentazione, DescrizioneRichiesta, AllegatoRichiesto, Obbligatorio, TipoFile, AnagDoc, NotEditable, RichiediFirma, DSE_ID
				from Document_Bando_DocumentazioneRichiesta with(nolock) 
				where idheader=@idDoc 
				order by idrow
		
		--copio sezione RIFERIMENTI (i precedenti + me stesso)
		insert into Document_Bando_Riferimenti (idHeader, idPfu, RuoloRiferimenti)
			 select  @IdNewDoc,idPfu,RuoloRiferimenti 
				from Document_Bando_Riferimenti with(nolock) 
				where idheader=@idDoc 
			 union 
			 select  @IdNewDoc,@IdUser,'Bando' as  RuoloRiferimenti
			 union 
			 select  @IdNewDoc,@IdUser,'Quesiti'  as RuoloRiferimenti

	end
	ELSE
	begin
		-- rettifica il tipo procedura caratteristica
		update DOCUMENT_BANDO 
			 set 

				TipoProceduraCaratteristica = 'RilancioCompetitivo' , 
				TipoBandoGara = '3' , 
				ProceduraGara = '15478' , 
				TipoAggiudicazione = 'monofornitore' , 
				tiposceltacontraente = null  ,
				regoleaggiudicatari = null ,
				TipoAccordoQuadro = 'monoround'

			 where idheader = @IdNewDoc

		update ctl_doc set idDoc = @IdNewDoc where id = @IdNuovoRilancio
		update ctl_doc set LinkedDoc = @IdDoc where id = @IdNewDoc

	end

	--kpf 430802  eredito il fascicolosecondario
	IF @RIFIUTA_PROSEGUI <> 0
	BEGIN 
		insert into Document_dati_protocollo ( idHeader,fascicoloSecondario)
			select   @IdNewDoc, fascicoloSecondario
				from Document_dati_protocollo with(nolock) where idHeader=@idDoc
	END
	ELSE
	BEGIN
		insert into Document_dati_protocollo ( idHeader)
				values (  @IdNewDoc )
	END


	-- Tutte le sezioni salvate sulla ctl_doc_value
	insert into CTL_DOC_VALUE (IdHeader, DSE_ID, Row, DZT_Name, Value)
		select 	@IdNewDoc, DSE_ID, Row, DZT_Name, Value
			from CTL_DOC_VALUE with(nolock)	
			where idheader=@idDoc --and DSE_ID <> 'TESTATA_PRODOTTI'

	--cancello eventuali sentinelle temp del processo di invio
	delete CTL_DOC_Value where idheader=@IdNewDoc and DSE_ID in ('bando_semplificato','CHECK_RDO_IMPORTO_WARNING')

	-- se non sono un rifiuta e prosegui devo svuotare l'esito riga sulla testata prodotti
	IF @RIFIUTA_PROSEGUI = 0
	BEGIN

		delete [CTL_DOC_Value] where [IdHeader]=@IdNewDoc and [DSE_ID]='TESTATA_PRODOTTI' and [DZT_Name]='EsitoRiga' 

		-- cancello eventuli sentinelle tecniche del TED
		delete from CTL_DOC_Value where [IdHeader]=@IdNewDoc and [DSE_ID] IN ( 'TED' )

		-- cancello IdDocPreGara se la gara era stata creata da un pregara
		delete from CTL_DOC_Value where [IdHeader]=@IdNewDoc and [DSE_ID] =  'InfoTec_comune' and [DZT_Name]='IdDocPreGara'
		--CANCELLO le pubblicazioni KPF.473085
		delete from CTL_DOC_Value where [IdHeader]=@IdNewDoc and [DSE_ID] IN ('InfoTec_DatePub','InfoTec_2DatePub','InfoTec_3DatePub')
	END

	-- cancello le sentinelle del simog
	delete from CTL_DOC_Value where [IdHeader]=@IdNewDoc and [DSE_ID] IN ( 'SIMOG_WS', 'SIMOG_GET', 'SIMOG_GET_PERFEZIONATO' )

	-- cancello entrata seduta virtuale se esiste
	delete [CTL_DOC_Value] where [IdHeader]=@IdNewDoc and [DSE_ID]='PrimaAperturaSedutaDaBusta' and [DZT_Name]='StatoSeduta' 

	-- cancello il legame con il sistema vision pbm
	delete [CTL_DOC_Value] where [IdHeader]=@IdNewDoc and [DSE_ID]='PROCEDURA_PBM'
	
	
	
	-----------------------------------------------------------------------------------------------------------------
	-- SE PROVENGO DA UN RIFIUTA E PROSEGUI MI COPIO IL CICLO DI APPROVAZIONE CAMBIANDO IL RIFERIMENTO ALLA GARA  ---
	-----------------------------------------------------------------------------------------------------------------
	IF @RIFIUTA_PROSEGUI <> 0
	BEGIN

		INSERT INTO CTL_ApprovalSteps ( APS_Doc_Type, APS_ID_DOC, APS_State, APS_Note, APS_Allegato, APS_UserProfile, APS_IdPfu, APS_IsOld, APS_Date, APS_APC_Cod_Node, APS_NextApprover )
			SELECT APS_Doc_Type, @IdNewDoc, APS_State, APS_Note, APS_Allegato, APS_UserProfile, APS_IdPfu, APS_IsOld, APS_Date, APS_APC_Cod_Node, APS_NextApprover
				from CTL_ApprovalSteps with(nolock)
				where aps_id_doc = @idDoc and APS_Doc_Type = @tipoDoc 
				order by APS_ID_ROW 

	END

	-----------------------------------------------------------------------------------------------------
	---	GENERO PER COPIA LA CONFIGURAZIONE DEL MODELLO ASSOCIATO CON TUTTO QUELLO CHE NE CONSEGUE -------
	-----------------------------------------------------------------------------------------------------
	
	IF EXISTS ( Select ID from ctl_doc with(nolock) where linkedDoc=@idDoc and StatoFunzionale IN ( 'Pubblicato', 'InLavorazione' ) and tipodoc like 'CONFIG_MODELLI%' and deleted = 0 )
	BEGIN		-- Aggiunto lo statoFunzionale InLavorazione nel recupero, perchè se si è aperto e salvato il modello non lo recupererei +

		declare @id_old_mod as int
		declare @cod_old_mod as varchar(4000)	
		declare @name_old_mod as varchar(4000)	

		Select top 1 @id_old_mod=id, @cod_old_mod=Titolo  
			from ctl_doc with(nolock)
				where linkedDoc=@idDoc and StatoFunzionale IN ( 'Pubblicato', 'InLavorazione' ) and tipodoc like 'CONFIG_MODELLI%' and deleted = 0 
				order by id desc

		set @name_old_mod = 'MODELLI_LOTTI_' + @cod_old_mod + '%'
		
			
		-- Lascio data, dataInvio, protocollo ed idPFU uguali a quelli originali. 
		insert into ctl_doc	(idPfuInCharge, IdPfu, IdDoc, TipoDoc, StatoDoc, Data, Protocollo, PrevDoc, Deleted, Titolo, Body, Azienda, StrutturaAziendale, DataInvio, DataScadenza, ProtocolloRiferimento, ProtocolloGenerale, Fascicolo, Note, DataProtocolloGenerale, LinkedDoc, SIGN_HASH, SIGN_ATTACH, SIGN_LOCK, JumpCheck, StatoFunzionale, Destinatario_User, Destinatario_Azi, RichiestaFirma, NumeroDocumento, DataDocumento, Versione, VersioneLinkedDoc, CanaleNotifica, URL_CLIENT, Caption)
				select @IdUser,@IdUser, IdDoc, TipoDoc, StatoDoc, GETDATE(), '', 0, 0, Titolo, Body, Azienda, StrutturaAziendale, getDate(), null, null, null, '', Note, null, @IdNewDoc, '', '', 0, null, 'InLavorazione', Destinatario_User, Destinatario_Azi, RichiestaFirma, NumeroDocumento, DataDocumento, null, null, CanaleNotifica, URL_CLIENT, Caption
				    from ctl_doc with(nolock)
				    where id = @id_old_mod

		set @IdNewMod = scope_identity()

		-- Aggiorno il codice modello con il nuovo id
		UPDATE CTL_DOC
			 set titolo = replace(titolo, @idDoc,@IdNewDoc)
			 WHERE ID = @IdNewMod

		UPDATE DOCUMENT_BANDO
			 set TipoBando = replace(TipoBando, @idDoc,@IdNewDoc)
			 WHERE idHeader = @IdNewDoc

		insert into CTL_DOC_VALUE ( IdHeader, DSE_ID, Row, DZT_Name, Value)
			select @IdNewMod, DSE_ID, Row, DZT_Name, Value
				from CTL_DOC_VALUE with(nolock)
				where idheader = @id_old_mod 
		
		--if @TipoProceduraCaratteristica <> 'AffidamentoSemplificato'
		--BEGIN			
			--forzo la sentinella a ERRORE sul nuovo modello per forzare il conferma sul modello
			update CTL_DOC_VALUE set Value='ERRORE' where IdHeader=@IdNewMod and DSE_ID='STATO_MODELLO' and DZT_Name='Stato_Modello_Gara'
							
		--END
		

		insert into Document_Vincoli ( IdHeader, Espressione, Descrizione, EsitoRiga, Seleziona,contesto_vincoli)
			select @IdNewMod,Espressione, Descrizione, EsitoRiga, Seleziona, contesto_vincoli
				from Document_Vincoli with(nolock)
				where IdHeader = @id_old_mod 
				order by IdRow

		--copio i record nella CTL_DOC_SECTION_MODEL
		insert into CTL_DOC_SECTION_MODEL ( IdHeader, DSE_ID, MOD_Name)
			select @IdNewMod, CM.DSE_ID, MOD_Name
			from 
				CTL_DOC_SECTION_MODEL CM with(nolock)
					inner join CTL_DOC C with(nolock) ON C.Id=@id_old_mod
					inner join LIB_DocumentSections with(nolock) on DSE_DOC_ID=C.TipoDoc and DSE_Param like '%DYNAMIC_MODEL=yes%'						
			where 
				IdHeader = @id_old_mod and CM.DSE_ID=LIB_DocumentSections.DSE_ID
				
			


		/*
		insert into CTL_Models( MOD_ID, MOD_Name, MOD_DescML, MOD_Type, MOD_Sys, MOD_help, MOD_Param, MOD_Module, MOD_Template )
			select replace(MOD_ID,@idDoc,@IdNewDoc), replace(MOD_Name,@idDoc,@IdNewDoc), replace(MOD_DescML,@idDoc,@IdNewDoc), MOD_Type, MOD_Sys, MOD_help, MOD_Param, MOD_Module, MOD_Template 
			from CTL_Models with(nolock) where mod_id like '%' + @cod_old_mod +'%'

		--INSERT INTO CTL_ModelAttributes ( MA_MOD_ID, MA_DZT_Name, MA_DescML, MA_Pos, MA_Len, MA_Order, DZT_Type, DZT_DM_ID, DZT_DM_ID_Um, DZT_Len, DZT_Dec, DZT_Format, DZT_Help, DZT_Multivalue, MA_Module)
		--	select replace(MA_MOD_ID,@idDoc,@IdNewDoc), MA_DZT_Name, MA_DescML, MA_Pos, MA_Len, MA_Order, DZT_Type, DZT_DM_ID, DZT_DM_ID_Um, DZT_Len, DZT_Dec, DZT_Format, DZT_Help, DZT_Multivalue, MA_Module
		--	from CTL_ModelAttributes with(nolock) where MA_MOD_ID like '%' + @cod_old_mod +'%'

		INSERT INTO CTL_ModelAttributes ( MA_MOD_ID, MA_DZT_Name, MA_DescML, MA_Pos, MA_Len, MA_Order, MA_Module)
			select replace(MA_MOD_ID,@idDoc,@IdNewDoc), MA_DZT_Name, MA_DescML, MA_Pos, MA_Len, MA_Order, MA_Module
			from CTL_ModelAttributes with(nolock) where MA_MOD_ID like '%' + @cod_old_mod +'%'

		INSERT INTO CTL_ModelAttributeProperties (MAP_MA_MOD_ID, MAP_MA_DZT_Name, MAP_Propety, MAP_Value, MAP_Module)
			select replace(MAP_MA_MOD_ID,@idDoc,@IdNewDoc), MAP_MA_DZT_Name, MAP_Propety, MAP_Value, MAP_Module
			from CTL_ModelAttributeProperties with(nolock) where MAP_MA_MOD_ID like '%' + @cod_old_mod +'%'
		*/

		-- sostituita la like con i % avanti e dietro con una solo nella parte terminale, con la speranza che sfrutti l'indice sulla tabella
		declare @stridDoc as varchar(50)
		declare @strIdNewDoc as varchar(50)

		set @stridDoc = @idDoc
		set @strIdNewDoc = @IdNewDoc
		
		--considero le sezioni con modello dinamico del bando_gara e bando_semplificato e con il nome modello che contiene il vecchio riferimento
		select MOD_Name into #TempModelToCopy
			from CTL_DOC_SECTION_MODEL with(nolock) 
			where IdHeader=@idDoc and DSE_ID  in ( 'BUSTA_ECONOMICA','BUSTA_TECNICA', 'CRITERI_AQ_EREDITA_TEC','LISTA_BUSTE','PRODOTTI','PROTOCOLLO','TESTATA')		
				and MOD_NAME like '%' + @stridDoc + '%'
		

		insert into CTL_Models( MOD_ID, MOD_Name, MOD_DescML, MOD_Type, MOD_Sys, MOD_help, MOD_Param, MOD_Module, MOD_Template )
			select replace(MOD_ID,@stridDoc,@strIdNewDoc), replace(M.MOD_Name,@stridDoc,@strIdNewDoc), replace(MOD_DescML,@stridDoc,@strIdNewDoc), MOD_Type, MOD_Sys, MOD_help, MOD_Param, MOD_Module, MOD_Template 
				from CTL_Models M with(nolock) 
				inner join #TempModelToCopy t on mod_id = t.MOD_Name

			
		INSERT INTO CTL_ModelAttributes ( MA_MOD_ID, MA_DZT_Name, MA_DescML, MA_Pos, MA_Len, MA_Order, MA_Module)
			select replace(MA_MOD_ID,@stridDoc,@strIdNewDoc), MA_DZT_Name, MA_DescML, MA_Pos, MA_Len, MA_Order, MA_Module
				from CTL_ModelAttributes with(nolock, index (IX_CTL_ModelAttributes_MA_MOD_ID)) 
				   --from CTL_ModelAttributes with(nolock) 
				   --messa inner join per fargli sfrutta reindice sulla ctl_models
				   --inner join CTL_Models with(nolock) ON mod_id = MA_MOD_ID AND MOD_ID like @name_old_mod
				   inner join #TempModelToCopy t on MA_MOD_ID = t.MOD_Name

				   --where MA_MOD_ID like @name_old_mod
				   --from CTL_ModelAttributes with(nolock) where MA_MOD_ID like @name_old_mod
			
		
		
		INSERT INTO CTL_ModelAttributeProperties (MAP_MA_MOD_ID, MAP_MA_DZT_Name, MAP_Propety, MAP_Value, MAP_Module)
			select replace(MAP_MA_MOD_ID,@stridDoc,@strIdNewDoc), MAP_MA_DZT_Name, MAP_Propety, MAP_Value, MAP_Module
				from CTL_ModelAttributeProperties with(nolock,index(IX_CTL_ModelAttributeProperties_MAP_MA_MOD_ID)) 
				   --messa inner join per fargli sfrutta reindice sulla ctl_models
				   --inner join CTL_Models with(nolock) ON mod_id = MAP_MA_MOD_ID AND MOD_ID like @name_old_mod
				   inner join #TempModelToCopy t on MAP_MA_MOD_ID = t.MOD_Name
				   --where MAP_MA_MOD_ID like @name_old_mod
			


		INSERT INTO Document_Modelli_MicroLotti ( StatoDoc, Deleted, DataCreazione, Codice, Descrizione, ModelloBando, ModelloOfferta, ColonneCauzione, Allegato, ModelloPDA, ModelloPDA_DrillTestata, ModelloPDA_DrillLista, ModelloOfferta_Drill, ModelloConformitaTestata, ModelloConformitaDettagli, CriterioAggiudicazioneGara, Conformita, Help_Bando, Help_Offerte, Help_Offerte_Indicativa, Complex, Base, LinkedDoc )
			select StatoDoc, Deleted, DataCreazione, replace(Codice,@idDoc,@IdNewDoc), Descrizione, replace(ModelloBando,@idDoc,@IdNewDoc), replace(ModelloOfferta,@idDoc,@IdNewDoc), replace(ColonneCauzione,@idDoc,@IdNewDoc), Allegato, replace(ModelloPDA,@idDoc,@IdNewDoc), replace(ModelloPDA_DrillTestata,@idDoc,@IdNewDoc), replace(ModelloPDA_DrillLista,@idDoc,@IdNewDoc), replace(ModelloOfferta_Drill,@idDoc,@IdNewDoc), replace(ModelloConformitaTestata,@idDoc,@IdNewDoc), replace(ModelloConformitaDettagli,@idDoc,@IdNewDoc), CriterioAggiudicazioneGara, Conformita, Help_Bando, Help_Offerte, Help_Offerte_Indicativa, Complex, Base, @IdNewMod
				from Document_Modelli_MicroLotti with(nolock) 
				where codice  like '%' + @cod_old_mod +'%'

		set @IdNewModMicrolotto = scope_identity()

		INSERT INTO Document_Modelli_MicroLotti_Formula ( StatoDoc, Deleted, DataCreazione, Codice, FormulaEconomica, CriterioFormulazioneOfferte, IdHeader, FieldBaseAsta, Quantita )
			select StatoDoc, Deleted, DataCreazione, replace(Codice,@idDoc,@IdNewDoc), FormulaEconomica, CriterioFormulazioneOfferte, IdHeader, FieldBaseAsta, Quantita
				from Document_Modelli_MicroLotti_Formula with(nolock) 
				where codice  like '%' + @cod_old_mod +'%'


		-- aggiorno la tabella del dominio
		exec INIT_DOMINIO_AttributoCriterio  @IdNewMod 

	END

	


	-------------------------------------------------------------------------------------------------------------------------
	------- SGANCIO IL MODELLO PRECEDENTEMENTE ASSOCIATO E ASSOCIO QUELLO NUOVO. SPECIFICO PER IL NUOVO DOCUMENTO DI COPIA --
	-------------------------------------------------------------------------------------------------------------------------
	UPDATE CTL_DOC_VALUE
		SET VALUE = @IdNewMod
		WHERE IdHeader = @IdNewDoc and DSE_ID = 'TESTATA_PRODOTTI' AND DZT_Name = 'id_modello'

	--copio modelli legati al documento e sostituisco gli eventuali riferimenti nei codici modelli
	insert into CTL_DOC_SECTION_MODEL( IdHeader, DSE_ID, MOD_Name )
		select @IdNewDoc, DSE_ID, replace(MOD_Name,@idDoc,@IdNewDoc)
			from CTL_DOC_SECTION_MODEL with(nolock) 
			where IdHeader=@idDoc and DSE_ID  in ( 'BUSTA_ECONOMICA','BUSTA_TECNICA', 'CRITERI_AQ_EREDITA_TEC','LISTA_BUSTE','PRODOTTI','PROTOCOLLO','TESTATA')
	
	-- SE ATTIVO INTEROP SULLA GARA  INNESCO LA SP CHE SETTA LE COSE COERENTI
	-- PER LA GARA COPIATA: POTREBBE ESSERE CAMBIATA LA VERSIONE AD ESEMPIO E QUINDI CAMBIANO I MODELLI INTEROP...
	if dbo.attivo_INTEROP_Gara(@idDoc) = 1
	begin
		exec INIT_SCHEDA_PCP_GARA @IdNewDoc, @IdUser
	end


	--COPIO I MODELLI DI INTEROPERABILITA' SE ESISTONO
	--IF EXISTS ( Select IdRow from CTL_DOC_SECTION_MODEL with(nolock) where idHeader = @idDoc and DSE_ID = 'INTEROP' )
	--BEGIN

	--	declare @mod_name varchar(500);
	--	SELECT @mod_name = MOD_Name from CTL_DOC_SECTION_MODEL with(nolock) where idHeader = @idDoc and DSE_ID = 'INTEROP'

	--	insert into CTL_DOC_SECTION_MODEL (IdHeader,DSE_ID,MOD_Name) values (@IdNewDoc,'INTEROP',@mod_name)
	--END

	--IF EXISTS ( Select IdRow from CTL_DOC_SECTION_MODEL with(nolock) where idHeader = @idDoc and DSE_ID = 'INTEROP_PCP' )
	--BEGIN

	--	declare @mod_name_pcp varchar(500);
	--	SELECT @mod_name_pcp = MOD_Name from CTL_DOC_SECTION_MODEL with(nolock) where idHeader = @idDoc and DSE_ID = 'INTEROP_PCP'

	--	insert into CTL_DOC_SECTION_MODEL (IdHeader,DSE_ID,MOD_Name) values (@IdNewDoc,'INTEROP_PCP',@mod_name_pcp)
	--END


	--Se mi è stato chiesto tra i parametri, copio il documento dei criteri di ricerca
	IF @NuovoRilancio = 0 and  @RIFIUTA_PROSEGUI <> 0 and exists( select id from ctl_doc with(nolock) where linkeddoc=@idDoc and tipodoc='RICERCA_OE' and deleted = 0 and StatoFunzionale = 'Pubblicato' )
	BEGIN

		select top 1 @IdOldRicerca=id from ctl_doc with(nolock) where linkeddoc=@idDoc and tipodoc='RICERCA_OE' and deleted = 0 and StatoFunzionale = 'Pubblicato' order by id desc

		-- Lascio data, dataInvio, protocollo ed idPFU uguali a quelli originali. 
		insert into ctl_doc	(IdPfu, IdDoc, TipoDoc, StatoDoc, Data, Protocollo, PrevDoc, Deleted, Titolo, Body, Azienda, StrutturaAziendale, DataInvio, DataScadenza, ProtocolloRiferimento, ProtocolloGenerale, Fascicolo, Note, DataProtocolloGenerale, LinkedDoc, SIGN_HASH, SIGN_ATTACH, SIGN_LOCK, JumpCheck, StatoFunzionale, Destinatario_User, Destinatario_Azi, RichiestaFirma, NumeroDocumento, DataDocumento, Versione, VersioneLinkedDoc, idPfuInCharge, CanaleNotifica, URL_CLIENT, Caption)
				select @IdUser, IdDoc, TipoDoc, StatoDoc, data, protocollo, 0, 0, Titolo, Body, Azienda, StrutturaAziendale, DataInvio, null, null, null, '', Note, null, @IdNewDoc, '', '', 0, null, StatoFunzionale, Destinatario_User, Destinatario_Azi, RichiestaFirma, NumeroDocumento, DataDocumento, null, null, idPfuInCharge, CanaleNotifica, URL_CLIENT, Caption
					from ctl_doc with(nolock)
					where id=@IdOldRicerca

		set @IdNewRicerca = scope_identity()		

		insert into CTL_DOC_VALUE (IdHeader, DSE_ID, Row, DZT_Name, Value)
					select @IdNewRicerca, DSE_ID, Row, DZT_Name, Value
						  from CTL_DOC_VALUE with(nolock) 
						  where idheader=@IdOldRicerca 		

		update 
		  CTL_DOC_VALUE 
			set Value='' 
			where idheader=@IdNewRicerca and dzt_name='NumRighe' and DSE_ID='BOTTONE'

	END

	-- Se devo includere i destinatari, a prescindere se ho un documento di ricerca_oe copio le righe della CTL_DOC_Destinatari 
	-- oppure se si tratta di un affidamento diretto semplificato
	--kpf 530073 per gli affidamenti diretti mi copio i destinatari
	--kpf 562261 ma lo devo fare per in fase di copia invito da avviso in quanto non è possibile riattivare la selezione degli OE da invitare
	--se lo fa per tutti gli affidamenti e capitato che per gli "Avviso aperto" avevamo ereditato i destinatari del precedente
	IF @RIFIUTA_PROSEGUI <> 0 or @TipoProceduraCaratteristica = 'AffidamentoSemplificato' or ( @ProceduraGara='15583' and @tipobandogara = '3')
	BEGIN

		INSERT INTO CTL_DOC_Destinatari  ( idHeader, IdPfu, IdAzi, aziRagioneSociale, aziPartitaIVA, aziE_Mail, aziIndirizzoLeg, aziLocalitaLeg, aziProvinciaLeg, aziStatoLeg, aziCAPLeg, aziTelefono1, aziFAX, aziDBNumber, aziSitoWeb, CDDStato, Seleziona, NumRiga, CodiceFiscale, StatoIscrizione, DataIscrizione, DataScadenzaIscrizione, DataSollecito, Id_Doc)
			select @IdNewDoc, IdPfu, IdAzi, aziRagioneSociale, aziPartitaIVA, aziE_Mail, aziIndirizzoLeg, aziLocalitaLeg, aziProvinciaLeg, aziStatoLeg, aziCAPLeg, aziTelefono1, aziFAX, aziDBNumber, aziSitoWeb, CDDStato, Seleziona, NumRiga, CodiceFiscale, StatoIscrizione, DataIscrizione, DataScadenzaIscrizione, DataSollecito, Id_Doc
				from CTL_DOC_Destinatari with(nolock)
				where idheader = @idDoc 
				order by idrow
	END

	declare @idRow INT
	declare @NewIdRow INT


	if @NuovoRilancio = 0
	begin 

			declare @Filter as varchar(500)
			declare @DestListField as varchar(500)

			set @Filter = ' Tipodoc=''' + @tipoDoc + ''' '
			set @DestListField = ' ''' + @tipoDoc + ''' as TipoDoc, '''' as EsitoRiga '
		
			-- se sono un rifiuta e prosegui NON devo svuotare i CIG dalle righe
			IF @RIFIUTA_PROSEGUI <> 0
			BEGIN


				exec INSERT_RECORD_NEW 'Document_MicroLotti_Dettagli', @idDoc, @IdNewDoc, 'IdHeader', 
							 ' Id,IdHeader,TipoDoc,EsitoRiga,Statoriga ', 
							 @Filter, 
							 ' TipoDoc, EsitoRiga ', 
							 @DestListField,
							 ' id '
			END
			ELSE
			BEGIN

				  exec INSERT_RECORD_NEW 'Document_MicroLotti_Dettagli', @idDoc, @IdNewDoc, 'IdHeader', 
							 ' Id,IdHeader,TipoDoc,EsitoRiga,CIG,Statoriga ', 
							 @Filter, 
							 ' TipoDoc, EsitoRiga ', 
							 @DestListField,
							 ' id '

			END

			

		  
		 --inserimento eventuale criterio di prodotto				
		 insert into Document_Microlotto_Valutazione
	   	 	 (idHeader, TipoDoc, CriterioValutazione, DescrizioneCriterio, PunteggioMax, Formula, AttributoCriterio,PunteggioMin,Allegati_da_oscurare)
			 select DBC.id, C.TipoDoc, CriterioValutazione, DescrizioneCriterio, PunteggioMax, Formula, replace(AttributoCriterio,@idDoc,@IdNewDoc),PunteggioMin,Allegati_da_oscurare
				    from
					   ctl_doc B  with(nolock)
						  inner join document_microlotti_dettagli DB  with(nolock) on DB.idheader = B.id and DB.voce=0
						  inner join Document_Microlotto_Valutazione C with(nolock) on DB.id =C.idheader and C.TipoDoc='LOTTO' and DB.voce=0
	   					  inner join document_microlotti_dettagli DBC  with(nolock) on DBC.idheader=@IdNewDoc and DBC.NumeroLotto = DB.NumeroLotto  and DBC.voce=0 
					   where B.id=@idDoc
				  

		  
		  insert into Document_Microlotto_Valutazione_eco
			 (idHeader, TipoDoc, DescrizioneCriterio, PunteggioMax, AttributoBase, AttributoValore, Coefficiente_X, FormulaEcoSDA, FormulaEconomica, CriterioFormulazioneOfferte , Alfa )
			 select DBC.id, C.TipoDoc, DescrizioneCriterio, PunteggioMax, replace(AttributoBase,@idDoc,@IdNewDoc), replace(AttributoValore,@idDoc,@IdNewDoc), Coefficiente_X, FormulaEcoSDA, FormulaEconomica, CriterioFormulazioneOfferte,Alfa
				    from 
					   ctl_doc B  with(nolock)
						  inner join document_microlotti_dettagli DB  with(nolock) on DB.idheader = B.id and DB.voce=0
						  inner join Document_Microlotto_Valutazione_eco C with(nolock) on DB.id =C.idheader and C.TipoDoc='LOTTO' and DB.voce=0
						  inner join document_microlotti_dettagli DBC  with(nolock) on DBC.idheader=@IdNewDoc and DBC.NumeroLotto = DB.NumeroLotto  and DBC.voce=0 
					   where B.id=@idDoc
				   

		  --inserimento eventuale modello relativo al lotto
			insert into CTL_DOC_SECTION_MODEL ( IdHeader, DSE_ID, MOD_Name )
				select DBC.id, DSE_ID, replace(MOD_Name,@idDoc,@IdNewDoc) 
				    from 
					   ctl_doc B  with(nolock)
						  inner join document_microlotti_dettagli DB  with(nolock) on DB.idheader = B.id and DB.voce=0
						  inner join CTL_DOC_SECTION_MODEL M with(nolock) on M.idheader=Db.id and  DSE_ID in( 'BANDO_SEMP_OFF_ECO' , 'BANDO_SEMP_OFF_TEC' )
    						  inner join document_microlotti_dettagli DBC  with(nolock) on DBC.idheader=@IdNewDoc and DBC.NumeroLotto = DB.NumeroLotto  and DBC.voce=0 
					   where B.id=@idDoc 
		  
		
		  	INSERT INTO Document_Microlotti_DOC_Value( IdHeader, DSE_ID, Row, DZT_Name, Value )
		  		select DBC.id, DSE_ID, Row, DZT_Name, Value 
				    from  ctl_doc B  with(nolock)
						  inner join document_microlotti_dettagli DB  with(nolock) on DB.idheader = B.id and DB.voce=0
						  inner join Document_Microlotti_DOC_Value DV with(nolock) on DV.idheader = Db.id
						  inner join document_microlotti_dettagli DBC  with(nolock) on DBC.idheader = @IdNewDoc and DBC.NumeroLotto = DB.NumeroLotto  and DBC.voce=0 
		  		     where B.id=@idDoc 

		  	 
		  -----------------------------------
		  --- RETTIFICO idHeaderLotto -------
		  -----------------------------------

		  select isnull(numerolotto,-1) as nl, min(id) as idX into #temp_idHeaderLotto
			 from Document_MicroLotti_Dettagli with(nolock)
				where tipoDoc = @tipoDoc and IdHeader = @idNewDoc
				group by numerolotto

		  update Document_MicroLotti_Dettagli 
			 set idheaderlotto = a.idX
				FROM Document_MicroLotti_Dettagli 
					   inner join #temp_idHeaderLotto a on isnull(numerolotto,-1) = nl 
				where tipoDoc = @tipoDoc and IdHeader = @idNewDoc 

	END


	IF @RIFIUTA_PROSEGUI = 0
		exec BANDO_GARA_DEFINIZIONE_STRUTTURA @IdNewDoc , @idDoc


	-----------------------------------------------
	--- RICOPIA EVENTUALI DGUE SE PRESENTI --------
	-----------------------------------------------
	declare @TEMPLATE_CONTEST as INT
	declare @id_template as INT


	

	--VERIFICA SE SUL BANDO DI PARTENZA E' PRESENTE IL DGUE
	IF @NuovoRilancio = 0 AND EXISTS ( select * from CTL_DOC_Value with(nolock) where IdHeader=@idDoc and DSE_ID='DGUE' and DZT_Name='PresenzaDGUE' and ISNULL(value,'')='si' )
	BEGIN
		--VERIFICO SE IL TEMPLATE_REQUEST E'ANCORA VALIDO, IN QUEL CASO FACCIO LA COPIA ALTRIMENTI SVUOTO I CAMPI TECNICI SUL NUOVO BANDO
		select @TEMPLATE_CONTEST=t.IdDoc from CTL_DOC C  with(nolock) 
			inner join ctl_doc t  with(nolock) on t.linkeddoc = C.id and t.tipodoc = 'TEMPLATE_CONTEST' and t.deleted = 0 and t.JumpCheck in ('DGUE_MANDATARIA')
				where C.tipodoc like  'BANDO%'  and C.Id=@idDoc

		IF EXISTS (select * from CTL_DOC  with(nolock) where Id=@TEMPLATE_CONTEST and Deleted=0 and StatoFunzionale='Pubblicato' and TipoDoc = 'TEMPLATE_REQUEST')
		BEGIN
			--RECUPERO ID_TEMPLATE MANDATARIA
			  select @id_template=value from BANDO_DGUE_VIEW where idheader=@idDoc and DSE_ID='DGUE' and DZT_Name='idTemplate'		      
			  
			  --creo teable temp per evitare che la SP COPIA_TEMPLATE_CONTEST_CREATE_FOR
			  --ritorna un record al chiamante perchè se è una makdocfrom ho più recordset
			  CREATE TABLE #TempCheck(
				[Id] [varchar](200) collate DATABASE_DEFAULT NULL,
				[Errore] [varchar](200) collate DATABASE_DEFAULT NULL
			   ) 
			  insert into #TempCheck
				EXEC COPIA_TEMPLATE_CONTEST_CREATE_FOR @IdNewDoc, @id_template ,@idUser, 'DGUE_MANDATARIA'
			  
			  --RECUPERO ID_TEMPLATE AUSILIARIE
			  select @id_template=value from BANDO_DGUE_VIEW where idheader=@idDoc and DSE_ID='DGUE' and DZT_Name='idTemplate_Ausiliarie'		      
			  insert into #TempCheck
				 EXEC COPIA_TEMPLATE_CONTEST_CREATE_FOR @IdNewDoc, @id_template ,@idUser, 'DGUE_AUSILIARIE'

			  --RECUPERO ID_TEMPLATE MANDANTI
			  select @id_template=value from BANDO_DGUE_VIEW where idheader=@idDoc and DSE_ID='DGUE' and DZT_Name='idTemplate_Mandanti'		      
			  insert into #TempCheck
				EXEC COPIA_TEMPLATE_CONTEST_CREATE_FOR @IdNewDoc, @id_template ,@idUser, 'DGUE_RTI'

			  --RECUPERO ID_TEMPLATE Subappaltarici
			  select @id_template=value from BANDO_DGUE_VIEW where idheader=@idDoc and DSE_ID='DGUE' and DZT_Name='idTemplate_Subappaltarici'		      
			  insert into #TempCheck
				  EXEC COPIA_TEMPLATE_CONTEST_CREATE_FOR @IdNewDoc, @id_template ,@idUser, 'DGUE_ESECUTRICI'		
			
			  --cancello la tabella temporanea
			  drop table #TempCheck	
		END
		ELSE
		BEGIN
			--IN QUESTO CASO RIMUOVO I RIFERIMENTI AL DGUE COPIATI NELLA CTL_DOC_VALUE del NUOVO BANDO
			delete from CTL_DOC_Value where IdHeader=@IdNewDoc and DSE_ID='DGUE'
		END

	END

	--SE IL LINKEDDOC DEL DOCUMENTO CHE STO COPIANDO E' UN PREGARA LO SVUOTIAMO
	IF EXISTS ( Select id from CTL_DOC with(nolock) where Id=@LinkedDoc and TipoDoc='PREGARA' )
	BEGIN
		update CTL_DOC set LinkedDoc=0 where Id=@IdNewDoc
	END


	--SECONDO LE RICHIESTE SETTIAMO COME RUP UTENTE COLLEGATO
	IF @NuovoRilancio = 1
	BEGIN
		update CTL_DOC_Value set Value=@IdUser
			where IdHeader=@IdNewDoc and DSE_ID='InfoTec_comune' and DZT_Name='UserRUP'

		update Document_Bando set RupProponente=@IdUser , EnteProponente= (select top 1  DMV_COD  from GESTIONE_DOMINIO_DIREZIONE where idaz = @idAzi and dmv_deleted = 0 and dmv_level = 2 order by DMV_Father)
			where idHeader=@IdNewDoc
	END

	--SE SUL TEMPLATE/GARA È PRESENTE IL QUESTIONARIO AMMINISTRATIVO LO COPIO E LO AGGANCIO AL DOCUMENTO APPENA CREATO
	--SE PresenzaQuestionario = si allora esite il questionario e lo recupero e lo copio
	DECLARE @PresenzaQuestionario_SiNo varchar(2)
	SELECT @PresenzaQuestionario_SiNo=ISNULL([value],'no') 
		FROM ctl_doc_Value WITH(NOLOCK) 
			WHERE idheader = @idDoc AND dse_id = 'QUESTIONARIO' AND dzt_name = 'PresenzaQuestionario'
  
	IF @PresenzaQuestionario_SiNo = 'si'
	BEGIN
		DECLARE @IdQuestionario as INT = -1
	
	

		  -- Copio la riga della ctl_doc ottengo un nuovo ID
		SELECT @IdQuestionario=Id 
			FROM CTL_DOC WITH(NOLOCK) 
			WHERE TipoDoc='QUESTIONARIO_AMMINISTRATIVO' 
				AND LinkedDoc=@idDoc 
				AND StatoFunzionale <> 'Annullato'
				AND isnull(jumpcheck,'')=''

		-- Se @IdQuestionario <> -1 allora copio il questionario e lo aggancio al nuovo documento creato per copia
		IF @IdQuestionario <> -1
		BEGIN
		
			DECLARE @IdNewQuestionario as INT = -1
    
			-- Copio la riga della ctl_doc del questionario
			INSERT INTO CTL_DOC (IdPfu, IdDoc, TipoDoc, StatoDoc, [Data], Titolo, Body, StrutturaAziendale, LinkedDoc, Note , StatoFunzionale)
			
				SELECT @IdUser as IdPfu, IdDoc, TipoDoc, StatoDoc, getdate(), Titolo, Body, StrutturaAziendale, @IdNewDoc, Note , 'InLavorazione'
					FROM CTL_DOC WITH (NOLOCK)
					WHERE Id = @IdQuestionario
      
			SET @IdNewQuestionario = scope_identity()

			-- Ricopio i dettagli del QUESTIONARIO_AMMINISTRATIVO
			INSERT INTO Document_Questionario_Amministrativo ([idHeader], [KeyRiga], [TipoRigaQuestionario], [Descrizione], [DescrizioneEstesa]
															, [TipoParametroQuestionario], [Tech_Info_Parametro], [EsitoRiga], [EsitoRiga_Parametro]
															, [ChiaveUnivocaRiga], [Valori_Di_Esclusione_Parametro], [SezioniCondizionate], [ElencoValori])
			
				SELECT @IdNewQuestionario, [KeyRiga], [TipoRigaQuestionario], [Descrizione], [DescrizioneEstesa], [TipoParametroQuestionario], [Tech_Info_Parametro]
					   , [EsitoRiga], [EsitoRiga_Parametro], [ChiaveUnivocaRiga], [Valori_Di_Esclusione_Parametro], [SezioniCondizionate], [ElencoValori]
				FROM Document_Questionario_Amministrativo
				WHERE idHeader=@IdQuestionario


			--genero i domini legati al questionario copiato
			exec  MAKE_DOMINI_QUESTIONARIO_AMMINISTRATIVO @IdNewQuestionario

			--genero i modelli legati al questionario copiato
			exec MAKE_MODULO_QUESTIONARIO_AMMINISTRATIVO @IdNewQuestionario

		END

  END

END

GO
