USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_BOZZA_FORN]    Script Date: 5/16/2024 2:45:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[DASHBOARD_VIEW_BOZZA_FORN]
AS
SELECT idAziDest AS AZI_Dest
     , * 
  FROM Document_Bozza 
 WHERE Deleted = 0
GO
