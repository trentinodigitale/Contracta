USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_DOCUMENT_AZIENDE_VIEW]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[OLD_DOCUMENT_AZIENDE_VIEW]
AS
SELECT     dbo.Document_Aziende.*, NomePF AS NomePF2, CognomePF AS CognomePF2
FROM         dbo.Document_Aziende

GO
