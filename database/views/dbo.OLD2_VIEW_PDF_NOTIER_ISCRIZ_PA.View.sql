USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_VIEW_PDF_NOTIER_ISCRIZ_PA]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--select * from VIEW_PDF_NOTIER_ISCRIZ_PA where id = 414083
CREATE VIEW [dbo].[OLD2_VIEW_PDF_NOTIER_ISCRIZ_PA] as

	select D.id as id -- la colonna ID non deve essere tolta
		   , a.aziRagioneSociale as RAGIONE_SOCIALE
		   , a.aziLocalitaLeg as SEDE_LEGALE
		   , a.aziPartitaIVA as CODFIS_PIVA
		   , a.aziPartitaIVA as PIVA
		   , dm.vatValore_FT as CODICE_FISCALE
		   , a.aziE_Mail as EMAIL
		   , a.aziTelefono1 as TELEFONO1
		   , a.aziTelefono2 as TELEFONO2

		   , p.pfuNome as RIC_NOME_COGNOME 

		   , p.pfuCodiceFiscale as RIC_CF  

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


		   ,p.pfuNome as RIC_NOME_COGNOME_FIRMATARIO

		   --- campi per la gestione della mancanza del kit di firma
		   , aa.aziRagioneSociale as RAGIONE_SOCIALE_SIGN
		   , aa.aziLocalitaLeg as SEDE_LEGALE_SIGN
		   , aa.aziPartitaIVA as CODFIS_PIVA_SIGN
		   , aa.aziPartitaIVA as PIVA_SIGN
		   , d22.value as CODICE_FISCALE_SIGN
		   , aa.aziE_Mail as EMAIL_SIGN
		   , aa.aziTelefono1 as TELEFONO1_SIGN
		   , aa.aziTelefono2 as TELEFONO2_SIGN
		   
		   , pP.pfuNome as RIC_NOME_COGNOME_SIGN 
		   
		   , pp.pfuCodiceFiscale as RIC_CF_SIGN

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

		   , isnull(pp.pfuNome,'') as RIC_NOME_COGNOME_FIRMATARIO_SIGN

		   , case when pat.IdUsAttr is null then 0 else 1 end as ResponsabilePeppol

		 from ctl_doc D with(nolock)
				inner join profiliutente P with(nolock) ON d.idpfu = p.idpfu
				left join ProfiliUtenteAttrib pat with(nolock) on pat.idpfu = p.IdPfu and pat.dztNome = 'UserRole' and pat.attValue = 'RESPONSABILE_PEPPOL'
				inner join  aziende A with(nolock) ON p.pfuidazi=a.idazi
				inner join  DM_Attributi dm with(nolock) ON dm.lnk = a.idazi and dm.dztNome = 'codicefiscale' and dm.idApp = 1

				left join tipidatirange tp1 with(nolock) ON tp1.tdridtid = 131 and tp1.tdrdeleted=0 and tp1.tdrCodice = a.aziIdDscFormaSoc 
				left join descsI desc1 with(nolock) ON desc1.IdDsc =  tp1.tdriddsc 

				-- INFORMAZIONI DEL PRIMO UTENTE FIRMATARIO ( PER GESTIONE PDF A MODULI PER ASSENZA DI KIT DI FIRMA )
				left join CTL_DOC_VALUE d2 with(nolock) ON d2.IdHeader = d.id and d2.dse_id = 'INFO' and d2.dzt_name = 'idDocUno' and isnull(d2.value,'') <> ''
				left join CTL_DOC_VALUE d22 with(nolock) ON d22.IdHeader = d.id and d22.dse_id = 'INFO' and d22.dzt_name = 'codicefiscale' and isnull(d22.value,'') <> ''
				left join CTL_DOC dUno with(nolock) ON dUno.id = cast(d2.value as int)

				left join profiliutente pp with(nolock) ON dUno.idpfu = pp.idpfu
				left join  aziende aa with(nolock) ON pp.pfuidazi=aa.idazi
				left join  DM_Attributi ddm with(nolock) ON ddm.lnk = aa.idazi and ddm.dztNome = 'codicefiscale' and ddm.idapp = 1

				left join tipidatirange ttp1 with(nolock) ON ttp1.tdridtid = 131 and ttp1.tdrdeleted=0 and ttp1.tdrCodice = aa.aziIdDscFormaSoc 
				left join descsI ddesc1 with(nolock) ON ddesc1.IdDsc =  ttp1.tdriddsc 

		where D.tipodoc = 'NOTIER_ISCRIZ_PA'



GO
