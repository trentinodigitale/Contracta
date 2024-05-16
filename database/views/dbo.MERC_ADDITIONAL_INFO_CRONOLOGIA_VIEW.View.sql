USE [AFLink_TND]
GO
/****** Object:  View [dbo].[MERC_ADDITIONAL_INFO_CRONOLOGIA_VIEW]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[MERC_ADDITIONAL_INFO_CRONOLOGIA_VIEW] as
select
	APS_ID_DOC,
	APS_ID_ROW,
	Protocollo,
	DataInvio as Data,
	IdPfu,
	APS_Doc_Type as tipodoc,
	APS_APC_Cod_Node as CRONOLOGIAGrid_ID_DOC,
	APS_Doc_Type as CRONOLOGIAGrid_OPEN_DOC_NAME

from CTL_ApprovalSteps
	--inner join CTL_DOC C on APS_ID_DOC=C.Id
	left join CTL_DOC  On APS_APC_Cod_Node=Id

GO
