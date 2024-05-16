USE [AFLink_TND]
GO
/****** Object:  View [dbo].[VIEW_MODULO_PDF_NOTIER_ISCRIZ]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VIEW_MODULO_PDF_NOTIER_ISCRIZ] as

	select D.id as id -- la colonna ID non deve essere tolta
		   , a.aziRagioneSociale as RAGIONE_SOCIALE
		   , a.aziLocalitaLeg as SEDE_LEGALE
		   , a.aziPartitaIVA as CODFIS_PIVA
		   , a.aziPartitaIVA as PIVA
		   , dm.vatValore_FT as CODICE_FISCALE
		   , a.aziE_Mail as EMAIL
		   , a.aziTelefono1 as TELEFONO1
		   , a.aziTelefono2 as TELEFONO2

		   -- Nuovi campi
		   , isnull(f1.Value,'') as RIC_COMUNE_NASCITA
		   , p.pfuNome as RIC_NOME_COGNOME 
		   , isnull(f2.Value,'') as RIC_PROV_NASCITA
		   , isnull(f3.Value,'') as RIC_STATO_NASCITA

		   , dbo.GETDATEDDMMYYYY(isnull(f4.Value,'')) as RIC_DT_NASCITA

		   , p.pfuCodiceFiscale as RIC_CF  

		   , isnull(r1.Value,'') as RIC_COMUNE_RESID
		   , isnull(r2.Value,'') as RIC_PROV_RESID
		   , isnull(r3.Value,'') as RIC_CAP_RESID 
		   , isnull(r4.Value,'') as RIC_STATO_RESID
		   , isnull(r5.Value,'') as RIC_INDIRIZ_E_CIVICO_RESID
		   , isnull(r5.Value,'') as RIC_INDIRIZZO_RESID
		   
		   , P.pfuRuoloAziendale as RIC_CARICA_SOCIALE 
		   
		   , a.aziRagioneSociale as AZI_RAG_SOC
		   , desc1.dscTesto as AZI_FORMA_GIURIDICA

		   , a.aziIndirizzoLeg as AZI_INDIRIZ_E_CIVICO_SEDE
		   , a.aziLocalitaLeg as AZI_COMUNE_SEDE
		   , a.aziProvinciaLeg as AZI_PROV_SEDE
		   , a.aziStatoLeg as AZI_STATO_SEDE
		   , a.aziCAPLeg as AZI_CAP_SEDE

		   , dm.vatValore_FT as AZI_CF
		   , a.aziPartitaIVA as AZI_PIVA

		   ,isnull(p1.Value,'') as RIC_NOTAIO

		   ,	case when isnull(p2.Value,'') <> '' then dbo.GETDATEDDMMYYYY(p2.Value)
					 else ''
				end as RIC_DATA_PROCURA

		   ,isnull(p3.Value,'') as RIC_NUM_REP_PROCURA
		   ,isnull(p4.Value,'') as RIC_RACCOLTA_PROCURA

		   ,p.pfuNome as RIC_NOME_COGNOME_FIRMATARIO

		   --,'NON-GESTITO' as RIC_LUOGO_FIRMA_DOCUMENTO -- tolti
		   --,'NON-GESTITO' as RIC_DATA_FIRMA_DOCUMENTO  -- tolti


		   --- campi per la gestione della mancanza del kit di firma
		   , aa.aziRagioneSociale as RAGIONE_SOCIALE_SIGN
		   , aa.aziLocalitaLeg as SEDE_LEGALE_SIGN
		   , aa.aziPartitaIVA as CODFIS_PIVA_SIGN
		   , aa.aziPartitaIVA as PIVA_SIGN
		   , d22.value as CODICE_FISCALE_SIGN
		   , aa.aziE_Mail as EMAIL_SIGN
		   , aa.aziTelefono1 as TELEFONO1_SIGN
		   , aa.aziTelefono2 as TELEFONO2_SIGN

		   -- Nuovi campi
		   , isnull(ff1.Value,'') as RIC_COMUNE_NASCITA_SIGN
		   , pP.pfuNome as RIC_NOME_COGNOME_SIGN 
		   , isnull(ff2.Value,'') as RIC_PROV_NASCITA_SIGN
		   , isnull(ff3.Value,'') as RIC_STATO_NASCITA_SIGN

		   , dbo.GETDATEDDMMYYYY(isnull(ff4.Value,'')) as RIC_DT_NASCITA_SIGN

		   , pp.pfuCodiceFiscale as RIC_CF_SIGN

		   , isnull(rr1.Value,'') as RIC_COMUNE_RESID_SIGN
		   , isnull(rr2.Value,'') as RIC_PROV_RESID_SIGN
		   , isnull(rr3.Value,'') as RIC_CAP_RESID_SIGN 
		   , isnull(rr4.Value,'') as RIC_STATO_RESID_SIGN
		   , isnull(rr5.Value,'') as RIC_INDIRIZ_E_CIVICO_RESID_SIGN
		   , isnull(rr5.Value,'') as RIC_INDIRIZZO_RESID_SIGN
		   
		   , pp.pfuRuoloAziendale as RIC_CARICA_SOCIALE_SIGN
		   
		   , aa.aziRagioneSociale as AZI_RAG_SOC_SIGN
		   , ddesc1.dscTesto as AZI_FORMA_GIURIDICA_SIGN

		   , aa.aziIndirizzoLeg as AZI_INDIRIZ_E_CIVICO_SEDE_SIGN
		   , aa.aziLocalitaLeg as AZI_COMUNE_SEDE_SIGN
		   , aa.aziProvinciaLeg as AZI_PROV_SEDE_SIGN
		   , aa.aziStatoLeg as AZI_STATO_SEDE_SIGN
		   , aa.aziCAPLeg as AZI_CAP_SEDE_SIGN

		   , ddm.vatValore_FT as AZI_CF_SIGN
		   , aa.aziPartitaIVA as AZI_PIVA_SIGN

		   ,isnull(pp1.Value,'') as RIC_NOTAIO_SIGN

		   ,	case when isnull(pp2.Value,'') <> '' then dbo.GETDATEDDMMYYYY(pp2.Value)
					 else ''
				end as RIC_DATA_PROCURA_SIGN

		   ,isnull(pp3.Value,'') as RIC_NUM_REP_PROCURA_SIGN
		   ,isnull(pp4.Value,'') as RIC_RACCOLTA_PROCURA_SIGN

		   ,pp.pfuNome as RIC_NOME_COGNOME_FIRMATARIO_SIGN

		 from ctl_doc D with(nolock)
				left join profiliutente P with(nolock) ON d.idpfu = p.idpfu
				left join  aziende A with(nolock) ON p.pfuidazi=a.idazi
				left join  DM_Attributi dm with(nolock) ON dm.lnk = a.idazi and dm.dztNome = 'codicefiscale'

				left join tipidatirange tp1 with(nolock) ON tp1.tdridtid = 131 and tp1.tdrdeleted=0 and tp1.tdrCodice = a.aziIdDscFormaSoc 
				left join descsI desc1 with(nolock) ON desc1.IdDsc =  tp1.tdriddsc 

				left join CTL_DOC_Value f1 with(nolock) ON f1.idheader = d.id and f1.DSE_ID = 'FIRMATARIO' and f1.DZT_Name = 'LocalitaRapLeg'
				left join CTL_DOC_Value f2 with(nolock) ON f2.idheader = d.id and f2.DSE_ID = 'FIRMATARIO' and f2.DZT_Name = 'ProvinciaRapLeg'
				left join CTL_DOC_Value f3 with(nolock) ON f3.idheader = d.id and f3.DSE_ID = 'FIRMATARIO' and f3.DZT_Name = 'StatoRapLeg'
				left join CTL_DOC_Value f4 with(nolock) ON f4.idheader = d.id and f4.DSE_ID = 'FIRMATARIO' and f4.DZT_Name = 'DataRapLeg'

				left join CTL_DOC_Value r1 with(nolock) ON r1.idheader = d.id and r1.DSE_ID = 'FIRMATARIO' and r1.DZT_Name = 'ResidenzaRapLeg'
				left join CTL_DOC_Value r2 with(nolock) ON r2.idheader = d.id and r2.DSE_ID = 'FIRMATARIO' and r2.DZT_Name = 'ProvResidenzaRapLeg'
				left join CTL_DOC_Value r3 with(nolock) ON r3.idheader = d.id and r3.DSE_ID = 'FIRMATARIO' and r3.DZT_Name = 'CapResidenzaRapLeg'
				left join CTL_DOC_Value r4 with(nolock) ON r4.idheader = d.id and r4.DSE_ID = 'FIRMATARIO' and r4.DZT_Name = 'StatoResidenzaRapLeg'
				left join CTL_DOC_Value r5 with(nolock) ON r5.idheader = d.id and r5.DSE_ID = 'FIRMATARIO' and r5.DZT_Name = 'IndResidenzaRapLeg'
				
				left join CTL_DOC_Value p1 with(nolock) ON p1.idheader = d.id and p1.DSE_ID = 'PROCURA' and p1.DZT_Name = 'procura_notario'
				left join CTL_DOC_Value p2 with(nolock) ON p2.idheader = d.id and p2.DSE_ID = 'PROCURA' and p2.DZT_Name = 'procura_del'
				left join CTL_DOC_Value p3 with(nolock) ON p3.idheader = d.id and p3.DSE_ID = 'PROCURA' and p3.DZT_Name = 'procura_numero_repertorio'
				left join CTL_DOC_Value p4 with(nolock) ON p4.idheader = d.id and p4.DSE_ID = 'PROCURA' and p4.DZT_Name = 'procura_raccolta_numero'

				-- INFORMAZIONI DEL PRIMO UTENTE FIRMATARIO ( PER GESTIONE PDF A MODULI PER ASSENZA DI KIT DI FIRMA )
				left join CTL_DOC_VALUE d2 with(nolock) ON d2.IdHeader = d.id and d2.dse_id = 'INFO' and d2.dzt_name = 'idDocUno' and isnull(d2.value,'') <> ''
				left join CTL_DOC_VALUE d22 with(nolock) ON d22.IdHeader = d.id and d22.dse_id = 'INFO' and d22.dzt_name = 'codicefiscale' and isnull(d22.value,'') <> ''
				left join CTL_DOC dUno with(nolock) ON dUno.id = cast(d2.value as int)

				left join profiliutente pp with(nolock) ON dUno.idpfu = pp.idpfu
				left join  aziende aa with(nolock) ON pp.pfuidazi=aa.idazi
				left join  DM_Attributi ddm with(nolock) ON ddm.lnk = aa.idazi and ddm.dztNome = 'codicefiscale'

				left join tipidatirange ttp1 with(nolock) ON ttp1.tdridtid = 131 and ttp1.tdrdeleted=0 and ttp1.tdrCodice = aa.aziIdDscFormaSoc 
				left join descsI ddesc1 with(nolock) ON ddesc1.IdDsc =  ttp1.tdriddsc 

				left join CTL_DOC_Value ff1 with(nolock) ON ff1.idheader = dUno.id and ff1.DSE_ID = 'FIRMATARIO' and ff1.DZT_Name = 'LocalitaRapLeg'
				left join CTL_DOC_Value ff2 with(nolock) ON ff2.idheader = dUno.id and ff2.DSE_ID = 'FIRMATARIO' and ff2.DZT_Name = 'ProvinciaRapLeg'
				left join CTL_DOC_Value ff3 with(nolock) ON ff3.idheader = dUno.id and ff3.DSE_ID = 'FIRMATARIO' and ff3.DZT_Name = 'StatoRapLeg'
				left join CTL_DOC_Value ff4 with(nolock) ON ff4.idheader = dUno.id and ff4.DSE_ID = 'FIRMATARIO' and ff4.DZT_Name = 'DataRapLeg'

				left join CTL_DOC_Value rr1 with(nolock) ON rr1.idheader = dUno.id and rr1.DSE_ID = 'FIRMATARIO' and rr1.DZT_Name = 'ResidenzaRapLeg'
				left join CTL_DOC_Value rr2 with(nolock) ON rr2.idheader = dUno.id and rr2.DSE_ID = 'FIRMATARIO' and rr2.DZT_Name = 'ProvResidenzaRapLeg'
				left join CTL_DOC_Value rr3 with(nolock) ON rr3.idheader = dUno.id and rr3.DSE_ID = 'FIRMATARIO' and rr3.DZT_Name = 'CapResidenzaRapLeg'
				left join CTL_DOC_Value rr4 with(nolock) ON rr4.idheader = dUno.id and rr4.DSE_ID = 'FIRMATARIO' and rr4.DZT_Name = 'StatoResidenzaRapLeg'
				left join CTL_DOC_Value rr5 with(nolock) ON rr5.idheader = dUno.id and rr5.DSE_ID = 'FIRMATARIO' and rr5.DZT_Name = 'IndResidenzaRapLeg'
				
				left join CTL_DOC_Value pp1 with(nolock) ON pp1.idheader = dUno.id and pp1.DSE_ID = 'PROCURA' and pp1.DZT_Name = 'procura_notario'
				left join CTL_DOC_Value pp2 with(nolock) ON pp2.idheader = dUno.id and pp2.DSE_ID = 'PROCURA' and pp2.DZT_Name = 'procura_del'
				left join CTL_DOC_Value pp3 with(nolock) ON pp3.idheader = dUno.id and pp3.DSE_ID = 'PROCURA' and pp3.DZT_Name = 'procura_numero_repertorio'
				left join CTL_DOC_Value pp4 with(nolock) ON pp4.idheader = dUno.id and pp4.DSE_ID = 'PROCURA' and pp4.DZT_Name = 'procura_raccolta_numero'

		where D.tipodoc = 'NOTIER_ISCRIZ'



GO
