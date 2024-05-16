USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_DASHBOARD_VIEW_ELENCO_CATALOGHI_MEA]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[OLD_DASHBOARD_VIEW_ELENCO_CATALOGHI_MEA]
AS
	SELECT        
			a.id,
			p.IdPfu,
			mo.Body as Descrizione,			
			al.Titolo as Titolo,
			a.Protocollo,
			a.DataInvio,
			a.StatoFunzionale 

		FROM	CTL_DOC as a with(nolock)
				inner join profiliutente p with(nolock) on p.pfuIdAzi = a.azienda				
				-- modello collegato
				inner join CTL_DOC as mo with(nolock) on a.IdDoc = mo.Id 
				-- albo collegato
				inner join CTL_DOC as al with(nolock) on a.LinkedDoc = al.Id 

		WHERE 
				a.TipoDoc = 'CATALOGO_MEA' and
				a.Deleted = 0 
GO
