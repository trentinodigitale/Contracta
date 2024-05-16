USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[WIDGET_GET_NUMBERS_OE]    Script Date: 5/16/2024 2:38:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--WIDGET_FUNZIONE  ( widget è un costante, funzione è il nome funzionale del widget ). non mettere mai in transazione !
--exec WIDGET_GET_NUMBERS_OE @idpfu, @CallerType, @WidgetType, @Command

CREATE PROC [dbo].[WIDGET_GET_NUMBERS_OE] 
( 
	@idpfu INT,
	@CallerType varchar(500), 
	@WidgetType int, 
	@Command varchar(500),
	@suffix varchar(50) = '',
    @Context varchar(500) = ''
)
AS

	-- ex: exec [WIDGET_GET_NUMBERS_OE] 1, 'WEBAPI',  0, 'INIT'

	SET NOCOUNT ON

	DECLARE @strCause nvarchar(500)

	BEGIN TRY

		DECLARE @numOE as int = 0

		set @strCause = 'Recupero il numero di OE dalla tabella aziende'
		select @numOE = count(idazi) from aziende az with(nolock) where aziDeleted = 0 and aziAcquirente = 0

		set @strCause = 'Ritorno al chiamante l''output desiderato'
		--output standard per tutti i widget di tipo BASE ( contatore/testo )
		select cast( @numOE as varchar(100) ) as result -- il recordset di output dovrà essere sempre identico, a meno chiaramente del contenuto

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
