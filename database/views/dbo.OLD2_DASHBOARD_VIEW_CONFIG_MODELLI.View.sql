USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_DASHBOARD_VIEW_CONFIG_MODELLI]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[OLD2_DASHBOARD_VIEW_CONFIG_MODELLI] as 
	select * from CTL_DOC where tipodoc in ('CONFIG_MODELLI', 'CONFIG_MODELLI_FABBISOGNI' ) and deleted = 0 and ISNULL(LinkedDoc,0) = 0



GO
