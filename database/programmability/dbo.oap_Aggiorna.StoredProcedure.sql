USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[oap_Aggiorna]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[oap_Aggiorna](@lastDate DATETIME = NULL OUTPUT) AS
 DECLARE @ConfDate DATETIME
 SELECT @ConfDate = umdUltimaMod FROM srv_UltimaMod WHERE umdNome = 'OggettiApplicativi'
 IF (@ConfDate IS NULL) /* Non Accade */
 BEGIN
  SELECT @lastDate = GETDATE()
  SELECT IdOap,oapVersione,rtrim(oapNomeOggetto) AS oapNomeOggetto,rtrim(oapCriterio) AS oapCriterio,oapDatiCriterio,rtrim(oapProfilo) AS oapProfilo,oapCancellato AS flagDeleted,oapUltimaMod
   FROM OggettiApplicativi
   ORDER BY IdOap
 END ELSE BEGIN
  IF (@lastDate IS NULL)
  SELECT IdOap,oapVersione,rtrim(oapNomeOggetto) AS oapNomeOggetto,rtrim(oapCriterio) AS oapCriterio,oapDatiCriterio,rtrim(oapProfilo) AS oapProfilo,oapCancellato AS flagDeleted,oapUltimaMod
   FROM OggettiApplicativi
   ORDER BY IdOap
  ELSE
   IF (@lastDate < @ConfDate)
  SELECT IdOap,oapVersione,rtrim(oapNomeOggetto) AS oapNomeOggetto,rtrim(oapCriterio) AS oapCriterio,oapDatiCriterio,rtrim(oapProfilo) AS oapProfilo,oapCancellato AS flagDeleted,oapUltimaMod
     FROM OggettiApplicativi   
     WHERE oapUltimaMod > @lastDate
     ORDER BY IdOap
  SELECT @lastDate = @ConfDate
 END
GO
