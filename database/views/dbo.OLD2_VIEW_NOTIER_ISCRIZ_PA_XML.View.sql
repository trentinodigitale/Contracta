USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_VIEW_NOTIER_ISCRIZ_PA_XML]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE VIEW [dbo].[OLD2_VIEW_NOTIER_ISCRIZ_PA_XML] AS
	select doc.Id -- chiave di ingresso

			, doc.Azienda as IdAzi

			/* Dati dell'Organizzazione */
			, az1.vatValore_FT as ORG_CodiceFiscale
			, az.aziPartitaIVA as ORG_PartitaIva
			, az.aziRagioneSociale as ORG_Denominazione
			, isnull(az.aziIndirizzoLeg,'') as ORG_Indirizzo
			, isnull(az.aziTelefono1,'') as ORG_Telefono
			, isnull(az.aziE_Mail,'') as ORG_PEC
			, p.pfuNome as ORG_Referente
			, p.pfuE_Mail as ORG_EmailReferente

			, SUBSTRING ( dv.dmv_father ,1 , charindex('-',dv.dmv_father)-1 ) as ORG_PrimoLivelloStruttura
			, isnull(d1.vatValore_FT,'') as ORG_SecondoLivelloStruttura

			, isnull(s.ISO_3166_1_2_LetterCode,'IT') as ORG_stato
			, isnull(az2.vatValore_FT,'') as IDNOTIER_ORGANIZZAZIONE

			/* Dati dell'Ufficio */
			, az1.vatValore_FT as UFF_CodiceFiscale
			, az.aziPartitaIVA as UFF_PartitaIva
			, isnull(s.ISO_3166_1_2_LetterCode,'IT') as UFF_stato
			, ip2.Value as UFF_Denominazione
			--, coalesce(ip1.Value,ip0.value,'') as UFF_CodiceIPA
			, case when doc.tipodoc = 'NOTIER_ISCRIZ_PA' then 
						case when isnull(ip1.Value,'') = '' then 'CODICE_FISCALE' else ip1.Value end
					ELSE isnull(ip1.Value,'') 
					END
				AS UFF_CodiceIPA
			, isnull(ip3.Value,'') as UFF_Indirizzo
			, ip4.Value as UFF_Telefono
			, isnull(ip5.Value,'') as UFF_PEC
			, ip6.Value as UFF_Referente
			, ip7.Value as UFF_EmailReferente
			, ip8.Value as UFF_Peppol_Invio_DDT
			, ip9.Value as UFF_Peppol_Invio_Ordine
			, ip10.Value as UFF_Peppol_Ricezione_DDT
			, ip11.Value as UFF_Peppol_Ricezione_Ordine
			, ip12.Value as UFF_Peppol_Invio_Fatture
			, ip13.Value as UFF_Peppol_Invio_NoteDiCredito

			, ip1.Row as IpaRow

		from ctl_doc doc with(nolock)
				inner join aziende az with(nolock) on az.IdAzi = doc.Azienda
				inner join DM_Attributi az1 with(nolock) on az1.lnk = az.IdAzi and az1.idApp = 1 and az1.dztNome = 'codicefiscale'
				left join DM_Attributi az2 with(nolock) on az2.lnk = az.IdAzi and az2.idApp = 1 and az2.dztNome = 'IDNOTIER_ORGANIZZAZIONE'

				--primo e secondo livello struttura
				left join DM_Attributi d1  with (nolock) on d1.lnk = az.idazi and D1.dztnome = 'TIPO_AMM_ER' and d1.idApp = 1
				left join LIB_DomainValues dv with (nolock) on dv.dmv_dm_id='TIPO_AMM_ER' and dv.dmv_cod = d1.vatValore_FT

				inner join ProfiliUtente p with(nolock) on p.pfuIdAzi = az.IdAzi and p.pfuDeleted = 0
				inner join ProfiliUtenteAttrib pa with(nolock) on pa.idpfu = p.idpfu and pa.dztNome = 'UserRole' and pa.attValue = 'RESPONSABILE_PEPPOL' -- c'è 1 solo resp peppol

				/* Esplodiamo sulle righe degli IPA */
				--left join ctl_doc_value ip0 with(nolock) on ip0.IdHeader = doc.id and ip0.DSE_ID = 'IPA' and ip0.DZT_Name = 'CodiceUfficio'
				left join ctl_doc_value ip1 with(nolock) on ip1.IdHeader = doc.id and ip1.DSE_ID = 'IPA' and ip1.DZT_Name = 'CodiceIPA'
				left join ctl_doc_value ip2 with(nolock) on ip2.IdHeader = doc.id and ip2.DSE_ID = 'IPA' and ip2.DZT_Name = 'DenominazioneIPA' and ip2.Row = ip1.Row
				left join ctl_doc_value ip3 with(nolock) on ip3.IdHeader = doc.id and ip3.DSE_ID = 'IPA' and ip3.DZT_Name = 'IndirizzoIPA' and ip3.Row = ip1.Row
				left join ctl_doc_value ip4 with(nolock) on ip4.IdHeader = doc.id and ip4.DSE_ID = 'IPA' and ip4.DZT_Name = 'TelefonoIPA' and ip4.Row = ip1.Row
				left join ctl_doc_value ip5 with(nolock) on ip5.IdHeader = doc.id and ip5.DSE_ID = 'IPA' and ip5.DZT_Name = 'pecIPA' and ip5.Row = ip1.Row
				left join ctl_doc_value ip6 with(nolock) on ip6.IdHeader = doc.id and ip6.DSE_ID = 'IPA' and ip6.DZT_Name = 'ReferenteIPA' and ip6.Row = ip1.Row
				left join ctl_doc_value ip7 with(nolock) on ip7.IdHeader = doc.id and ip7.DSE_ID = 'IPA' and ip7.DZT_Name = 'EmailReferenteIPA' and ip7.Row = ip1.Row

				left join ctl_doc_value ip8 with(nolock) on ip8.IdHeader = doc.id and ip8.DSE_ID = 'IPA' and ip8.DZT_Name = 'Peppol_Invio_DDT' and ip8.Row = ip1.Row
				left join ctl_doc_value ip9 with(nolock) on ip9.IdHeader = doc.id and ip9.DSE_ID = 'IPA' and ip9.DZT_Name = 'Peppol_Invio_Ordine' and ip9.Row = ip1.Row
				left join ctl_doc_value ip10 with(nolock) on ip10.IdHeader = doc.id and ip10.DSE_ID = 'IPA' and ip10.DZT_Name = 'Peppol_Ricezione_DDT' and ip10.Row = ip1.Row
				left join ctl_doc_value ip11 with(nolock) on ip11.IdHeader = doc.id and ip11.DSE_ID = 'IPA' and ip11.DZT_Name = 'Peppol_Ricezione_Ordine' and ip11.Row = ip1.Row
				left join ctl_doc_value ip12 with(nolock) on ip12.IdHeader = doc.id and ip12.DSE_ID = 'IPA' and ip12.DZT_Name = 'Peppol_Invio_Fatture' and ip12.Row = ip1.Row
				left join ctl_doc_value ip13 with(nolock) on ip13.IdHeader = doc.id and ip13.DSE_ID = 'IPA' and ip13.DZT_Name = 'Peppol_Invio_NoteDiCredito' and ip13.Row = ip1.Row

				left join GEO_Elenco_Stati_ISO_3166_1 S with(nolock) ON dbo.getpos(az.aziStatoLeg2,'-', 4) = s.ISO_3166_1_3_LetterCode

		where doc.TipoDoc IN ( 'NOTIER_ISCRIZ_PA', 'NOTIER_ANNULLA_ISCRIZ' )
	--select * from ctl_doc_value with(nolock) where idheader = 414083
	--select * from VIEW_NOTIER_ISCRIZ_PA_XML where id = 414083


GO
