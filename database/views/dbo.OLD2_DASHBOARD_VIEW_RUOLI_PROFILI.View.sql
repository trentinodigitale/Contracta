USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_DASHBOARD_VIEW_RUOLI_PROFILI]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[OLD2_DASHBOARD_VIEW_RUOLI_PROFILI] AS
select
	LV.DMV_Cod as userrole,
	K.PROF_List as Profilo,
	LV.*,
	ISNULL(D.id,0) as GridViewer_ID_DOC
	from LIB_DomainValues LV with(nolock)
		left join ( SELECT
					 REL_ValueInput,
					
						   (SELECT DISTINCT '###' + REL_ValueOutput --+ '###'
							  FROM CTL_Relations with(nolock)
									WHERE REL_ValueInput = a.REL_ValueInput and  REL_Type='RUOLI_PROFILI'
							 FOR XML PATH ('')
							 ) + '###' AS PROF_List
					

					FROM CTL_Relations  a with(nolock)
						where REL_Type='RUOLI_PROFILI'
					GROUP BY REL_ValueInput
				 ) K on K.REL_ValueInput=LV.DMV_Cod
		left join CTL_DOC D with(nolock) on D.TipoDoc='RUOLI_PROFILI' and D.StatoFunzionale='Confermato' and D.JumpCheck=LV.DMV_Cod
	where LV.DMV_DM_ID='UserRole' and ISNULL(LV.DMV_Deleted,0)=0

GO
