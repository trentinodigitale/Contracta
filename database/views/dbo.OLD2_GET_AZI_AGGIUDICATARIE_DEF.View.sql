USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_GET_AZI_AGGIUDICATARIE_DEF]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE VIEW [dbo].[OLD2_GET_AZI_AGGIUDICATARIE_DEF] as 

	select 

			--------------------------------------------------------------		
			--------------------------------------------------------------		
			O.idheader as idPDA ,  
			LO.NumeroLotto ,  
			--------------------------------------------------------------		
			--------------------------------------------------------------		

			isnull(dz.vatValore_FV, ap.CodiceFiscale) as CFIMP ,	--Codice fiscale
			isnull(az.aziragionesociale,ap.RagSoc)  as NOMIMP ,	--Ragione sociale dell'impresa'

			--'1' as W3AGIDGRP , 					--Numero raggruppamento ( da fare capire  ) 
			O.IdRow as W3AGIDGRP , 					
			
			case 
				when ap.IdRow is null then '1' 
				when  ap.TipoRiferimento in ( 'RTI' ) then '1'
				else '2'
			
			end as AGGAUS ,					--Aggiudicataria o ausiliaria 1 = Aggiudicataria , 2 = Ausiliaria
			
			dbo.OCP_getTipologiaSoggetto( case when RTI.IdHeader is not null then '1' else '0' end,   AZ.aziIdDscFormaSoc) as W3ID_TIPOA ,--Tipologia del soggetto aggiudicatario	ATI  ( da fare capire )

			dbo.OCP_getRuoloRTI ( case when RTI.IdHeader is not null then '1' else '0' end, ap.ruolo_impresa) as W3RUOLO, --Ruolo (eventuale) nell'associazione	1 = Mandataria , 2 = Mandante  
	
			case when ap2.IdRow is null then  '0' else '3' end as  W3FLAG_AVV,					--L'aggiudicatario ha fatto ricorso all'avvalimento?	0 : NO - 3 : Per i requisiti e l'attestazione
			
			t.ValOut as G_NAZIMP,

			isnull(az.aziIndirizzoLeg, ap.IndirizzoLeg) as INDIMP ,		--Indirizzo	VIA RAGAZZI DEL '99
			isnull( az.aziNumeroCivico , '' ) as  NCIIMP , 					--N. civico	13 ( da fare )
			left(az.aziCAPLeg,5) as CAPIMP ,			--CAP
			isnull(az.aziLocalitaLeg, ap.LocalitaLeg) as LOCIMP , 		--Comune
			az.aziTelefono1 as TELIMP , 		--Telefono
			az.aziFAX as FAXIMP	,				--Fax
			az.aziE_Mail as EMAI2IP , 			--e-mail
			dz2.vatValore_FT as NCCIAA  ,	--N. iscrizione registro imprese 

			az.idAzi,	-- è 0 o null se nell'offerta si è inserito un operatore economico non presente a sistema

			ap2.CodiceFiscale as CFIMP_AUSILIARIA 



		from Document_PDA_OFFERTE O with(nolock)
			inner join Document_MicroLotti_Dettagli LO with(nolock) on LO.idheader = O.IdRow and LO.TipoDoc = 'PDA_OFFERTE' and LO.Voce = 0 and LO.Posizione in ( 'Aggiudicatario definitivo', 'Idoneo definitivo' ) 
			left join CTL_DOC  p with(nolock) on p.LinkedDoc = O.idmsg and p.tipodoc = 'OFFERTA_PARTECIPANTI' and p.Deleted  = 0 and p.StatoFunzionale = 'Pubblicato'
			
			left join Document_Offerta_Partecipanti ap with(nolock) on ap.IdHeader = p.Id  and ap.TipoRiferimento in ( 'RTI' ) 
			left join Document_Offerta_Partecipanti ap2 with(nolock) on ap2.IdHeader = p.Id  and ap2.TipoRiferimento in ( 'AUSILIARIE' ) -- utile per capire se una ditta ha fatto ricorso all'avvalimento

			left join ( select distinct IdHeader from  Document_Offerta_Partecipanti with(nolock) where TipoRiferimento in ( 'RTI' ) ) as RTI on RTI.IdHeader = p.Id
			
			left join Aziende AZ with(nolock) on  ( AZ.idazi = ap.IdAzi and isnull(ap.IdAzi,0) <> 0 ) -- PRENDO I DATI DELLA PARTECIPANTE SE E' PRESENTE A SISTEMA
															or
													 --PRENDIAMO I DATI DELL'AZIENDA CHE HA PRESENTATO L'OFFERTA SE PARTECIPA DA SOLA
													 ( AZ.idazi = O.idAziPartecipante and ap.IdHeader is null )

			left  join dm_attributi dz with(nolock) on dz.idApp = 1 and dz.lnk = az.idazi and dz.dztNome = 'Codicefiscale'
			left  join dm_attributi dz2 with(nolock) on dz2.idApp = 1 and dz2.lnk = az.idazi and dz2.dztNome = 'IscrCCIAA'

			

			left join GEO_Elenco_Stati_ISO_3166_1 g with(nolock) on g.ISO_3166_1_3_LetterCode = dbo.GetPos( az.azistatoleg2, '-', 4)
			left join CTL_Transcodifica t with(nolock) on t.dztNome = 'G_NAZIMP' and t.Sistema = 'SITAR' and t.ValIn = g.ISO_3166_1_2_LetterCode

	--	where O.idheader = 329217

		

UNION-- ALL

	select 

			--------------------------------------------------------------		
			--------------------------------------------------------------		
			O.idheader as idPDA ,  
			LO.NumeroLotto ,  
			--------------------------------------------------------------		
			--------------------------------------------------------------		

			isnull(dz.vatValore_FV, ap.CodiceFiscale) as CFIMP ,	--Codice fiscale
			isnull(az.aziragionesociale,ap.RagSoc)  as NOMIMP ,	--Ragione sociale dell'impresa'

			'1' as W3AGIDGRP , 					--Numero raggruppamento ( da fare capire  ) 
			
			'2' as AGGAUS ,					--Aggiudicataria o ausiliaria 1 = Aggiudicataria , 2 = Ausiliaria
			
			'1' W3ID_TIPOA ,

			'' W3RUOLO	,				--Ruolo (eventuale) nell'associazione	1 = Mandataria , 2 = Mandante  

			--'0' as  W3FLAG_AVV,					--L'aggiudicatario ha fatto ricorso all'avvalimento?	0 : NO - 3 : Per i requisiti e l'attestazione
			null as  W3FLAG_AVV,					--L'aggiudicatario ha fatto ricorso all'avvalimento?	0 : NO - 3 : Per i requisiti e l'attestazione
			
			t.ValOut as G_NAZIMP,

			isnull(az.aziIndirizzoLeg, ap.IndirizzoLeg) as INDIMP ,		--Indirizzo	VIA RAGAZZI DEL '99
			isnull( az.aziNumeroCivico , '' ) as  NCIIMP , 					--N. civico	13 ( da fare )
			left(az.aziCAPLeg,5) as CAPIMP ,			--CAP
			isnull(az.aziLocalitaLeg, ap.LocalitaLeg) as LOCIMP , 		--Comune
			az.aziTelefono1 as TELIMP , 		--Telefono
			az.aziFAX as FAXIMP	,				--Fax
			az.aziE_Mail as EMAI2IP , 			--e-mail
			'' as NCCIAA  ,	--N. iscrizione registro imprese ( da fare

			az.idAzi,	-- è 0 o null se nell'offerta si è inserito un operatore economico non presente a sistema

			NULL as  CFIMP_AUSILIARIA 

			--, ap.*
			--, p.*

		from Document_PDA_OFFERTE O with(nolock)
			inner join Document_MicroLotti_Dettagli LO with(nolock) on LO.idheader = O.IdRow and LO.TipoDoc = 'PDA_OFFERTE' and LO.Voce = 0 and LO.Posizione IN ( 'Aggiudicatario definitivo', 'Idoneo definitivo' ) 
			left  join CTL_DOC  p with(nolock) on p.LinkedDoc = O.idmsg and p.tipodoc = 'OFFERTA_PARTECIPANTI' and p.Deleted  = 0 and p.StatoFunzionale = 'Pubblicato'
			
			INNER join Document_Offerta_Partecipanti ap with(nolock) on ap.IdHeader = p.Id  and ap.TipoRiferimento in ( 'AUSILIARIE' )  -- and ap.TipoRiferimento in ( 'AUSILIARIE',  'RTI' ) 
			left  join ( select distinct IdHeader from  Document_Offerta_Partecipanti with(nolock) where TipoRiferimento in ( 'AUSILIARIE' ) ) as AU on AU.IdHeader = p.Id
			left  join Aziende AZ with(nolock) on  ( AZ.idazi = ap.IdAzi and isnull(ap.IdAzi,0) <> 0 ) -- PRENDO I DATI DELLA PARTECIPANTE SE E' PRESENTE A SISTEMA
			left  join dm_attributi dz with(nolock) on dz.idApp = 1 and dz.lnk = az.idazi and dz.dztNome = 'Codicefiscale'
			left join GEO_Elenco_Stati_ISO_3166_1 g with(nolock) on g.ISO_3166_1_3_LetterCode = dbo.GetPos( az.azistatoleg2, '-', 4)
			left join CTL_Transcodifica t with(nolock) on t.dztNome = 'G_NAZIMP' and t.Sistema = 'SITAR' and t.ValIn = g.ISO_3166_1_2_LetterCode
		--where O.idheader = 329217
GO
