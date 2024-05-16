USE [AFLink_TND]
GO
/****** Object:  View [dbo].[ISTANZA_AlboOperaEco_TESTATA_FROM_BANDO]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE view [dbo].[ISTANZA_AlboOperaEco_TESTATA_FROM_BANDO] as 

SELECT 

	id as ID_FROM   
	,p.idPfu

	,a.*

,aziRagioneSociale as RagSoc
,aziIdDscFormasoc as NaGi
,aziIndirizzoLeg as INDIRIZZOLEG
,aziLocalitaLeg as LOCALITALEG
,aziLocalitaLeg2 as LOCALITALEG2
,aziCAPLeg as CAPLEG
,aziProvinciaLeg as PROVINCIALEG
,aziProvinciaLeg2 as PROVINCIALEG2
,aziTelefono1 as NUMTEL
,aziTelefono2 as NUMTEL2
,aziFAX as NUMFAX
,aziE_Mail as EMail
,aziE_Mail as EmailAssociato
,aziPartitaIVA as PIVA
,aziPartitaIVA as PIVAassociato
,aziStatoLeg as STATOLOCALITALEG
,aziStatoLeg2 as STATOLOCALITALEG2


		,d1.vatValore_FT as NomeRapLeg
		,d2.vatValore_FT as CognomeRapLeg
		,d3.vatValore_FT as LocalitaRapLeg
		,d23.vatValore_FT as LocalitaRapLeg2
		,d26.vatValore_FT as ProvinciaRapLeg
		,d27.vatValore_FT as ProvinciaRapLeg2
		,d4.vatValore_FT as DataRapLeg
		,d5.vatValore_FT as CFRapLeg
		,d6.vatValore_FT as TelefonoRapLeg
		,d7.vatValore_FT as CellulareRapLeg
		,d8.vatValore_FT as ResidenzaRapLeg
		,d25.vatValore_FT as ResidenzaRapLeg2
		,d9.vatValore_FT as ProvResidenzaRapLeg
		,d24.vatValore_FT as ProvResidenzaRapLeg2
		,d10.vatValore_FT as IndResidenzaRapLeg
		,d11.vatValore_FT as CapResidenzaRapLeg
		,d12.vatValore_FT as RuoloRapLeg
		,d13.vatValore_FT as NumProcura
		,d14.vatValore_FT as DelProcura
		,d15.vatValore_FT as NumRaccolta
		,d16.vatValore_FT as codicefiscale
		,d18.vatValore_FT as EmailRapLeg
		,d19.vatValore_FT as StatoRapLeg
		,d20.vatValore_FT as StatoResidenzaRapLeg
		,d21.vatValore_FT as StatoResidenzaRapLeg2
		,d22.vatValore_FT as StatoRapLeg2
		
	

	FROM         CTL_DOC  
		cross join profiliutente p
		inner join  aziende a on a.idazi = p.pfuidazi and a.azivenditore <> 0

		left outer join DM_Attributi d1 on d1.lnk = a.idazi and d1.idApp = 1 and d1.dztNome = 'NomeRapLeg'
		left outer join DM_Attributi d2 on d2.lnk = a.idazi and d2.idApp = 1 and d2.dztNome = 'CognomeRapLeg'
		left outer join DM_Attributi d3 on d3.lnk = a.idazi and d3.idApp = 1 and d3.dztNome = 'LocalitaRapLeg'
		left outer join DM_Attributi d4 on d4.lnk = a.idazi and d4.idApp = 1 and d4.dztNome = 'DataRapLeg'
		left outer join DM_Attributi d5 on d5.lnk = a.idazi and d5.idApp = 1 and d5.dztNome = 'CFRapLeg'
		left outer join DM_Attributi d6 on d6.lnk = a.idazi and d6.idApp = 1 and d6.dztNome = 'TelefonoRapLeg'
		left outer join DM_Attributi d7 on d7.lnk = a.idazi and d7.idApp = 1 and d7.dztNome = 'CellulareRapLeg'
		left outer join DM_Attributi d8 on d8.lnk = a.idazi and d8.idApp = 1 and d8.dztNome = 'ResidenzaRapLeg'
		left outer join DM_Attributi d9 on d9.lnk = a.idazi and d9.idApp = 1 and d9.dztNome = 'ProvResidenzaRapLeg'
		left outer join DM_Attributi d10 on d10.lnk = a.idazi and d10.idApp = 1 and d10.dztNome = 'IndResidenzaRapLeg'
		left outer join DM_Attributi d11 on d11.lnk = a.idazi and d11.idApp = 1 and d11.dztNome = 'CapResidenzaRapLeg'
		left outer join DM_Attributi d12 on d12.lnk = a.idazi and d12.idApp = 1 and d12.dztNome = 'RuoloRapLeg'
		left outer join DM_Attributi d13 on d13.lnk = a.idazi and d13.idApp = 1 and d13.dztNome = 'NumProcura'
		left outer join DM_Attributi d14 on d14.lnk = a.idazi and d14.idApp = 1 and d14.dztNome = 'DelProcura'
		left outer join DM_Attributi d15 on d15.lnk = a.idazi and d15.idApp = 1 and d15.dztNome = 'NumRaccolta'
		left outer join DM_Attributi d16 on d16.lnk = a.idazi and d16.idApp = 1 and d16.dztNome = 'codicefiscale'
		left outer join DM_Attributi d18 on d18.lnk = a.idazi and d18.idApp = 1 and d18.dztNome = 'EmailRapLeg'
		left outer join DM_Attributi d19 on d19.lnk = a.idazi and d19.idApp = 1 and d19.dztNome = 'StatoRapLeg'
		left outer join DM_Attributi d20 on d20.lnk = a.idazi and d20.idApp = 1 and d20.dztNome = 'StatoResidenzaRapLeg'
		left outer join DM_Attributi d21 on d21.lnk = a.idazi and d21.idApp = 1 and d21.dztNome = 'StatoResidenzaRapLeg2'
		left outer join DM_Attributi d22 on d22.lnk = a.idazi and d22.idApp = 1 and d22.dztNome = 'StatoRapLeg2'
		left outer join DM_Attributi d23 on d23.lnk = a.idazi and d23.idApp = 1 and d23.dztNome = 'LocalitaRapLeg2'
		left outer join DM_Attributi d24 on d24.lnk = a.idazi and d24.idApp = 1 and d24.dztNome = 'ProvResidenzaRapLeg2'
		left outer join DM_Attributi d25 on d25.lnk = a.idazi and d25.idApp = 1 and d25.dztNome = 'ResidenzaRapLeg2'
		left outer join DM_Attributi d26 on d26.lnk = a.idazi and d26.idApp = 1 and d26.dztNome = 'ProvinciaRapLeg'
		left outer join DM_Attributi d27 on d27.lnk = a.idazi and d27.idApp = 1 and d27.dztNome = 'ProvinciaRapLeg2'

		
	where 
		TipoDoc='BANDO' and deleted=0 





GO
