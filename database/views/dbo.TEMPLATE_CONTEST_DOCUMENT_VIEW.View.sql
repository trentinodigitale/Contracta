USE [AFLink_TND]
GO
/****** Object:  View [dbo].[TEMPLATE_CONTEST_DOCUMENT_VIEW]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[TEMPLATE_CONTEST_DOCUMENT_VIEW] as


select  
	c.id as ID_REQUEST , d.*
	, ISNULL(PCP.pcp_CodiceAppalto,'') as  pcp_CodiceAppalto
	from 
		ctl_doc d with(nolock) 
			left join ctl_doc c with(nolock) on d.id = c.linkeddoc and c.deleted = 0 and c.tipodoc = 'MODULO_TEMPLATE_REQUEST'

			--salgo sulla gara per controllare se è stato fatto conferma appalto
			left join CTL_DOC G with(nolock) on G.Id = d.LinkedDoc and G.TipoDoc in ('BANDO_GARA','BANDO_SEMPLIFICATO')
			left join Document_PCP_Appalto PCP with(nolock) on PCP.idHeader = G.id


GO
