USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[WIDGET_GET_LISTA_SDA]    Script Date: 5/16/2024 2:38:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[WIDGET_GET_LISTA_SDA]
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

		CREATE TABLE #lista
		(
			[text] nvarchar(max),
			[subText] nvarchar(max),
			[rightText] nvarchar(max),
			[action] nvarchar(max)
		)

		set @strCause = 'Caricamento lista iscritti'

		SELECT idheader , 
				sum( case when statoiscrizione = 'Iscritto' and A.aziDeleted = 0  then 1 else 0 end ) as N_Iscritti

				INTO #iscritti_sda

			from ctl_doc_destinatari D with(nolock)
					inner join Aziende A with(nolock) on D.idazi=A.idazi 
			group by idheader 

		set @strCause = 'Caricamento lista SDA'

		select d.Titolo, d.Body, d.Id into #lista_sda
			from CTL_DOC d with(nolock) 
			where d.deleted = 0 and d.TipoDoc = 'BANDO_SDA' and d.StatoFunzionale = 'Pubblicato'

		declare @maxLenObject int = 450

		INSERT INTO #lista
			SELECT l.Titolo as [text],
					case when len(l.Body) > @maxLenObject then left(l.Body, @maxLenObject) + '...' else l.Body end as [subText],
					i.N_Iscritti as [rightText],
					'' as [action]
				FROM #iscritti_sda i
						inner join #lista_sda l on i.idHeader = l.Id

		select * from #lista

		drop table #lista
		drop table #lista_sda
		drop table #iscritti_sda
	
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
