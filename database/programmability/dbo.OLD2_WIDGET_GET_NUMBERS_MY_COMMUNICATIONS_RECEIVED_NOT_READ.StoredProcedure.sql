USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_WIDGET_GET_NUMBERS_MY_COMMUNICATIONS_RECEIVED_NOT_READ]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--exec WIDGET_GET_NUMBERS_MY_COMMUNICATIONS_NOT_READ 45642, '', 2, ''

CREATE PROC [dbo].[OLD2_WIDGET_GET_NUMBERS_MY_COMMUNICATIONS_RECEIVED_NOT_READ]
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

		DECLARE @num as int = 0

		set @strCause = 'Recupero il numero di OE dalla tabella aziende'
		
		set @strCause = 'Ritorno al chiamante l''output desiderato'

		--output standard per tutti i widget di tipo BASE ( contatore/testo )
		--bRead = 0 mostra (controintuitivamente) le comunicazioni lette, quindi il where giusto è bRead = 1
		select count(*) as result from DASHBOARD_VIEW_COMUNICAZIONI_FORNITORI where owner = @idpfu and ( datediff(d,datacreazione,getdate())<=90 ) and bRead = 1
			
		

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
