USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[Fnzu_Aggiorna_Lng3]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.Fnzu_Aggiorna_Lng3    Script Date: 14/06/00 13.28.20 ******/
CREATE PROCEDURE [dbo].[Fnzu_Aggiorna_Lng3] (@lastDate DATETIME = NULL OUTPUT) AS
 DECLARE @ConfDate DATETIME
 SELECT @ConfDate = umdUltimaMod FROM srv_UltimaMod WHERE umdNome = 'FunzionalitaUtente'
 IF (@ConfDate IS NULL) /* Non accade le la vista e' in catalogo, ma per sicurezza diamo un OUTPUT */
 BEGIN
  /* Restituisce comunque tutti i valori cercati */
  SELECT IdTab, tabPadre, tabFiglio, tabIdMlng, tabTesto, tabPos, tabOrdine, tabProfili, tabDeleted AS flagDeleted, tabIType, tabProfiloAzi, tabSource, tabIcona, tabHidden,tabISubType, tabUse, tabIsPrimary,FnzuCodice
    FROM FunzionalitaUtente_Lng3
   ORDER BY IdTab
  SELECT @lastDate = GETDATE()
 END ELSE BEGIN
  IF (@lastDate IS NULL)
  SELECT IdTab, tabPadre, tabFiglio, tabIdMlng, tabTesto, tabPos, tabOrdine, tabProfili, tabDeleted AS flagDeleted, tabIType, tabProfiloAzi, tabSource, tabIcona, tabHidden,tabISubType, tabUse, tabIsPrimary,FnzuCodice
    FROM FunzionalitaUtente_Lng3
    ORDER BY IdTab
  ELSE
   IF (@lastDate < @ConfDate)
  SELECT IdTab, tabPadre, tabFiglio, tabIdMlng, tabTesto, tabPos, tabOrdine, tabProfili, tabDeleted AS flagDeleted, tabIType, tabProfiloAzi, tabSource, tabIcona, tabHidden,tabISubType, tabUse, tabIsPrimary,FnzuCodice
     FROM FunzionalitaUtente_Lng3
     WHERE tabUltimaMod > @lastDate
     ORDER BY IdTab
  SELECT @lastDate = @ConfDate
 END
GO
