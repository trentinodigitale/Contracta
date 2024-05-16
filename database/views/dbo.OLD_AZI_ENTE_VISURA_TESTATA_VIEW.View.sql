USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_AZI_ENTE_VISURA_TESTATA_VIEW]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO











CREATE VIEW [dbo].[OLD_AZI_ENTE_VISURA_TESTATA_VIEW]
AS
SELECT A.IdAzi
     , A.aziLog
     , A.aziDataCreazione
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

	 , a.aziLocalitaLeg2
	 , a.aziProvinciaLeg2
	 , a.aziStatoLeg2
	 , d6.vatValore_FT  as SetEnteProponente
	 --, isnull(d7.vatValore_FT,'no') as Attiva_OCP
	 , case
		when d7.vatValore_FT is null or d7.vatValore_FT = '' then 'no'
		else d7.vatValore_FT
		end as Attiva_OCP 
	 , A.aziProfili 
	 , dbo.MultiSelAziProfili( A.aziProfili ) as aziProfilo
	 
	 , d8.vatValore_FT as disabilita_iscriz_peppol
	 , dbo.Get_PARTICIPANTID_Ente(A.idazi) as PARTICIPANTID
	 
	 , case 
			
			when not PART_ID.Idazi is null and  IPA.Idazi is null then '10' -- Fuori Piattaforma - (le P.A. hanno il Participant ID e non sono registrate Noti-ER) qualcosa nella prima PART_ID
			when not IPA.Idazi is null and PART_ID.Idazi is null then '11'-- In Piattaforma – (le P.A. sono registrate Noti-ER) hanno almeno 1 della seconda  IPA
			when not PART_ID.Idazi is null or not IPA.Idazi is null  then '1_'-- SI - (le P.A. hanno un Participant ID) hanno un participant id  (o l'uno oppure l'altro)
			when PART_ID.Idazi is null and IPA.idazi is null  then '00' -- NO – (le P.A. non hanno un Participant ID) non hanno un participant id (nessuno dei 2)
     
		end as iscrittoPeppolEnte

	 , case when pv.Status = 'Elaborated' and pv.isPEC = 0 then 1 else 0 end as PecNonValida

	FROM Aziende A
		left outer join dbo.DM_Attributi d1 on d1.dztNome = 'TIPO_AMM_ER' and d1.idApp = 1 and d1.lnk = A.idazi
		left outer join dbo.DM_Attributi d2 on d2.dztNome = 'codicefiscale' and d2.idApp = 1 and d2.lnk = A.idazi
		left outer join dbo.DM_Attributi d3 on d3.dztNome = 'ELIMINATA' and d3.idApp = 1 and d3.lnk = A.idazi
		left outer join dbo.DM_Attributi d4 on d4.dztNome = 'aziRegioneLeg' and d4.idApp = 1 and d4.lnk = A.idazi
		left outer join dbo.DM_Attributi d5 on d5.dztNome = 'aziRegioneLeg2' and d5.idApp = 1 and d5.lnk = A.idazi
		left outer join dbo.DM_Attributi d6 on d6.dztNome = 'SetEnteProponente' and d6.idApp = 1 and d6.lnk = A.idazi
		--left join document_Aziende da on da.idazi=A.idazi and da.azideleted=0 and TipoOperAnag='AZI_ENTE'

		left outer join LIB_DomainValues on dmv_dm_id='TIPO_AMM_ER' and dmv_cod=d1.vatValore_FT
		left join dbo.dm_attributi d7 with(nolock) ON d7.dztNome = 'Attiva_OCP' and d7.idApp = 1 and d7.lnk = a.IdAzi  
		left join DM_Attributi d8 with(nolock) on d8.dztNome = 'disabilita_iscriz_peppol' and d8.idApp = 1 and d8.lnk = A.idazi

		left join CTL_Pec_Verify pv with(nolock) on pv.eMail = a.aziE_Mail

		left join
			(
				 select distinct  lnk as Idazi 
					from 
						DM_Attributi with(nolock) 
					where  ( dztnome = 'PARTICIPANTID' or dztnome = 'IDNOTIER' ) and isnull(vatValore_FT,'') <> '' 
					group by lnk
					
			) PART_ID on PART_ID.Idazi = A.idazi

		left join 
			( 
				select distinct idazi from VIEW_SCHEDA_ANAGRAFICA_IPA  where 
																			( 
																				Peppol_Invio_DDT = '1' 
																				or 
																				Peppol_Invio_Ordine = '1' 
																				or 
																				Peppol_Ricezione_DDT = '1' 
																				or 
																				Peppol_Ricezione_Ordine = '1' 
																				Or 
																				Peppol_Invio_Fatture = '1'
																				Or 
																				Peppol_Invio_NoteDiCredito = '1'
																			)
			) IPA on IPA.IdAzi= A.idazi
	WHERE A.aziAcquirente = 3

GO
