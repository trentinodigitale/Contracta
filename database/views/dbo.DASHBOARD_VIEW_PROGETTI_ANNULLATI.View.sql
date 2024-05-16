USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_PROGETTI_ANNULLATI]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[DASHBOARD_VIEW_PROGETTI_ANNULLATI]
AS
SELECT DISTINCT 
                      TOP 100 PERCENT dbo.Document_Progetti.IdProgetto, dbo.Document_Progetti.StatoProgetto, dbo.Document_Progetti.PEG, 
                      dbo.Document_Progetti.Protocol, dbo.Document_Progetti.Importo, dbo.Document_Progetti.NumLotti,
                      dbo.Document_Progetti.AllegatoDPE,dbo.Document_Progetti.UserDirigente, dbo.Document_Progetti.DataInvio, dbo.Document_Progetti.Pratica, 
                      dbo.Document_Progetti.UserProvveditore, dbo.Document_Progetti.DataCompilazione, 
                      CAST(dbo.Document_Progetti.Oggetto AS nvarchar(200)) AS Sintesi, dbo.ProfiliUtenteAttrib.IdPfu
FROM         dbo.Document_Progetti INNER JOIN
                      dbo.CTL_Relations ON dbo.Document_Progetti.PEG = dbo.CTL_Relations.REL_ValueOutput INNER JOIN
                      dbo.ProfiliUtenteAttrib ON dbo.CTL_Relations.REL_ValueInput = dbo.ProfiliUtenteAttrib.attValue
WHERE     (dbo.ProfiliUtenteAttrib.dztNome = 'UserRole') AND (dbo.CTL_Relations.REL_Type = 'UserRole_2_PlantCDC') AND 
                      (dbo.Document_Progetti.Storico = 0)


GO
