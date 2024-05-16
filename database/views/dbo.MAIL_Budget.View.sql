USE [AFLink_TND]
GO
/****** Object:  View [dbo].[MAIL_Budget]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[MAIL_Budget]
AS
SELECT     dbo.ProfiliUtente.IdPfu AS idDOC, dbo.Lingue.lngSuffisso AS LNG, dbo.ProfiliUtente.pfuNome
FROM         dbo.ProfiliUtente INNER JOIN
                      dbo.Lingue ON dbo.ProfiliUtente.pfuIdLng = dbo.Lingue.IdLng


GO
