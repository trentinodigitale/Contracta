USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DATI_BASE_TEST_PCP]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[DATI_BASE_TEST_PCP] as 

	select 
			U.IdHeader as ID
			, c.Value as PCP_CONTESTO
			, s.Value as PCP_SERVIZIO
			, p.Value as PCP_PARAMETRI
			, T.Value AS PCP_ID_TIPO_UTENTE
			, L.Value as PCP_LOA
			, F.Value as codicefiscale
			, j.Body as PCP_JSON
 
		from ctl_doc_value U with(nolock) 
			left join ctl_doc_value C with(nolock) on U.IdHeader = c.IdHeader and u.DSE_ID = c.DSE_ID and c.DZT_Name = 'PCP_CONTESTO'
			left join ctl_doc_value S with(nolock) on U.IdHeader = s.IdHeader and u.DSE_ID = s.DSE_ID and s.DZT_Name = 'PCP_SERVIZIO'
			left join ctl_doc_value P with(nolock) on U.IdHeader = p.IdHeader and u.DSE_ID = p.DSE_ID and p.DZT_Name = 'PCP_PARAMETRI'
			left join ctl_doc_value T with(nolock) on U.IdHeader = t.IdHeader and u.DSE_ID = t.DSE_ID and t.DZT_Name = 'PCP_ID_TIPO_UTENTE'
			left join ctl_doc_value L with(nolock) on U.IdHeader = l.IdHeader and u.DSE_ID = l.DSE_ID and l.DZT_Name = 'PCP_LOA'
			left join ctl_doc_value F with(nolock) on U.IdHeader = f.IdHeader and u.DSE_ID = f.DSE_ID and f.DZT_Name = 'codicefiscale'
			inner join ctl_doc J with(nolock) on J.id = u.idheader

	where u.DZT_Name = 'UserRup' and u.DSE_ID = 'InfoTec_comune' 

	

GO
