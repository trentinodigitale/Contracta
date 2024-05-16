USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[PUBBLICA_GARE_SUL_PORTALE]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[PUBBLICA_GARE_SUL_PORTALE] 
AS
BEGIN

	SET NOCOUNT ON

	--BEGIN TRAN

	-- LISTA BANDI --

	BEGIN TRY

		declare @sysOldDB varchar(4000)
		set @sysOldDB = ''

		select @sysOldDB = ltrim(rtrim(isnull(DZT_ValueDef,'')))
			from LIB_Dictionary with(nolock)
			where DZT_Name = 'SYS_DBNAME_PREV_VER'
		
		--drop table #TEMP_DPCM_AF
		
		-- Effettuo prima il riversamento dei dati in una tabella temporanea dal database corrente
		SELECT * ,'PIATTAFORMA' as origineDati, cast('bandi' as varchar(500)) as paginaJoomla  INTO #TEMP_DPCM_AF FROM DASHBOARD_VIEW_DOCUMENTI_PUBBLICI_ORIGINAL
		
		SELECT *,'PIATTAFORMA' as origineDati, cast('albo' as varchar(500)) as paginaJoomla , '' as RECEIVEDDATAMSG INTO #TEMP_DPCM_ALBO_AF  FROM DASHBOARD_VIEW_ISCRIZIONEALBOFORNITORIPUBBLICI

		-- SE la tabella delle gare deve essere popolata da più database sorgente ( vedi caso AFLink_NA + AFLink_NA_New )
		IF @sysOldDB <> ''
		BEGIN

			-- DOPO AVER CREATO LA TABELLA #TEMP_DPCM_AF NELLA SELECT INSERT SOPRA
			-- CON TUTTE LE COLONNE DISPONIBILI. PASSO A FARE UN ULTERIORE SELECT INSERT PER AGGIUNGERCI I RECORD DEL DATABASE SLAVE
			-- con le colonne fisse, perchè non cambieranno nel tempo, disponibili sul db slave. congelate al momento dell'implementazione

			INSERT INTO #TEMP_DPCM_AF (msgIType,msgISubType,IdDoc, origineDati, paginaJoomla, IdMsg, OPEN_DOC_NAME, IdMittente, TipoAppalto, bScaduto, bConcluso, EvidenzaPubblica, ProtocolloBando, TipoProcedura, StatoGD, Oggetto, Tipo, Contratto, DenominazioneEnte, SenzaImporto, a_base_asta, di_aggiudicazione, DtPubblicazione, RECEIVEDDATAMSG, DataInvio, DtScadenzaBando, DtScadenzaBandoTecnical, DtScadenzaPubblEsito, RequisitiQualificazione, CPV, SCP, URL, CIG, RichiestaQuesito, bEsito, VisualizzaQuesiti, direzioneespletante, Appalto_Verde, Acquisto_Sociale, DtPubblicazioneTecnical, Provincia, Comune, TipoEnte, Bando_Verde_Sociale, statoFunzionale, tipoDocOriginal, ambito, titoloDocumento, DataChiusuraTecnical,gestore, Merceologia )
						exec ('select '''','''','''',''LEGACY'',''bandi-legacy'', IdMsg, OPEN_DOC_NAME, IdMittente, TipoAppalto, bScaduto, bConcluso, EvidenzaPubblica, ProtocolloBando, TipoProcedura, StatoGD, Oggetto, Tipo, ISNULL(Contratto,''''), DenominazioneEnte, SenzaImporto, a_base_asta, di_aggiudicazione, DtPubblicazione, NULL as RECEIVEDDATAMSG, NULL as DataInvio, DtScadenzaBando, DtScadenzaBandoTecnical, DtScadenzaPubblEsito, RequisitiQualificazione, CPV, SCP, URL, CIG, RichiestaQuesito, bEsito, VisualizzaQuesiti, '''' as direzioneespletante, ''no'' AS Appalto_Verde, ''no'' AS Acquisto_Sociale, NULL as DtPubblicazioneTecnical, Provincia, Comune, TipoEnte, NULL AS Bando_Verde_Sociale, '''' as statoFunzionale, ''DOCUMENTO_GENERICO'' as tipoDocOriginal, '''' as ambito, '''' as titoloDocumento, '''' as DataChiusuraTecnical , 1, '''' as Merceologia   from ' + @sysOldDB + '..DASHBOARD_VIEW_DOCUMENTI_PUBBLICI_ORIGINAL')
			
			INSERT INTO #TEMP_DPCM_ALBO_AF (origineDati, paginaJoomla, [IdMsg], [IdPfu], [msgIType], [msgISubType], [Name], [ProtocolloBando], [ProtocolloOfferta], [ReceivedDataMsg], [Oggetto], [Tipologia], [ExpiryDate], [ImportoBaseAsta], [tipoprocedura], [StatoGD], [Fascicolo], [CriterioAggiudicazione], [CriterioFormulazioneOfferta], [DOCUMENT], [IDDOCR], [Precisazioni],jumpcheck,gestore)
					    exec ('select ''LEGACY'',''albo-legacy'',[IdMsg], [IdPfu], [msgIType], [msgISubType], [Name], [ProtocolloBando], [ProtocolloOfferta],  ISNULL([ReceivedDataMsg],''''), [Oggetto], [Tipologia], [ExpiryDate], [ImportoBaseAsta], [tipoprocedura], [StatoGD], [Fascicolo], [CriterioAggiudicazione], [CriterioFormulazioneOfferta], [DOCUMENT], [IDDOCR], [Precisazioni],jumpcheck,1  from ' + @sysOldDB + '..DASHBOARD_VIEW_ISCRIZIONEALBOFORNITORIPUBBLICI')
		END
		
		-- Se esiste la tabella faccio la truncate del suo contenuto
		IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE' AND TABLE_NAME='FAST_DPCM_DOCUMENTI_PUBBLICI') 
		BEGIN

			--TRUNCATE TABLE FAST_DPCM_DOCUMENTI_PUBBLICI
			DROP TABLE FAST_DPCM_DOCUMENTI_PUBBLICI

		END

		--la tabella #TEMP_DPCM_AF contiene una colonna in più
		--CodEnteProponente e al colonna EnteProponente è vuota
		--la risolviamo adesso per migliorare le prestazioni

		--Conservo dominio per risolvere in una TEMP
		select * into #DOM_ENTI FROM GESTIONE_DOMINIO_DIREZIONE
		--select * from #DOM_ENTI
		
		--Copio le Gare in un'altra TEMP
		select * into #TEMP_DPCM_AF_2 from #TEMP_DPCM_AF
		--select * from #TEMP_DPCM_AF_2

		declare @ID INT
		declare @idRow INT
		DECLARE @EnteProponente NVARCHAR(MAX) 
		DECLARE @A NVARCHAR(MAX) 

		declare CurProg Cursor static for 
				Select distinct  isnull(CodEnteProponente,'') from #TEMP_DPCM_AF    
		open CurProg

		FETCH NEXT FROM CurProg    INTO  @EnteProponente
		WHILE @@FETCH_STATUS = 0
		BEGIN
				SET @a = ''
				SELECT @a = @a + DMV_DescML + ', '  FROM #DOM_ENTI WHERE '###' + @EnteProponente + '###'  LIKE '%###' + DMV_Cod + '###%' 
                
				if  @a <> ''
					update  #TEMP_DPCM_AF set EnteProponente = left(@a,len(@a)-1)  where CodEnteProponente = @EnteProponente
                    
				FETCH NEXT FROM CurProg    INTO  @EnteProponente
		END 
		CLOSE CurProg
		DEALLOCATE CurProg
		
		

		--select * from #TEMP_DPCM_AF
		--select * from FAST_DPCM_DOCUMENTI_PUBBLICI

		-- sposto i dati dalla tabella temporanea in quella definitiva per la lista bandi dpcm
		SELECT * INTO FAST_DPCM_DOCUMENTI_PUBBLICI FROM #TEMP_DPCM_AF 

		-- Se esiste la tabella faccio la truncate del suo contenuto
		IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE' AND TABLE_NAME='FAST_DPCM_DOCUMENTI_ALBO_PUBBLICI') 
		BEGIN

			--TRUNCATE TABLE FAST_DPCM_DOCUMENTI_PUBBLICI
			DROP TABLE FAST_DPCM_DOCUMENTI_ALBO_PUBBLICI

		END

		-- sposto i dati dalla tabella temporanea in quella definitiva per la lista bandi dpcm
		SELECT * INTO FAST_DPCM_DOCUMENTI_ALBO_PUBBLICI FROM #TEMP_DPCM_ALBO_AF 

		-- ULTIMI BANDI --

		-- Effettuo prima il riversamento dei dati in una tabella temporanea
		SELECT * INTO #TEMP_ULTIMI_DPCM_AF FROM DASHBOARD_VIEW_ULTIMI_DOCUMENTI_PUBBLICI_ORIGINAL

		-- Se esiste la tabella faccio la truncate del suo contenuto
		IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE' AND TABLE_NAME='FAST_DPCM_ULTIMI_DOCUMENTI_PUBBLICI') 
		BEGIN

			--TRUNCATE TABLE FAST_DPCM_ULTIMI_DOCUMENTI_PUBBLICI
			DROP TABLE FAST_DPCM_ULTIMI_DOCUMENTI_PUBBLICI

		END

		-- sposto i dati dalla tabella temporanea in quella definitiva per la lista bandi dpcm
		SELECT * INTO FAST_DPCM_ULTIMI_DOCUMENTI_PUBBLICI FROM #TEMP_ULTIMI_DPCM_AF


		--COMMIT TRANSACTION

	END TRY  
	BEGIN CATCH

		DECLARE @ErrorMessage NVARCHAR(4000)
		DECLARE @ErrorSeverity INT
		DECLARE @ErrorState INT

		SELECT	@ErrorMessage = ERROR_MESSAGE(),  
				@ErrorSeverity = ERROR_SEVERITY(),  
				@ErrorState = ERROR_STATE()

		--ROLLBACK TRANSACTION

		RAISERROR ( @ErrorMessage,
					@ErrorSeverity,
					@ErrorState
				  )

	END CATCH

END
GO
