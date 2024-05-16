USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_RIC_PREV_PUBB_EVASE]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[DASHBOARD_VIEW_RIC_PREV_PUBB_EVASE]
AS
SELECT DISTINCT 
                      TOP 100 PERCENT dbo.Document_RicPrevPubblic.id, dbo.Document_RicPrevPubblic.StatoRicPrevPubblic, dbo.Document_RicPrevPubblic.PEG, 
                      dbo.Document_RicPrevPubblic.Protocol, dbo.Document_RicPrevPubblic.Importo, dbo.Document_RicPrevPubblic.FAX, 
                      dbo.Document_RicPrevPubblic.NumQuotReg, dbo.Document_RicPrevPubblic.NumQuotNaz, dbo.Document_RicPrevPubblic.NumCaratteri, 
                      dbo.Document_RicPrevPubblic.NumRigheBollo, dbo.Document_RicPrevPubblic.NumRigheGuri, dbo.Document_RicPrevPubblic.RigoLungo, dbo.Document_RicPrevPubblic.NumRighe, dbo.Document_RicPrevPubblic.Allegato, 
                      dbo.Document_RicPrevPubblic.UserDirigente, dbo.Document_RicPrevPubblic.DataInvio, dbo.Document_RicPrevPubblic.Pratica, 
                      dbo.Document_RicPrevPubblic.UserProvveditore, dbo.Document_RicPrevPubblic.DataCompilazione, 
                      CAST(dbo.Document_RicPrevPubblic.Oggetto AS nvarchar(200)) AS Sintesi, dbo.ProfiliUtenteAttrib.IdPfu
FROM         dbo.Document_RicPrevPubblic INNER JOIN
                      dbo.CTL_Relations ON dbo.Document_RicPrevPubblic.PEG = dbo.CTL_Relations.REL_ValueOutput INNER JOIN
                      dbo.ProfiliUtenteAttrib ON dbo.CTL_Relations.REL_ValueInput = dbo.ProfiliUtenteAttrib.attValue
WHERE     (dbo.ProfiliUtenteAttrib.dztNome = 'UserRole') AND (dbo.CTL_Relations.REL_Type = 'UserRole_2_PlantCDC') AND 
                      (dbo.Document_RicPrevPubblic.Storico = 0)


GO
