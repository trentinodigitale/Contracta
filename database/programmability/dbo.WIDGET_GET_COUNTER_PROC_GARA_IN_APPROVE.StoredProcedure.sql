USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[WIDGET_GET_COUNTER_PROC_GARA_IN_APPROVE]    Script Date: 5/16/2024 2:38:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[WIDGET_GET_COUNTER_PROC_GARA_IN_APPROVE] 
( 
	@idpfu INT,
	@params NVARCHAR(4000)
)
AS

	SET NOCOUNT ON

	DECLARE @strCause nvarchar(500)

	BEGIN TRY

		DECLARE @numPROC as int = 0

		set @strCause = 'Recupero il numero di procedure di gara in approvazione per l''utente collegato'

		select case when isnull( APS_IdPfu , '' ) = '' 
						then a.idpfu
						else cast( APS_IdPfu as int ) 
					end as [IdpfuOwner] into #tmp_count
			from CTL_DOC d with(nolock)
				inner join CTL_ApprovalSteps s with(nolock) on tipodoc = APS_Doc_Type and APS_State = 'InCharge' and APS_ID_DOC = d.id and APS_IsOld=0
				-- recupero l'utente dal ruolo solamente se non è indicato in modo specifico 
				left join profiliutenteattrib a with(nolock) on isnull( s.APS_IdPfu , '' ) = '' and a.dztNome = 'UserRole' and s.APS_UserProfile = a.attValue
			where d.deleted = 0 and d.TipoDoc in ( 'BANDO_GARA' ) 

		select @numPROC = count(IdpfuOwner) from #tmp_count where IdpfuOwner = @idpfu

		set @strCause = 'Ritorno al chiamante l''output desiderato'
		select cast( @numPROC as varchar(100) ) as result -- il recordset di output dovrà essere sempre identico, a meno chiaramente del contenuto

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
