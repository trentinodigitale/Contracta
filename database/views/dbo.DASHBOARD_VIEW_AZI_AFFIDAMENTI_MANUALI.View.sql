USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_AZI_AFFIDAMENTI_MANUALI]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[DASHBOARD_VIEW_AZI_AFFIDAMENTI_MANUALI] as
select id,idaziendamittente as idazi, valoreofferta as affidamento, receiveddatamsg  from document_affidamenti 


GO
