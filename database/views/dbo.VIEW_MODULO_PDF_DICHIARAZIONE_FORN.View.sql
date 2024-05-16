USE [AFLink_TND]
GO
/****** Object:  View [dbo].[VIEW_MODULO_PDF_DICHIARAZIONE_FORN]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [dbo].[VIEW_MODULO_PDF_DICHIARAZIONE_FORN] AS

	select a.id, -- la colonna ID non deve essere tolta
		   b.pfunomeutente AS NOME_FIRMA,
		   b.pfuCognome AS COGNOME_FIRMA,
		   b.pfuCodiceFiscale AS CODICE_FISCALE,

		   case when c.aziStatoLeg2 = 'M-1-11-ITA' then c1.vatValore_FT else '' end AS CODICE_FISCALE_DITTA,
		   c.aziPartitaIVA AS PARTITA_IVA_DITTA,
		   c.aziStatoLeg AS STATO_DITTA,
		   case when c.aziStatoLeg2 <> 'M-1-11-ITA' then right( c1.vatValore_FT, len(c1.vatValore_FT)-4) else '' end AS ID_FISCALE_ESTERO_DITTA,
		   c.aziRagioneSociale AS RAGIONE_SOCIALE_DITTA,

		   c.aziIndirizzoLeg AS SEDE_LEGALE_VIA_LOCALITA,
		   c.aziCAPLeg AS CAP_SEDE_LEGALE_DITTA,
		   c.aziLocalitaLeg AS COMUNE_SEDE_LEGALE_DITTA,
		   c.aziProvinciaLeg AS PROV_SEDE_LEGALE_DITTA,

		   case when c.aziStatoLeg2 = 'M-1-11-ITA' then c1.vatValore_FT else '' end AS CODICE_FISCALE_DITTA_NEW,

		   sub.aziPartitaIVA AS PARTITA_IVA_DITTA_NEW,
		   sub.aziStatoLeg AS STATO_DITTA_NEW,
		   case when c.aziStatoLeg2 <> 'M-1-11-ITA' then right( c1.vatValore_FT, len(c1.vatValore_FT)-4) else '' end AS ID_FISCALE_ESTERO_DITTA_NEW,
		   sub.aziRagioneSociale AS RAGIONE_SOCIALE_DITTA_NEW,
		   FormaGiuridica.dscTesto /*DMV_DescML*/ AS FORMA_GIURIDICA_DITTA_NEW,
		   sub.CodiceEORI AS CODICE_EORI_DITTA_NEW,
		   d8v.DMV_DescML AS OPERAZIONI_STRAORDINARIE_DITTA_NEW,
		   case when isnull(sub.DataVariazione,'') = '' then '' else dbo.GETDATEDDMMYYYY(sub.DataVariazione) end AS DATA_VARIAZIONE_DITTA_NEW,
		   dbo.GetColumnValue(sub.AttoOperazioneStraordinaria, '*', 1) AS ATTO_OPERAZIONE_STRAORDINARIA_DITTA_NEW,

		   sub.aziIndirizzoLeg AS VIA_LOCALITA_DITTA_LEGALE_NEW,
		   sub.aziCAPLeg AS CAP_DITTA_LEGALE_NEW,
		   sub.aziLocalitaLeg AS COMUNE_DITTA_LEGALE_NEW,
		   sub.aziProvinciaLeg AS PROV_DITTA_LEGAL_NEW,

		   sub.aziIndirizzoAmm AS VIA_LOCALITA_DITTA_AMM_NEW,
		   sub.aziCAPAmm AS CAP_DITTA_AMM_NEW,
		   sub.aziLocalitaAmm AS COMUNE_DITTA_AMM_NEW,
		   sub.aziProvinciaAmm AS PROV_DITTA_AMM_NEW,

		   c.aziTelefono1 AS TELEFONO_DITTA_NEW,
		   c.aziFAX AS FAX_DITTA_NEW, 
		   --b.pfuE_Mail AS E_MAIL_DITTA_NEW,
		   '' as E_MAIL_DITTA_NEW,		-- e' stato chiesto di passarlo sempre vuoto
		   
		   --c.aziE_Mail AS PEC_DITTA_NEW,
		   sub.aziE_Mail AS PEC_DITTA_NEW,

		   case when isnull(sub.DataDecorrenzaVariazioni,'') = '' then '' else dbo.GETDATEDDMMYYYY(sub.DataDecorrenzaVariazioni) end AS DATA_DECORRENZA_DELLE_VARIAZIONI,

		   convert(varchar, getdate(), 103) AS DATA_DOCUMENTO_VARIAZIONE

		   --'' AS FOOTER_1_1,
		   --'' AS FOOTER_1_2

	from ctl_doc a with(nolock)
			inner join ProfiliUtente b with(nolock) on b.idpfu = a.IdPfu	--compilatore
			inner join aziende c with(nolock) on c.IdAzi = a.Azienda
			inner join DM_Attributi c1 with(nolock) on c1.lnk = c.IdAzi and c1.dztNome = 'codicefiscale'

			left join VIEW_MODULO_PDF_DICHIARAZIONE_FORN_SUB sub on sub.idheader = a.Id

			left join tipidatirange tdr with(nolock) on tdridtid = 131 and tdrdeleted=0 and tdrcodice = sub.aziIdDscFormaSoc /*d5.Value*/
			left join descsi FormaGiuridica with(nolock) on  IdDsc = tdriddsc 

			left join LIB_DomainValues d8v with(nolock) on d8v.DMV_DM_ID = 'OPER_STRAORD' and d8v.DMV_Cod = sub.OperazioniStraordinarie

						--left join ctl_doc_value d1 with(nolock) on d1.IdHeader = a.id and d1.DSE_ID = 'TESTATA' and d1.DZT_Name = 'aziPartitaIVA'
			--left join ctl_doc_value d2 with(nolock) on d2.IdHeader = a.id and d2.DSE_ID = 'TESTATA' and d2.DZT_Name = 'aziStatoLeg'
			--left join ctl_doc_value d3 with(nolock) on d3.IdHeader = a.id and d3.DSE_ID = 'TESTATA' and d3.DZT_Name = 'aziProvinciaLeg'
			--left join ctl_doc_value d4 with(nolock) on d4.IdHeader = a.id and d4.DSE_ID = 'TESTATA' and d4.DZT_Name = 'aziLocalitaLeg'
			--left join ctl_doc_value d5 with(nolock) on d5.IdHeader = a.id and d5.DSE_ID = 'TESTATA' and d5.DZT_Name = 'aziIdDscFormaSoc'
			--left join ( 					
			--				select tdrcodice  as  DMV_Cod,
			--						dscTesto as DMV_DescML
			--					from tipidatirange with(nolock), descsi with(nolock)
			--					where tdridtid = 131 and tdrdeleted=0 and IdDsc = tdriddsc 
			--			) FormaGiuridica ON FormaGiuridica.DMV_Cod = d5.Value
			--left join ctl_doc_value d6 with(nolock) on d6.IdHeader = a.id and d6.DSE_ID = 'TESTATA' and d6.DZT_Name = 'aziRagioneSociale'
			--left join ctl_doc_value d7 with(nolock) on d7.IdHeader = a.id and d7.DSE_ID = 'TESTATA' and d7.DZT_Name = 'CodiceEORI'
			--left join ctl_doc_value d8 with(nolock) on d8.IdHeader = a.id and d8.DSE_ID = 'TESTATA' and d8.DZT_Name = 'OperazioniStraordinarie'
			--left join LIB_DomainValues d8v with(nolock) on d8v.DMV_DM_ID = 'OPER_STRAORD' and d8v.DMV_Cod = d8.Value
			--left join ctl_doc_value d9 with(nolock) on d9.IdHeader = a.id and d9.DSE_ID = 'TESTATA' and d9.DZT_Name = 'DataVariazione'
			--left join ctl_doc_value d10 with(nolock) on d10.IdHeader = a.id and d10.DSE_ID = 'TESTATA' and d10.DZT_Name = 'aziIndirizzoLeg'
			--left join ctl_doc_value d11 with(nolock) on d11.IdHeader = a.id and d11.DSE_ID = 'TESTATA' and d11.DZT_Name = 'aziCAPLeg'
			--left join ctl_doc_value d12 with(nolock) on d12.IdHeader = a.id and d12.DSE_ID = 'TESTATA' and d12.DZT_Name = 'aziLocalitaLeg'
			--left join ctl_doc_value d13 with(nolock) on d13.IdHeader = a.id and d13.DSE_ID = 'TESTATA' and d13.DZT_Name = 'aziProvinciaLeg'
			--left join ctl_doc_value d14 with(nolock) on d14.IdHeader = a.id and d14.DSE_ID = 'TESTATA' and d14.DZT_Name = 'AttoOperazioneStraordinaria'
			--left join ctl_doc_value d15 with(nolock) on d15.IdHeader = a.id and d15.DSE_ID = 'TESTATA' and d15.DZT_Name = 'aziIndirizzoAmm'
			--left join ctl_doc_value d16 with(nolock) on d16.IdHeader = a.id and d16.DSE_ID = 'TESTATA' and d16.DZT_Name = 'aziCAPAmm'
			--left join ctl_doc_value d17 with(nolock) on d17.IdHeader = a.id and d17.DSE_ID = 'TESTATA' and d17.DZT_Name = 'aziLocalitaAmm'
			--left join ctl_doc_value d18 with(nolock) on d18.IdHeader = a.id and d18.DSE_ID = 'TESTATA' and d18.DZT_Name = 'aziProvinciaAmm'
			--left join ctl_doc_value d19 with(nolock) on d19.IdHeader = a.id and d19.DSE_ID = 'TESTATA' and d19.DZT_Name = 'DataDecorrenzaVariazioni'
			

	where a.TipoDoc = 'VARIAZIONE_ANAGRAFICA'

GO
