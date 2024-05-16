USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[dzt_Aggiorna_E]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.dzt_Aggiorna_E    Script Date: 22/06/00 18.12.17 ******/
CREATE PROCEDURE [dbo].[dzt_Aggiorna_E] (@lastDate DATETIME = NULL OUTPUT) AS
 DECLARE @ConfDate DATETIME
 SELECT @ConfDate = umdUltimaMod FROM srv_UltimaMod WHERE umdNome = 'DizionarioAttributi'
 IF (@ConfDate IS NULL) /* Non accade */
 BEGIN
  SELECT @lastDate = GETDATE()
  SELECT IdTab, tabTesto, dztNome, dztValoreDef, dztDataCreazione, dztIdTid, 
   dztIstanzeTotali, dztValidita, dztIdGum, dztIdUmsDefault, dztLunghezza, 
   dztCifreDecimali, dztFRegObblig, dztFAziende, dztFArticoli, dztFOFID, 
   dztFValutazione, dztFIndicatoreQTA, dztPesoFvaDefault, dztTabellaSpeciale, 
   dztCampoSpeciale, _dztFIndicatore, dztFMascherato, _dztFOfferta, _verso, 
   _dztAppartenenza, dztFQualita, dztProfili, dztMultiValue, dztLocked,dztdeleted AS flagDeleted,
   dztTipologiaStorico, 
   dztMemStorico  /* per il client per le 3 SELECT*/
   FROM DizionarioAttributi_E
   ORDER BY IdTab
 END ELSE BEGIN
  IF (@lastDate IS NULL)
   SELECT IdTab, tabTesto, dztNome, dztValoreDef, dztDataCreazione, dztIdTid, 
    dztIstanzeTotali, dztValidita, dztIdGum, dztIdUmsDefault, dztLunghezza, 
    dztCifreDecimali, dztFRegObblig, dztFAziende, dztFArticoli, dztFOFID, 
    dztFValutazione, dztFIndicatoreQTA, dztPesoFvaDefault, dztTabellaSpeciale, 
    dztCampoSpeciale, _dztFIndicatore, dztFMascherato, _dztFOfferta, _verso, 
   _dztAppartenenza, dztFQualita, dztProfili, dztMultiValue, dztLocked,dztdeleted AS flagDeleted,
   dztTipologiaStorico, 
   dztMemStorico  
    FROM DizionarioAttributi_E
    ORDER BY IdTab
  ELSE
   IF (@lastDate < @ConfDate)
    SELECT IdTab, tabTesto, dztNome, dztValoreDef, dztDataCreazione, dztIdTid, 
     dztIstanzeTotali, dztValidita, dztIdGum, dztIdUmsDefault, dztLunghezza, 
     dztCifreDecimali, dztFRegObblig, dztFAziende, dztFArticoli, dztFOFID, 
     dztFValutazione, dztFIndicatoreQTA, dztPesoFvaDefault, dztTabellaSpeciale, 
     dztCampoSpeciale, _dztFIndicatore, dztFMascherato, _dztFOfferta, _verso, 
     _dztAppartenenza, dztFQualita, dztProfili, dztMultiValue, dztLocked,dztdeleted AS flagDeleted,
   dztTipologiaStorico, 
   dztMemStorico  
     FROM DizionarioAttributi_E
     WHERE tabUltimaMod > @lastDate
     ORDER BY IdTab
  SELECT @lastDate = @ConfDate
 END
GO
