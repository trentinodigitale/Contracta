USE [AFLink_TND]
GO
/****** Object:  View [dbo].[View_testata_controlli_albo]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[View_testata_controlli_albo] AS
SELECT    distinct idazi as IdAziControllata 
FROM       Aziende
 LEFT OUTER JOIN Document_Aziende_Comunicazioni ON Idazi = idazicontrollata




GO
