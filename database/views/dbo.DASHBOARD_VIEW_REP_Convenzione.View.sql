USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_REP_Convenzione]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[DASHBOARD_VIEW_REP_Convenzione]
AS
SELECT Id_Convenzione                                                   AS RDA_Id
     , RDA_Owner
     , Id_Convenzione                                
     , Document_ODC.Plant
     , SUM(RDA_Total)                                                   AS RDA_Total
     , Id_Convenzione                                                   AS Convenzione
     , YEAR (RDA_DataCreazione)                                         AS Anno
     , Doc_Name
     , Protocol
     , CAST(DescrizioneEstesa AS VARCHAR(8000))                         AS DescrizioneEstesa
     , Merceologia
  FROM Document_ODC
     , Document_Convenzione
 WHERE Document_Convenzione.Id = Document_ODC.Id_Convenzione
   AND RDA_Deleted = ' '
   AND RDA_Stato <> 'Saved'
GROUP BY Id_Convenzione, RDA_Owner, Document_ODC.Plant, YEAR (RDA_DataCreazione), Doc_Name, Protocol, CAST(DescrizioneEstesa AS VARCHAR(8000)), Merceologia
UNION 
SELECT Id_Convenzione                                                   AS RDA_Id
     , b.IdPfu                                                          AS RDA_Owner
     , Id_Convenzione                                
     , Document_ODC.Plant
     , SUM(RDA_Total)                                                   AS RDA_Total
     , Id_Convenzione                                                   AS Convenzione
     , YEAR (RDA_DataCreazione)                                         AS Anno
     , Doc_Name
     , Protocol
     , CAST(DescrizioneEstesa AS VARCHAR(8000))                         AS DescrizioneEstesa
     , Merceologia
  FROM Document_ODC
     , Document_Convenzione
     , ProfiliUtente a
     , ProfiliUtenteAttrib b
 WHERE Document_Convenzione.Id = Document_ODC.Id_Convenzione
   AND RDA_Owner = CAST(a.IdPfu AS VARCHAR)
   AND b.attValue = ODC_PEG
   AND b.dztNome = 'FiltroPeg'
   AND RDA_Deleted = ' '
   AND RDA_Stato <> 'Saved'
GROUP BY Id_Convenzione, RDA_Owner, Document_ODC.Plant, YEAR (RDA_DataCreazione), Doc_Name, Protocol, CAST(DescrizioneEstesa AS VARCHAR(8000)), Merceologia, b.IdPfu


GO
