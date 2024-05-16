USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_DASHBOARD_VIEW_AZIENDE]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[OLD2_DASHBOARD_VIEW_AZIENDE]
AS
SELECT  
     A.*
     , DM_5.vatValore_FT AS CodiceFiscale
  FROM Aziende A
  LEFT OUTER JOIN DM_Attributi AS DM_5 ON A.IdAzi = DM_5.lnk AND DM_5.idApp = 1 AND DM_5.dztNome = 'CodiceFiscale'
 WHERE aziDeleted = 0

GO
