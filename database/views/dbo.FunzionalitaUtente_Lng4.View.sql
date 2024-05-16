USE [AFLink_TND]
GO
/****** Object:  View [dbo].[FunzionalitaUtente_Lng4]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  View dbo.FunzionalitaUtente_Lng4    Script Date: 14/06/00 13.27.28 ******/
CREATE VIEW [dbo].[FunzionalitaUtente_Lng4]
AS
SELECT FunzionalitaUtente.IdFnzu AS IdTab, 
       FunzionalitaUtente.FnzuPadre AS tabPadre, 
       FunzionalitaUtente.FnzuFiglio AS tabFiglio, 
       FunzionalitaUtente.FnzuIdmultilng AS tabIdMlng, 
       Multilinguismo.mlngDesc_Lng4 AS tabTesto, 
       FunzionalitaUtente.FnzuPos AS tabPos,  
       FunzionalitaUtente.FnzuOrdine AS tabOrdine,
       FunzionalitaUtente.FnzuProfili AS tabProfili,
       FunzionalitaUtente.FnzuDeleted AS tabDeleted,    
       FunzionalitaUtente.FnzuIType AS tabIType,    
       FunzionalitaUtente.FnzuProfiloAzi AS tabProfiloAzi,    
       FunzionalitaUtente.FnzuSource AS tabSource,    
       FunzionalitaUtente.FnzuIcona AS tabIcona,    
       FunzionalitaUtente.FnzuHidden AS tabHidden,
       FunzionalitaUtente.FnzuUltimaMod AS tabUltimaMod,
       FunzionalitaUtente.FnzuISubType AS tabISubType,
       FunzionalitaUtente.FnzuUse AS tabUse,    
       FunzionalitaUtente.FnzuIsPrimary AS tabIsPrimary,
       FunzionalitaUtente.FnzuCodice as FnzuCodice
  FROM FunzionalitaUtente, Multilinguismo
 WHERE FunzionalitaUtente.FnzuIdmultilng = Multilinguismo.IdMultilng
   AND FunzionalitaUtente.FnzuUltimaMod >= Multilinguismo.MlngUltimaMod
UNION ALL
SELECT FunzionalitaUtente.IdFnzu AS IdTab, 
       FunzionalitaUtente.FnzuPadre AS tabPadre, 
       FunzionalitaUtente.FnzuFiglio AS tabFiglio, 
       FunzionalitaUtente.FnzuIdmultilng AS tabIdMlng, 
       Multilinguismo.mlngDesc_Lng4 AS tabTesto, 
       FunzionalitaUtente.FnzuPos AS tabPos,  
       FunzionalitaUtente.FnzuOrdine AS tabOrdine,
       FunzionalitaUtente.FnzuProfili AS tabProfili,
       FunzionalitaUtente.FnzuDeleted AS tabDeleted,    
       FunzionalitaUtente.FnzuIType AS tabIType,    
       FunzionalitaUtente.FnzuProfiloAzi AS tabProfiloAzi,    
       FunzionalitaUtente.FnzuSource AS tabSource,    
       FunzionalitaUtente.FnzuIcona AS tabIcona,    
       FunzionalitaUtente.FnzuHidden AS tabHidden,
       Multilinguismo.MlngUltimaMod AS tabUltimaMod,
       FunzionalitaUtente.FnzuISubType AS tabISubType,
       FunzionalitaUtente.FnzuUse AS tabUse,    
       FunzionalitaUtente.FnzuIsPrimary AS tabIsPrimary,
       FunzionalitaUtente.FnzuCodice as FnzuCodice
  FROM FunzionalitaUtente, Multilinguismo
 WHERE FunzionalitaUtente.FnzuIdmultilng = Multilinguismo.IdMultilng
   AND FunzionalitaUtente.FnzuUltimaMod < Multilinguismo.MlngUltimaMod
GO
