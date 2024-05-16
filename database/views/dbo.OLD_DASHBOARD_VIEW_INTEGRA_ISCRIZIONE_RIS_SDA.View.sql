USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_DASHBOARD_VIEW_INTEGRA_ISCRIZIONE_RIS_SDA]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [dbo].[OLD_DASHBOARD_VIEW_INTEGRA_ISCRIZIONE_RIS_SDA] as
select 
		p.idPfu
		,d.Titolo
		,a.aziRagioneSociale
		,d.DataInvio
		,d.ProtocolloRiferimento
		,d.Protocollo
		,d.tipoDoc as OPEN_DOC_NAME
		,d.id
		,case when r.DOC_NAME is not null then '0' else '1'end as bRead 
		,d.StatoFunzionale
		,d.StatoDoc
		,a.aziPartitaIVA
		,f.vatvalore_ft as CodiceFiscale
		,a.idazi
		, d.Data
		,a.idazi as idAziPartecipante
		,b.protocollo as ProtocolloCapoStipite
		,b.Id as ListaAlbi

FROM CTL_DOC d
     
	inner join ctl_doc II on II.id=d.LinkedDoc and II.TipoDoc='INTEGRA_ISCRIZIONE_SDA'
	inner join ctl_doc I on I.id=II.LinkedDoc  and I.tipodoc like 'ISTANZA_SDA_%'
	inner join ctl_doc B on B.id=I.LinkedDoc and b.tipodoc='BANDO_SDA'

	inner join profiliutente p on p.pfuidazi = d.Destinatario_Azi --des.IdAzi
	inner join aziende a on d.azienda = a.idazi
	left outer join CTL_DOC_READ r on r.DOC_NAME = d.TipoDoc and p.idpfu = r.idPfu and r.id_Doc = d.id
     left outer join dm_attributi f on d.azienda =f.lnk and f.dztnome = 'codicefiscale' and f.idapp=1

where d.StatoDoc <> 'Saved'
	and  d.tipoDoc = 'INTEGRA_ISCRIZIONE_RIS_SDA'
	




GO
