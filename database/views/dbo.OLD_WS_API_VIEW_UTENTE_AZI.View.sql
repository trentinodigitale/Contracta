USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_WS_API_VIEW_UTENTE_AZI]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[OLD_WS_API_VIEW_UTENTE_AZI] AS

	SELECT  p.pfuIdAzi as idAzienda, --chiave di ingresso
			p.IdPfu as idUtente, 
			isnull(p.pfuLogin,'') as Login,
			isnull(p.pfuCognome,'') as Cognome,
			isnull(p.pfunomeutente,'') as Nome,
			isnull(p.pfuCodiceFiscale,'') as CodiceFiscale,
			isnull(p.pfuE_Mail,'') as eMail,
			isnull(p.pfuTel,'') as Telefono,
			isnull( isnull(rm.ML_Description, r.DMV_DescML), '') as Qualifica

		FROM profiliutente p with(nolock)
				LEFT JOIN LIB_DomainValues r with(nolock) on r.DMV_DM_ID = 'pfuRuoloAziendale' and r.DMV_Cod = p.pfuRuoloAziendale
				LEFT JOIN LIB_Multilinguismo rm with(nolock) on rm.ML_KEY = r.DMV_DescML and rm.ML_LNG = 'I'
		where p.pfuDeleted = 0 and idpfu > 0
GO
