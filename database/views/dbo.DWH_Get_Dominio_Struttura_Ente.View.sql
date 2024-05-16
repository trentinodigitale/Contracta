USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DWH_Get_Dominio_Struttura_Ente]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[DWH_Get_Dominio_Struttura_Ente] as 

select 
		B.* 
		, isnull( p.Codice , '' ) as linked_cod 
	
	from DOMINIO_STRUTTURA_AZIENDALE_ENTE B
		left join DOMINIO_STRUTTURA_AZIENDALE_ENTE p with(nolock) on b.Path like p.Path  + '%' and b.Livello= p.Livello + 1
GO
