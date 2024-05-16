USE [AFLink_TND]
GO
/****** Object:  View [dbo].[Progetti_TESTATA_DOSSIER]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[Progetti_TESTATA_DOSSIER]
AS
SELECT     

  IdProgetto AS ID, 
  cast ( UserDirigente as integer ) AS Doc_Owner, 
  cast ( Oggetto as varchar(50)) AS name, 
  DataInvio AS data, 
	35152001 as AZI,
  Protocol as ProtocolloOfferta,
  1 AS IDMP, 
  Pratica as Pratica,
  PEG,
  Tipologia
FROM         Document_Progetti




GO
