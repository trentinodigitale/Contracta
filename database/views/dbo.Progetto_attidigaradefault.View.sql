USE [AFLink_TND]
GO
/****** Object:  View [dbo].[Progetto_attidigaradefault]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[Progetto_attidigaradefault]
AS
SELECT     idAttoDiGara AS id_from, Descrizione,' Descrizione ' as NotEditable
FROM         dbo.AttiDiGara
WHERE     (idAttoDiGara = 10)

GO
