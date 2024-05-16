USE [AFLink_TND]
GO
/****** Object:  View [dbo].[RicPrevPubblic_For_RDBE_TESTATA_DOSSIER]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[RicPrevPubblic_For_RDBE_TESTATA_DOSSIER]
AS
SELECT     

	id as 	iddoc,
  LinkDocRdBE as ID, 
  cast ( UserDirigente as integer ) AS Doc_Owner, 
  RDA_Name AS name, 
  RDA_DataCreazione AS data, 
	35152001 as AZI,
  RDA_Protocol as ProtocolloOfferta,
  1 AS IDMP, 
  RDA_Plant_CDC as PEG,
  Pratica,
  TipoDocumento,
  Tipologia

FROM         Document_RicPrevPubblic, dbo.Document_RDA
	where  RDA_ID = LinkDocRdBE

GO
