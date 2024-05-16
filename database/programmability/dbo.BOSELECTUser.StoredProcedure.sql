USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[BOSELECTUser]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[BOSELECTUser] (@CurIdAzi INT, @IdPfuSel INT OUTPUT) AS
 DECLARE @NumeroRdo INT
 DECLARE @SedeOpLw INT
 DECLARE @SedeOpUp INT
 SELECT @SedeOpLw = aziGphValueOper FROM Aziende WHERE IdAzi = @CurIdAzi
 EXEC UpperRange @SedeOpLw, @SedeOpUp OUTPUT
  --Individua il venditore che copre l'area geografica  
  SELECT @IdPfuSel = NULL
  SELECT DISTINCT TOP 1 @IdPfuSel = DfSPfuGph.IdPfu
   FROM DfSPfuGph 
   INNER JOIN ProfiliUtente ON ProfiliUtente.IdPfu = DfSPfuGph.IdPfu
   WHERE (DfSPfuGph.gphValue BETWEEN @SedeOpLw AND @SedeOpUp) AND
    ProfiliUtente.pfuIdAzi = @CurIdAzi AND
    ProfiliUtente.pfuVenditore = 1 AND
    ProfiliUtente.pfuDeleted = 0
  
  IF @IdPfuSel IS NULL
  BEGIN
   -- In questo caso non vi sono venditori sull'area geografica selezionata
   -- oppure il venditore non ha selezionato un'area geografica
   -- Viene selezionato il venditore pi" scarico
   SELECT TOP 1 @IdPfuSel = ProfiliUtente.IdPfu
   FROM ProfiliUtente
   LEFT OUTER JOIN RdoElaborate ON ProfiliUtente.IdPfu = RdoElaborate.IdPfu
   WHERE pfuIdAzi = @CurIdAzi AND pfuVenditore = 1 AND pfuDeleted = 0
   ORDER BY RdoElaborate.NumeroRdo
   IF @IdPfuSel IS NULL
   BEGIN
     -- Viene selezionato l'amministratore dell'azienda destinataria
     SELECT TOP 1 @IdPfuSel = IdPfu 
     FROM ProfiliUtente WHERE pfuIdAzi = @CurIdAzi AND pfuAdmin = 1 AND pfuDeleted = 0
   END   
  END
  IF NOT (@IdPfuSel IS NULL)
  BEGIN
    --incrementa di uno il numero di Rdo Elaborate
    SELECT @NumeroRdo = NULL
    SELECT @NumeroRdo = RdoElaborate.NumeroRdo
    FROM RdoElaborate WHERE RdoElaborate.IdPfu = @IdPfuSel
    IF @NumeroRdo IS NULL
    BEGIN
      INSERT RdoElaborate(IdPfu,NumeroRdo) VALUES (@IdPfuSel,1)
    END
    IF NOT (@NumeroRdo IS NULL)
    BEGIN
      UPDATE RdoElaborate SET NumeroRdo = NumeroRdo + 1 
      WHERE IdPfu = @IdPfuSel 
    END
  END
  
  IF (@IdPfuSel IS NULL)
  BEGIN
    SELECT @IdPfuSel = -1
  END
GO
