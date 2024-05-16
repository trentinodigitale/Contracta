USE [AFLink_TND]
GO
/****** Object:  View [dbo].[MAIL_RICHIESTA_ATTI_GARA]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[MAIL_RICHIESTA_ATTI_GARA]
AS
SELECT     dbo.CTL_DOC.ProtocolloRiferimento AS Protocol, l.aziRagioneSociale AS RagSociale, l.codicefiscale AS CF, dbo.CTL_DOC.Id AS idDOC, 'I' AS LNG, 
                      dbo.CTL_DOC.DataInvio AS DataCreazione, l.Allegato, dbo.GetLINK(dbo.CTL_DOC_ALLEGATI.idHeader) AS Link
FROM         dbo.Document_Richiesta_Atti l INNER JOIN
                      dbo.CTL_DOC ON dbo.CTL_DOC.Id = l.idHeader INNER JOIN
                      dbo.CTL_DOC_ALLEGATI ON dbo.CTL_DOC_ALLEGATI.idHeader = l.idHeader



GO
