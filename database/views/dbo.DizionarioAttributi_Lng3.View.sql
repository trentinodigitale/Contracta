USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DizionarioAttributi_Lng3]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  View dbo.DizionarioAttributi_Lng3    Script Date: 22/06/00 18.09.55 ******/
CREATE VIEW [dbo].[DizionarioAttributi_Lng3]
AS
SELECT DizionarioAttributi.IdDzt AS IdTab, 
       DescsLng3.dscTesto tabTesto, 
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
  FROM DizionarioAttributi, DescsLng3 
 WHERE DizionarioAttributi.dztIdDsc = DescsLng3.IdDsc
   AND DizionarioAttributi.dztUltimaMod >= DescsLng3.dscUltimaMod
UNION ALL
SELECT DizionarioAttributi.IdDzt AS IdTab, 
       DescsLng3.dscTesto tabTesto, 
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
       DescsLng3.dscUltimaMod AS tabUltimaMod,
       DizionarioAttributi.dztTipologiaStorico, 
       DizionarioAttributi.dztMemStorico
  FROM DizionarioAttributi, DescsLng3 
 WHERE DizionarioAttributi.dztIdDsc = DescsLng3.IdDsc
   AND DizionarioAttributi.dztUltimaMod < DescsLng3.dscUltimaMod
GO
