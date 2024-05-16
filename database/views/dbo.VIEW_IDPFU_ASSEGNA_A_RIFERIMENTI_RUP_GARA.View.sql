USE [AFLink_TND]
GO
/****** Object:  View [dbo].[VIEW_IDPFU_ASSEGNA_A_RIFERIMENTI_RUP_GARA]    Script Date: 5/16/2024 2:45:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[VIEW_IDPFU_ASSEGNA_A_RIFERIMENTI_RUP_GARA] as 

	select r.idpfu ,  g.IdHeader as id
		from ctl_doc_value g with(nolock) 
			inner join ELENCO_RESPONSABILI r on r.DMV_COD = g.value
		where 
			g.DSE_ID = 'InfoTec_comune'
			and g.DZT_Name = 'UserRUP'
		
GO
