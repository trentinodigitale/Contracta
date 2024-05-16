USE [AFLink_TND]
GO
/****** Object:  View [dbo].[SIMOG_CONSULTA_GARA_DATI_WS]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[SIMOG_CONSULTA_GARA_DATI_WS] AS
	select GARA.idHeader as ID
			, pfu.pfuCodiceFiscale as [LOGIN]
			, dbo.DecryptPwd(pfuA.attValue) as [PASSWORD]
			, gara.id_gara as ID_GARA
		FROM Document_SIMOG_GARA gara				with(nolock) 
				inner join ProfiliUtente pfu		with(nolock) on pfu.IdPfu = gara.idpfuRup
				left  join ProfiliUtenteAttrib pfuA	with(nolock) on pfuA.IdPfu = gara.idpfuRup and pfuA.dztNome = 'simog_password'
		where isnull(gara.id_gara,'') <> ''
GO
