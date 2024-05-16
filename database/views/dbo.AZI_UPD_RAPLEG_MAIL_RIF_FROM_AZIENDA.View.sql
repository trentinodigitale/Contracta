USE [AFLink_TND]
GO
/****** Object:  View [dbo].[AZI_UPD_RAPLEG_MAIL_RIF_FROM_AZIENDA]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[AZI_UPD_RAPLEG_MAIL_RIF_FROM_AZIENDA]
AS

SELECT 
       a.IdAzi
     , a.IdAzi AS ID_FROM
     ,ISNULL(vatValore_FT,'') as emailriferimentoazienda
     
  FROM Aziende AS a 
  --INNER JOIN Document_Aziende_RapLeg AS s ON a.IdAzi = s.idAziRapLeg AND s.isOld = 0
  LEFT JOIN DM_ATTRIBUTI AS DA on a.IdAzi=DA.lnk and dztNome='emailriferimentoazienda'
  
  
GO
