USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_PARAMETRI_RDO]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[DASHBOARD_VIEW_PARAMETRI_RDO] as 
Select 
		*
from ctl_doc
where tipodoc='PARAMETRI_RDO' and deleted=0
GO
