USE [AFLink_TND]
GO
/****** Object:  View [dbo].[VIEW_GET_ENTI_FROM_CF_USER_AZI]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VIEW_GET_ENTI_FROM_CF_USER_AZI] as 

	-- ENTRANDO PER IDPFU DELL'UTENTE COLLEGATO, RITORNO L'ELENCO DEGLI ENTI CHE HANNO IL CODICEFISCALE UGUALE A QUELLO
	-- DELL'ENTE DELL'UTENTE COLLEGATO. OPPURE RITORNO TUTTI GLI ENTI SE L'UTENTE COLLEGATO HA IL PROFILO AVCPADMIN

	select distinct p.idpfu as idpfu,  isnull(enti.idazi,entiALL.idazi) as idAziEnte
		from profiliutente p with(nolock)
				left join profiliutenteattrib attr with(nolock) on attr.idpfu = p.idpfu and attr.dztNome = 'profilo' and attr.attValue = 'AvcpAdmin'
				inner join DM_Attributi d1 with(nolock) on d1.idApp = 1 and d1.lnk = p.pfuidazi and d1.dztnome = 'CodiceFiscale' 

				-- relazione per quando l'utente non ha il profilo AvcpAdmin
				left join DM_Attributi d2 with(nolock) on ( attr.IdUsAttr is null ) and d2.idApp = 1 and d2.dztnome = 'CodiceFiscale' and d1.vatValore_FT = d2.vatValore_FT
				left join aziende enti with(nolock) ON enti.idazi = d2.lnk and enti.azivenditore = 0   and enti.aziDeleted = 0

				left join aziende entiALL with(nolock) ON ( NOT attr.IdUsAttr IS NULL ) and entiALL.azivenditore = 0   and entiALL.aziDeleted = 0

		where p.idpfu > 0 and p.pfuDeleted = 0 and ( not isnull(enti.idazi,entiALL.idazi) is null ) 


GO
