USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[dg_Aggiorna_Lng3]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[dg_Aggiorna_Lng3] (@lastDate DATETIME = NULL OUTPUT) AS
 DECLARE @ConfDate DATETIME
 SELECT @ConfDate = umdUltimaMod FROM srv_UltimaMod WHERE umdNome = 'DominiGerarchici'
 IF (@ConfDate IS NULL) /* Non accade le la vista e' in catalogo, ma per sicurezza diamo un OUTPUT */
 BEGIN
  /* Restituisce comunque tutti i valori cercati */
  SELECT IdTab, tabTesto, tabTipo, tabValue, tabCode, tabPath, tabLiv, tabFoglia, tabLenPathPadre, tabDeleted AS flagDeleted, tabUltimaMod
   FROM DominiGerarchici_Lng3
   ORDER BY IdTab
  SELECT @lastDate = GETDATE()
 END ELSE BEGIN
  IF (@lastDate IS NULL)
  SELECT IdTab, tabTesto, tabTipo, tabValue, tabCode, tabPath, tabLiv, tabFoglia, tabLenPathPadre, tabDeleted AS flagDeleted, tabUltimaMod
   FROM DominiGerarchici_Lng3
    ORDER BY IdTab
  ELSE
   IF (@lastDate < @ConfDate)
     SELECT IdTab, tabTesto, tabTipo, tabValue, tabCode, tabPath, tabLiv, tabFoglia, tabLenPathPadre, tabDeleted AS flagDeleted, tabUltimaMod
       FROM DominiGerarchici_Lng3
      WHERE tabUltimaMod > @lastDate
     ORDER BY IdTab
  SELECT @lastDate = @ConfDate
 END
GO
