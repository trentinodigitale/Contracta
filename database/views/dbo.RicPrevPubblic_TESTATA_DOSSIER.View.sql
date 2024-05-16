USE [AFLink_TND]
GO
/****** Object:  View [dbo].[RicPrevPubblic_TESTATA_DOSSIER]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[RicPrevPubblic_TESTATA_DOSSIER]
AS
SELECT     

  ID, 
  cast ( UserDirigente as integer ) AS Doc_Owner, 
  cast ( Oggetto as varchar(50)) AS name, 
  DataInvio AS data, 
	35152001 as AZI,
  Protocol as ProtocolloOfferta,
  1 AS IDMP, 
  Pratica as Pratica,
  PEG,
  TipoDocumento,
  Tipologia
FROM         Document_RicPrevPubblic

GO
