USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_DASHBOARD_VIEW_AVCP_IMPORT_CSV]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[OLD_DASHBOARD_VIEW_AVCP_IMPORT_CSV] as

select d.* , a.aziRagioneSociale , NumeroRiga,
	case when TipoDoc='AVCP_IMPORT_CSV' then 'CSV'
		 when TipoDoc='AVCP_IMPORT_XML' then 'XML'
		 
	end as Tipo,
	tipodoc as OPEN_DOC_NAME
	from CTL_DOC d  with(nolock) 
		left outer join aziende a  with(nolock) on a.idazi = d.azienda
		left outer join ( select idheader , count(*) as NumeroRiga from document_AVCP_Import_CSV with(nolock)  group by idheader) as r on r.idheader = d.id
	where TipoDoc in (  'AVCP_IMPORT_CSV','AVCP_IMPORT_XML' ) and deleted = 0
	






GO
