USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[E_FORMS_CN16_DATI_LOTTI]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE [dbo].[E_FORMS_CN16_DATI_LOTTI] ( @idProc int , @idUser int = 0, @extraParams nvarchar(4000) = '', @lotti varchar(1000) = '')
AS
BEGIN

	SET NOCOUNT ON

	-- QUESTA STORED RECUPERA E GESTISCE TUTTI I LOTTI DELLA GARA, MENO I REVOCATI

	-- AGGIUNTA PER A1_29 NON_AGGIUDICAZIONE:  SE PASSIAMO IL PARAMETRO INCLUDI_REVOCATI RECUPERA ANCHE I REVOCATI

	-----------------------------
	-- DICHIARAZIONE VARIBILI ---
	-----------------------------
	DECLARE @idAziEnte INT
	DECLARE @tipoDoc varchar(100)
	DECLARE @Divisione_lotti varchar(10)
	DECLARE @TipoAppaltoGara varchar(10)
	DECLARE @Classprincipale varchar(100) = ''
	DECLARE @codExtCPV varchar(100) = ''
	DECLARE @CriterioAggiudicazioneGara varchar(100) = ''
	DECLARE @pg varchar(100) = ''
	DECLARE @dataTermineQuesiti datetime
	DECLARE @Acquisto_Sociale varchar(10)
	DECLARE @tipoSceltaContr varchar(100) = ''

	--BT-24-Lot
	DECLARE @descrizioneLotto nvarchar(4000) = ''

	--BT-131 - Termine per il ricevimento delle offerte
		--<cbc:EndDate>2023-09-29+02:00</cbc:EndDate>
		--<cbc:EndTime>12:00:00+02:00</cbc:EndTime>
	DECLARE @DataScadenzaOfferta datetime
	DECLARE @xmlDataScadenzaOfferta nvarchar(1000) = ''

	--BT-13 Additional Information Deadline
	DECLARE @quesiti_endDateStr VARCHAR(50)
	DECLARE @quesiti_endTimeStr VARCHAR(50)

	--È coinvolto un sistema dinamico di acquisizione (BT-766-Lot) 
	DECLARE @coinvoltoSDA varchar(100) = ''

	--BT-747-Lot
	DECLARE @criterioSelezione varchar(1000) = ''

	--BT-23
	DECLARE @naturaAppalto varchar(100) = ''

	--BT-18-Lot
	DECLARE @indirizzoPresentazione nvarchar(1000) = ''

	DECLARE @Appalto_Verde varchar(100) = ''

	DECLARE @punteggioEcoGara varchar(100) = ''
	DECLARE @punteggioTecGara varchar(100) = ''

	DECLARE @enteOrgID varchar(1000) = 'ORG-0001'
	DECLARE @orgRicorsoID varchar(1000) = 'ORG-0002'

	DECLARE @importoBaseAsta float

	DECLARE @concessione varchar(10)
	DECLARE @COD_LUOGO_ISTAT varchar(50) = ''
	DECLARE @tipoScheda varchar(20)

	-- BT-5071 +  BT-5141
	DECLARE @xmlRealizedLocation varchar(1000) = '' 

	DECLARE @ContractingType varchar (20) = ''

	--BT-539 ( Tipo criterio di aggiudicazione )
	--DECLARE @tipoCriterioAggiudicazione varchar(100) = ''
	--DECLARE @descTipoCriterioAggiudicazione nvarchar(1000) = ''

	--------------------
	-- RECUPERO DATI ---
	--------------------

	SELECT  @idAziEnte = azienda,
			@tipoDoc = TipoDoc
		FROM ctl_doc gara with(nolock) 
		WHERE id = @idProc

	SELECT	  @Divisione_lotti = Divisione_lotti
			, @DataScadenzaOfferta = DataScadenzaOfferta
			, @TipoAppaltoGara = TipoAppaltoGara
			, @CriterioAggiudicazioneGara = CriterioAggiudicazioneGara
			, @pg = ProceduraGara
			, @Appalto_Verde = Appalto_Verde
			, @dataTermineQuesiti = DataTermineQuesiti
			, @Acquisto_Sociale = Acquisto_Sociale
			, @importoBaseAsta = ImportoBaseAsta -- a video è "Importo Appalto €"
			, @concessione = Concessione
			, @tipoSceltaContr = TipoSceltaContraente
			, @tipoScheda = pcp_TipoScheda
			, @ContractingType = isnull(ContractingType,'none')
		FROM document_bando B WITH (NOLOCK)
			left join Document_pcp_Appalto A with(nolock) on B.idheader = A.idheader
		WHERE B.idheader = @idProc

	-- recupero e gestione dati geo
	select @COD_LUOGO_ISTAT = [Value]
		from ctl_doc_value  with(nolock) 
		where idheader = @idProc and dse_id = 'InfoTec_SIMOG' and dzt_name = 'COD_LUOGO_ISTAT' 
					
	IF @COD_LUOGO_ISTAT <> '' 
	BEGIN

		declare @codiceNUTS varchar(100) = ''

		select @codiceNUTS = case when geo.DMV_Level = 6 then dbo.GetColumnValue( @COD_LUOGO_ISTAT,'-', 7)	-- se si è scelto una provincia prendo il suo codice NUTS
								  when geo.DMV_Level = 5 then dbo.GetColumnValue( @COD_LUOGO_ISTAT,'-', 6)	-- se si è scelta una regione prendo il suo codice NUTS
							 else '' end
			from LIB_DomainValues geo with(nolock)
			where geo.DMV_DM_ID = 'GEO' and geo.DMV_Cod = @COD_LUOGO_ISTAT

		IF @codiceNUTS <> ''
		BEGIN

			set @xmlRealizedLocation = '
			<cac:RealizedLocation>
				<cac:Address>
				   <!-- BT-5071 - Place Performance Country Subdivision -->
				   <cbc:CountrySubentityCode listName="nuts">' + @codiceNUTS + '</cbc:CountrySubentityCode>
				   <cac:Country>
				      <!-- BT-5141 - Place Performance Country Code -->
					  <cbc:IdentificationCode listName="country">ITA</cbc:IdentificationCode>
				   </cac:Country>
				</cac:Address>
			 </cac:RealizedLocation>
			'

		END

	END

	-- left join LIB_DomainValues geo		with(nolock) on geo.DMV_DM_ID = 'GEO' and geo.DMV_Cod = lot.LUOGO_ISTAT
	--case when geo.DMV_Level = 6 then dbo.GetColumnValue( lot.LUOGO_ISTAT,'-', 7)	-- se si è scelto una provincia prendo il suo codice NUTS
	--				 when geo.DMV_Level = 5 then dbo.GetColumnValue( lot.LUOGO_ISTAT,'-', 6)	-- se si è scelta una regione prendo il suo codice NUTS
	--				 else '' 
	--			end as CODICE_NUTS

	-- fine gestione dati geo

	select @punteggioEcoGara = [value] from CTL_DOC_VALUE v1 WITH(NOLOCK) where v1.idheader = @idProc and v1.DSE_ID = 'CRITERI_ECO' and  v1.DZT_Name = 'PunteggioEconomico'
	select @punteggioTecGara = [value] from CTL_DOC_VALUE v1 WITH(NOLOCK) where v1.idheader = @idProc and v1.DSE_ID = 'CRITERI_ECO' and  v1.DZT_Name = 'PunteggioTecnico'

	IF @tipoDoc = 'BANDO_SEMPLIFICATO'
		set @coinvoltoSDA = 'dps-nlist'
	else
		set @coinvoltoSDA = 'none'

	SELECT b.id as idProc, d.id, numerolotto, descrizione, CODICE_CPV, cvl.PunteggioEconomico, cvl.PunteggioTecnico, 
				case when @divisione_lotti = '0' then @importoBaseAsta 
												 else d.ValoreImportoLotto + ISNULL(d.IMPORTO_ATTUAZIONE_SICUREZZA,0) + ISNULL(d.IMPORTO_OPZIONI,0) + ISNULL(d.pcp_UlterioriSommeNoRibasso,0) + ISNULL(d.pcp_SommeRipetizioni,0) + ISNULL(d.pcp_SommeOpzioniRinnovi,0)
				end as ImportoLotto
			INTO #lotti_cn16
			FROM ctl_doc b WITH(NOLOCK) 
					inner join Document_MicroLotti_Dettagli d WITH(NOLOCK) on d.IdHeader = b.id and b.TipoDoc = d.TipoDoc and d.voce = 0 
					--per recuperare le specializzazioni per lotto
					LEFT JOIN  View_Criteri_Valutazione_Lotto CVL with (nolock) on CVL.idheader = d.id
			WHERE b.id = @idProc 
				and (d.StatoRiga <> 'Revocato' OR @extraParams = 'INCLUDI_REVOCATI')


	IF @lotti <> '' --se non si sta filtrando per numero lotto ( giro can-29 ad esempio )
	BEGIN
		DELETE FROM #lotti_cn16 where NumeroLotto not in ( select items from dbo.Split(@lotti,',') )
	END
	
	select @indirizzoPresentazione = a.DZT_ValueDef
		from LIB_Dictionary a with(nolock)
		where a.DZT_Name = 'SYS_SITOPORTALE'

	-- se l'indirizzo presente nella SYS non inizia per http o http ( problemi di configurazione sys )
	IF left(@indirizzoPresentazione,7) <> 'http://' and left(@indirizzoPresentazione,8) <> 'https://'
	BEGIN
		set @indirizzoPresentazione = 'https://' + isnull(@indirizzoPresentazione,'')
	END

	-- Calcola l'offset per CEST (Central European Summer Time)
	--DECLARE @DataIngressoOffset INT = -120
	-- Applica l'offset di orario alla data scadenza offerte
	--DECLARE @DataConFusoOrarioItaliano DATETIME
	--set @DataConFusoOrarioItaliano = DATEADD(MINUTE, @DataIngressoOffset, @DataScadenzaOfferta)

	DECLARE @endDateStr VARCHAR(50) = dbo.eFroms_GetStrDateOrTimeUTCfromITA(@DataScadenzaOfferta,0)  --CONVERT(VARCHAR(10), @DataConFusoOrarioItaliano, 121) + '+02:00'
	DECLARE @endTimeStr VARCHAR(50) =  dbo.eFroms_GetStrDateOrTimeUTCfromITA(@DataScadenzaOfferta,1) --CONVERT(VARCHAR(8), @DataConFusoOrarioItaliano, 108) + '+02:00'

	-- per la procedura ristretta si devono popolare i dati di scadenza delle domande di partecipazione e RIMUOVERE quelli di scadenza delle offerte
	IF ( @pg = '15477' )  -- restricted	/ Ristretta	/ ProceduraGara : 15477
	BEGIN

		set @xmlDataScadenzaOfferta = '
		<!-- BT-1311 - Termine per il ricevimento delle domande di partecipazione -->
		<cac:ParticipationRequestReceptionPeriod>
		    <cbc:EndDate>' + @endDateStr + '</cbc:EndDate>
            <cbc:EndTime>' + @endTimeStr + '</cbc:EndTime>
         </cac:ParticipationRequestReceptionPeriod>'
		
	END
	ELSE
	BEGIN

		set @xmlDataScadenzaOfferta = '
		<!-- BT-131 - Termine per il ricevimento delle offerte -->
		<cac:TenderSubmissionDeadlinePeriod>
		    <cbc:EndDate>' + @endDateStr + '</cbc:EndDate>
            <cbc:EndTime>' + @endTimeStr + '</cbc:EndTime>
         </cac:TenderSubmissionDeadlinePeriod>'

	END

	DECLARE @idDgue INT = 0

	select @idDgue = id from CTL_DOC with(nolock) where linkeddoc= @idProc and TipoDoc='TEMPLATE_CONTEST' and JumpCheck='DGUE_MANDATARIA' and Deleted=0

	SELECT row, value INTO #key_riga FROM CTL_DOC_Value with(nolock) where IdHeader = @idDgue and DSE_ID='VALORI' and DZT_Name='KeyRiga'
	SELECT row, value INTO #sel_row FROM CTL_DOC_Value with(nolock) where IdHeader = @idDgue and DSE_ID='VALORI' and DZT_Name='SelRow'
	SELECT * INTO #interop FROM Document_E_FORM_CONTRACT_NOTICE with(nolock) where IdHeader = @idProc 

	IF EXISTS ( select a.Row 
					from #key_riga a
							inner join #sel_row b on b.Row = a.Row and b.Value = '1'
					where a.value IN ( 'E.1' )
			)
	BEGIN
		--sui-act / Abilitazione all'esercizio dell'attività professionale
		set @criterioSelezione = 'sui-act'
	END

	IF EXISTS ( select a.Row 
					from #key_riga a
							inner join #sel_row b on b.Row = a.Row and b.Value = '1'
					where a.value IN ( 'E.2' )
			)
	BEGIN
		--ef-stand / Capacità economica e finanziaria
		set @criterioSelezione = @criterioSelezione + '###ef-stand'
	END

	IF EXISTS ( select a.Row 
					from #key_riga a
							inner join #sel_row b on b.Row = a.Row and b.Value = '1'
					where a.value IN ( 'E.3' )
			)
	BEGIN
		--tp-abil / Capacità tecniche e professionali
		set @criterioSelezione = @criterioSelezione + '###tp-abil'
	END

	IF EXISTS ( select a.Row 
					from #key_riga a
							inner join #sel_row b on b.Row = a.Row and b.Value = '1'
					where a.value IN ( 'E.4' )
			)
	BEGIN
		--other / Altro
		set @criterioSelezione = @criterioSelezione + '###other'
	END

	-----------------------------------------------------
	-- DESUMIAMO IL CAMPO "BT-23 - Natura dell'appalto" -
	-----------------------------------------------------
	IF @TipoAppaltoGara = '1'
	BEGIN
		--supplies - Forniture ( dmv_cod 1 )
		SET @naturaAppalto = 'supplies'
	END
	ELSE IF @TipoAppaltoGara = '2'
	BEGIN
		--works - Lavori ( dmv_cod 2 )
		SET @naturaAppalto = 'works'
	END
	ELSE IF @TipoAppaltoGara = '3'
	BEGIN
		--services - Servizi ( dmv_cod 3 )
		SET @naturaAppalto = 'services'
	END

	select @Classprincipale = [Value] from ctl_doc_value with(nolock) where idheader = @idProc and dse_id = 'InfoTec_SIMOG' and dzt_name = 'CODICE_CPV' 

	select @codExtCPV = cpv.DMV_CodExt from LIB_DomainValues cpv with(nolock) where cpv.DMV_DM_ID = 'CODICE_CPV' and cpv.DMV_Deleted = 0 and cpv.DMV_Cod = @Classprincipale

	set @Classprincipale = dbo.GetPos(@codExtCPV,'-',1)

	-------------
	-- OUTPUT ---
	-------------
	SELECT  NumeroLotto AS LOTTO_NUMERO,   --BT-22-Lot
			Descrizione AS LOTTO_DESC,     --BT-24-Lot
			@coinvoltoSDA AS LOTTO_SDA,    --BT-766-Lot

			-- non usiamo più i singoli campi data, ma passiamo l'intera porzione di XML per gestire la variabiltà sul giro di ristretta. per passare la data di fine presentazione domande di partecipazione
			@endDateStr AS LOTTO_END_DATE, --BT-131
			@endTimeStr AS LOTTO_END_TIME,  --BT-131

			dbo.eFroms_GetStrDateOrTimeUTCfromITA(@dataTermineQuesiti, 0) as LOTTO_TERMINE_QUESITI_DATE,
			dbo.eFroms_GetStrDateOrTimeUTCfromITA(@dataTermineQuesiti, 1) as LOTTO_TERMINE_QUESITI_TIME,

			@xmlDataScadenzaOfferta AS LOTTO_NO_ENCODE_TERMINI,

			@criterioSelezione AS LOTTO_CRITERI, --BT-747-Lot
			--'LOT-' + RIGHT('0000' + CAST( ROW_NUMBER() OVER(ORDER BY a.id ASC) AS NVARCHAR(4)), 4) AS LOTTO_ID,
			dbo.eFroms_GetIdentifier('Lot', NumeroLotto,'') AS LOTTO_ID,

			case when b.cn16_FundingProgramCode_eu_funded = 'true' then 'eu-funds' else 'no-eu-funds' end as LOTTO_FONDI_EU,
			case when b.cn16_CallForTendersDocumentReference_DocumentType = 'true' then 'restricted-document' else 'non-restricted-document' end as LOTTO_RESTRICTED_DOCUMENT,
			b.cn16_CallForTendersDocumentReference_ExternalRef as LOTTO_EXTERNAL_REFERENCE_URI,
			b.cn16_TendererRequirementTypeCode_reserved_proc as LOTTO_TENDERER_REQUIREMENT_TYPECODE,

			--b.cn16_AuctionConstraintIndicator AS AUCTION_CONSTRAINT_INDICATOR,
			case when isnull(b.cn16_AuctionConstraintIndicator,'') = '' then 'false' else b.cn16_AuctionConstraintIndicator end AS AUCTION_CONSTRAINT_INDICATOR,

			case when b.cn16_ExecutionRequirementCode_reserved_execution = 'true' then 'yes' else 'no' end as LOTTO_RESERVED_EXECUTION,

			case when b.cn16_ContractingSystemTypeCode_framework = 'true' then 'fa-w-rc' else 'none' end AS LOTTO_CONTRACTING_SYSTEM_TYPECODE_FRAMEWORK,
			case when @tipoDoc = 'BANDO_SEMPLIFICATO' then 'dps-nlist' else 'none' end as LOTTO_CONTRACTING_SYSTEM_DPS_USAGE,

			@naturaAppalto as LOTTO_PROCUREMENT_TYPE_CODE,

			case when isnull(a.CODICE_CPV,'') = '' then @Classprincipale else dbo.GetPos(cpv.DMV_CodExt,'-',1)  end as LOTTO_ITEM_CLASSIFICATIONCODE,

			@enteOrgID as LOTTO_ENTE_ID,
			case when isnull(@indirizzoPresentazione,'') <> '' then @indirizzoPresentazione else b.cn16_CallForTendersDocumentReference_ExternalRef end as LOTTO_INDIRIZZO_PRESENTAZIONE,

			CASE isnull( CAL.CriterioAggiudicazioneGara , @CriterioAggiudicazioneGara ) 
				WHEN '15531' then 'price'
				WHEN '16291' then 'price'
				WHEN '15532' then 'quality'
				WHEN '25532' then 'cost'
			END AS LOTTO_CRITERIO_AGGIUD_COD,

			CASE isnull( CAL.CriterioAggiudicazioneGara , @CriterioAggiudicazioneGara ) 
				WHEN '15531' then 'Prezzo'
				WHEN '16291' then 'Prezzo'				
				WHEN '15532' then 'Offerta economicamente più vantaggiosa'
				WHEN '25532' then 'Costo fisso'
			END AS LOTTO_CRITERIO_AGGIUD_DESC,

			-- dati aggiunti per l'avviso di aggiudcazione
			'Punteggio Economico: ' + isnull(a.PunteggioEconomico, @punteggioEcoGara)
					+ case when @punteggioTecGara <> '' then ' - Punteggio Tecnico: ' + isnull(a.PunteggioTecnico, @punteggioTecGara) else '' end
				AS LOTTO_CALCULATION_EXPRESSION, --"Punteggio Economico: XX - Punteggio Tecnico: YY"  (da recuperare nei criteri di valutazione della gara considerando anche eventuale specializzazione dei lotti

			@orgRicorsoID as LOTTO_ORG_RICORSO_ID,

			case when @Appalto_Verde = 'si' then 'national' else 'none' end as LOTTO_PROCUREMENT_GGP_CRITERIA,

			-- se sono stati inseriti uno dei 2 dati chiave per i fondi UE aggiungiamo il blocco xml "Funding"
			case when b.cn16_Funding_FinancingIdentifier <> '' or b.cn16_FundingProgramCode <> '' then '
				<efac:Funding>
				' + case when b.cn16_Funding_FinancingIdentifier <> '' then '
					<!-- BT-5010-Lot - Identificativo dei fondi UE -->
					<efbc:FinancingIdentifier>' + dbo.HTML_Encode(b.cn16_Funding_FinancingIdentifier) + '</efbc:FinancingIdentifier>' else '' end 
				  + case when b.cn16_FundingProgramCode <> '' then '
					<!-- BT-7220-Lot -->
					<cbc:FundingProgramCode listName="eu-programme">' + dbo.HTML_Encode(b.cn16_FundingProgramCode) + '</cbc:FundingProgramCode>
					<!-- BT-6140-Lot -->
					<cbc:Description languageID="ITA">' + dbo.HTML_Encode(b.cn16_FundingProgram_Description) + '</cbc:Description>' else '' end + '
				</efac:Funding>' else '' end AS LOTTO_NO_ENCODE_ID_FONDI_UE,

			case when @Acquisto_Sociale = 'si' then '
			<!-- BT-775 - Social procurement -->
			<cac:ProcurementAdditionalType>
				<cbc:ProcurementTypeCode listName="social-objective">other</cbc:ProcurementTypeCode>
			</cac:ProcurementAdditionalType>' else '' end as LOTTO_NO_ENCODE_PROCUREMENT_SOCIAL_OBJECTIVE,

			ltrim( str( a.ImportoLotto , 25 , 2 ) ) as LOTTO_IMPORTO_BASE_ASTA, --BT-27 (Estimated Value), considera l'importo Lotto compresivo di sicurezza e opzioni.

			case when @concessione = 'si' then '' else '
			<cac:ContractExecutionRequirement>
				<!-- BT-764 - costante -->
				<cbc:ExecutionRequirementCode listName="ecatalog-submission">required</cbc:ExecutionRequirementCode>
			</cac:ContractExecutionRequirement>' end as LOTTO_NO_ENCODE_BT_764,
			
			case when @tipoScheda = 'P1_19' then ''
			else '<cac:ContractingSystem>
					<!-- (BT-765-Lot) - è una procedura negoziata all''interno di un accordo quadro -->
					<cbc:ContractingSystemTypeCode listName="framework-agreement">' + case when @ContractingType = '' then 'none' else @ContractingType end  + '</cbc:ContractingSystemTypeCode>
				</cac:ContractingSystem>
				<cac:ContractingSystem>
					<!-- BT-766-Lot - è coinvolto un sistema dinamico di acquisizione -->
					<cbc:ContractingSystemTypeCode listName="dps-usage">' + case when @tipoDoc = 'BANDO_SEMPLIFICATO' then 'dps-nlist' else 'none' end  + '</cbc:ContractingSystemTypeCode>
				</cac:ContractingSystem>' 
			end
			as LOTTO_NO_ENCODE_CONTRACTING_SYSTEM,

			--case when @concessione = 'si' then 'false' else 'true' end  AS LOTTO_TENDERINGPROCESS_BT_115,
			'false' AS LOTTO_TENDERINGPROCESS_BT_115,

			case when @tipoScheda <> 'P1_20' then '
					<!-- BT-115 -->
					<cbc:GovernmentAgreementConstraintIndicator>false</cbc:GovernmentAgreementConstraintIndicator>' 
				else ''
			end as LOTTO_NO_ENCODE_TENDERINGPROCESS_BT_115,

			case when @concessione = 'si' then '
			<!-- OPT-301 -->
			<cac:AdditionalInformationParty>
				<cac:PartyIdentification>
				   <cbc:ID>' + @enteOrgID + '</cbc:ID>
				</cac:PartyIdentification>
			 </cac:AdditionalInformationParty>
			' else '' end  AS LOTTO_NO_ENCODE_OPT_301_ADDITIONALIN_FORMATION_PARTY,

			case when @tipoSceltaContr = 'ACCORDOQUADRO' then '
			 <ext:UBLExtensions>
				<ext:UBLExtension>
				   <ext:ExtensionContent>
					  <efext:EformsExtension>
						 <!-- BT-271 - Framework Maximum Value -->
						 <efbc:FrameworkMaximumAmount currencyID="EUR">' + ltrim( str( a.ImportoLotto , 25 , 2 ) ) + '</efbc:FrameworkMaximumAmount>
					  </efext:EformsExtension>
				   </ext:ExtensionContent>
				</ext:UBLExtension>
			 </ext:UBLExtensions>' else '' end  AS LOTTO_NO_ENCODE_FRAMEWORK_MAXIMUM_VALUE,

			 @xmlRealizedLocation as LOTTO_NO_ENCODE_REALIZED_LOCATION,

			 case when @tiposcheda <> 'P1_20' then '
					<cbc:GovernmentAgreementConstraintIndicator>false</cbc:GovernmentAgreementConstraintIndicator>'
				else ''
			 end as LOTTO_NO_ENCODE_GOVERNMENT_AGREEMENT_CONSTRAINT_INDICATOR

		FROM #lotti_cn16 a
				INNER JOIN #interop b on b.idHeader = a.idProc
				LEFT JOIN View_Criteri_Aggiudicazione_Lotto CAL on CAL.idheader = a.id --recuperiamo un eventuale specializzazione di aggiudicazione lotto per lotto
				LEFT JOIN LIB_DomainValues cpv with(nolock) on cpv.DMV_DM_ID = 'CODICE_CPV' and cpv.DMV_Deleted = 0 and cpv.DMV_Cod = a.CODICE_CPV
		ORDER BY a.id

	DROP TABLE #lotti_cn16
	DROP TABLE #key_riga
	DROP TABLE #sel_row
	DROP TABLE #interop

END
GO
