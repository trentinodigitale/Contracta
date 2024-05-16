USE [AFLink_TND]
GO
/****** Object:  View [dbo].[VIEW_ODA_INTEROP_PCP]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[VIEW_ODA_INTEROP_PCP] AS
	select a.* ,
			b.CN16_CODICE_APPALTO, b.cn16_AuctionConstraintIndicator, b.cn16_ContractingSystemTypeCode_framework
			,Dett_ODC.value as COD_LUOGO_ISTAT
			,Dett1_ODC.value as DESC_LUOGO_ISTAT
			,c.TipoAppaltoGara
			,c.Appalto_PNC
			,c.Appalto_PNRR
			,c.Motivazione_Appalto_PNRR
			,c.Motivazione_Appalto_PNC
	from Document_PCP_Appalto a with (nolock)
			inner join Document_E_FORM_CONTRACT_NOTICE  b with (nolock) on b.idHeader = a.idHeader
			inner join document_ODA c with (nolock) on c.idHeader  = a.idHeader
			left join CTL_DOC_Value Dett_ODC with (nolock) on Dett_ODC.IdHeader=a.idHeader and Dett_ODC.DSE_ID ='DICHIARAZIONI'
															and Dett_ODC.DZT_Name ='COD_LUOGO_ISTAT'
			left join CTL_DOC_Value Dett1_ODC with (nolock) on Dett1_ODC.IdHeader=a.idHeader and Dett1_ODC.DSE_ID ='DICHIARAZIONI'
															and Dett1_ODC.DZT_Name ='DESC_LUOGO_ISTAT'
GO
