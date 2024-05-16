USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[rd_Aggiorna]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[rd_Aggiorna](@lastDate DATETIME = NULL OUTPUT) AS
 DECLARE @ConfDate DATETIME
 SELECT @ConfDate = umdUltimaMod FROM srv_UltimaMod WHERE umdNome = 'RegDefault'
 IF (@ConfDate IS NULL) /* Non Accade */
 BEGIN
  SELECT @lastDate = GETDATE()
  SELECT IdRd AS IdTab, rdIdMp AS tabIdMp, rdPath AS tabPath, rdKey AS tabKey, rdDefValue AS tabDefValue, 
         rdDeleted AS flagDeleted, rdUltimaMod AS tabUltimaMod
   FROM RegDefault
     ORDER BY IdRd
 END ELSE BEGIN
  IF (@lastDate IS NULL)
  SELECT IdRd AS IdTab, rdIdMp AS tabIdMp, rdPath AS tabPath, rdKey AS tabKey, rdDefValue AS tabDefValue, 
         rdDeleted AS flagDeleted , rdUltimaMod AS tabUltimaMod
   FROM RegDefault
     ORDER BY IdRd
  ELSE
   IF (@lastDate < @ConfDate)
  SELECT IdRd AS IdTab, rdIdMp AS tabIdMp, rdPath AS tabPath, rdKey AS tabKey, rdDefValue AS tabDefValue, 
         rdDeleted AS flagDeleted , rdUltimaMod AS tabUltimaMod
   FROM RegDefault
  WHERE rdUltimaMod > @lastDate
     ORDER BY IdRd
  SELECT @lastDate = @ConfDate
 END
GO
