USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_PREGARA_CRONOLOGIA_VIEW]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE  view  [dbo].[OLD2_PREGARA_CRONOLOGIA_VIEW] as 

	select s.* , d.id as CRONOLOGIAGrid_ID_DOC , d.TipoDoc as CRONOLOGIAGrid_OPEN_DOC_NAME  
		from CTL_ApprovalSteps s with(nolock) 
			left join CTL_DOC d with(nolock)  on d.LinkedDoc = s.APS_ID_ROW and d.TipoDoc = 'PREGARA' and d.Deleted = 1
		
GO
