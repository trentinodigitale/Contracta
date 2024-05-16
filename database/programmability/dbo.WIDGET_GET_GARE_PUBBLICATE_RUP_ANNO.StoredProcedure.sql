USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[WIDGET_GET_GARE_PUBBLICATE_RUP_ANNO]    Script Date: 5/16/2024 2:38:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[WIDGET_GET_GARE_PUBBLICATE_RUP_ANNO] 
( 
	@idpfu INT,
	@CallerType varchar(500), 
	@WidgetType int, 
	@Command varchar(500),
	@suffix varchar(50) = '',
    @Context varchar(500) = ''
)
AS

	-- ex: exec WIDGET_GET_GARE_PUBBLICATE_RUP_ANNO 1, 'WEBAPI',  0, 'INIT'

	SET NOCOUNT ON

	DECLARE @strCause nvarchar(500)

	BEGIN TRY

		DECLARE @numeroProcedure as int = 0
		DECLARE @rup varchar(10) = cast(@idpfu as varchar) --converto in stringa l'idpfu int in input

		set @strCause = 'Recupero il numero di procedure'

		SELECT @numeroProcedure = count(g.id)
			FROM ctl_doc g with(nolock)
				 inner join CTL_DOC_Value rup with(nolock) on rup.IdHeader = g.id and rup.dse_id='InfoTec_comune' and rup.dzt_name='UserRUP' 
			WHERE g.tipodoc in ( 'BANDO_GARA' ,'BANDO_SEMPLIFICATO') and g.deleted = 0 and g.statodoc = 'sended' -- la condizione di rcupero è stata presa dal report 'Elenco procedure'
					and rup.Value = @rup --solo le procedure del rup collegato
					and year(g.DataInvio) = year(getdate()) --solo le procedure dell'anno corrente
			
		set @strCause = 'Ritorno al chiamante l''output desiderato'
		--output standard per tutti i widget di tipo BASE ( contatore/testo )
		select cast( @numeroProcedure as varchar(100) ) as result -- il recordset di output dovrà essere sempre identico, a meno chiaramente del contenuto

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
