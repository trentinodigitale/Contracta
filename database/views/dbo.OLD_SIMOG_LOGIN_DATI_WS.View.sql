USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_SIMOG_LOGIN_DATI_WS]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[OLD_SIMOG_LOGIN_DATI_WS] AS
	select  pfu.IdPfu
			, pfu.pfuCodiceFiscale as [LOGIN]
			, case when dbo.DecryptPwd(pfuA.attValue) = '' then 'NO_PWD'else dbo.DecryptPwd(pfuA.attValue) end as [PASSWORD] --non facciamo uscire mai la password vuota altrimenti si chiede l'imputazione a video lato richiesta cig
			, dm1.vatValore_FT as [CF_ENTE]
		from ProfiliUtente pfu						with(nolock)
				left  join ProfiliUtenteAttrib pfuA	with(nolock) on pfuA.IdPfu = pfu.IdPfu and pfuA.dztNome = 'simog_password'
				inner join aziende ente				with(nolock) on ente.idazi = pfu.pfuIdAzi
				inner join DM_Attributi dm1			with(nolock) on dm1.lnk = ente.IdAzi and dm1.dztNome = 'codicefiscale'
			
		


GO
