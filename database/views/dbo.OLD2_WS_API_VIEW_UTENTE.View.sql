USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_WS_API_VIEW_UTENTE]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[OLD2_WS_API_VIEW_UTENTE] AS

	SELECT  p.IdPfu as idUtente, --chiave di ingresso
			isnull(p.pfuLogin,'') as Login,
			isnull(p.pfuCognome,'') as Cognome,
			isnull(p.pfunomeutente,'') as Nome,
			isnull(p.pfuCodiceFiscale,'') as CodiceFiscale,
			isnull(p.pfuE_Mail,'') as eMail,
			isnull(p.pfuTel,'') as Telefono,
			isnull(p.pfuDeleted,0) as Cessato,

			isnull(az.IdAzi,0) as idAzienda,
			isnull(az.aziLog,'') as Codice,
			isnull(az.aziRagioneSociale,'') as RagioneSociale,
			isnull(s.Codice,'') as CodiceDirezione,
			isnull(s.Descrizione,'') as DescrizioneDirezione

		FROM profiliutente p with(nolock)
				INNER JOIN aziende az with(nolock) ON az.IdAzi = p.pfuIdAzi
				left join profiliutenteattrib a with(nolock) on a.idpfu = p.idpfu and a.dztnome = 'PLANT' 
				left join DOMINIO_STRUTTURA_AZIENDALE_ENTE S on s.Codice = a.attValue

				--LEFT JOIN DM_Attributi strut with(nolock) ON strut.lnk = az.IdAzi and strut.dztNome  = 'TIPO_AMM_ER'
				--LEFT JOIN LIB_DomainValues strutD with(nolock) ON strutD.DMV_DM_ID = 'TIPO_AMM_ER' and strutd.DMV_Cod = strut.vatValore_FT
GO
