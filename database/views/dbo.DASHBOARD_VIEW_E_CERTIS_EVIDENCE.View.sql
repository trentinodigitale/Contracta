USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_E_CERTIS_EVIDENCE]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create view [dbo].[DASHBOARD_VIEW_E_CERTIS_EVIDENCE] as 
	select * 
		from Document_eCertis_evidence with(nolock) 
		where deleted = 0

GO
