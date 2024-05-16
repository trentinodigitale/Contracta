USE [AFLink_TND]
GO
/****** Object:  View [dbo].[SIMOG_LOGIN_RPNT_DATI_WS]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[SIMOG_LOGIN_RPNT_DATI_WS] AS

	select ws.*,
			p.idpfu as id
		from profiliutente p with(nolock)
				inner join ProfiliUtenteAttrib pa with(nolock) on pa.idpfu = p.idpfu and pa.dztNome = 'simogRupRPNT' and pa.attValue = '1'
				inner join SIMOG_LOGIN_DATI_WS ws on ws.IdPfu = pa.IdPfu
		where p.pfuIdAzi = 35152001 and p.pfuDeleted = 0 --per restringere/velocizzare la ricerca prendiamo solo gli utenti dell'azimastewr
GO
