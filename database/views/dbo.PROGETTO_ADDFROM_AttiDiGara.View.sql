USE [AFLink_TND]
GO
/****** Object:  View [dbo].[PROGETTO_ADDFROM_AttiDiGara]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[PROGETTO_ADDFROM_AttiDiGara]
AS
SELECT     idAttoDiGara AS indrow, Descrizione,case Descrizione when 'Varie' then '' else ' Descrizione ' end as NotEditable
FROM         dbo.AttiDiGara

GO
