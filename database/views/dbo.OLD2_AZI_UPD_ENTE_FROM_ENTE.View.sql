USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_AZI_UPD_ENTE_FROM_ENTE]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE view [dbo].[OLD2_AZI_UPD_ENTE_FROM_ENTE] as 
	SELECT 
	  A.IdAzi as ID_FROM 
	 , A.IdAzi
     , A.aziLog
     , null as aziDataCreazione
     , A.aziRagioneSociale
     , A.aziRagioneSocialeNorm
     , A.aziIdDscFormaSoc
     , A.aziPartitaIVA
     , A.aziE_Mail
     , A.aziAcquirente
     , A.aziVenditore
     , A.aziProspect
     , A.aziIndirizzoLeg
     , A.aziIndirizzoOp
     , A.aziLocalitaLeg
     , A.aziLocalitaOp
     , A.aziProvinciaLeg
     , A.aziProvinciaOp
     , A.aziStatoLeg
     , A.aziStatoOp
     , A.aziCAPLeg
     , A.aziCapOp
     , A.aziPrefisso
     , A.aziTelefono1
     , A.aziTelefono2
     , A.aziFAX
     , A.aziLogo
     , A.aziGphValueOper
     , A.aziDeleted
     , dbo.getAtecoAzi(A.IdAzi) AS aziAtvAtecord 
     , A.azisitoWeb
	 ,A.TipodiAmministr
	 , d1.vatValore_FT  as TIPO_AMM_ER
	 --,codicefiscale as aziCodiceFiscale
	 ,d2.vatValore_FT  as aziCodiceFiscale
	 ,d2.vatValore_FT  as codicefiscale
	, SUBSTRING ( dmv_father ,1 , charindex('-',dmv_father)-1 ) as PrimoLivelloStruttura
	, case 
		   when A.azideleted=1 and ISNULL(d3.vatValore_FT,'') = '1'
				then 'Eliminato'
		   when A.azideleted=1 and ISNULL(d3.vatValore_FT,'') = ''
		   		then 'Cessato'
		   else	'Attivo'
	 end  as statoente
	 ,d4.vatValore_FT  as aziRegioneLeg
	 ,d5.vatValore_FT  as aziRegioneLeg2

	 ,a.aziLocalitaLeg2
	 ,a.aziProvinciaLeg2
	 ,a.aziStatoLeg2

	 , d6.vatValore_FT as PARTICIPANTID
	 , d7.vatValore_FT as IDNOTIER
	 , d8.vatValore_FT as SetEnteProponente,
		 b.vatValore_FT as CognomeRapLeg,
			c.vatValore_FT as NomeRapLeg,
			d.vatValore_FT as CFRapLeg,
			e.vatValore_FT as LocalitaRapLeg,
			f.vatValore_FT as DataRapLeg,
			g.vatValore_FT as ResidenzaRapLeg,
			h.vatValore_FT as IndResidenzaRapLeg,

			d9.vatValore_FT as disabilita_iscriz_peppol
				
  FROM Aziende A
	left outer join dbo.DM_Attributi d1 with(nolock) on d1.dztNome = 'TIPO_AMM_ER' and d1.idApp = 1 and d1.lnk = A.idazi
	left outer join dbo.DM_Attributi d2 with(nolock) on d2.dztNome = 'codicefiscale' and d2.idApp = 1 and d2.lnk = A.idazi
	left outer join dbo.DM_Attributi d3 with(nolock) on d3.dztNome = 'ELIMINATA' and d3.idApp = 1 and d3.lnk = A.idazi
	left outer join dbo.DM_Attributi d4 with(nolock) on d4.dztNome = 'aziRegioneLeg' and d4.idApp = 1 and d4.lnk = A.idazi
	left outer join dbo.DM_Attributi d5 with(nolock) on d5.dztNome = 'aziRegioneLeg2' and d5.idApp = 1 and d5.lnk = A.idazi
	--left join document_Aziende da on da.idazi=A.idazi and da.azideleted=0 and TipoOperAnag='AZI_ENTE'

	left outer join LIB_DomainValues with(nolock) on dmv_dm_id='TIPO_AMM_ER' and dmv_cod=d1.vatValore_FT

	left outer join dbo.DM_Attributi d6 with(nolock) on d6.dztNome = 'PARTICIPANTID' and d6.idApp = 1 and d6.lnk = A.idazi
	left outer join dbo.DM_Attributi d7 with(nolock) on d7.dztNome = 'IDNOTIER' and d7.idApp = 1 and d7.lnk = A.idazi
	left outer join dbo.DM_Attributi d8 with(nolock) on d8.dztNome = 'SetEnteProponente' and d8.idApp = 1 and d8.lnk = A.idazi
	
	left join dm_attributi b with(nolock) ON b.lnk = a.IdAzi and b.dztNome = 'CognomeRapLeg'
	left join dm_attributi c with(nolock) ON c.lnk = a.IdAzi and c.dztNome = 'NomeRapLeg'
	left join dm_attributi d with(nolock) ON d.lnk = a.IdAzi and d.dztNome = 'CFRapLeg'
	left join dm_attributi e with(nolock) ON e.lnk = a.IdAzi and e.dztNome = 'LocalitaRapLeg'
	left join dm_attributi f with(nolock) ON f.lnk = a.IdAzi and f.dztNome = 'DataRapLeg'
	left join dm_attributi g with(nolock) ON g.lnk = a.IdAzi and g.dztNome = 'ResidenzaRapLeg'
	left join dm_attributi h with(nolock) ON h.lnk = a.IdAzi and h.dztNome = 'IndResidenzaRapLeg'

	left join DM_Attributi d9 with(nolock) on d9.dztNome = 'disabilita_iscriz_peppol' and d9.idApp = 1 and d9.lnk = A.idazi

 --WHERE 
 --aziDeleted = 0   AND 
 --A.aziAcquirente = 3





GO
