USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_NEWAZI]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[DASHBOARD_VIEW_NEWAZI]
AS
SELECT     TOP 100 PERCENT LFN_CaptionML AS TIPO_AZI, LFN_paramTarget AS PARAM, LFN_GroupFunction
FROM         dbo.LIB_Functions
WHERE     (LFN_GroupFunction = 'NEW_AZI')
ORDER BY LFN_Order

GO
