USE [AFLink_TND]
GO
/****** Object:  View [dbo].[AFV_Elenco_Utenti]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[AFV_Elenco_Utenti] as

	select 
	
		p.idpfu as idUtente 
		, pfuLogin as Login
		, pfunomeutente as Nome
		, pfucognome as Cognome
		, pfuCodiceFiscale as CodiceFiscale
		, pfuE_Mail as eMail
		, pfuTel as Telefono

		, idazi as idAzienda
		, aziLog as AziendaCodice
		, a.aziragioneSociale as AziendaRagioneSociale		
		
		, s.attvalue as CodiceDirezione
		, az.Descrizione as DescrizioneDirezione


		, R.attValue as  RuoloCodice
		, RU.DMV_DescML as RuoloDescrizione
		, convert( varchar(19) , R.DataUltimaMod , 121 ) as RuoloData
		
		, pfudeleted as Cessato

		from profiliUtente p with(nolock)
			inner join aziende a with(nolock) on a.idazi = p.pfuidazi
			
			left join ProfiliUtenteAttrib s with(nolock) on s.IdPfu = p.IdPfu and s.dztNome = 'Plant'
			left join AZ_Struttura az with(nolock) on cast( az.idaz as varchar(20)) + az.Path = s.attvalue

			left join ProfiliUtenteAttrib R with(nolock) on R.IdPfu = p.IdPfu and R.dztNome = 'UserRole'
			left join ( SELECT top 100000 dmv_cod , DMV_DescML from UserRole_MLNG where ML_LNG='I'  ) as RU on RU.DMV_Cod = R.attValue

		where p.pfudeleted = 0



GO
