USE [AFLink_TND]
GO
/****** Object:  View [dbo].[CONTRATTO_CRONOLOGIA_VIEW]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE  view   [dbo].[CONTRATTO_CRONOLOGIA_VIEW]  as 

	-- prendo i documenti in linea
	select 
		distinct 
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


		
		APS_ID_DOC_STEP as CRONOLOGIAGrid_ID_DOC,
		M.tipodoc as CRONOLOGIAGrid_OPEN_DOC_NAME
		

		from 
			CTL_DOC C with(nolock)
				inner join CTL_ApprovalSteps s with(nolock) on s.APS_ID_DOC = C.id and s.APS_Doc_Type = C.tipodoc
				left join CTL_DOC M  with(nolock)  on M.id = s.aps_id_doc_STEP and  M.Deleted = 0 
								and M.StatoDoc ='Sended'
		where C.deleted = 0 and C.tipodoc in ( 'SCRITTURA_PRIVATA','CONTRATTO_GARA')
	
GO
