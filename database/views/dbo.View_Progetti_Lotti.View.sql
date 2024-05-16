USE [AFLink_TND]
GO
/****** Object:  View [dbo].[View_Progetti_Lotti]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[View_Progetti_Lotti]
AS
SELECT     dbo.Document_Progetti.IdProgetto, dbo.Document_Progetti_Lotti.IdRow, dbo.Document_Progetti.Tipologia, dbo.Document_Progetti.TipoProcedura, 
                      dbo.Document_Progetti.CriterioAggiudicazione, dbo.Document_Progetti.NumLotti
FROM         dbo.Document_Progetti INNER JOIN
                      dbo.Document_Progetti_Lotti ON dbo.Document_Progetti.IdProgetto = dbo.Document_Progetti_Lotti.IdProgetto

GO
