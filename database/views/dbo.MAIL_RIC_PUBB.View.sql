USE [AFLink_TND]
GO
/****** Object:  View [dbo].[MAIL_RIC_PUBB]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[MAIL_RIC_PUBB]
AS
SELECT Document_RicPubblic.id AS idDOC
     , Lingue.lngSuffisso AS LNG
     , Document_RicPubblic.Pratica
     , CONVERT(VARCHAR(10), Document_RicPubblic.Data, 105) AS Data
     , Document_RicPubblic.Bando
     , Document_RicPubblic.Imp
     , Document_RicPubblic.Bil
     , Document_RicPubblic.Oggetto
     , PEG.CodProgramma + ' / ' + PEG.Progetto AS PEG,dbo.GetPubblicazioneOrdinata(Document_RicPubblic.id) AS QuotBurcGuri
  FROM Document_RicPubblic 
 INNER JOIN PEG ON SUBSTRING(Document_RicPubblic.PEG, CHARINDEX('#~#', Document_RicPubblic.PEG) + 3, 10) = PEG.ProPro 
CROSS JOIN Lingue





GO
