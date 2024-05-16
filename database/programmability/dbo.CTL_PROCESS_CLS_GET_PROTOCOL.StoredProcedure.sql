USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[CTL_PROCESS_CLS_GET_PROTOCOL]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CTL_PROCESS_CLS_GET_PROTOCOL] (@algoritmo varchar(50), @valIniziale varchar (50), @valFinale varchar (50), @valCorrente varchar (50), @valPrefisso varchar (50), @lIdMP int = -1 , @lIdAzi int = -1, @lIdPfu int)
AS
BEGIN

    SET NOCOUNT ON

	DECLARE @ReturnValue varchar (50)
	DECLARE @strAnno varchar (4)
	DECLARE @valAnnoValoreCorrente varchar (4)
	DECLARE @valoreCorrente varchar (6)
	DECLARE @valoreFin varchar (6)
	
	CREATE TABLE #TMP_GET_PROTOCOL(protocol varchar (50))

	IF @algoritmo = 'ProtocolloOfferta'
	BEGIN

		set @strAnno = SUBSTRING(CAST(YEAR(GETDATE()) AS varchar (4)), 3, 2)
		set @valAnnoValoreCorrente = SUBSTRING(@valCorrente, 10, 2)
		set @valoreCorrente = SUBSTRING(@valCorrente, 3, 6)
		set @valoreFin = SUBSTRING(@valFinale, 3, 6)

		IF (CAST(@valoreCorrente AS int) < CAST(@valoreFin AS int) And CAST(@valAnnoValoreCorrente AS int) >= CAST(@strAnno AS int))
		BEGIN

			set @valoreCorrente = CAST(@valoreCorrente AS int) + 1

			IF LEN(@valoreCorrente) > 6
				INSERT INTO #TMP_GET_PROTOCOL (protocol) SELECT '0'
			ELSE
				INSERT INTO #TMP_GET_PROTOCOL (protocol) SELECT 'PI' + SUBSTRING('000000', 1, 6 - LEN(@valoreCorrente)) + @valoreCorrente + '-' + @valAnnoValoreCorrente

		END
		ELSE
		BEGIN

			IF (CAST(@valAnnoValoreCorrente AS int) < CAST(@strAnno AS int))
				set @valAnnoValoreCorrente = @strAnno 
					
			INSERT INTO #TMP_GET_PROTOCOL (protocol) SELECT 'PI' + SUBSTRING('000000', 1, 6 - LEN(@valIniziale)) + @valIniziale + '-' + @valAnnoValoreCorrente

		END

	END
	ELSE IF @algoritmo = 'ProtocolBG'
	BEGIN

		set @valoreCorrente = SUBSTRING(@valCorrente, 3, 6)
		set @valoreFin = SUBSTRING(@valFinale, 3, 6)

		IF CAST(@valoreCorrente AS int) < CAST(@valoreFin AS int) 
			set @valoreCorrente = CAST(@valoreCorrente AS int) + 1
		else
			set @valoreCorrente = CAST(@valIniziale AS int) + 1

		IF LEN(@valoreCorrente) > 6
			INSERT INTO #TMP_GET_PROTOCOL (protocol) SELECT '0'
		ELSE
			INSERT INTO #TMP_GET_PROTOCOL (protocol) SELECT 'FE' + SUBSTRING('000000', 1, 6 - LEN(@valoreCorrente)) + @valoreCorrente 

	END

	SELECT * FROM #TMP_GET_PROTOCOL RETURN @@FETCH_STATUS

	DROP TABLE #TMP_GET_PROTOCOL

	SET NOCOUNT OFF

END

GO
