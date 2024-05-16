USE [AFLink_TND]
GO
/****** Object:  View [dbo].[GAAC_ACQUISIZIONE_SOGGETTI]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [dbo].[GAAC_ACQUISIZIONE_SOGGETTI] AS
	select  azi.IdAzi,
			azi.aziRagioneSociale as RAGIONE_SOCIALE,
			aziPartitaIVA as PIVA,
			case when isnull(azi.aziPartitaIVA,'') <> '' then right(azi.aziPartitaIVA, len(azi.aziPartitaIVA)-2) else '' end as PIVA_NOPREFIX,
			case when azi.aziStatoLeg2 = 'M-1-11-ITA' then '' else upper(left(azi.aziPartitaIVA,2)) end as NAZIONE_ISO,

			case when azi.aziStatoLeg2 = 'M-1-11-ITA' then '' 
				 else
					case when isnull(azi.aziPartitaIVA,'') <> '' then right(azi.aziPartitaIVA, len(azi.aziPartitaIVA)-2) else '' end 
				 end as PIVA_CEE, -- da documentazione sembrava volere anche il prefisso ma la lunghezza del campo non è sufficienti e negli esempi è passato senza
			
			cf.vatValore_FT as CF_PIVA,

			isnull(azi.aziSitoWeb,'') as SITO_WEB,
			isnull(azi.aziTelefono1,'') as TELEFONO,
			isnull(eori.vatValore_FT,'') as CODICE_EORI,
			isnull(pid.vatValore_FT,'') as ID_PEPPOL,
			isnull(azi.aziFAX,'') as FAX,
			azi.aziE_Mail as EMAIL_PEC,
			isnull(azi.aziIndirizzoLeg,'') as INDIRIZZO,
			isnull(azi.aziCAPLeg,'') as CAP,
			case when isnull(azi.aziPartitaIVA,'') = '' then 'IT' else upper(left(azi.aziPartitaIVA,2)) end as NAZIONE_PREFIX,

			case when isnumeric( dbo.GetColumnValue( aziLocalitaLeg2, '-', 8) ) = 1 then left( right('000000' + dbo.GetColumnValue( aziLocalitaLeg2, '-', 8),6)  ,3) else '' end  as ISTAT_PROVINCIA,
			case when isnumeric( dbo.GetColumnValue( aziLocalitaLeg2, '-', 8) ) = 1 then right('000000' + dbo.GetColumnValue( aziLocalitaLeg2, '-', 8), 6) else '' end  as ISTAT_COMUNE,

			case when azi.aziStatoLeg2 <> 'M-1-11-ITA' then right( cf.vatValore_FT, len(cf.vatValore_FT)-4) else '' end AS ID_FISCALE_ESTERO

		from aziende azi with(nolock)
				inner join DM_Attributi cf with(nolock) on cf.lnk = azi.IdAzi and cf.dztNome = 'codicefiscale'
				left join dm_attributi eori with(nolock) on eori.lnk = azi.IdAzi and eori.dztnome = 'CodiceEORI'
				left join dm_attributi pid with(nolock) on pid.lnk = azi.IdAzi and pid.dztnome = 'PARTICIPANTID'
GO
