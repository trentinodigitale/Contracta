USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[WIDGET_GET_NUMBERS_ORDERS_RECEIVED_NOTIER]    Script Date: 5/16/2024 2:38:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--exec WIDGET_GET_NUMBERS_ORDERS_RECEIVED_NOTIER 35845, '', 2, ''

CREATE PROC [dbo].[WIDGET_GET_NUMBERS_ORDERS_RECEIVED_NOTIER]
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

		set @strCause = 'Ritorno al chiamante l''output desiderato'
		--output standard per tutti i widget di tipo BASE ( contatore/testo )
		select count(*) as result from view_Document_NoTIER_ListaDocumenti
		where idOwner = @idpfu

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
