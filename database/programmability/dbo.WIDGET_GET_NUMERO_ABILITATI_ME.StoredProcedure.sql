USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[WIDGET_GET_NUMERO_ABILITATI_ME]    Script Date: 5/16/2024 2:38:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[WIDGET_GET_NUMERO_ABILITATI_ME] 
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

		DECLARE @totIscrittiME as int = 0
		DECLARE @rup varchar(10) = cast(@idpfu as varchar) --converto in stringa l'idpfu int in input

		set @strCause = 'Recupero la lista albi'
		select id into #Temp_List_Bandi 
			from ctl_doc a with(nolock) 
			where a.tipodoc = 'BANDO' and a.deleted = 0 and isnull( a.jumpcheck , '' ) = '' and a.StatoFunzionale = 'Pubblicato'

		set @strCause = 'Recupero il Numero di abilitati al ME'
		select @totIscrittiME = count(d.idrow) --Numero di abilitati al ME 
			from CTL_DOC_Destinatari D with(nolock) 
					inner join Aziende A with(nolock) on D.IdAzi = A.idazi and aziDeleted = 0
					inner join ctl_doc c1 with(nolock) on D.id_doc=C1.LinkedDoc and c1.TipoDoc like'CONFERMA_ISCRIZIONE%' and c1.StatoFunzionale='Notificato'
					inner join #Temp_List_Bandi tl on d.idheader = tl.id
			where D.StatoIscrizione = 'Iscritto'

		set @strCause = 'Ritorno al chiamante l''output desiderato'
		--output standard per tutti i widget di tipo BASE ( contatore/testo )
		select cast( @totIscrittiME as varchar(100) ) as result -- il recordset di output dovrà essere sempre identico, a meno chiaramente del contenuto

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
