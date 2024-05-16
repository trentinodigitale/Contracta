USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_VIEW_ACCORDO_CREA_FABBISOGNI_ENTI]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[OLD_VIEW_ACCORDO_CREA_FABBISOGNI_ENTI] as 
select c1.idHeader,'ENTI' as DSE_ID, c1.Row,  c1.Value as idAzi, c4.value as aziPartitaIVA
	,c2.Value  as aziRagioneSociale
	,c3.Value  as codicefiscale
	from CTL_DOC_Value  c1
		inner join CTL_DOC_Value  c2 on  c1.idheader = c2.idheader and c1.Row= c2.row and c2.DZT_Name ='aziRagioneSociale' 
		inner join CTL_DOC_Value  c3 on  c1.idheader = c3.idheader and c1.Row= c3.row and c3.DZT_Name ='codicefiscale' 
		inner join CTL_DOC_Value  c4 on  c1.idheader = c4.idheader and c1.Row= c4.row and c4.DZT_Name ='aziPartitaIVA' 
		
	where  c1.DSE_ID='ENTI' and c1.DZT_Name ='idAzi'  

GO
