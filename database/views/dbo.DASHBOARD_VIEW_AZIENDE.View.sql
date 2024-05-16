USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_AZIENDE]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[DASHBOARD_VIEW_AZIENDE]
AS
SELECT  
     A.*
     , DM_5.vatValore_FT AS CodiceFiscale
  FROM Aziende A  with(nolock) 
  LEFT OUTER JOIN DM_Attributi AS DM_5  with(nolock) ON A.IdAzi = DM_5.lnk AND DM_5.idApp = 1 AND DM_5.dztNome = 'CodiceFiscale'
 WHERE aziDeleted = 0



GO
