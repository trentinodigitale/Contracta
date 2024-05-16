USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_INSERT_SERVICE_REQUEST]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[OLD2_INSERT_SERVICE_REQUEST] ( @integrazione varchar(50), @operazioneRichiesta varchar(50), @idPfu INT,  @idDocRichiedente INT = NULL )
AS
BEGIN

	SET NOCOUNT ON

	declare @idAzi INT
	declare @statoRichiesta varchar(20)

	set @statoRichiesta = 'Inserita'

	-- SE ESISTE IL PARAMETRO CON CONTESTO 'SERVICE_REQUEST' E OGGETTO IL NOME DELL'INTEGRAZIONE, ED LA PROPRIETA ATTIVO A YES
	IF dbo.PARAMETRI( 'SERVICE_REQUEST', @integrazione, 'ATTIVO', 'NO', -1) = 'YES'
	BEGIN

		select @idAzi = pfuIdAzi from profiliutente with(nolock) where idpfu = @idPfu

		INSERT INTO Services_Integration_Request([idRichiesta],[integrazione],[operazioneRichiesta],[statoRichiesta],[isOld],[dateIn],[idPfu],[idAzi])
									VALUES  (@idDocRichiedente, @integrazione, @operazioneRichiesta, @statoRichiesta,0,getDate(),@idPfu,@idAzi)


	END

END


GO
