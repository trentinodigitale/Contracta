USE [AFLink_TND]
GO
/****** Object:  View [dbo].[RIC_PREV_PUBB_STORICO]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[RIC_PREV_PUBB_STORICO]
AS
SELECT     TOP 100 PERCENT dbo.Document_RicPrevPubblic.id, Document_RicPrevPubblic_1.id AS LinkModified, 
                      dbo.Document_RicPrevPubblic.LinkModified AS Expr1, dbo.Document_RicPrevPubblic.StatoRicPrevPubblic, dbo.Document_RicPrevPubblic.PEG, 
                      dbo.Document_RicPrevPubblic.Protocol, CAST(dbo.Document_RicPrevPubblic.Oggetto AS nvarchar(200)) AS Sintesi, 
                      dbo.Document_RicPrevPubblic.Importo, dbo.Document_RicPrevPubblic.FAX, dbo.Document_RicPrevPubblic.NumQuotReg, 
                      dbo.Document_RicPrevPubblic.NumQuotNaz, dbo.Document_RicPrevPubblic.NumCaratteri, dbo.Document_RicPrevPubblic.RigoLungo, 
                      dbo.Document_RicPrevPubblic.NumRighe, dbo.Document_RicPrevPubblic.Allegato, dbo.Document_RicPrevPubblic.UserDirigente, 
                      dbo.Document_RicPrevPubblic.DataInvio, dbo.Document_RicPrevPubblic.Pratica, dbo.Document_RicPrevPubblic.UserProvveditore, 
                      dbo.Document_RicPrevPubblic.DataCompilazione, dbo.Document_RicPrevPubblic.NumRigheBollo, dbo.Document_RicPrevPubblic.AllegatoBURC, 
                      dbo.Document_RicPrevPubblic.AllegatoGURI, 'RIC_PREV_PUBB' AS STORICOGrid_OPEN_DOC_NAME, 
                      dbo.Document_RicPrevPubblic.id AS STORICOGrid_ID_DOC, dbo.Document_RicPrevPubblic.DataOperazione, 
                      dbo.Document_RicPrevPubblic.[User]
FROM         dbo.Document_RicPrevPubblic INNER JOIN
                      dbo.Document_RicPrevPubblic AS Document_RicPrevPubblic_1 ON 
                      dbo.Document_RicPrevPubblic.LinkModified = Document_RicPrevPubblic_1.LinkModified
WHERE     (dbo.Document_RicPrevPubblic.Storico = 1)

GO
