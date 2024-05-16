USE [AFLink_TND]
GO
/****** Object:  View [dbo].[MAIL_INVIO_ATTI_GARA]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[MAIL_INVIO_ATTI_GARA]
AS
SELECT     dbo.CTL_DOC.ProtocolloRiferimento AS Protocol, dbo.Document_Richiesta_Atti.aziRagioneSociale AS RagSociale, 
                      dbo.Document_Richiesta_Atti.codicefiscale AS CF, dbo.CTL_DOC.Id AS idDOC, 'I' AS LNG, dbo.CTL_DOC.DataInvio AS DataCreazione
FROM         dbo.Document_Richiesta_Atti INNER JOIN
                      dbo.CTL_DOC ON dbo.CTL_DOC.LinkedDoc = dbo.Document_Richiesta_Atti.idHeader



GO
