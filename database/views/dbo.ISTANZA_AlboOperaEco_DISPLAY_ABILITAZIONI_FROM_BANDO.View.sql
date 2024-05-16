USE [AFLink_TND]
GO
/****** Object:  View [dbo].[ISTANZA_AlboOperaEco_DISPLAY_ABILITAZIONI_FROM_BANDO]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[ISTANZA_AlboOperaEco_DISPLAY_ABILITAZIONI_FROM_BANDO] as
SELECT 
	id as ID_FROM,
	p.idPfu,
	dbo.GetMultiValueAzi(a.idazi, 'ClasseIscriz') AS ClasseIscriz,
	dbo.GetMultiValueAzi(a.idazi, 'ClassificazioneSOA') AS GerarchicoSOA	
	
FROM CTL_DOC  
	cross join profiliutente p
	inner join  aziende a on a.idazi = p.pfuidazi
	--left outer join DM_Attributi d1 on d1.lnk = a.idazi and d1.idApp = 1 and d1.dztNome = 'ClasseIscriz'	
	--left outer join DM_Attributi d2 on d2.lnk = a.idazi and d2.idApp = 1 and d2.dztNome = 'ClassificazioneSOA'	
where 
		TipoDoc='BANDO'
GO
