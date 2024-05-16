USE [AFLink_TND]
GO
/****** Object:  View [dbo].[VIEW_TS_OFO_WS]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VIEW_TS_OFO_WS] AS 
	select idazi as id,
			idazi as ID_AZI,
			--replace(aziPartitaIVA,'IT','') as CHIAVE			lato TS hanno cambiato. non vogliono più la PIVA ma il CF
			b.vatValore_FT as CHIAVE
		from aziende a with(nolock)
				inner join DM_Attributi b with(nolock) on b.lnk = a.IdAzi and b.dztNome = 'codicefiscale' and b.idApp = 1
GO
