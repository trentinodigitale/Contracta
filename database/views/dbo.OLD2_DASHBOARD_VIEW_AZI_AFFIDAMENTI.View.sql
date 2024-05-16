USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_DASHBOARD_VIEW_AZI_AFFIDAMENTI]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[OLD2_DASHBOARD_VIEW_AZI_AFFIDAMENTI] as
select idaziendamittente as idazi,sum (valoreofferta) as affidamento,year(receiveddatamsg) as anno from document_affidamenti  with(nolock) 
group by  idaziendamittente,year(receiveddatamsg) 




GO
