USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_E_CERTIS_CRITERIA]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[DASHBOARD_VIEW_E_CERTIS_CRITERIA] as 


	select * 
		from Document_eCertis_criterion with(nolock) 
		where deleted = 0
GO
