USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[vc_Aggiorna]    Script Date: 5/16/2024 2:38:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[vc_Aggiorna](@lastDate DATETIME = NULL OUTPUT) AS
 DECLARE @ConfDate DATETIME
 SELECT @ConfDate = umdUltimaMod FROM srv_UltimaMod WHERE umdNome = 'VersioneComponenti'
 IF (@ConfDate IS NULL) /* Non Accade */
 BEGIN
  SELECT @lastDate = GETDATE()
  SELECT IdVc,rtrim(vcSO) AS vcSO,rtrim(vcObject) AS vcObject, vcVersion, vcStato, rtrim(vcSito) AS vcSito,rtrim(vcDescr) AS vcDescr,vcUltimaMod,vcDeleted AS flagDeleted
   FROM VersioneComponenti
   ORDER BY IdVc
 END ELSE BEGIN
  IF (@lastDate IS NULL)
  SELECT IdVc,rtrim(vcSO) AS vcSO,rtrim(vcObject) AS vcObject, vcVersion, vcStato, rtrim(vcSito) AS vcSito,rtrim(vcDescr) AS vcDescr,vcUltimaMod,vcDeleted AS flagDeleted
   FROM VersioneComponenti
   ORDER BY IdVc
  ELSE
   IF (@lastDate < @ConfDate)
  SELECT IdVc,rtrim(vcSO) AS vcSO,rtrim(vcObject) AS vcObject, vcVersion, vcStato, rtrim(vcSito) AS vcSito,rtrim(vcDescr) AS vcDescr,vcUltimaMod,vcDeleted AS flagDeleted
     FROM VersioneComponenti   
     WHERE vcUltimaMod > @lastDate
     ORDER BY IdVc
  SELECT @lastDate = @ConfDate
 END
GO
