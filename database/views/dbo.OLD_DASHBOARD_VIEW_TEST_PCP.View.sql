USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_DASHBOARD_VIEW_TEST_PCP]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[OLD_DASHBOARD_VIEW_TEST_PCP] as 
Select 
		*
from ctl_doc
where tipodoc='TEST_PCP' and deleted=0
GO
