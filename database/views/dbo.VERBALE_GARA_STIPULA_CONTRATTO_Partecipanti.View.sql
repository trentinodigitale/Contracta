USE [AFLink_TND]
GO
/****** Object:  View [dbo].[VERBALE_GARA_STIPULA_CONTRATTO_Partecipanti]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE VIEW [dbo].[VERBALE_GARA_STIPULA_CONTRATTO_Partecipanti] as

	select
		
		CONTR.id
		, 
		case 
			when DOP.Ruolo_Impresa in ('Mandante') then 'Mandante'
			when DOP.Ruolo_Impresa in ('Mandataria') then 'Mandataria'
			when DOP.TipoRiferimento='ESECUTRICI' then 'Esecutrice'
			when DOP.TipoRiferimento='AUSILIARIE' then 'Ausiliaria'

			else ''
		end as Ruolo_OE

		, 
		case 
				when DOP.TipoRiferimento IN ('ESECUTRICI','AUSILIARIE') then DOP.RagSocRiferimento 
				else ''
		 end as RagSocRiferimento
			

		, OE.aziRagioneSociale as RagioneSociale_OE
		, replace(OE.aziPartitaIVA,'IT','')  as  PartitaIva_OE
		, isnull(OE1.vatValore_FV,'') as  CodiceFiscale_OE
		, OE.aziIndirizzoLeg + ' ' + OE.aziProvinciaLeg  as  SedeLegale_OE
		, OE.aziTelefono1 as Telefono_OE
		, OE.aziE_Mail as  PostaElettronica_OE
		, FormaSoc.dscTesto as TipologiaImpresa_OE
		, isnull(OE2.vatValore_FV,'') as NumeroIscrizioneRea
		, isnull(OE3.vatValore_FV,'')  as AnnoIscrizioneRea
		, isnull(OE4.vatValore_FV,'')  as SedeIscrizioneRea
		, DOP.TipoRiferimento
		, OE.aziIdDscFormaSoc as CodiceFormaSoc
	from 
		ctl_doc CONTR with(nolock) 

			inner join CTL_DOC_VALUE C4 with(nolock) on C4.IdHeader = CONTR.id and C4.dse_id='DOCUMENT' and C4.DZT_Name ='ProtocolloOfferta'
			inner join ctl_doc O with (nolock) on O.Protocollo = C4.value
			inner join ctl_doc OP with (nolock) on OP.LinkedDoc = O.id and OP.TipoDoc = 'OFFERTA_PARTECIPANTI' and OP.statofunzionale='Pubblicato' 
			inner join Document_Offerta_Partecipanti DOP with(nolock) on OP.id = DOP.IdHeader
			inner join Aziende OE with (nolock) on OE.idazi = DOP.IdAzi
			inner join tipidatirange with(nolock) on tdridtid = 131 and tdrCodice =  OE.aziIdDscFormaSoc
			inner join DescsI FormaSoc with(nolock) on  tdrIdDsc= IdDsc
			left join DM_ATTRIBUTI OE1 with(nolock) on OE1.lnk = OE.IdAzi and OE1.dztNome = 'codicefiscale'
			left join DM_ATTRIBUTI OE2 with(nolock) on OE2.lnk = OE.IdAzi and OE2.dztNome = 'IscrCCIAA'
			left join DM_ATTRIBUTI OE3 with(nolock) on OE3.lnk = OE.IdAzi and OE3.dztNome = 'AnnoIscrCCIAA'
			left join DM_ATTRIBUTI OE4 with(nolock) on OE4.lnk = OE.IdAzi and OE4.dztNome = 'SedeCCIAA'

	where
		CONTR.tipodoc='CONTRATTO_GARA' and CONTR.Deleted = 0
GO
