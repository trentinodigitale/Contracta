USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_WIDGET_GET_LISTA_ULTIME_CONVENZIONI_PUBBLICATE]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--WIDGET_FUNZIONE  ( widget è un costante, funzione è il nome funzionale del widget ). non mettere mai in transazione !
--exec WIDGET_GET_LISTA_ULTIME_CONVENZIONI_PUBBLICATE 45094, '', 1, ''
CREATE PROC [dbo].[OLD_WIDGET_GET_LISTA_ULTIME_CONVENZIONI_PUBBLICATE] 
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
		
      CREATE TABLE #lista2
        (
           [text]      NVARCHAR(max),
           [subText]   NVARCHAR(max),
           [rightText] NVARCHAR(max),
           [action]    NVARCHAR(max),
		   [Sort] datetime
        )
		
      INSERT INTO #lista2
		SELECT Distinct 
			totals.DOC_Name																																	AS [text],
			'Stato: ' + totals.StatoFunzionale + ' - '
			+ 'Protocollo: ' + totals.protocollo + ' - '
			+ 'Fornitore: ' + (select aziRagioneSociale from ProfiliUtente join Aziende on pfuIdAzi = IdAzi where idpfu = totals.ReferenteFornitore)		AS [subText],
			totals.datainvio																																AS [rightText],
			'ShowDocument(' + '''convenzione'',' + Convert(varchar(10), totals.ID) + ')'																	AS [action],
			totals.datainvio as [Sort]	
		FROM   (
			select * from DASHBOARD_VIEW_CONVENZIONI where owner = @idpfu and (  ISNULL(JumpCheck,'') <> 'INTEGRAZIONE' )  
			and StatoFunzionale = 'Pubblicato'
		) as totals

		--order by [rightText] desc

      SELECT [text],[subText],[rightText],[action] FROM   #lista2 order by Sort desc
	  DROP TABLE #lista2

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
