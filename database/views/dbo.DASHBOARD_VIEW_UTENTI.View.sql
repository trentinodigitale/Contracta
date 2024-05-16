USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_UTENTI]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create VIEW [dbo].[DASHBOARD_VIEW_UTENTI]
AS
SELECT  
   *
  FROM Aziende A  with(nolock) 
		inner join profiliutente on pfuidazi=idazi
 WHERE aziDeleted = 0 and pfudeleted=0
GO
