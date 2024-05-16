USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_WS_API_VIEW_UTENTE_PROFILI]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[OLD_WS_API_VIEW_UTENTE_PROFILI] AS

	SELECT  p.IdPfu as idUtente, --chiave di ingresso
			
			pr.attValue as Codice,
			isnull(prd.Descrizione,'') as Descrizione

		FROM profiliutente p with(nolock)
				INNER JOIN ProfiliUtenteAttrib pr with(nolock) ON pr.IdPfu = p.IdPfu and pr.dztNome = 'Profilo'
				INNER JOIN Profili_Funzionalita prD with(nolock) oN prd.Codice = PR.attValue
GO
