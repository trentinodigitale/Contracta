USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_OFFERTA]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE view [dbo].[DASHBOARD_VIEW_OFFERTA] as
SELECT     
	r.ID, r.idpfu as owner, 
	StatoFunzionale  ,  r.Deleted, r.Data as DataCreazione, 
	r.data,
	r.DataInvio, 
	'' as ProtocolRDO, r.Protocollo as Protocol, 
	r.StrutturaAziendale as Plant, r.Body as Object, r.Azienda as idAzi, r.DataScadenza
	, r.Azienda  as Societa , r.Note , r.Body as Name , r.idpfu , 
	--r.HideCol , 
	--idRDO , 
	r.Azienda  as LogoSocieta,'' as valuta,
	
	'' as tipordo,
	--case isnull(tipordo,'')
	--	when 'Prestazioni' then 'OFFERTA_PRESTAZIONI'
	--	else 'OFFERTA' end as OPEN_DOC_NAME
		'OFFERTA'  as OPEN_DOC_NAME

FROM         ctl_doc r with(NOLOCK)
	inner join profiliutente with(NOLOCK) on r.idpfu=profiliutente.idpfu-- r.azienda = pfuidazi
	--left outer join document_rdo y on y.id=r.idrdo

WHERE     r.Deleted = 0 and r.TipoDoc = 'offerta'


--select *  FROM         ctl_doc r with(NOLOCK)
--WHERE     r.Deleted = 0 and r.TipoDoc = 'offerta'
--order by 1 desc
--select * from profiliutente where pfuidazi=35152033  idpfu=45661
--select * from aziende where idazi=35152033


GO
