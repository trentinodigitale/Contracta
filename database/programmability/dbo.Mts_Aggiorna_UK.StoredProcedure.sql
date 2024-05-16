USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[Mts_Aggiorna_UK]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[Mts_Aggiorna_UK] (@lastDate DATETIME = NULL OUTPUT) AS
 DECLARE @ConfDate DATETIME
 SELECT @ConfDate = umdUltimaMod FROM srv_UltimaMod WHERE umdNome = 'MotivazioneScarti'
 IF (@ConfDate IS NULL) /* Non accade le la vista e' in catalogo, ma per sicurezza diamo un OUTPUT */
 BEGIN
  /* Restituisce comunque tutti i valori cercati */
  SELECT IdTab, tabTesto, tabCode,tabDeleted AS flagDeleted
   FROM MotivazioneScarti_UK
   ORDER BY IdTab
  SELECT @lastDate = GETDATE()
 END ELSE BEGIN
  IF (@lastDate IS NULL)
   SELECT IdTab, tabTesto, tabCode,tabDeleted AS flagDeleted
    FROM MotivazioneScarti_UK
    ORDER BY IdTab
  ELSE
   IF (@lastDate < @ConfDate)
    SELECT IdTab, tabTesto, tabCode,tabDeleted AS flagDeleted
     FROM MotivazioneScarti_UK
     WHERE tabUltimaMod > @lastDate
     ORDER BY IdTab
  SELECT @lastDate = @ConfDate
 END
GO
