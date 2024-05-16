USE [AFLink_TND]
GO
/****** Object:  View [dbo].[ProfiliPerUtenza]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[ProfiliPerUtenza] as 
select f.Codice , idPfu 
	from Profili_Funzionalita f
		inner join aziende a on charindex( aziprofilo , aziprofili , 0 ) > 0 
		inner join profiliutente p on  a.idazi = p.pfuidazi
		

GO
