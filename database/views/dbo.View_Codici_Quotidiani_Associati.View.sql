USE [AFLink_TND]
GO
/****** Object:  View [dbo].[View_Codici_Quotidiani_Associati]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[View_Codici_Quotidiani_Associati]
as 
	
	select 
		distinct 
			F.dmv_cod 
		from 
			Quotidiani_ML_LNG F  
				inner join	
					( select 
						dmv_cod,dmv_father 
						from  	
							ctl_Doc with (nolock)	 
								inner join ctl_doc_value with (nolock) on idheader = id and dzt_name='Quotidiani' and value <>''  
								inner join Quotidiani_ML_LNG on ML_LNG = 'i' 
						where tipodoc='QUOTIDIANI_FORNITORI' and statofunzionale = 'Confermato' and  value = dmv_cod
					) QA on  QA.dmv_cod = F.dmv_cod  or  QA.DMV_Father like F.dmv_father + '%' 
	
		where  ML_LNG = 'i'
GO
