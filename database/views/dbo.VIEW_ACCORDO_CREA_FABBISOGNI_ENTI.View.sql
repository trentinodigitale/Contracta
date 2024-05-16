USE [AFLink_TND]
GO
/****** Object:  View [dbo].[VIEW_ACCORDO_CREA_FABBISOGNI_ENTI]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [dbo].[VIEW_ACCORDO_CREA_FABBISOGNI_ENTI] as 
select 

	c1.idHeader,'ENTI' as DSE_ID, c1.Row,  c1.Value as idAzi
	,c2.Value  as aziRagioneSociale
	,c3.Value  as codicefiscale
	, c4.value as aziPartitaIVA
	from 
		CTL_DOC c
		inner join CTL_DOC_Value  c1 with (nolock) on c1.idheader = c.id and c1.DSE_ID='ENTI' and c1.DZT_Name ='idAzi'  
			inner join CTL_DOC_Value  c2 with (nolock) on  c1.idheader = c2.idheader and c1.Row= c2.row and c2.DZT_Name ='aziRagioneSociale' 
			inner join CTL_DOC_Value  c3 with (nolock) on  c1.idheader = c3.idheader and c1.Row= c3.row and c3.DZT_Name ='codicefiscale' 
			inner join CTL_DOC_Value  c4 with (nolock) on  c1.idheader = c4.idheader and c1.Row= c4.row and c4.DZT_Name ='aziPartitaIVA' 
		
	where  
		c.TipoDoc = 'ACCORDO_CREA_FABBISOGNI'

GO
