USE [AFLink_TND]
GO
/****** Object:  View [dbo].[NumAzi]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE VIEW [dbo].[NumAzi]
AS
SELECT aziragionesocialenorm, COUNT(aziragionesocialenorm) AS NumRagSoc
  FROM Aziende
 WHERE aziprospect = 0
   AND azideleted = 0
GROUP BY aziragionesocialenorm
HAVING COUNT(aziragionesocialenorm) > 1
GO
