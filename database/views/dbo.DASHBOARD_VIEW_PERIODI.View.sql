USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_PERIODI]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create view [dbo].[DASHBOARD_VIEW_PERIODI] as
select * from dbo.Document_Report_Periodi
where deleted = 0
GO
