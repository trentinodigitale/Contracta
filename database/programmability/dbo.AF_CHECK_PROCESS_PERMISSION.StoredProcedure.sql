USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[AF_CHECK_PROCESS_PERMISSION]    Script Date: 5/16/2024 2:38:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[AF_CHECK_PROCESS_PERMISSION] ( @DPR_DOC_ID varchar(50), @DPR_ID varchar(50), @idPfu int )
AS
BEGIN

	SET NOCOUNT ON

	declare @blocca INT
	declare @DPR_listaPermessi  varchar(1000)
	declare @pfuFunzionalita	varchar(1000)

	set @blocca = 0
	set @DPR_listaPermessi = '0'
	set @pfuFunzionalita = ''

	select @DPR_listaPermessi = DPR_listaPermessi from CTL_PROCESS_PERMISSION with(nolock) where DPR_DOC_ID = @DPR_DOC_ID and DPR_ID = @DPR_ID and DPR_deleted = 0

	IF @DPR_listaPermessi <> '0' -- se non è presente il record nella CTL_PROCESS_PERMISSION o ha come DPR_listaPermessi il valore 0, allora il processo passerà sempre
	BEGIN

		select @pfuFunzionalita = pfuFunzionalita from profiliutente with(nolock) where idpfu = @idPfu
		select ltrim(rtrim(items)) as permesso into #listaPermessi from dbo.split(@DPR_listaPermessi, ',')

		IF isnull(@pfuFunzionalita,'') <> ''
		BEGIN

			BEGIN TRY  
				 
				 IF EXISTS ( select * from #listaPermessi where substring(@pfuFunzionalita , cast(permesso AS INT) , 1 ) = '1' )
				 BEGIN
					set @blocca = 0
				 END
				 ELSE
				 BEGIN
					set @blocca = 1
				 END

			END TRY  
			BEGIN CATCH  
				 set @blocca = 1
			END CATCH 

		END
		ELSE
		BEGIN
			set @blocca = 1
		END

	END


	IF @blocca = 1
	BEGIN

		declare @nomeProcesso varchar(1000)

		set @nomeProcesso = isnull(@DPR_DOC_ID,'') + '-' + isnull(@DPR_ID,'')

		INSERT INTO CTL_blacklist( ip, statoBlocco, dataBlocco, paginaAttaccata, queryString, idPfu, motivoBlocco )
							values ('', 'log-attack', getdate(), 'ESECUZIONE_PROCESSI', '', @idPfu, 'Privilege escalation : Stored AF_CHECK_PROCESS_PERMISSION. Accesso non consentito al processo ' + @nomeProcesso )

		select top 0 'KO' as esito
	
	END
	ELSE
	BEGIN

		select 'OK' as esito

	END

END











GO
