USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[lng_Aggiorna_I]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[lng_Aggiorna_I] (@lastDate DATETIME = NULL OUTPUT) AS
 DECLARE @ConfDate DATETIME
 SELECT @ConfDate = umdUltimaMod FROM srv_UltimaMod WHERE umdNome = 'Lingue'
 IF (@ConfDate IS NULL) /* Non accade */
 BEGIN
  SELECT @lastDate = GETDATE()
  SELECT IdTab, tabTesto, lngSuffisso,lngDeleted AS flagDeleted
   FROM Lingue_I
   ORDER BY IdTab
 END ELSE BEGIN
  IF (@lastDate IS NULL)
   SELECT IdTab, tabTesto, lngSuffisso,lngDeleted AS flagDeleted
    FROM Lingue_I
    ORDER BY IdTab
  ELSE
   IF (@lastDate < @ConfDate)
    SELECT IdTab, tabTesto, lngSuffisso,lngDeleted AS flagDeleted
     FROM Lingue_I
     WHERE tabUltimaMod > @lastDate
     ORDER BY IdTab
  SELECT @lastDate = @ConfDate
 END
GO
