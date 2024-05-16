USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_ISCRIZIONEALBOFORNITORI_RISPOSTE]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[DASHBOARD_VIEW_ISCRIZIONEALBOFORNITORI_RISPOSTE]  AS

select 

a.id as idmsg,
a.IdPfu,
-1 as msgIType,
-1 as msgIsubType,
a.titolo as Oggetto,
a.data,
'' as bread,
a.Protocollo as ProtocolloBando,
--Protocollo as ProtocolloOfferta,
a.DataScadenza as ReceidevDataMsg,
--cast(Body as nvarchar (2000)) as Oggetto,
'' as Tipologia,
a.DataScadenza AS ExpiryDate,
'' as ImportoBaseAsta,
'' as tipoprocedura,
'' as StatoGd,
a.Fascicolo,
'' as CriterioAggiudicazione,
'' as CriterioFormulazioneOfferta
,'1' as OpenDettaglio
,0 as Scaduto
,'ISTANZA_AlboOperaEco_QF' as OPEN_DOC_NAME ,
a.statofunzionale,
a.LinkedDoc as idbando,
b.body as titolo


from CTL_DOC a
--left outer join CTL_DOC_DESTINATARI on CTL_DOC_DESTINATARI.idheader=CTL_DOC.Id
--cross join dm_attributi 
--inner join profiliutente p on  p.pfuidazi = lnk

left outer join ctl_doc b on b.TipoDoc = 'bando_QF' and b.id=a.linkeddoc and b.deleted=0

where a.TipoDoc='ISTANZA_AlboOperaEco_QF'
and a.deleted=0
--and idapp=1 and dztnome='AttivazioneValutazione'
--		  and vatvalore_ft='10099'









GO
