USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_FermoSistema]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [dbo].[DASHBOARD_VIEW_FermoSistema] as 

	select 
		C.*,
			[idRow], [idHeader],
			
			--[DataInizio],
			case 
				when Fermo_Avviso ='avviso' then [DataAvvisoDal]
				else [DataInizio]
			end as [DataInizio], 
			
			--[DataFine], 
			case 
				when Fermo_Avviso ='avviso' then [DataAvvisoAl]
				else [DataFine]
			end as [DataFine], 
			
			[DataComunicazione], [DataAnnullamento], 

			case 
				when Fermo_Avviso ='avviso' then [DataAvvisoDal]
				else [DataSysMsgDA]
			end as [DataSysMsgDA], 

			[DataAvvisoDal], [DataAvvisoAl], [Fermo_Avviso]

		from ctl_doc C with (nolock)
			inner join document_FermoSistema F with (nolock) on id=idheader
		
		where tipodoc='FERMOSISTEMA'
GO
