USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_E_CERTIS_LOG]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[DASHBOARD_VIEW_E_CERTIS_LOG] as 


	select * , [dateIns] as DataDa , [dateIns] as DataA
		from Document_eCertis_log with(nolock) 
GO
