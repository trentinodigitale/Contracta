USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[SIMOG_PWD_CREATE_FROM_IDPFU_RUP]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SIMOG_PWD_CREATE_FROM_IDPFU_RUP] ( @Rup int, @newid int output, @IdUser int = 0 )
AS
BEGIN

	SET NOCOUNT ON

	set @newId = 0

	IF ( @IdUser = 0 )
		SET @IdUser = @Rup

	--- VERIFICA SE ESISTE UN DOCUMENTO DI CAMBIO PWD SIMOG IN LAVORAZIONE PER L'UTENTE RUP E LO APRE. ALTRIMENTI NE CREA UNO
	select @newId = max(id) from CTL_DOC with(nolock) where Destinatario_User = @Rup and deleted = 0 and TipoDoc = 'SIMOG_PWD' and StatoFunzionale = 'InLavorazione'

	IF @newId is null
	BEGIN

		INSERT INTO CTL_DOC( IdPfu, idPfuInCharge, Destinatario_User, TipoDoc, Titolo, Body  )
					select  @IdUser as IdPfu,
							@IdUser as idPfuInCharge,
							idpfu as Destinatario_User,
							'SIMOG_PWD' as TipoDoc,
							pfuNome as Titolo,
							pfuCodiceFiscale as Body
						from ProfiliUtente with(nolock) 
						where idpfu = @Rup


		SET @newid = SCOPE_IDENTITY()

	END

END

GO
