USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DizionarioAttributi_E]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  View dbo.DizionarioAttributi_E    Script Date: 22/06/00 18.09.55 ******/
CREATE VIEW [dbo].[DizionarioAttributi_E]
AS
SELECT DizionarioAttributi.IdDzt AS IdTab, 
       DescsE.dscTesto tabTesto, 
       DizionarioAttributi.dztNome, 
       DizionarioAttributi.dztValoreDef, 
       DizionarioAttributi.dztDataCreazione, 
       DizionarioAttributi.dztIdTid, 
       DizionarioAttributi.dztIstanzeTotali, 
       DizionarioAttributi.dztValidita, 
       DizionarioAttributi.dztIdGum, 
       DizionarioAttributi.dztIdUmsDefault, 
       DizionarioAttributi.dztLunghezza, 
       DizionarioAttributi.dztCifreDecimali, 
       DizionarioAttributi.dztFRegObblig, 
       DizionarioAttributi.dztFAziende, 
       DizionarioAttributi.dztFArticoli, 
       DizionarioAttributi.dztFOFID, 
       DizionarioAttributi.dztFValutazione, 
       DizionarioAttributi.dztFIndicatoreQTA, 
       DizionarioAttributi.dztPesoFvaDefault, 
       DizionarioAttributi.dztTabellaSpeciale, 
       DizionarioAttributi.dztCampoSpeciale, 
       DizionarioAttributi._dztFIndicatore, 
       DizionarioAttributi.dztFMascherato, 
       DizionarioAttributi._dztFOfferta, 
       DizionarioAttributi._verso, 
       DizionarioAttributi._dztAppartenenza, 
       DizionarioAttributi.dztFQualita, 
       DizionarioAttributi.dztProfili, 
       DizionarioAttributi.dztMultiValue,
       DizionarioAttributi.dztLocked,
       DizionarioAttributi.dztDeleted,
       DizionarioAttributi.dztUltimaMod AS tabUltimaMod,
       DizionarioAttributi.dztTipologiaStorico, 
       DizionarioAttributi.dztMemStorico
  FROM DizionarioAttributi, DescsE 
 WHERE DizionarioAttributi.dztIdDsc = DescsE.IdDsc
   AND DizionarioAttributi.dztUltimaMod >= DescsE.dscUltimaMod
UNION ALL
SELECT DizionarioAttributi.IdDzt AS IdTab, 
       DescsE.dscTesto tabTesto, 
       DizionarioAttributi.dztNome, 
       DizionarioAttributi.dztValoreDef, 
       DizionarioAttributi.dztDataCreazione, 
       DizionarioAttributi.dztIdTid, 
       DizionarioAttributi.dztIstanzeTotali, 
       DizionarioAttributi.dztValidita, 
       DizionarioAttributi.dztIdGum, 
       DizionarioAttributi.dztIdUmsDefault, 
       DizionarioAttributi.dztLunghezza, 
       DizionarioAttributi.dztCifreDecimali, 
       DizionarioAttributi.dztFRegObblig, 
       DizionarioAttributi.dztFAziende, 
       DizionarioAttributi.dztFArticoli, 
       DizionarioAttributi.dztFOFID, 
       DizionarioAttributi.dztFValutazione, 
       DizionarioAttributi.dztFIndicatoreQTA, 
       DizionarioAttributi.dztPesoFvaDefault, 
       DizionarioAttributi.dztTabellaSpeciale, 
       DizionarioAttributi.dztCampoSpeciale, 
       DizionarioAttributi._dztFIndicatore, 
       DizionarioAttributi.dztFMascherato, 
       DizionarioAttributi._dztFOfferta, 
       DizionarioAttributi._verso, 
       DizionarioAttributi._dztAppartenenza, 
       DizionarioAttributi.dztFQualita, 
       DizionarioAttributi.dztProfili, 
       DizionarioAttributi.dztMultiValue,
       DizionarioAttributi.dztLocked,
       DizionarioAttributi.dztDeleted,
       DescsE.dscUltimaMod AS tabUltimaMod,
       DizionarioAttributi.dztTipologiaStorico, 
       DizionarioAttributi.dztMemStorico
  FROM DizionarioAttributi, DescsE 
 WHERE DizionarioAttributi.dztIdDsc = DescsE.IdDsc
   AND DizionarioAttributi.dztUltimaMod < DescsE.dscUltimaMod
GO
