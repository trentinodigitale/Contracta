USE [AFLink_TND]
GO
/****** Object:  View [dbo].[MAIL_PROGETTO_COMP]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[MAIL_PROGETTO_COMP] AS
SELECT Document_Progetti.IdProgetto AS idDOC
     , 'I' AS LNG
     , Document_Progetti.Pratica
     , CONVERT(VARCHAR(10), Document_Progetti.DataInvio, 105) AS DataInvio
     , Document_Progetti.Protocol
     , Document_Progetti.Importo
     , Document_Progetti.EmailComunicazioni
     , a.ML_Description AS TipoProcedura
     , b.ML_Description AS Tipologia
     , Document_Progetti.Oggetto
     , PEG.CodProgramma + ' / ' + PEG.Progetto AS PEG
     , pfunome AS UserDirigente 
     , Document_Progetti.ProtocolloBando
  FROM Document_Progetti
     , Peg
     , LIB_Multilinguismo a
     , LIB_Multilinguismo b
     , LIB_Domainvalues c
     , LIB_DomainValues d
     , ProfiliUtente
 WHERE SUBSTRING(Document_Progetti.PEG, CHARINDEX('#~#', Document_Progetti.PEG) + 3, 10) = PEG.ProPro
   AND Document_Progetti.TipoProcedura = c.DMV_Cod
   AND c.DMV_DM_ID = 'TipoProcedura'
   AND c.DMV_DescML = a.ml_key
   AND a.ml_Lng = 'I'
   AND Document_Progetti.Tipologia = d.DMV_Cod
   AND d.DMV_DM_ID = 'Tipologia'
   AND d.DMV_DescML = b.ml_key
   AND b.ml_Lng = 'I'
   AND UserDirigente = IdPfu


GO
