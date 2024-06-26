USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_SIMOG_SMART_CIG_DATI_WS]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[OLD_SIMOG_SMART_CIG_DATI_WS] AS 

	select d.id,
			pfu.pfuCodiceFiscale as [LOGIN],
			dbo.DecryptPwd(pfuA.attValue) as [PASSWORD],
			left ( cast(d.Body as nvarchar(max)), 1024 ) as OGGETTO,
			gara.*
		from ctl_doc d with(nolock)
				inner join Document_SIMOG_SMART_CIG gara with(nolock) on gara.idHeader = d.Id
				inner join ProfiliUtente pfu		with(nolock) on pfu.IdPfu = gara.idpfuRup
				left  join ProfiliUtenteAttrib pfuA	with(nolock) on pfuA.IdPfu = gara.idpfuRup and pfuA.dztNome = 'simog_password'
		where d.TipoDoc = 'RICHIESTA_SMART_CIG'


GO
