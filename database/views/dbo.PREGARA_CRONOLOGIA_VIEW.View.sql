USE [AFLink_TND]
GO
/****** Object:  View [dbo].[PREGARA_CRONOLOGIA_VIEW]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE  view   [dbo].[PREGARA_CRONOLOGIA_VIEW]  as 

	-- prendo i documenti in linea
	select 
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


		d.id as CRONOLOGIAGrid_ID_DOC , 
		d.TipoDoc as CRONOLOGIAGrid_OPEN_DOC_NAME,
		d.DataProtocolloGenerale,
		d.ProtocolloGenerale,
		
		d.SIGN_ATTACH as APS_Allegato,
		d.Note as APS_Note
		
		--APS_Allegato,
		--APS_Note

		from 
			CTL_DOC P with(nolock)
			inner join CTL_ApprovalSteps s with(nolock) on s.APS_ID_DOC = p.id and s.APS_Doc_Type = 'PREGARA'
			left join CTL_DOC d with(nolock)  on d.LinkedDoc = s.APS_ID_ROW and d.TipoDoc = 'PREGARA' and d.Deleted = 1
		where p.deleted = 0 and p.tipodoc = 'PREGARA'

	union all

	-- prendo i documenti dalla cronologia
	select 
		s.APS_ID_ROW,
		s.APS_Doc_Type, 
		p.ID AS APS_ID_DOC , 
		s.APS_State , 
		
		s.APS_UserProfile ,
		s.APS_IdPfu , 
		s.APS_IsOld , 
		s.APS_Date , 
		s.APS_APC_Cod_Node , 
		s.APS_NextApprover ,


		d.id as CRONOLOGIAGrid_ID_DOC , 
		d.TipoDoc as CRONOLOGIAGrid_OPEN_DOC_NAME,
		d.DataProtocolloGenerale,
		d.ProtocolloGenerale,
		
		d.SIGN_ATTACH as APS_Allegato,
		d.Note as APS_Note
		
		--S.APS_Allegato,
		--S.APS_Note

		from 
			CTL_DOC P with(nolock)
			inner join CTL_ApprovalSteps c with(nolock) on p.LinkedDoc = c.APS_ID_ROW -- dalla cronologia recupero l'id del documento base

			inner join CTL_ApprovalSteps s with(nolock) on s.APS_ID_DOC = c.APS_ID_DOC and s.APS_Doc_Type = 'PREGARA' and s.[APS_Date] <= c.APS_Date
			left join CTL_DOC d with(nolock)  on d.LinkedDoc = s.APS_ID_ROW and d.TipoDoc = 'PREGARA' and d.Deleted = 1
		where p.deleted = 1 and p.tipodoc = 'PREGARA'

		
GO
