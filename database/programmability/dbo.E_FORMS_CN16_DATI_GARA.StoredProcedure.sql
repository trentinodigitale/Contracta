USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[E_FORMS_CN16_DATI_GARA]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[E_FORMS_CN16_DATI_GARA] ( 
				@idProc int , 
				@idUser int = 0, 
				@extraParams nvarchar(4000) = '', 
				@guidOperation varchar(500) = '',
				@idDocContrConv int = 0,
				@uuidFles varchar(100) = '')
AS
BEGIN

SET NOCOUNT ON

	-----------------------------
	-- DICHIARAZIONE VARIBILI ---
	-----------------------------
	DECLARE @idAziEnte INT
	DECLARE @tb VARCHAR(50) --ProceduraGara
	DECLARE @pg VARCHAR(50) --TipoBandoGara
	DECLARE @tipoDoc varchar(100)
	DECLARE @TipoProceduraCaratteristica varchar(100)
	DECLARE @Divisione_lotti varchar(10)
	DECLARE @TipoAppaltoGara varchar(10)
	DECLARE @concessione varchar(10)
	DECLARE @RegulatoryDomain varchar(10) --BT-01-notice - Base giuridica della procedura
	DECLARE @codExtCPV varchar(100) = ''
	DECLARE @importoBaseAsta float
	DECLARE @tipoSceltaContr varchar(100) = ''
	DECLARE @W3PROCEDUR varchar(10) = ''
	DECLARE @aziSitoWeb nvarchar(1000) = ''
	DECLARE @idTemplateContest INT = 0
	DECLARE @idTemplateRequest INT = 0
	DECLARE @IdentificativoIniziativa varchar(100) = ''
	DECLARE @ContractingType as varchar(100) = ''

	--CAMPI SPECIFICI CAN38/40 - flusso esecuzione
	DECLARE @ContractModification varchar(4000) = ''
	DECLARE @PublicationID varchar(100) = '' 
	DECLARE @CAN_FLES_ChangeDescription varchar(1000) = ''
	DECLARE @CAN_FLES_chReasonCode varchar(100) = ''
	DECLARE @CAN_FLES_chReasonDesc varchar(1000) = ''
	DECLARE @CAN_FLES_IMPORTO_LAVORI DECIMAL(18,2) = 0
	DECLARE @CAN_FLES_IMPORTO_SERVIZI DECIMAL(18,2) = 0
	DECLARE @CAN_FLES_IMPORTO_FORNITURE DECIMAL(18,2) = 0
	DECLARE @CAN_FLES_IMPORTO_TOTALE_SICUREZZA DECIMAL(18,2) = 0
	DECLARE @CAN_FLES_ULTERIORI_SOMME_NO_RIBASSO DECIMAL(18,2) = 0
	DECLARE @CAN_FLES_SOMME_A_DISPOSIZIONE DECIMAL(18,2) = 0
	DECLARE @CAN_FLES_SOMME_OPZIONI_RINNOVI DECIMAL(18,2) = 0

	--BT-105
	DECLARE @tipoProcedura varchar(100) = 'oth-single' -- default
	--BT-21
	DECLARE @titoloProcedura nvarchar(400) = ''
	--BT-24
	DECLARE @descrProc nvarchar(4000) = ''
	--BT-23
	DECLARE @naturaAppalto varchar(100) = ''
	--BT-262
	DECLARE @Classprincipale varchar(100) = ''
	--BT-01-notice
	DECLARE @baseGiuridica varchar(100) = ''
	--BT-04 - Procedure Identifier ( UID generato dalla piattaforma ) - Codice Appalto
	DECLARE @CONTRACT_FOLDER_ID nvarchar(500) = ''
	DECLARE @cn16_ProcessJustification_ProcessReason nvarchar(4000)

	DECLARE @MaximumLotsAwardedNumeric varchar(100) = '' -- BT-33 (Lots Max Awarded) 
	DECLARE @MaximumLotsSubmittedNumeric varchar(100) = '' -- BT-31 (Lots Max Allowed).

	--BT-22 (Internal Identifier)
	DECLARE @projectInternalId nvarchar(1000) = '' 

	declare @LinkedDoc as int
	declare @idPda INT
	declare @tipoScheda varchar(20)
	DECLARE @tipoCAN varchar(20) = ''
	declare @tipoCN varchar(20)
	declare @body nvarchar(max) = ''

	set @LinkedDoc=0

	--------------------
	-- RECUPERO DATI ---
	--------------------

	-- recuperiamo il valore della colonna 'CN16_CODICE_APPALTO'. se vuota, generiamo un nuovo UID e lo associamo, altrimenti lasciamo quello
	SELECT @CONTRACT_FOLDER_ID = CN16_CODICE_APPALTO,
		   @cn16_ProcessJustification_ProcessReason = cn16_ProcessJustification_ProcessReason
		FROM Document_E_FORM_CONTRACT_NOTICE with(nolock) 
		where idHeader = @idProc

	-- IN ASSENZA DEL CODICE APPALTO LO ANDIAMO A GENERARE ASSOCIANDOLO ALLA GARA
	IF isnull(@CONTRACT_FOLDER_ID,'') = ''
	BEGIN

		SET @CONTRACT_FOLDER_ID = lower(newid())

		update Document_E_FORM_CONTRACT_NOTICE
				set CN16_CODICE_APPALTO = lower(@CONTRACT_FOLDER_ID)
			where idHeader = @idProc

	END

	-- Se proveniamo da una generazione di change notice allora dobbiamo cambiare il valore dei tag '<cbc:ID schemeName="notice-id">'
	--		e <cbc:ContractFolderID>. NON devono avere lo stesso valore del Contract Notice, quindi lo generiamo a runtime
	IF @extraParams like '%OPERATION=CHANGE_NOTICE%'
	BEGIN
		SET @CONTRACT_FOLDER_ID = lower(newid())
	END

	declare @statoFunzionaleGara varchar(100) = ''

	SELECT  @idAziEnte = azienda,
			@tipoDoc = TipoDoc,
			@titoloProcedura = left(titolo,200),
			@descrProc = left(body, 2000),
			@statoFunzionaleGara = StatoFunzionale,
			@LinkedDoc=ISNULL(LinkedDoc,0),
			@Body = Body
		FROM ctl_doc gara with(nolock) 
		WHERE id = @idProc

	select @idPda = id
		from ctl_doc with(nolock) 
		where LinkedDoc = @idProc and tipodoc = 'PDA_MICROLOTTI' and deleted = 0

	declare @numOfferte INT = 0

	SELECT	  @pg = ProceduraGara
			, @tb = TipoBandoGara
			, @TipoProceduraCaratteristica = TipoProceduraCaratteristica
			, @Divisione_lotti = Divisione_lotti
			, @TipoAppaltoGara = TipoAppaltoGara
			, @concessione = Concessione
			, @importoBaseAsta = ImportoBaseAsta -- "Importo Appalto €", campo dove ci finisce già la somma degli altri importi
			, @tipoSceltaContr = TipoSceltaContraente
			, @W3PROCEDUR = isnull(W3PROCEDUR,'')
			, @numOfferte = isnull(RecivedIstanze,0)
			, @IdentificativoIniziativa = isnull(IdentificativoIniziativa,'')
			, @tipoScheda = pcp_TipoScheda
			, @tipoCAN = CAN.REL_ValueOutput
			, @tipoCN = CN.REL_ValueOutput
			, @ContractingType = isnull(ContractingType,'')
		FROM document_bando B WITH (NOLOCK)
			left join Document_PCP_Appalto A with(nolock) on B.idHeader = A.idHeader
			left join CTL_Relations CAN on CAN.REL_Type = 'PCP_SCHEDA_E_FORM_CAN' and CAN.REL_ValueInput = pcp_TipoScheda
			left join CTL_Relations CN on CN.REL_Type = 'PCP_SCHEDA_E_FORM_CN' and CN.REL_ValueInput = pcp_TipoScheda
		WHERE B.idheader = @idProc

	select @idTemplateContest = id 
		from ctl_doc with(nolock) 
		where linkeddoc  = @idProc and tipodoc='TEMPLATE_CONTEST' and jumpcheck='DGUE_MANDATARIA' and Deleted = 0

	select @idTemplateRequest = id 
		from ctl_doc with(nolock) 
		where linkeddoc = @idTemplateContest and tipodoc = 'MODULO_TEMPLATE_REQUEST' and JumpCheck = 'DGUE_MANDATARIA' and Deleted = 0

	-- EVO futura : prende i dzt_name del dgue da una relazione
	select @MaximumLotsAwardedNumeric = [value] 
		from ctl_doc_Value with(nolock) 
		where idheader=@idTemplateRequest and dzt_name in ('MOD_B_3_2_FLD_T1_M3') and dse_id='MODULO'

	select @MaximumLotsSubmittedNumeric = [value] 
		from ctl_doc_Value with(nolock) 
		where idheader=@idTemplateRequest and dzt_name in ('MOD_B_3_2_FLD_T1_M2') and dse_id='MODULO'

	-- inizio gestione dell'identificativo dell'iniziativa
	IF @IdentificativoIniziativa <> '' and @IdentificativoIniziativa <> '9999'
	BEGIN

		IF @IdentificativoIniziativa = 'I0000' 
		BEGIN
			set @projectInternalId = 'I0000– Iniziativa Generica'
		END
		ELSE
		BEGIN

			SELECT top 1 @projectInternalId = CAST(
						CAST(
						case 
						  when charindex('-',NumeroDocumento) = 0 then NumeroDocumento
						  else left(NumeroDocumento , charindex('-',NumeroDocumento)-1) 
						end  as bigint)  as varchar(100)
						) + ' - ' + isnull( cast( Body as nvarchar(max)) , Titolo ) -- AS DMV_DescML 
				FROM ctl_doc C with(nolock)
				WHERE StatoDoc = 'Sended' and TipoDoc = 'INIZIATIVA' 
						and StatoFunzionale<>'Variato'
						and NumeroDocumento = @IdentificativoIniziativa

			-- se il cliente non ha utilizzato il codice 9999 come "altri..." aggiungiamo questo IF di controllo per impedire
			--	il passaggio dell'iniziativa come "altri enti"
			IF @projectInternalId like '%ALTRI ENTI%'
			BEGIN
				set @projectInternalId = ''
			END
	
		END

		IF @projectInternalId <> ''
			set @projectInternalId = '<cbc:ID>' + dbo.HTML_Encode(@projectInternalId) + '</cbc:ID>'

	END
	-- fine gestione identificativo iniziativa


	select @Classprincipale = [Value] from ctl_doc_value  with(nolock) where idheader = @idProc and dse_id = 'InfoTec_SIMOG' and dzt_name = 'CODICE_CPV' 
	select @codExtCPV = cpv.DMV_CodExt from LIB_DomainValues cpv with(nolock) where cpv.DMV_DM_ID = 'CODICE_CPV' and cpv.DMV_Deleted = 0 and cpv.DMV_Cod = @Classprincipale

	set @Classprincipale = dbo.GetPos(@codExtCPV,'-',1)

	----------------------------------------------------
	-- DESUMIAMO IL CAMPO "BT-105 - Tipo di procedura" -
	----------------------------------------------------
	IF @tipoDoc = 'BANDO_SEMPLIFICATO' --oth-mult	/	Altra procedura a più fasi /	Appalto Specifico
	BEGIN
		SET @tipoProcedura = 'oth-mult'
	END
	ELSE IF @pg = '15476' --open /	Aperta /	ProceduraGara = Aperta ( cod 15476 )
	BEGIN
		SET @tipoProcedura = 'open'
	END
	ELSE IF ( @pg = '15477' )  --restricted	/ Ristretta	/	ProceduraGara : 15477
	BEGIN
		SET @tipoProcedura = 'restricted'
	END
	ELSE IF ( @pg = '15478' and @tb = '1' ) --neg-w-call /	Negoziata con previa indizione di gara / competitiva con negoziazione	/	Invito con avviso - cioè Avviso - Negoziata 
	BEGIN
		SET @tipoProcedura = 'neg-w-call'
	END
	ELSE IF ( @pg = '15478' and @tb <> '1' ) --neg-wo-call	/	Negoziata senza previa indizione di gara	/	Invito senza avviso - negoziata senza avviso
	BEGIN
		SET @tipoProcedura = 'neg-wo-call'
	END
	ELSE --oth-single	/	Altra procedura a fase unica /	Tutti gli altri casi
	BEGIN 
		SET @tipoProcedura = 'oth-single'
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

	declare @dtNOW_UTC datetime =  GETUTCDATE()
	declare @dtNOW_ITA datetime =  getDate()

	declare @IssueDate varchar(100) =  CONVERT(VARCHAR(10), @dtNOW_UTC, 121) + 'Z'
	declare @IssueTime varchar(100) =  CONVERT(VARCHAR(8), @dtNOW_UTC, 108) + 'Z'

	--Se il campo di testata "Concessione" vale 'si' questo tag prenderà il valore '32014L0023' ( Direttiva 2014/23/UE )
	--		else 32014L0024 ( Direttiva 2014/24/UE )
	set @RegulatoryDomain = '32014L0024'
	IF @concessione = 'si'
	BEGIN
		set @RegulatoryDomain = '32014L0023'
	END

	declare @orgID varchar(100) = 'ORG-0001'
	declare @formaGiuridicaEnte varchar(500)
	declare @attivitaAmmEnte varchar(500)

	-- recuperiamo in modo puntuale i dati dell'ente che ha indetto la gara, per inserirli nella parte xml di gara
	select  @orgID = a.PartyIdentification,
			@formaGiuridicaEnte = a.formaGiuridica,
			@attivitaAmmEnte = a.attivitaAmm,
			@aziSitoWeb = a.BuyerProfileURI
		from Document_E_FORM_ORGANIZATION a with(nolock) 
		where idHeader = @idProc and recordType = 'ente' 

	DECLARE @valoreAppaltiAggiudicati float = 0
	DECLARE @xmlValAppaltiAgg varchar(1000) = ''

	DECLARE @valoreAQ decimal(18,2) = 0
	DECLARE @tipoDocInnesco varchar(200) = ''

	DECLARE @OverallMaximumFrameworkContractsAmount FLOAT = NULL
	DECLARE @OverallApproximateFrameworkContractsAmount FLOAT = NULL

	DECLARE @XMLOverallMaximumFrameworkContractsAmount varchar(500) = ''
	DECLARE @XMLOverallApproximateFrameworkContractsAmount varchar(500) = ''

	DECLARE @dataAggiudicazione datetime = null
	DECLARE @strDataAggiudicazione varchar(100) = null

	SELECT idRow as idMicDet,strData1 as NumeroLotto, decimalData1 as impAggAQ
		INTO #lotti_agg_def
		FROM Document_E_FORM_BUFFER a WITH(NOLOCK)
		WHERE a.[guid] = @guidOperation and infoType = 'LOTTI_CHIUSI' and strData2 = 'AggiudicazioneDef'

	-- se ci sono lotti aggiudicati ( giro can29 ) calcolo il campo "BT-161-NOTICERESULT"
	IF EXISTS ( select idMicDet from #lotti_agg_def )
	BEGIN
		
		select @valoreAppaltiAggiudicati = @valoreAppaltiAggiudicati + ValoreImportoLotto
			from #lotti_agg_def a
					inner join document_microlotti_dettagli b with(nolock) on b.IdHeader = @idProc and b.TipoDoc = @tipoDoc and b.voce = 0 and b.NumeroLotto = a.NumeroLotto

		IF isnull(@valoreAppaltiAggiudicati,0) = 0
			set @valoreAppaltiAggiudicati = @importoBaseAsta

		-- Se mi è stato passato l'id del contratto/convenzione
		IF @idDocContrConv > 0 
		BEGIN

			select @tipoDocInnesco = TipoDoc
				from ctl_doc with(nolock) 
				where id = @idDocContrConv

			IF @tipoDocInnesco IN ( 'CONTRATTO_GARA', 'SCRITTURA_PRIVATA' )
			BEGIN

				--Recupero il campo "Valore contratto"
				select @valoreAppaltiAggiudicati = [value] -- conversione implicita da varchar a float
					from CTL_DOC_Value with (nolock) 
					where IdHeader = @idDocContrConv and DSE_ID='CONTRATTO' and DZT_Name='NewTotal'

			END
			
			IF @tipoDocInnesco = 'CONVENZIONE'
			BEGIN

				select  @OverallMaximumFrameworkContractsAmount = sum(ValoreRinnoviOpzioni),
						@OverallApproximateFrameworkContractsAmount = sum(Importo)
					from Document_Convenzione_Lotti a with(nolock) 
					where a.idHeader = @idDocContrConv

				--BT-118 = Sommatoria BT-709
				set @OverallMaximumFrameworkContractsAmount = isnull(@OverallMaximumFrameworkContractsAmount,0) + isnull(@OverallApproximateFrameworkContractsAmount,0)

				set @valoreAppaltiAggiudicati = @OverallMaximumFrameworkContractsAmount

			END

			-- Recupero della "Data aggiudicazione". BT-1451. per i contratti con più lotti aggiudicati in momenti diversi si considera la minima data
			select @dataAggiudicazione = MIN( isnull(  CAST(ltVa.value AS datetime) , ed.datainvio) )
				FROM Document_E_FORM_BUFFER a WITH(NOLOCK)
						-- prendiamo le comunicazioni di aggiudicazione
						INNER JOIN CTL_Doc ed WITH (NOLOCK) on ed.LinkedDoc = @idPDA and ed.deleted = 0 and ed.TipoDoc = 'PDA_COMUNICAZIONE_GENERICA' AND ed.StatoDoc = 'Sended' AND ed.JumpCheck = '0-ESITO_DEFINITIVO_MICROLOTTI'
						-- restringiamo per il lotto aggiudicato ( se è monolotto è 1 ed andranno sempre in match )
						INNER JOIN Document_comunicazione_StatoLotti ced WITH (NOLOCK) ON ced.IdHeader = ed.Id and ced.deleted = 0 and ced.NumeroLotto = a.strData1
						-- se l'aggiudicazione era condizionata, la data di agg non è l'invio della comunicazione ma andiamo a recuperare la data di conferma			
						LEFT JOIN Document_Microlotti_DOC_Value ltVa with(nolock) ON ltVa.idheader = a.idRow and ltVa.dse_id = 'INVIO_FINE_AGG_CONDIZ' and ltVa.DZT_Name = 'DataInvio' and isnull(ltVa.value,'') <> ''
				WHERE a.[guid] = @guidOperation and infoType = 'LOTTI_CHIUSI' and strData2 = 'AggiudicazioneDef'

			set @strDataAggiudicazione = CONVERT(VARCHAR(10), @dataAggiudicazione, 121) + 'Z'

		END

		--BT-161 SE ACCORDOQUADRO OMETTO
		IF(@tipoSceltaContr = 'ACCORDOQUADRO' OR @ContractingType IN ('fa-wo-rc','fa-w-rc','fa-mix'))
		BEGIN
			set @xmlValAppaltiAgg = ''
		END
		ELSE
		BEGIN
			set @xmlValAppaltiAgg = '<cbc:TotalAmount currencyID="EUR">' + ltrim( str( @valoreAppaltiAggiudicati , 25 , 2 ) ) + '</cbc:TotalAmount>'
		END

		--prev BT-118 ( prima, ora lavoriamo sulla convenzione )
		select @valoreAQ = sum(impAggAQ) from #lotti_agg_def

	END


	set @XMLOverallApproximateFrameworkContractsAmount = case when @OverallApproximateFrameworkContractsAmount is not null AND @tipoScheda <> 'P1_19'
															  then '<efbc:OverallApproximateFrameworkContractsAmount currencyID="EUR">' + ltrim( str(@OverallApproximateFrameworkContractsAmount, 25 , 2 ) ) + '</efbc:OverallApproximateFrameworkContractsAmount>' 
															  else '' 
														  end

	set @XMLOverallMaximumFrameworkContractsAmount = case when @OverallMaximumFrameworkContractsAmount is not null OR @valoreAQ > 0
														  then '<efbc:OverallMaximumFrameworkContractsAmount currencyID="EUR">' + ltrim( str( isnull(@OverallMaximumFrameworkContractsAmount, @valoreAQ) , 25 , 2 ) ) + '</efbc:OverallMaximumFrameworkContractsAmount>' 
														  else '' 
													  end


	-------------------------------------------------------------------
	--SE PROVENIAMO DA UN GIRO DEL FLUSSO DI ESECUZIONE ( CAN38/40 ) --
	-------------------------------------------------------------------
	IF @uuidFles <> ''
	BEGIN

		-- Per il flusso esecuzioni cambiamo tipo can essendo il secondo giro di CAN non dobbiamo più utilizzare il tipo "originale".
		IF @tipoScheda = 'P1_19'
		BEGIN
			set @tipoCAN = '40'
		END
		ELSE
		BEGIN
			set @tipoCAN = '38'
		END

		SELECT @PublicationID = cn16_publication_id
			FROM Document_E_FORM_CONTRACT_NOTICE with(nolock) 
			where idHeader = @idProc

		SELECT  @CAN_FLES_ChangeDescription = isnull(CAUSA_MODIFICA,''),
				@CAN_FLES_chReasonCode = isnull(MOTIVI_MODIFICA,''),
				@CAN_FLES_chReasonDesc = isnull(MOTIVI_MODIFICA_DESCRIZIONE,''),
				@CAN_FLES_IMPORTO_LAVORI = IMPORTO_LAVORI,
				@CAN_FLES_IMPORTO_SERVIZI = IMPORTO_SERVIZI,
				@CAN_FLES_IMPORTO_FORNITURE = IMPORTO_FORNITURE,
				@CAN_FLES_IMPORTO_TOTALE_SICUREZZA = IMPORTO_TOTALE_SICUREZZA,
				@CAN_FLES_ULTERIORI_SOMME_NO_RIBASSO = ULTERIORI_SOMME_NO_RIBASSO,
				@CAN_FLES_SOMME_A_DISPOSIZIONE = SOMME_A_DISPOSIZIONE,
				@CAN_FLES_SOMME_OPZIONI_RINNOVI = SOMME_OPZIONI_RINNOVI
			FROM FLES_TABLE_MODIFICA_CONTRATTUALE with(nolock)
			WHERE UUID = @uuidFles

		set @ContractModification = '
               <efac:ContractModification>
				  <!-- Pubblication id del contract notice -->
                  <efbc:ChangedNoticeIdentifier>' + ISNULL(@PublicationID,'') + '</efbc:ChangedNoticeIdentifier>
                  <efac:Change>
					 <!-- BT-202 - ChangeDescription proveniente dal flusso di esecuzione - MOTIVI_MODIFICA_DESCRIZIONE -->
                     <efbc:ChangeDescription languageID="ITA">' + dbo.HTML_Encode(@CAN_FLES_ChangeDescription) + '</efbc:ChangeDescription>
                     <efac:ChangedSection>
						<!-- costante -->
                        <efbc:ChangedSectionIdentifier>CON-0001</efbc:ChangedSectionIdentifier>
                     </efac:ChangedSection>
                  </efac:Change>
                  <efac:ChangeReason>
					 <!-- BT-200 - Modification Reason Code proveniente dal flusso di esecuzione -->
                     <cbc:ReasonCode listName="modification-justification">' + dbo.HTML_Encode(@CAN_FLES_chReasonCode) + '</cbc:ReasonCode>
					 <!-- BT-201 - Modification Reason Description proveniente dal flusso di esecuzione -->
                     <efbc:ReasonDescription languageID="ITA">' + dbo.HTML_Encode(@CAN_FLES_chReasonDesc) + '</efbc:ReasonDescription>
                  </efac:ChangeReason>
               </efac:ContractModification>'

		DECLARE @totaleImportiFles DECIMAL(18,2) = 0

		set @totaleImportiFles = isnull(@CAN_FLES_IMPORTO_LAVORI,0) + isnull(@CAN_FLES_IMPORTO_SERVIZI,0) + isnull(@CAN_FLES_IMPORTO_FORNITURE,0) + isnull(@CAN_FLES_IMPORTO_TOTALE_SICUREZZA,0) +
				isnull(@CAN_FLES_ULTERIORI_SOMME_NO_RIBASSO,0) + isnull(@CAN_FLES_SOMME_A_DISPOSIZIONE,0) 
		-- + isnull(@CAN_FLES_SOMME_OPZIONI_RINNOVI,0) ( specifico del CAN40 )

		IF @tipoCAN = '38'
		BEGIN

			--Come richiesto i tag efbc:OverallApproximateFrameworkContractsAmount e efbc:OverallMaximumFrameworkContractsAmount devono essere portati nell'xml
			--	con le stesse logiche presenti negli altri CAN. Quindi sfrutto la presenza di un dato al loro interno per capire questa cosa e poi li sovrascrivo con i dati
			--	del giro dell'esecuzione
			IF @XMLOverallApproximateFrameworkContractsAmount <> ''
			BEGIN
				set @XMLOverallApproximateFrameworkContractsAmount = ltrim( str( @totaleImportiFles  , 25 , 2 ) )
			END

			IF @XMLOverallMaximumFrameworkContractsAmount <> ''
			BEGIN
				set @XMLOverallMaximumFrameworkContractsAmount = ltrim( str( @totaleImportiFles  , 25 , 2 ) )
			END
	
		END
		ELSE
		BEGIN
			-- per il can-40 non devono esserci i BT-1118 e BT-118
			set @XMLOverallApproximateFrameworkContractsAmount = ''
			set @XMLOverallMaximumFrameworkContractsAmount = ''
		END

	END --IF @uuid_fles <> ''

	declare @vbcrlf varchar(10) = '
'

	-------------
	-- OUTPUT ---
	-------------
	SELECT  
			-- Pregresso, campo ritornato a prescindere
			isnull(@tipoProcedura,'') AS GARA_TIPO_PROC, --BT-105

			--Nuovo, campo ritornato in base al tipo di scheda --- BT-105 - Tipo di procedura
			case when @tipoScheda not in ('P1_19') then '<cbc:ProcedureCode listName="procurement-procedure-type">' + isnull(@tipoProcedura,'') + '</cbc:ProcedureCode>'
				else ''
			END AS GARA_NO_ENCODE_TIPO_PROC, --BT-105

			isnull(@titoloProcedura,'') AS GARA_TITOLO, --BT-21
			isnull(@descrProc,'') AS GARA_DESCRIZIONE,--BT-24
			isnull(@naturaAppalto,'') AS GARA_NATURA_APPALTO, --BT-23
			isnull(@Classprincipale,'') AS GARA_CLASSIFICAZIONE, --BT-262

			isnull(@IssueDate,'') AS ISSUE_DATE,
			isnull(@IssueTime,'') AS ISSUE_TIME,
			isnull(@strDataAggiudicazione,@IssueDate) AS TENDER_RESULT_AWARD_DATE,

			dbo.eFroms_GetStrDateOrTimeUTCfromITA(@dtNOW_ITA,0) as TRANSMISSION_DATE,
			dbo.eFroms_GetStrDateOrTimeUTCfromITA(@dtNOW_ITA,1) as TRANSMISSION_TIME,

			isnull(@RegulatoryDomain,'') AS GARA_BASE_GIURIDICA,
			ltrim( str( @importoBaseAsta  , 25 , 2 ) ) as GARA_IMPORTO_APPALTO,
			ltrim( str( @importoBaseAsta  , 25 , 2 ) ) as ESTIMATED_OVERALL_CONTRACT_AMOUNT,
			'eforms-sdk-1.9' as CUSTOMIZATION_ID,
			isnull(@CONTRACT_FOLDER_ID,'') AS CONTRACT_FOLDER_ID,

			case when @tipoSceltaContr = 'ACCORDOQUADRO' then '
			 <ext:UBLExtensions>
				<ext:UBLExtension>
				   <ext:ExtensionContent>
					  <efext:EformsExtension>
						 <!-- BT-271-Procedure - Valore massimo dell''accordo quadro -->
						 <efbc:FrameworkMaximumAmount currencyID="EUR">' + ltrim( str( @importoBaseAsta  , 25 , 2 ) ) + '</efbc:FrameworkMaximumAmount>
					  </efext:EformsExtension>
				   </ext:ExtensionContent>
				</ext:UBLExtension>
			 </ext:UBLExtensions>' else '' end  AS GARA_NO_ENCODE_FRAMEWORK_MAXIMUM_VALUE,

			 CASE WHEN @W3PROCEDUR = '' or @concessione = 'si' or @tipoScheda in('P1_20') then '' -- se il campo manca o non è valorizzato omettiamo il blocco XML OPPURE SE SIAMO SU UN GIRO DI CONCESSIONE ( CN19 )
				  --Se il campo è valorizzato e la procedura rientra tra quelle che prevedono questo blocco XML ( Se tipo procedura = ‘Aperta’ o ‘Ristretta” o tipoprocedura = ‘invito’ e precedentemente c’è stato un avviso )
				  WHEN @W3PROCEDUR <> '' and @tipoDoc <> 'BANDO_SEMPLIFICATO' and ( @pg = '15476' OR @pg = '15477' OR ( @tb = '3' AND @pg = '15478' and @LinkedDoc=0 ) ) then '<cac:ProcessJustification>
												 <!-- BT-106 - La procedura è accelerata -->
												 <cbc:ProcessReasonCode listName="accelerated-procedure">' + @W3PROCEDUR + '</cbc:ProcessReasonCode>'

												 +
												 case when @W3PROCEDUR = 'true' and @cn16_ProcessJustification_ProcessReason <> '' then '<!-- BT-1351 --><cbc:ProcessReason languageID="ITA">' + dbo.HTML_Encode(LEFT(@cn16_ProcessJustification_ProcessReason,2000)) + '</cbc:ProcessReason>'
													  else '' end
												 +

											  '</cac:ProcessJustification>'
				  ELSE '' END
				 AS GARA_NO_ENCODE_ACCELERATED_PROCEDURE,

			isnull(@formaGiuridicaEnte,'') AS GARA_ENTE_FORM_GIUR,
			isnull(@attivitaAmmEnte,'') AS GARA_ENTE_ATT_AMM,
			--ISNULL(@orgID,'') AS GARA_ENTE_ID,

			'ORG-0001' AS GARA_ENTE_ID, 
			'ORG-0003' as GARA_ANAC_ID,		-- RIFERIMENTI ANAC / far evolvere per prendere questo id ORG dinamicamente ( previo inserimento nella tab delle organizations )

			case when @aziSitoWeb <> '' then '<!-- BT-508 - Buyer Profile URL -->' + @vbcrlf + '<cbc:BuyerProfileURI>' + LTRIM(RTRIM(LEFT(dbo.HTML_Encode(@aziSitoWeb),400))) + ' </cbc:BuyerProfileURI>' else '' end AS GARA_NO_ENCODE_BUYERPROFILEURI,

			@xmlValAppaltiAgg as GARA_NO_ENCODE_TOTAL_AMOUNT,

			
			--BT-118 OverallMaximumFrameworkContractsAmount +
			--BT-1118 OverallApproximateFrameworkContractsAmount
			--	( valgono anche per i can 38 e 40 )
				 @XMLOverallApproximateFrameworkContractsAmount
					+
				 @XMLOverallMaximumFrameworkContractsAmount
				AS GARA_NO_ENCODE_CONTRACTS_AMOUNT,

			'' as CONTRACT_NOTICE_CHANGES, --caso cn16 classico. senza change notices

			--case when @concessione = 'si' then '19' else '16' end AS CONTRACT_NOTICE_SUBTYPE,
			@tipoCN as CONTRACT_NOTICE_SUBTYPE,

			case when @concessione = 'si' then '
				  <!--BT-740 specifico CN-19 -->
				  <cac:ContractingPartyType>
					 <cbc:PartyTypeCode listName="buyer-contracting-type">cont-ent</cbc:PartyTypeCode>
				  </cac:ContractingPartyType>' else '' end as GARA_NO_ENCODE_BUYER_CONTRACTING_TYPE,

			case when @MaximumLotsAwardedNumeric <> '' and @MaximumLotsSubmittedNumeric <> '' then '
			  <cac:LotDistribution>
				 <!--  BT-33 (Lots Max Awarded)  -->
				 <cbc:MaximumLotsAwardedNumeric>' + @MaximumLotsAwardedNumeric + '</cbc:MaximumLotsAwardedNumeric>
				 <!--  BT-31 (Lots Max Allowed) -->
				 <cbc:MaximumLotsSubmittedNumeric>' + @MaximumLotsSubmittedNumeric + '</cbc:MaximumLotsSubmittedNumeric>
			  </cac:LotDistribution>
			' else '' end AS GARA_NO_ENCODE_LOT_DISTRIBUTION,

			@projectInternalId as GARA_PROCUREMENT_PROJECT_NO_ENCODE_ID,

			-- deserta ? dati nn usati da questa stored
			'RES-0001' as LOTTO_RESULT_ID,
			'clos-nw' as LOTTO_RESULT_TENDER_RESULT_CODE,
			case when @statoFunzionaleGara = 'Revocato' then 'chan-need'
				 else 'no-rece'
				end	 as LOTTO_RESULT_DECISION_REASON,
			'' as LOTTO_RESULT_TENDER_LOT_ID,

			-- AdditionalInformationParty (OPT-301): Mantengo ORG-0001 cablato essendo per noi l'ente
			case when @tiposcheda = 'P1_19' then '
					<cac:AdditionalInformationParty>
						<cac:PartyIdentification>
							<cbc:ID>ORG-0001</cbc:ID>
						</cac:PartyIdentification>
					</cac:AdditionalInformationParty>'
				else ''
			end as GARA_NO_ENCODE_ADDITIONAL_INFORMATION_PARTY,

			--OPP-070 - Notice Subtype
			@tipoCAN as GARA_NOTICE_SUBTYPE_CODE,

			--BT-88
			case when @tipoScheda in ('P1_20') then '
				<!-- BT-88 -->
				<cbc:Description languageID="ITA">' + @Body + '</cbc:Description>'
				else ''
			end as GARA_NO_ENCODE_TENDERING_PROCESS_DESCRIPTION,

			-- BT-02 (ContractNotice)
			case when @tipoScheda not in ('P1_20') then 'cn-standard'
				else 'cn-social'
			end as GARA_CN_NOTICE_TYPE_CODE,
			
			-- BT-02 (ContractAwardNotice)
			case when @uuidFles <> '' then 'can-modif'
				 when @tipoScheda not in ('P1_20') then 'can-standard'
				 else 'can-social'
			end as GARA_CAN_NOTICE_TYPE_CODE,

			@ContractModification as FLES_NO_ENCODE_CONTRACT_MODIFICATION --specifico can38/40


END
GO
