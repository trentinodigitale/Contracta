USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DizionarioAttributi_FRA]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE VIEW [dbo].[DizionarioAttributi_FRA]
AS
SELECT DizionarioAttributi.IdDzt AS IdTab, 
       DescsFRA.dscTesto tabTesto, 
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
  FROM DizionarioAttributi, DescsFRA 
 WHERE DizionarioAttributi.dztIdDsc = DescsFRA.IdDsc
   AND DizionarioAttributi.dztUltimaMod >= DescsFRA.dscUltimaMod
UNION ALL
SELECT DizionarioAttributi.IdDzt AS IdTab, 
       DescsFRA.dscTesto tabTesto, 
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
       DescsFRA.dscUltimaMod AS tabUltimaMod,
       DizionarioAttributi.dztTipologiaStorico, 
       DizionarioAttributi.dztMemStorico
  FROM DizionarioAttributi, DescsFRA 
 WHERE DizionarioAttributi.dztIdDsc = DescsFRA.IdDsc
   AND DizionarioAttributi.dztUltimaMod < DescsFRA.dscUltimaMod
GO
