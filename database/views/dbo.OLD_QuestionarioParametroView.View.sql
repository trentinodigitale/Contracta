USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_QuestionarioParametroView]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[OLD_QuestionarioParametroView] AS
SELECT 
        1 AS Id
      , 1 AS idHeader
      , 1 AS idRow
Union
SELECT 
        2 AS Id
      , 1 AS idHeader
      , 2 AS idRow
GO
