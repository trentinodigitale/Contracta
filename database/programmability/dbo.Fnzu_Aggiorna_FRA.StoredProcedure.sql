USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[Fnzu_Aggiorna_FRA]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[Fnzu_Aggiorna_FRA] (@lastDate DATETIME = NULL OUTPUT) AS
 DECLARE @ConfDate DATETIME
 SELECT @ConfDate = umdUltimaMod FROM srv_UltimaMod WHERE umdNome = 'FunzionalitaUtente'
 IF (@ConfDate IS NULL) /* Non accade le la vista e' in catalogo, ma per sicurezza diamo un OUTPUT */
 BEGIN
  /* Restituisce comunque tutti i valori cercati */
  SELECT IdTab, tabPadre, tabFiglio, tabIdMlng, tabTesto, tabPos, tabOrdine, tabProfili, tabDeleted AS flagDeleted, tabIType, tabProfiloAzi, tabSource, tabIcona, tabHidden,tabISubType, tabUse, tabIsPrimary,FnzuCodice
   FROM FunzionalitaUtente_FRA
   ORDER BY IdTab
  SELECT @lastDate = GETDATE()
 END ELSE BEGIN
  IF (@lastDate IS NULL)
  SELECT IdTab, tabPadre, tabFiglio, tabIdMlng, tabTesto, tabPos, tabOrdine, tabProfili, tabDeleted AS flagDeleted, tabIType, tabProfiloAzi, tabSource, tabIcona, tabHidden,tabISubType, tabUse, tabIsPrimary,FnzuCodice
    FROM FunzionalitaUtente_FRA
    ORDER BY IdTab
  ELSE
   IF (@lastDate < @ConfDate)
  SELECT IdTab, tabPadre, tabFiglio, tabIdMlng, tabTesto, tabPos, tabOrdine, tabProfili, tabDeleted AS flagDeleted, tabIType, tabProfiloAzi, tabSource, tabIcona, tabHidden,tabISubType, tabUse, tabIsPrimary,FnzuCodice
     FROM FunzionalitaUtente_FRA
     WHERE tabUltimaMod > @lastDate
     ORDER BY IdTab
  SELECT @lastDate = @ConfDate
 END
GO
