USE [AFLink_TND]
GO
/****** Object:  View [dbo].[NowTime]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE View [dbo].[NowTime]
as
--getdate non consentito in funzioni SQL (SQL 2000)
Select Getdate() as MyNow
GO
