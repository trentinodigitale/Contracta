USE [AFLink_TND]
GO
/****** Object:  View [dbo].[PUBBLICITA_LEGALE_CRONOLOGIA_VIEW]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO













CREATE  view   [dbo].[PUBBLICITA_LEGALE_CRONOLOGIA_VIEW]  as 

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

		case 
			when s.APS_State='Annullato' then a.id 
			--when s.APS_State='Denied' then R.id 
			else d.id 
		end as CRONOLOGIAGrid_ID_DOC ,
		
		case 
			when s.APS_State='Annullato' then a.TipoDoc 
			--when s.APS_State='Denied' then R.TipoDoc 
			else d.TipoDoc 
		end as CRONOLOGIAGrid_OPEN_DOC_NAME,
		

		s.APS_Allegato,
		 cast( s.APS_Note as nvarchar(max)) as  APS_Note
		
		--APS_Allegato,
		--APS_Note

		from 
			CTL_DOC P with(nolock)
			
			inner join CTL_ApprovalSteps s with(nolock) on s.APS_ID_DOC = p.id and s.APS_Doc_Type = 'PUBBLICITA_LEGALE'
			
			left join CTL_DOC d with(nolock)  on 
			
			 (d.LinkedDoc = s.APS_ID_ROW and d.TipoDoc = 'PUBBLICITA_LEGALE' and d.Deleted = 1)
			
			left join CTL_DOC A  with(nolock)  on a.LinkedDoc = p.id and a.TipoDoc = 'PUBBLICITA_LEGALE_ANNULLA' and a.Deleted = 1 
			--left join CTL_DOC R  with(nolock)  on R.LinkedDoc = p.id and R.TipoDoc = 'PUBBLICITA_LEGALE_RIFIUTA' and R.Deleted = 1 and s.APS_State='denied'
			
		
		where p.deleted = 0 and p.tipodoc = 'PUBBLICITA_LEGALE' 
		


	--union 


	------ prendo le non approvazioni
	--select 
	--	s.APS_ID_ROW,
	--	s.APS_Doc_Type, 
	--	s.APS_ID_DOC , 
	--	s.APS_State , 
		
	--	s.APS_UserProfile ,
	--	s.APS_IdPfu , 
	--	s.APS_IsOld , 
	--	s.APS_Date , 
	--	s.APS_APC_Cod_Node , 
	--	s.APS_NextApprover ,

	--	--case 
	--		--when s.APS_State='Annullato' then a.id 
	--	--	when s.APS_State='Denied' then R.id 
	--	--	else d.id 
	--	R.id  as CRONOLOGIAGrid_ID_DOC ,
		
	--	--case 
	--		--when s.APS_State='Annullato' then a.TipoDoc 
	--	--	when s.APS_State='Denied' then R.TipoDoc 
	--	--	else d.TipoDoc 
	--	R.TipoDoc as CRONOLOGIAGrid_OPEN_DOC_NAME,
		

	--	s.APS_Allegato,
	--	 cast( s.APS_Note as nvarchar(max)) as  APS_Note
		
	--	--APS_Allegato,
	--	--APS_Note

	--	from 
	--		CTL_DOC  R
	--		inner join CTL_DOC P with(nolock) on p.id=r.linkeddoc 
			
	--		inner join CTL_ApprovalSteps s with(nolock) on s.APS_ID_DOC = p.id and s.APS_Doc_Type = 'PUBBLICITA_LEGALE' and s.APS_State='denied'
			
	--		--inner join CTL_DOC R  with(nolock)  on R.LinkedDoc = p.id and R.TipoDoc = 'PUBBLICITA_LEGALE_RIFIUTA' and R.Deleted = 1 and s.APS_State='denied'
			
		
	--	where 
	--	--p.deleted = 0 and p.tipodoc = 'PUBBLICITA_LEGALE' 
	--		r.Deleted=1 and R.TipoDoc = 'PUBBLICITA_LEGALE_RIFIUTA'
		
	union 

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
		
		
		 s.APS_Allegato,
		cast( s.APS_Note as nvarchar(max)) as  APS_Note
		
		--S.APS_Allegato,
		--S.APS_Note

		from 
			CTL_DOC P with(nolock)
			inner join CTL_ApprovalSteps c with(nolock) on p.LinkedDoc = c.APS_ID_ROW -- dalla cronologia recupero l'id del documento base
			inner join CTL_ApprovalSteps s with(nolock) on s.APS_ID_DOC = c.APS_ID_DOC and s.APS_Doc_Type = 'PUBBLICITA_LEGALE' and s.[APS_Date] <= c.APS_Date
			left join CTL_DOC d with(nolock)  on d.LinkedDoc = s.APS_ID_ROW and d.TipoDoc = 'PUBBLICITA_LEGALE' and d.Deleted = 1

		where p.deleted = 1 and p.tipodoc = 'PUBBLICITA_LEGALE' 
	
		



GO
