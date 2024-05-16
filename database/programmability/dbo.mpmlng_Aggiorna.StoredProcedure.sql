USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[mpmlng_Aggiorna]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[mpmlng_Aggiorna] (@lastDate DATETIME = NULL OUTPUT) AS
 DECLARE @ConfDate DATETIME
 SELECT @ConfDate = umdUltimaMod FROM srv_UltimaMod WHERE umdNome = 'MPMultiLinguismo'
 IF (@ConfDate IS NULL) /* Non accade */
 BEGIN
  SELECT @lastDate = GETDATE()
  SELECT IdMpMlng, mpmlngIdMp, mpmlngMPKey, mpmlngMlngKey, mpmlngDeleted AS flagDeleted, mpmlngUltimaMod
  FROM MPMultiLinguismo
  ORDER BY IdMpMlng
 END ELSE BEGIN
  IF (@lastDate IS NULL)
  SELECT IdMpMlng, mpmlngIdMp, mpmlngMPKey, mpmlngMlngKey, mpmlngDeleted AS flagDeleted, mpmlngUltimaMod
  FROM MPMultiLinguismo
  ORDER BY IdMpMlng
  ELSE
   IF (@lastDate < @ConfDate)
  SELECT IdMpMlng, mpmlngIdMp, mpmlngMPKey, mpmlngMlngKey, mpmlngDeleted AS flagDeleted, mpmlngUltimaMod
    FROM MPMultiLinguismo
    WHERE mpmlngUltimaMod > @lastDate
  ORDER BY IdMpMlng
  SELECT @lastDate = @ConfDate
 END
GO
