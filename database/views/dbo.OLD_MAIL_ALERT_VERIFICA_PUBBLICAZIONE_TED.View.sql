USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_MAIL_ALERT_VERIFICA_PUBBLICAZIONE_TED]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[OLD_MAIL_ALERT_VERIFICA_PUBBLICAZIONE_TED] AS
	SELECT a.id AS idDOC, 
			'I' AS LNG, 
			g.*
		from CTL_DOC a with(nolock) 
				inner join Document_TED_GARA g with(nolock) on g.idHeader = a.id
		--where a.tipodoc = 'PUBBLICA_GARA_TED' and a.StatoFunzionale <> 'Annullato'
GO
