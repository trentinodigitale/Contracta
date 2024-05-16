USE [AFLink_TND]
GO
/****** Object:  View [dbo].[PARAMETRI_CONVENZIONE_TESTATA_VIEW]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[PARAMETRI_CONVENZIONE_TESTATA_VIEW] 
AS
Select
	C.*,
	ISNULL(A.value,0) as Attiva_Chiusura_Auto,
	B.value as FreqPrimaria,
	H.value as FreqSecondaria,
	D.value as NumGiorni,
	E.value as NumPeriodiFreqPrimaria,
	ISNULL(F.value,0) as Sollecito
	from CTL_DOC C with(nolock)
		left join CTL_DOC_VALUE A with(nolock) on A.idheader=C.id and A.DSE_ID='SISTEMA' and A.DZT_Name='Attiva_Chiusura_Auto' and A.row=0
		left join CTL_DOC_VALUE B with(nolock) on B.idheader=C.id and B.DSE_ID='SISTEMA' and B.DZT_Name='FreqPrimaria' and B.row=0
		left join CTL_DOC_VALUE H with(nolock) on H.idheader=C.id and H.DSE_ID='SISTEMA' and H.DZT_Name='FreqSecondaria' and H.row=0
		left join CTL_DOC_VALUE D with(nolock) on D.idheader=C.id and D.DSE_ID='SISTEMA' and D.DZT_Name='NumGiorni' and D.row=0
		left join CTL_DOC_VALUE E with(nolock) on E.idheader=C.id and E.DSE_ID='SISTEMA' and E.DZT_Name='NumPeriodiFreqPrimaria' and E.row=0
		left join CTL_DOC_VALUE F with(nolock) on F.idheader=C.id and F.DSE_ID='SISTEMA' and F.DZT_Name='Sollecito' and F.row=0
	where C.tipodoc='PARAMETRI_CONVENZIONE'

GO
