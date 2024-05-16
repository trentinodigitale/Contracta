USE [AFLink_TND]
GO
/****** Object:  View [dbo].[RDA_TESTATA_DOSSIER]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[RDA_TESTATA_DOSSIER]
AS
SELECT     dbo.Document_RDA.RDA_ID, dbo.Document_RDA.RDA_ID AS ID, dbo.Document_RDA.RDA_Owner AS Doc_Owner, 
                      dbo.Document_RDA.RDA_Name AS name, dbo.Document_RDA.RDA_DataCreazione AS data, dbo.Document_RDA.RDA_AZI AS AZI, 
                      dbo.Document_RDA.RDA_Protocol AS NumOrdCliente, a.aziRagioneSociale AS ragsoc, 1 AS IDMP, dbo.Document_RDA.RDA_Protocol AS Protocol
FROM         dbo.Document_RDA INNER JOIN
                      dbo.Aziende AS a ON dbo.Document_RDA.RDA_AZI = a.IdAzi



GO
