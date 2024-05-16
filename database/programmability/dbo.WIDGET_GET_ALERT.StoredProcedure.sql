USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[WIDGET_GET_ALERT]    Script Date: 5/16/2024 2:38:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[WIDGET_GET_ALERT] 
( 
    @idpfu INT,
    @CallerType varchar(500), 
    @WidgetType int, 
    @Command varchar(500) = '',
    @suffix varchar(50) = '',
    @Context varchar(500) = ''
)
AS

    SET NOCOUNT ON

    DECLARE @strCause nvarchar(500)

    BEGIN TRY

		set @strCause = 'Caricamento avvisi di sistema'

		CREATE TABLE #avvisi
		(
			[text] nvarchar(max),
			[subText] nvarchar(max),
			[rightText] nvarchar(max),
			[action] nvarchar(max)
		)

		INSERT INTO #avvisi 
			SELECT 'Avviso di sistema' as [text],
					a.Body as [subText],
					convert (varchar(10),getdate(),103) as [rightText],
					'' as [action]
				FROM CTL_DOC a with(nolock) 
						inner join Document_FermoSistema b with(nolock) on b.idHeader = a.Id 
				WHERE TipoDoc = 'FERMOSISTEMA' and Deleted = 0 and StatoFunzionale = 'Confermato' and ( ( getdate() >= DataSysMsgDA and getdate() < DataInizio ) or ( getdate() >= DataAvvisoDal and getdate() < DataAvvisoAl ) )

		set @strCause = 'Caricamento scadenza password'

		declare @sys_ggScadenzaPwd INT
		declare @dataUltimoCambio datetime = NULL

		select top 1 @sys_ggScadenzaPwd = cast( isnull( DZT_ValueDef , 90 ) as INT )
			from LIB_Dictionary with(nolock) 
			where DZT_Name = 'SYS_PWD_GG_SCADENZA'

		IF @sys_ggScadenzaPwd < 30 
			set @sys_ggScadenzaPwd = 90

		select @dataUltimoCambio = pfuDataCambioPassword
			from profiliutente a with(nolock)
			where a.idpfu = @idpfu and isnull(UtenteFedera,0) = 0 and isnull(PasswordScaduta,0) = 0

		IF not @dataUltimoCambio is null
		BEGIN

			DECLARE @dataScadenza DATETIME = DATEADD( DAY , @sys_ggScadenzaPwd , @dataUltimoCambio )
			DECLARE @giorniAllaScadenza INT =  DATEDIFF( DAY , getdate() , @dataScadenza )

			-- Non mostriamo l'avviso di scadenza per gli utenti di servizio con scadenze fittizie ( uscirebbe un valore negativo )
			IF @giorniAllaScadenza > 0
			BEGIN

				INSERT INTO #avvisi 
					VALUES ( 'Scadenza password' ,
							'La password scadrà tra ' + cast( @giorniAllaScadenza as varchar) + ' giorni',
							convert (varchar(10),getdate(),103),
							'' )

			END

		END

		-- [text] deve essere oggetto di CNV mentre le altre colonne NO
		select * from #avvisi		
	
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
