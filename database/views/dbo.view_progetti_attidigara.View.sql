USE [AFLink_TND]
GO
/****** Object:  View [dbo].[view_progetti_attidigara]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[view_progetti_attidigara]
AS
SELECT     idProgetto AS iddoc, descrizione AS DescrAttach, Allegato AS Attach
FROM    Document_Progetti_AttiDiGara


GO
