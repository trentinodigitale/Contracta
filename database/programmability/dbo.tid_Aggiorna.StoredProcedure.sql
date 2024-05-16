USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[tid_Aggiorna]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[tid_Aggiorna](@lastDate DATETIME = NULL OUTPUT) AS
 DECLARE @ConfDate DATETIME
 SELECT @ConfDate = umdUltimaMod FROM srv_UltimaMod WHERE umdNome = 'TipiDati'
 IF (@ConfDate IS NULL) /* Non accade */
 BEGIN
  SELECT @lastDate = GETDATE()
  SELECT IdTid, tidNome, tidTipoMem, tidTipoDom,tidDeleted AS flagDeleted
   FROM TipiDati
   ORDER BY IdTid
 END ELSE BEGIN
  IF (@lastDate IS NULL)
    SELECT IdTid, tidNome, tidTipoMem, tidTipoDom,tidDeleted AS flagDeleted
    FROM TipiDati
    ORDER BY IdTid
  ELSE
   IF (@lastDate < @ConfDate)
    SELECT IdTid, tidNome, tidTipoMem, tidTipoDom,tidDeleted AS flagDeleted
     FROM TipiDati
     WHERE tidUltimaMod > @lastDate
     ORDER BY IdTid
  SELECT @lastDate = @ConfDate
 END
GO
