USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_dashboard_view_Services_Integration_Request]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[OLD_dashboard_view_Services_Integration_Request] AS
	select s.*,
			s.dateIn as DataDA,
			s.datein as DataA
	From Services_Integration_Request s with(nolock)

GO
