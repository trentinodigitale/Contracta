USE [AFLink_TND]
GO
/****** Object:  View [dbo].[SUBENTRO_OE_LISTA_VIEW_XLSX]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[SUBENTRO_OE_LISTA_VIEW_XLSX] AS
select 
	C.id,
	C.id as idheader,
	C.tipodoc,
	case when ISNULL(CV7.Value,'0')='1' then 'includi' else 'escludi' end as Seleziona,
	CV8.Value as NumeroRiga,
	CV2.Value as DataCreazione,
    CV.Value as NomeDocumento,
	CV5.Value as Fascicolo,
    CV4.Value as Titolo
 
	
from CTL_DOC C with(NOLOCK)
	inner join CTL_DOC_Value CV with(NOLOCK)  on CV.IdHeader=C.id and CV.DSE_ID='LISTA' and CV.DZT_Name='NomeDocumento'
	inner join CTL_DOC_Value CV2 with(NOLOCK) on CV2.IdHeader=CV.IdHeader and CV2.DSE_ID='LISTA' and CV2.DZT_Name='DataCreazione' and CV.[Row]=CV2.[Row]	
	inner join CTL_DOC_Value CV4 with(NOLOCK)  on CV4.IdHeader=CV.IdHeader and CV4.DSE_ID='LISTA' and CV4.DZT_Name='Titolo' and Cv.Row=CV4.Row
	inner join CTL_DOC_Value CV5 with(NOLOCK)  on CV5.IdHeader=CV.IdHeader and CV5.DSE_ID='LISTA' and CV5.DZT_Name='Fascicolo' and Cv.Row=CV5.Row	
	inner join CTL_DOC_Value CV8 with(NOLOCK)  on CV8.IdHeader=CV.IdHeader and CV8.DSE_ID='LISTA' and CV8.DZT_Name='NumeroRiga' and Cv.Row=CV8.Row
	left join CTL_DOC_Value CV7 with(NOLOCK)  on CV7.IdHeader=CV.IdHeader and CV7.DSE_ID='LISTA' and CV7.DZT_Name='Checkcessati' and Cv.Row=CV7.Row
where C.tipodoc='SUBENTRO_OE' 

GO
