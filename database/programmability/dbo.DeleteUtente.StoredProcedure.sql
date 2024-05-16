USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[DeleteUtente]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[DeleteUtente] ( @IdAzi int, @idPfu int = -100 )
AS
BEGIN

	SET NOCOUNT ON

	-- SE E' STATA RICHIESTA LA CANCELLAZIONE AVENDO L'IDAZI
	IF @idPfu = -100
	BEGIN

		DELETE FROM ProfiliUtenteAttrib WHERE IdPfu IN ( select IdPfu from ProfiliUtente with(nolock) where pfuIdAzi = @IdAzi )
		DELETE FROM ProfiliUtente WHERE pfuIdAzi = @IdAzi
		

	END
	ELSE
	BEGIN

		-- SE E' STATA RICHIESTA LA CANCELLAZIONE DI UNO SPECIFICO IDPFU
		DELETE FROM ProfiliUtente WHERE IdPfu = @idPfu
		DELETE FROM ProfiliUtenteAttrib WHERE IdPfu = @idPfu

	END

	

END
GO
