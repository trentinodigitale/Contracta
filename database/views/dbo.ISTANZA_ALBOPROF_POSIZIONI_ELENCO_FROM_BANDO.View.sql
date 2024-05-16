USE [AFLink_TND]
GO
/****** Object:  View [dbo].[ISTANZA_ALBOPROF_POSIZIONI_ELENCO_FROM_BANDO]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE  view [dbo].[ISTANZA_ALBOPROF_POSIZIONI_ELENCO_FROM_BANDO] as 

SELECT 

		id as ID_FROM  
		,p.idPfu
		,d1.vatValore_FT as NomeDirTec
		,d2.vatValore_FT as CognomeDirTec
		,d3.vatValore_FT as LocalitaDirTec
		,d4.vatValore_FT as DataDirTec
		,d5.vatValore_FT as CFDirTec
		
	

	FROM         CTL_DOC  
		cross join profiliutente p
		inner join  aziende a on a.idazi = p.pfuidazi

		left outer join DM_Attributi d1 on d1.lnk = a.idazi and d1.idApp = 1 and d1.dztNome = 'NomeRapLeg'
		left outer join DM_Attributi d2 on d2.lnk = a.idazi and d2.idApp = 1 and d2.dztNome = 'CognomeRapLeg'
		left outer join DM_Attributi d3 on d3.lnk = a.idazi and d3.idApp = 1 and d3.dztNome = 'LocalitaRapLeg'
		left outer join DM_Attributi d4 on d4.lnk = a.idazi and d4.idApp = 1 and d4.dztNome = 'DataRapLeg'
		left outer join DM_Attributi d5 on d5.lnk = a.idazi and d5.idApp = 1 and d5.dztNome = 'CFRapLeg'
		
	where 
		TipoDoc='BANDO'



GO
