USE [AFLink_TND]
GO
/****** Object:  View [dbo].[USER_AZI_STESSO_CF]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  view [dbo].[USER_AZI_STESSO_CF] as 

select distinct p.idpfu as pfuSource , p2.idPfu as pfuDest
	from profiliutente p 
		--inner join aziende a on p.pfuidazi = a.idazi
		inner join DM_Attributi d1 on d1.idApp = 1 and d1.lnk = p.pfuidazi and d1.dztnome = 'CodiceFiscale' 
		inner join DM_Attributi d2 on d2.idApp = 1 and d2.dztnome = 'CodiceFiscale' and d1.vatValore_FT = d2.vatValore_FT
		inner join profiliutente p2 on p2.pfuidazi = d2.lnk 

GO
