USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_WIDGET_GET_LAST_TENDERS]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--WIDGET_FUNZIONE  ( widget è un costante, funzione è il nome funzionale del widget ). non mettere mai in transazione !
--exec WIDGET_GET_LAST_TENDERS 45642, '', 1, ''
CREATE PROC [dbo].[OLD_WIDGET_GET_LAST_TENDERS] 
(
	@idpfu      INT,
	@CallerType VARCHAR(500),
	@WidgetType INT,
	@Command VARCHAR(500),
	@suffix VARCHAR(50) = '',
	@Context VARCHAR(500) = ''
)
AS
    -- ex: exec [WIDGET_GET_NUMBERS_OE] 1, 'WEBAPI',  0, 'INIT'
    SET nocount ON

    DECLARE @strCause NVARCHAR(500)

  BEGIN try
	
      CREATE TABLE #lista
        (
		   [ID]		INT,
           [text]      NVARCHAR(max),
           [subText]   NVARCHAR(max),
           [rightText] NVARCHAR(max),
           [action]    NVARCHAR(max)
        )

		CREATE TABLE #TempTable (
			IdMsg INT,
			IdPfu INT,
			msgIType INT,
			msgISubType INT,
			IDDOCR INT,
			Precisazioni INT,
			Name NVARCHAR(MAX),
			bRead INT,
			ProtocolloBando NVARCHAR(MAX),
			ProtocolloOfferta NVARCHAR(MAX),
			ReceivedDataMsg DATETIME,
			Oggetto NVARCHAR(MAX),
			Tipologia INT,
			expirydate DATETIME,
			ImportoBaseAsta INT,
			tipoprocedura INT,
			StatoGD NVARCHAR(MAX),
			Fascicolo NVARCHAR(MAX),
			CriterioAggiudicazione INT,
			CriterioFormulazioneOfferta INT,
			OpenDettaglio INT,
			Scaduto INT,
			IdDoc NVARCHAR(50),
			TipoBando INT,
			CIG NVARCHAR(MAX),
			StatoCollegati NVARCHAR(MAX),
			OPEN_DOC_NAME NVARCHAR(MAX),
			OpenOfferte NVARCHAR(MAX),
			EnteAppaltante NVARCHAR(MAX),
			Protocollo NVARCHAR(MAX),
			TipoProceduraCaratteristica NVARCHAR(MAX),
			Appalto_Verde NVARCHAR(MAX),
			Acquisto_Sociale NVARCHAR(MAX),
			Bando_Verde_Sociale NVARCHAR(MAX),
			AZI_Ente INT,
			SedutaVirtuale NVARCHAR(MAX),
			EnteProponente NVARCHAR(MAX),
			statoiscrizione NVARCHAR(MAX),
			utentedomanda INT
		)
		
		CREATE TABLE #TempTable2 (
			ID INT,
			IdMsg INT,
			IdPfu INT,
			msgIType INT,
			IDDOCR INT,
			Precisazioni INT,
			OpenDettaglio INT,
			Name NVARCHAR(MAX),
			IdDoc NVARCHAR(50),
			ProtocolloBando NVARCHAR(MAX),
			CIG NVARCHAR(MAX),
			ProtocolloOfferta NVARCHAR(MAX),
			ReceivedDataMsg DATETIME,
			Oggetto NVARCHAR(MAX),
			Tipologia INT,
			ExpiryDate DATETIME,
			ExpiryDateAl DATETIME,
			ImportoBaseAsta DECIMAL(10, 2),
			tipoprocedura INT,
			StatoGD INT,
			CriterioAggiudicazione INT,
			EnteAppaltante NVARCHAR(MAX),
			Appalto_Verde NVARCHAR(10),
			Acquisto_Sociale NVARCHAR(10),
			TipoBandoGara INT,
			IdMittente INT,
			AZI_Ente INT,
			EvidenzaPubblica INT,
			DOCUMENT NVARCHAR(MAX),
			OPEN_DOC_NAME NVARCHAR(MAX),
			Bando_Verde_Sociale NVARCHAR(MAX),
			Protocollo NVARCHAR(MAX),
			SedutaVirtuale NVARCHAR(MAX),
			EnteProponente NVARCHAR(MAX),
			msgISubType INT,
			Scaduto INT
		)

		INSERT INTO #TempTable
		exec DASHBOARD_SP_VIEW_BANDI_FORN_SERV_PRIV  
			@idpfu ,
			'',
			'', 
			'',
			'Scaduto=0 and ((msgISubType in (21,49,79,153,113,69,75,222,386) and (tipologia in(1,2,3))) or (msgISubType = 168 and (tipologia in(1,2,3)) and TipoBando in (3 , 5 ) ) )', 
			'',
			2500,
			1
		 
		INSERT INTO #TempTable2
			exec DASHBOARD_SP_VIEW_BANDI_FORN_SERV_PUBB  
			@idpfu , 
				'' , 
				'' , 
				'' , 
				'Scaduto=0 and Tipologia in(1,2,3) and TipoBandoGara <> ''1'' ' , 
				'' , 
				2500, 
				1

		INSERT INTO #lista
			select 
			Distinct 
				IdMsg																																			AS [ID],
				Name																																			AS [text],
				'Protocollo: ' + ProtocolloOfferta + ' - '
				+ 'Ente Appaltante: ' + EnteAppaltante		AS [subText],
				ReceivedDataMsg																																	AS [rightText],
				--"../ctl_library/path.asp?url=dashboard%2FreportDocument.asp%3Flo%3Dbase%26IDDOC%3D422066%26DOCUMENT%3DBANDO_GARA&KEY=REPORT
				--ExecFunctionSelf(url, '', '');
				--"../ctl_library/path.asp?url=dashboard%2FreportDocument.asp%3Flo%3Dbase%26IDDOC%3D" + IdMsg + "%26DOCUMENT%3DBANDO_GARA&KEY=REPORT"
				
				'ExecFunctionSelf(' + '''../ctl_library/path.asp?url=dashboard%2FreportDocument.asp%3Flo%3Dbase%26IDDOC%3D' + 
				Convert(varchar(10), IdMsg) +
				'%26DOCUMENT%3DBANDO_GARA&KEY=REPORT''' +
				','''','''');'																																	AS [action]
			--'' as [text], 
			--'' as [subText], 
			--'' as [rightText],
			--'' as [action]
			from #TempTable

		INSERT INTO #lista
			select  
			Distinct
				IdMsg																																			AS [ID],
				Name																																			AS [text],
				'Protocollo: ' + ProtocolloOfferta + ' - '
				+ 'Ente Appaltante: ' + EnteAppaltante		AS [subText],
				ReceivedDataMsg																																AS [rightText],
				
				'ExecFunctionSelf(' + '''../ctl_library/path.asp?url=dashboard%2FreportDocument.asp%3Flo%3Dbase%26IDDOC%3D' +
				Convert(varchar(10), IdMsg) +
				'%26DOCUMENT%3DBANDO_GARA&KEY=REPORT''' +
				','''','''');'																																AS [action]
			from #TempTable2
		

      SELECT DISTINCT [text], [subText], [rightText], [action] FROM   #lista 
	  order by rightText desc

	  DROP TABLE #lista

  END try

  BEGIN catch
      DECLARE @ErrorMessage NVARCHAR(max)
      DECLARE @ErrorSeverity INT
      DECLARE @ErrorState INT

      SET @ErrorMessage = @strCause + ' - ' + Error_message()
      SET @ErrorSeverity = Error_severity()
      SET @ErrorState = Error_state()

      RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)
  END catch


GO
