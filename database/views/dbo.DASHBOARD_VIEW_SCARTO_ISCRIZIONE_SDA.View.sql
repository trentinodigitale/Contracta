USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_SCARTO_ISCRIZIONE_SDA]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[DASHBOARD_VIEW_SCARTO_ISCRIZIONE_SDA] as
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
		,rif.idpfu 
		,bando.id as ListaAlbi
FROM CTL_DOC d
	inner join aziende a on d.Destinatario_Azi = a.idazi
--	left outer join CTL_DOC_READ r on r.DOC_NAME = d.TipoDoc and p.idpfu = r.idPfu and r.id_Doc = d.id
--	left outer join dm_attributi d1 on d.azienda =d1.lnk and d1.dztnome = 'CancellatoDiUfficio' and d1.idapp=1
--    left outer join dm_attributi e on d.azienda =e.lnk and e.dztnome = 'CarBelongTo' and e.idapp=1
    left outer join dm_attributi f on d.azienda =f.lnk and f.dztnome = 'codicefiscale' and f.idapp=1
	left join CTL_DOC istanza ON d.linkeddoc = istanza.id
	left join CTL_DOC bando ON istanza.linkeddoc = bando.id
	left join Document_Bando_Riferimenti RIF on RIF.idHeader=bando.id and RIF.RuoloRiferimenti='Istanze' 

where d.tipoDoc = 'SCARTO_ISCRIZIONE_SDA' and d.deleted=0




GO
