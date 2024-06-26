USE [AFLink_TND]
GO
/****** Object:  View [dbo].[Seleziona_Ente]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[Seleziona_Ente]
as
SELECT     dbo.Aziende.IdAzi AS indrow,
 dbo.Aziende.IdAzi AS idAziPartecipante,
 dbo.Aziende.aziRagioneSociale,
 convert( varchar(20),IdAzi)	+ '#' + '\0000\0000' /* path*/ as Plant
FROM         dbo.Aziende 
			--, az_struttura	
where  dbo.Aziende.AziVenditore=0 
	--and dbo.Aziende.IdAzi NOT IN (Select mpIdAziMaster from [MarketPlace])
	--and idazi=idaz 
	and azideleted=0
	and Aziende.IdAzi <> 35152002




GO
