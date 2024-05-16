USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DWH_Get_Dominio_ATC]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [dbo].[DWH_Get_Dominio_ATC]  as 

	select 
			desc12.DMV_CodExt as [Codice] , 
			desc12.dmv_father as [Path],
			desc12.DMV_Level as [Livello],
			isnull( p.DMV_CodExt , '' ) as linked_cod ,
			case when isnull(desc12.DMV_CodExt,'')='' then '' else isnull(desc12.DMV_CodExt,'') + ' - ' + isnull(desc12.DMV_DescML,'') end as [Descrizione] , 
			desc12.DMV_Cod as [Codice_Ext] ,
			isnull( desc12.DMV_Deleted , 0 ) as [Cancellato]

		from 
 			--LIB_DomainValues desc12 WITH (NOLOCK) where desc12.DMV_DM_ID = 'A_ATC' 
			GESTIONE_DOMINIO_A_ATC desc12 WITH (NOLOCK)
			left join GESTIONE_DOMINIO_A_ATC p with(nolock) on   desc12.DMV_Father like p.DMV_Father + '%' and desc12.DMV_Level  = p.DMV_Level + 1 and isnull( p.DMV_Deleted , 0 )  = 0


GO
