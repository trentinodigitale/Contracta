USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_DASHBOARD_VIEW_SCARTO_ISCRIZIONE]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


---------------------------------------------------------------
--[OK]per filtrare i deleted=1
---------------------------------------------------------------

CREATE view [dbo].[OLD2_DASHBOARD_VIEW_SCARTO_ISCRIZIONE] as
select 
		d.Titolo
		,a.aziRagioneSociale
		,d.DataInvio
		,d.ProtocolloRiferimento
		,d.Protocollo
--		,d1.vatvalore_ft as CancellatoDiUfficio
--		,e.vatvalore_ft as CarBelongTo
		,d.tipoDoc as OPEN_DOC_NAME
		,d.id
--		,case when r.DOC_NAME is not null then '0' else '1'end as bRead 
		,d.StatoFunzionale
		,d.StatoDoc
		,a.aziPartitaIVA
		,f.vatvalore_ft as CodiceFiscale
		,a.idazi
		, d.Data
		,a.idazi as idAziPartecipante
		, isnull(b.JumpCheck,'') as JumpCheck
FROM CTL_DOC d
	inner join ctl_doc I on I.id=d.LinkedDoc 
	inner join ctl_doc B on B.id=I.LinkedDoc and b.tipodoc='BANDO'
	inner join aziende a  with(nolock) on d.Destinatario_Azi = a.idazi
--	left outer join CTL_DOC_READ r on r.DOC_NAME = d.TipoDoc and p.idpfu = r.idPfu and r.id_Doc = d.id
--	left outer join dm_attributi d1 on d.azienda =d1.lnk and d1.dztnome = 'CancellatoDiUfficio' and d1.idapp=1
--    left outer join dm_attributi e on d.azienda =e.lnk and e.dztnome = 'CarBelongTo' and e.idapp=1
    left outer join dm_attributi f on d.azienda =f.lnk and f.dztnome = 'codicefiscale' and f.idapp=1

where d.tipoDoc in ('SCARTO_ISCRIZIONE','SCARTO_ISCRIZIONE_LAVORI') and d.deleted=0




GO
