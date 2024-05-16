USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_VIEW_PROGRAMMAZIONE_INIZIATIVA_CRONOLOGIA]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO










CREATE  view   [dbo].[OLD_VIEW_PROGRAMMAZIONE_INIZIATIVA_CRONOLOGIA]  as 

	-- prendo i documenti cancellati logicamenti inseriti nella cronologia 
	-- per il doc PROGRAMMAZIONE_INIZIATIVA
	select 
		--distinct 
		s.APS_ID_ROW,
		s.APS_Doc_Type, 
		s.APS_ID_DOC , 
		s.APS_State , 
		
		s.APS_UserProfile ,
		s.APS_IdPfu , 
		s.APS_IsOld , 
		s.APS_Date , 
		s.APS_APC_Cod_Node , 
		s.APS_NextApprover ,

		s.APS_Note ,
		
		APS_ID_DOC_STEP as CRONOLOGIAGrid_ID_DOC,
		M.tipodoc as CRONOLOGIAGrid_OPEN_DOC_NAME
		

		from 
			CTL_DOC C with(nolock)
				inner join CTL_ApprovalSteps s with(nolock) on s.APS_ID_DOC = C.id and s.APS_Doc_Type = C.tipodoc
				left join CTL_DOC M  with(nolock)  on M.id = s.aps_id_doc_STEP and  M.Deleted = 1 
								--and M.StatoDoc ='Sended'
		where 
			C.tipodoc = 'PROGRAMMAZIONE_INIZIATIVA'
	
		
GO
