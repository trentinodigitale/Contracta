USE [AFLink_TND]
GO
/****** Object:  View [dbo].[RicPubblic_TESTATA_DOSSIER]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[RicPubblic_TESTATA_DOSSIER]
AS
SELECT     

  ID, 
  cast ( Owner as integer ) AS Doc_Owner, 
  cast ( Oggetto as varchar(50)) AS name, 
  Data AS data, 
	35152001 as AZI,
  Bando as ProtocolloBando,
  1 AS IDMP, 
  Pratica as Pratica,
  PEG
  
FROM         Document_RicPubblic

GO
