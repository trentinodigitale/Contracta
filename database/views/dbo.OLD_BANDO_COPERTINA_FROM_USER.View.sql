USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_BANDO_COPERTINA_FROM_USER]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[OLD_BANDO_COPERTINA_FROM_USER] as 
select 
	idpfu as ID_FROM , 
	pfuidazi as Azienda,
	p.NumGiorniDomandaPartecipazione

from profiliutente
left outer join Document_Parametri_SDA p on p.deleted = 0

GO
