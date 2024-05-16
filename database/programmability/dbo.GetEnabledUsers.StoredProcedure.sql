USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[GetEnabledUsers]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GetEnabledUsers](
                                   @IdPfuMitt INT, 
                                   @IdAziDest INT, 
                                   @IType     SMALLINT, 
                                   @ISubType  SMALLINT
                                 )
AS
DECLARE @fnzuPos INT
SELECT @fnzuPos = fnzuPos 
  FROM FunzionalitaUtente 
 WHERE fnzuIType = @iType
   AND fnzuISubType = @iSubType
   AND fnzuDeleted = 0
IF @fnzuPos IS NULL
   BEGIN
        RAISERROR ('FunzionalitO [%d;%d] non trovata in FunzionalitaUtente', 16, 1, @iType, @iSubType)
        RETURN 99
   END
IF EXISTS (SELECT * FROM DFBPfuGph WHERE IdPfu = @IdPfuMitt)
        BEGIN
                SELECT IdPfu 
                  FROM ProfiliUtente 
                 WHERE pfuIdAzi = @IdAziDest
                   AND SUBSTRING (pfuFunzionalita, @fnzuPos, 1) = '1'
                   AND pfuDeleted = 0
                   AND IdPfu <> @IdPfuMitt
                   AND IdPfu IN (SELECT pfugphDest.IdPfu 
                                   FROM DFBPfuGph pfugphDest, DFBPfuGph pfugphMitt, DominiGerarchici a, DominiGerarchici b
                                  WHERE pfugphMitt.IdPfu = @IdPfuMitt
                                    AND pfugphMitt.gphValue = b.dgCodiceInterno
                                    AND b.dgTipoGerarchia = 17
                                    AND a.dgTipoGerarchia = 17
                                    AND b.dgDeleted = 0
                                    AND a.dgDeleted = 0
                                    AND b.dgpath LIKE a.dgPath + '%'
                                    AND pfugphDest.gphValue = a.dgCodiceInterno)
                UNION 
                
                SELECT IdPfu 
                  FROM ProfiliUtente 
                 WHERE pfuIdAzi = @IdAziDest
                   AND SUBSTRING (pfuFunzionalita, @fnzuPos, 1) = '1'
                   AND pfuDeleted = 0
                   AND IdPfu <> @IdPfuMitt
                   AND IdPfu NOT IN (SELECT pfugphDest.IdPfu 
                                       FROM DFBPfuGph pfugphDest)
        END
ELSE
        BEGIN
                SELECT IdPfu 
                  FROM ProfiliUtente 
                 WHERE pfuIdAzi = @IdAziDest
                   AND SUBSTRING (pfuFunzionalita, @fnzuPos, 1) = '1'
                   AND pfuDeleted = 0
                   AND IdPfu <> @IdPfuMitt
        END
GO
