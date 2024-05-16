USE [AFLink_TND]
GO
/****** Object:  View [dbo].[WS_API_VIEW_UTENTE_RUOLI]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[WS_API_VIEW_UTENTE_RUOLI] AS

	SELECT  p.IdPfu as idUtente, --chiave di ingresso
			
			r.attValue as Codice,
			isnull(rd.DMV_DescML,'') as Descrizione

		FROM profiliutente p with(nolock)
				INNER JOIN ProfiliUtenteAttrib r with(nolock) ON r.IdPfu = p.IdPfu and r.dztNome = 'UserRole'
				LEFT JOIN LIB_DomainValues rD with(nolock) ON rd.DMV_DM_ID = 'UserRole' and rd.DMV_Cod = r.attValue
GO
