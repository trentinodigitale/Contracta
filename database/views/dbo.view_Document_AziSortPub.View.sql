USE [AFLink_TND]
GO
/****** Object:  View [dbo].[view_Document_AziSortPub]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[view_Document_AziSortPub] as 
		select isnull(ordinamento,10000) as ordina, * from Document_AziSortPub 
GO
