USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_PROFILI]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[DASHBOARD_VIEW_PROFILI] as 
	
	select 
		id, NomeProfilo, TipoProfilo, Funzionalita, Deleted, aziProfilo as aziProfili, Descrizione, Codice , DataUltimaMod
	from Profili_Funzionalita
		--where deleted = 0 
GO
