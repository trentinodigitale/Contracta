USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_INVIO_ATTI_GARA_TESTATA_VIEW]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[OLD_INVIO_ATTI_GARA_TESTATA_VIEW]
AS
SELECT     *
FROM         dbo.CTL_DOC LEFT OUTER JOIN
                      dbo.Document_Richiesta_Atti ON dbo.CTL_DOC.Id = dbo.Document_Richiesta_Atti.idHeader




GO
