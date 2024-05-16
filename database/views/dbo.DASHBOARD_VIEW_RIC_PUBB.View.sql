USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_RIC_PUBB]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[DASHBOARD_VIEW_RIC_PUBB]
AS
SELECT    StatoRicPrevPubblic,  dbo.Document_RicPubblic.id, dbo.Document_RicPubblic.idRicPrevPubblic, dbo.Document_RicPubblic.StatoRicPubblic, dbo.Document_RicPubblic.PEG, 
                      dbo.Document_RicPubblic.Bando, dbo.Document_RicPubblic.Pratica, dbo.Document_RicPubblic.Fornitore, dbo.Document_RicPubblic.Fax, 
                      dbo.Document_RicPubblic.Allegato, dbo.Document_RicPubblic.UserDirigente, dbo.Document_RicPubblic.Num, dbo.Document_RicPubblic.Data, 
                      dbo.Document_RicPubblic.Prog, dbo.Document_RicPubblic.Imp, dbo.Document_RicPubblic.Bil, dbo.Document_RicPubblic.Owner, dbo.Document_RicPubblic.DataInvio,
                      CAST(dbo.Document_RicPubblic.Oggetto AS nvarchar(200)) AS Sintesi, dbo.Document_RicPubblic.idRicPrevPubblic AS IDDOC, 
                      dbo.ProfiliUtenteAttrib.IdPfu
FROM         dbo.Document_RicPubblic INNER JOIN
                      dbo.ProfiliUtenteAttrib ON dbo.Document_RicPubblic.TipoPubblic = dbo.ProfiliUtenteAttrib.attValue AND 
                      dbo.ProfiliUtenteAttrib.dztNome = 'RichiestePreventivi'
inner join Document_RicPrevPubblic on idRicPrevPubblic = Document_RicPrevPubblic.id and Storico = 0
--where StatoRicPrevPubblic <> 'Published'

GO
