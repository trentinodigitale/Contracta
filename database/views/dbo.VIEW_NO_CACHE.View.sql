USE [AFLink_TND]
GO
/****** Object:  View [dbo].[VIEW_NO_CACHE]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VIEW_NO_CACHE] AS
	select id, newid() as NO_CACHE
		from ctl_doc with(nolock)


GO
