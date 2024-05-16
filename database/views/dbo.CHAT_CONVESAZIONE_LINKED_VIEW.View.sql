USE [AFLink_TND]
GO
/****** Object:  View [dbo].[CHAT_CONVESAZIONE_LINKED_VIEW]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[CHAT_CONVESAZIONE_LINKED_VIEW] AS
SELECT
		APS_ID_ROW, 
		APS_Doc_Type, 
		APS_State, 
		APS_Note, 
		APS_Allegato, 
		APS_UserProfile, 
		APS_IdPfu, 
		APS_IsOld, 
		APS_Date, 
		APS_APC_Cod_Node, 
		APS_NextApprover,
		c1.id as APS_ID_DOC
		
FROM
CTL_ApprovalSteps
inner join ctl_doc c2 on c2.id=APS_ID_DOC and c2.tipodoc='RICHIESTA_CODIFICA_PRODOTTI'
inner join ctl_doc c1 on c1.linkeddoc=c2.id and c1.tipodoc='CODIFICA_PRODOTTI'
WHERE APS_Doc_Type='CHAT'
GO
