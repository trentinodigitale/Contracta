USE [AFLink_TND]
GO
/****** Object:  View [dbo].[MAIL_REPERTORIO]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[MAIL_REPERTORIO] AS
SELECT     IdRepertorio AS idDOC, 'I' AS LNG,  *
FROM       Document_Repertorio 
GO
