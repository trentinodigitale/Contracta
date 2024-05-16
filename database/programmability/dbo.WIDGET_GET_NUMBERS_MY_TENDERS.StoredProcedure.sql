USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[WIDGET_GET_NUMBERS_MY_TENDERS]    Script Date: 5/16/2024 2:38:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--exec WIDGET_GET_NUMBERS_MY_TENDERS 45642, '', 2, ''

CREATE PROC [dbo].[WIDGET_GET_NUMBERS_MY_TENDERS] 
( 
	@idpfu INT,
	@CallerType varchar(500), 
	@WidgetType int, 
	@Command varchar(500),
	@suffix varchar(50) = '',
    @Context varchar(500) = ''
)
AS


	SET NOCOUNT ON

	DECLARE @strCause nvarchar(500)

	BEGIN TRY

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

		DECLARE @num as int = 0

		set @strCause = 'Recupero il numero di OE dalla tabella aziende'
		INSERT INTO #TempTable
			exec DASHBOARD_SP_VIEW_BANDI_FORN_SERV_PRIV  @idpfu , '' , '' , '' , 
				' TipoBando <> ''1'' and Scaduto=0 and ((msgISubType in ( 25 ,37 , 64 ) and (Tipologia in (1,2,3))) or (msgISubType = 168 and (Tipologia in (1,2,3)) and TipoBando <> 3 ))' , 
				'' , 2500,  0
		SELECT @num = COUNT(IdMsg) from #TempTable
		set @strCause = 'Ritorno al chiamante l''output desiderato'
		--output standard per tutti i widget di tipo BASE ( contatore/testo )
		select cast( @num as varchar(100) ) as result -- il recordset di output dovrà essere sempre identico, a meno chiaramente del contenuto

	END TRY
	BEGIN CATCH

		declare @ErrorMessage nvarchar(max)
		declare @ErrorSeverity int
		declare @ErrorState int

		SET @ErrorMessage  = @strCause + ' - ' + ERROR_MESSAGE()
		SET @ErrorSeverity = ERROR_SEVERITY()
		SET @ErrorState    = ERROR_STATE()

		RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState)

	END CATCH



GO
