USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_DASHBOARD_VIEW_CATALOGHI_MEA]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[OLD_DASHBOARD_VIEW_CATALOGHI_MEA]
AS
SELECT 
		d.Id,
		p.idPfu,
		a.aziRagioneSociale,
		mo.Body as Titolo,
		d.Protocollo,
		d.DataInvio,
		d.StatoFunzionale,
		d.LinkedDoc
		
FROM
		dbo.CTL_DOC d with (nolock)
		--inner join CTL_DOC ba with (nolock) on ba.Id = d.LinkedDoc
		inner join CTL_DOC as mo with (nolock) on d.IdDoc = mo.Id
		inner join aziende a with (nolock) on d.Azienda = a.IdAzi
		cross join profiliutente p with (nolock) 
WHERE
		d.TipoDoc = 'CATALOGO_MEA' AND
		d.StatoFunzionale <> 'InLavorazione' AND
		d.Deleted = 0 
GO
