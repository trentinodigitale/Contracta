USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[fnz_Aggiorna]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[fnz_Aggiorna](@lastDate DATETIME = NULL OUTPUT) AS
 DECLARE @ConfDate DATETIME
 SELECT @ConfDate = umdUltimaMod FROM srv_UltimaMod WHERE umdNome = 'Funzionalita'
 IF (@ConfDate IS NULL) /* Non Accade */
 BEGIN
  SELECT @lastDate = GETDATE()
  SELECT IdFnz,rtrim(fnzNomeGruppo) AS fnzNomeGruppo,rtrim(fnzChiaveGruppo) AS fnzChiaveGruppo,rtrim(fnzSorgente) AS fnzSorgente,rtrim(fnzProfilo) AS fnzProfilo,fnzUltimaMod,fnzCancellato AS flagDeleted
   FROM Funzionalita
   ORDER BY IdFnz
 END ELSE BEGIN
  IF (@lastDate IS NULL)
   SELECT IdFnz,rtrim(fnzNomeGruppo) AS fnzNomeGruppo,rtrim(fnzChiaveGruppo) AS fnzChiaveGruppo,rtrim(fnzSorgente) AS fnzSorgente,rtrim(fnzProfilo) AS fnzProfilo,fnzUltimaMod,fnzCancellato AS flagDeleted
   FROM Funzionalita
   ORDER BY IdFnz
  ELSE
   IF (@lastDate < @ConfDate)
    SELECT IdFnz,rtrim(fnzNomeGruppo) AS fnzNomeGruppo,rtrim(fnzChiaveGruppo) AS fnzChiaveGruppo,rtrim(fnzSorgente) AS fnzSorgente,rtrim(fnzProfilo) AS fnzProfilo,fnzUltimaMod,fnzCancellato AS flagDeleted
     FROM Funzionalita   
     WHERE fnzUltimaMod > @lastDate
     ORDER BY IdFnz
  SELECT @lastDate = @ConfDate
 END
GO
