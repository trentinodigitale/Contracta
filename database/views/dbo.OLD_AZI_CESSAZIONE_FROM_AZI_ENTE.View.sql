USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_AZI_CESSAZIONE_FROM_AZI_ENTE]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[OLD_AZI_CESSAZIONE_FROM_AZI_ENTE] as
select 	
	IdAzi,
	IdAzi as ID_FROM,
	aziragionesociale
FROM Aziende
	left outer join dbo.DM_Attributi d1 on d1.dztNome = 'TIPO_AMM_ER' and d1.idApp = 1 and d1.lnk = idazi
 WHERE aziDeleted = 0 
GO
