USE [AFLink_TND]
GO
/****** Object:  View [dbo].[BANDO_FABBISOGNI_IA_APPROVAL_VIEW]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[BANDO_FABBISOGNI_IA_APPROVAL_VIEW] as
select 
	CD.idrow as APS_ID_DOC,APS_ID_ROW, APS_Doc_Type, APS_State, APS_Note, APS_Allegato, APS_UserProfile, APS_IdPfu, APS_IsOld, APS_Date, APS_APC_Cod_Node, APS_NextApprover
	

from CTL_DOC_Destinatari CD 
inner join CTL_ApprovalSteps CA on CA.APS_ID_DOC=CD.idheader and APS_Doc_Type in ( 'BANDO_FABBISOGNI','BANDO_FABBISOGNI_IA' )

GO
