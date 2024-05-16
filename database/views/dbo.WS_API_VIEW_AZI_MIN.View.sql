USE [AFLink_TND]
GO
/****** Object:  View [dbo].[WS_API_VIEW_AZI_MIN]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--select * From [WS_API_VIEW_AZI_MIN] where idazienda = 35152033
--select * from WS_API_VIEW_AZI_REFERENTE where idAzi =35152033
CREATE VIEW [dbo].[WS_API_VIEW_AZI_MIN] AS
	SELECT az.IdAzi as idAzienda,
			az.aziRagioneSociale as RagioneSociale,
			cf.vatValore_FT as CodiceFiscale,
			az.aziPartitaIVA as PartitaIVA,
			isnull(az.aziE_Mail,'') as eMail,
			isnull(az.aziTelefono1,'') as Telefono,
			isnull(az.aziStatoLeg,'') as Stato,
			isnull(az.aziProvinciaLeg,'') as Provincia,
			isnull(az.aziLocalitaLeg,'') as Localita,
			isnull(az.aziCAPLeg,'') as CAP,
			isnull(az.aziIndirizzoLeg,'') as Indirizzo,
			isnull(az.aziNumeroCivico,'') as NumeroCivico,
			case when ( az.aziVenditore <> 0 and az.aziacquirente = 0 ) then 'OE' else 'Ente' end as TipoAnagrafica,

			isnull(g1.SiglaAuto,'') as ProvinciaSigla,
			isnull(az.aziFAX ,'') as FAX,
			isnull(dbo.GetPos( az.aziLocalitaLeg2,'-',8),'') as CodiceIstatLocalita,

			isnull( case when ( az.aziVenditore <> 0 and az.aziacquirente = 0 ) then t1.ValIn else t2.ValIn end, '') as IdCategoria,
			isnull( case when ( az.aziVenditore <> 0 and az.aziacquirente = 0 ) then t1Desc.dscTesto else ammD.DMV_DescML end,'') as DescCategoria

		FROM aziende az with(nolock)
				LEFT JOIN dm_attributi cf with(nolock) on cf.lnk = az.idazi and cf.dztNome = 'CodiceFiscale' and cf.idApp = 1
				LEFT JOIN GEO_ISTAT_elenco_comuni_italiani g1 with(nolock) on g1.CodiceIstatDelComune_formato_alfanumerico = dbo.GetPos( az.aziLocalitaLeg2,'-',8)

				LEFT JOIN CTL_Transcodifica T1 with(nolock) ON t1.sistema = 'soresa' and t1.dztNome = 'aziIdDscFormaSoc' and t1.ValOut = az.aziIdDscFormaSoc

				LEFT JOIN tipidatirange td with(Nolock) on td.tdridtid = 131 and td.tdrCodice = az.aziIdDscFormaSoc
				LEFT JOIN descsi t1Desc with(nolock) on t1Desc.iddsc = td.tdriddsc 

				LEFT JOIN dm_attributi amm with(nolock) on amm.lnk = az.idazi and amm.dztNome = 'TIPO_AMM_ER' and amm.idApp = 1
				LEFT JOIN LIB_DomainValues ammD with(nolock) on ammD.DMV_DM_ID = 'TIPO_AMM_ER' and ammD.DMV_Cod = amm.vatValore_FT
				LEFT JOIN CTL_Transcodifica T2 with(nolock) ON t2.sistema = 'soresa' and t2.dztNome = 'TIPO_AMM_ER' and t2.ValOut = amm.vatValore_FT

--		where az.aziDeleted = 0 and az.aziiddscformasoc <> 845326 -- escludiamo le RTI e le cessate

GO
