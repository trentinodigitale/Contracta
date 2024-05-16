USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_UserRole_MLNG]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[OLD_UserRole_MLNG] AS
	SELECT LB.id, 
			LB.DMV_DM_ID, 
			LB.DMV_Cod as DMV_Cod,
			LB.DMV_Father, 
			LB.DMV_Level, 	
			cast ( isnull( m1.ML_Description,LB.DMV_DescML)  as nvarchar(max)) as DMV_DescML,
			LB.DMV_Image, 
			LB.DMV_Sort, 
			LB.DMV_CodExt, 
			LB.DMV_Module,
			case 
				when ISNULL(LB.DMV_Deleted,0) = 1 then DMV_Deleted
				when CR.REL_ValueOutput IS not NULL and W.items IS NULL then 1  --SE TROVA LA RELAZIONE PER MODULO E RUOLO e non trova il modulo tra quelli attivi va a deleted
				else ISNULL(LB.DMV_Deleted,0)
			end as DMV_Deleted,
			lngSuffisso as ML_LNG
		from LIB_DomainValues LB with(nolock)

			cross join lingue lng with(nolock)

			cross join (
							select  min(idmp) as idmp from MarketPlace with(nolock)
						) m 

			left outer join LIB_Multilinguismo m1 with (nolock) on LB.DMV_DescML=m1.ML_KEY and m1.ML_LNG = lngSuffisso and m.IdMp = m1.ML_Context

			left join CTL_Relations CR with(nolock) on CR.REL_Type='DOMINIO_UserRole' and CR.REL_ValueOutput=LB.DMV_Cod
			left join ( select items from dbo.Split((select DZT_ValueDef from lib_dictionary with(nolock) where DZT_Name='SYS_MODULI_GRUPPI'),',') where items <> '' ) W on W.items=CR.REL_ValueInput

		where  LB.DMV_DM_ID = 'UserRole'



GO
