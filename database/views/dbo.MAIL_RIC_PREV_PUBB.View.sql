USE [AFLink_TND]
GO
/****** Object:  View [dbo].[MAIL_RIC_PREV_PUBB]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[MAIL_RIC_PREV_PUBB]
AS
SELECT TOP 100 PERCENT 
       Document_RicPrevPubblic.id AS idDOC
     , 'I' AS LNG
     , Document_RicPrevPubblic.Pratica
     , CONVERT(VARCHAR(10), Document_RicPrevPubblic.DataInvio,105) AS DataInvio
     , Document_RicPrevPubblic.Protocol
     , Document_RicPrevPubblic.Importo
     , a.ML_Description AS TipoDocumento
     , b.ML_Description AS Tipologia
     , Document_RicPrevPubblic.Oggetto
     , PEG.CodProgramma + ' / ' + PEG.Progetto AS PEG
     , dbo.GetDatePubblicazione(Document_RicPrevPubblic.id) AS DatePubb
  FROM Document_RicPrevPubblic
     , Peg
     , LIB_Multilinguismo a
     , LIB_Multilinguismo b
     , LIB_DomainValues c
     , LIB_DomainValues d
 WHERE SUBSTRING(Document_RicPrevPubblic.PEG, CHARINDEX('#~#', Document_RicPrevPubblic.PEG) + 3, 10) = PEG.ProPro
   AND Document_RicPrevPubblic.TipoDocumento = c.DMV_Cod
   AND c.DMV_DM_ID = 'Documento'
   AND c.DMV_DescML = a.ml_key
   AND a.ml_Lng = 'I'
   AND Document_RicPrevPubblic.Tipologia = d.DMV_Cod
   AND d.DMV_DM_ID = 'Tipologia'
   AND d.DMV_DescML = b.ml_Key
   AND b.ml_Lng = 'I'
 ORDER BY Document_RicPrevPubblic.id




GO
