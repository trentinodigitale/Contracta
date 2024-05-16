USE [AFLink_TND]
GO
/****** Object:  View [dbo].[SIMOG_CONSULTA_DATI_CIG_WS]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[SIMOG_CONSULTA_DATI_CIG_WS] AS
	select lotto.idRow as ID
			, pfu.pfuCodiceFiscale as [LOGIN]
			, dbo.DecryptPwd(pfuA.attValue) as [PASSWORD]
			, lotto.cig as CIG
		FROM Document_SIMOG_LOTTI lotto with(nolock) 
				inner join Document_SIMOG_GARA gara with(nolock) on gara.idheader = lotto.idHeader
				inner join ProfiliUtente pfu		with(nolock) on pfu.IdPfu = gara.idpfuRup
				left  join ProfiliUtenteAttrib pfuA	with(nolock) on pfuA.IdPfu = gara.idpfuRup and pfuA.dztNome = 'simog_password'
		where isnull(lotto.CIG,'') <> ''
GO
