USE [AFLink_TND]
GO
/****** Object:  View [dbo].[WS_API_VIEW_AZIENDA]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[WS_API_VIEW_AZIENDA] AS
	-- LA VISTA E' UTILIZZATA ESCLUSIVAMENTE DAI WEB SERVICES REST 
	-- ED E' OTTIMIZZATA PER L'INGRESSO CON IDAZI
	SELECT  az.IdAzi as idAzienda,
			az.aziLog as Codice,
			az.aziRagioneSociale as RagioneSociale,
			cf.vatValore_FT as CodiceFiscale,
			az.aziPartitaIVA as PartitaIVA,
			isnull(fg.dscTesto,'') as FormaGiuridica,
			az.aziE_Mail as eMail,
			isnull(az.aziTelefono1,'') as Telefono,

			isnull(az.aziStatoLeg,'') as Stato,
			isnull(az.aziStatoLeg2,'') as CodiceStato,
			isnull(az.aziProvinciaLeg,'') as Provincia,
			isnull(az.aziProvinciaLeg2,'') as CodiceProvincia,
			isnull(az.aziLocalitaLeg,'') as Localita,
			isnull(az.aziLocalitaLeg2,'') as CodiceLocalita,

			isnull(az.aziCAPLeg,'') as CAP,
			isnull(az.aziIndirizzoLeg,'') as Indirizzo,
			
			case when ( az.aziVenditore <> 0 and az.aziacquirente = 0 ) then 'OE' else 'Ente' end as TipoAnagrafica,

			isnull( IscrittoAlME , 'N' ) as IscrittoAlMercatoElettronico,

			isnull(strut2.DMV_Cod,'')  as CodicePrimoLivello,
			isnull(strut2.DMV_DescML,'') as DescrizionePrimoLivello,

			isnull(strut1.DMV_Cod,'')  as CodiceSecondoLivello,
			isnull(strut1.DMV_DescML,'') as DescrizioneSecondoLivello

		FROM aziende az with(nolock, index(IX_Aziende_IdAzi))
				INNER JOIN dm_attributi cf with(nolock, index(IX_DM_ATTRIBUTI_lnk_dztNome_vatValore_FV_vatIDzt)) on cf.lnk = az.idazi and cf.dztNome = 'CodiceFiscale'
				LEFT JOIN tipidatirange td with(Nolock) on td.tdridtid = 131 and td.tdrdeleted=0 and td.tdrCodice = az.aziIdDscFormaSoc
				LEFT JOIN descsi fg with(nolock) on fg.iddsc = td.tdriddsc 

				LEFT JOIN ( select distinct  top  1000000 D.idAzi as idIscritto , 'S' as IscrittoAlME
								from ctl_doc B with(nolock)
										inner join CTL_DOC_Destinatari D with(nolock) on D.idheader = B.id and D.StatoIscrizione = 'Iscritto'
								where B.TipoDoc = 'BANDO' and isnull( B.Jumpcheck , '' )= '' and B.Deleted = 0 
					) as I on idAzi = idIscritto

				LEFT JOIN dbo.DM_Attributi d1 with(nolock, index(IX_DM_ATTRIBUTI_lnk_dztNome_vatValore_FV_vatIDzt)) on d1.dztNome = 'TIPO_AMM_ER' and d1.lnk = az.idazi

				LEFT JOIN LIB_DomainValues strut1 with(nolock, index(IX_LIB_DomainValues_DMV_DM_ID_DMV_COD_DMV_DescML)) on strut1.dmv_dm_id='TIPO_AMM_ER' and strut1.dmv_cod=d1.vatValore_FT
				LEFT JOIN LIB_DomainValues strut2 with(nolock, index(IX_LIB_DomainValues_DMV_DM_ID_DMV_COD_DMV_DescML)) on strut2.dmv_dm_id='TIPO_AMM_ER' and strut2.dmv_cod = SUBSTRING ( strut1.dmv_father ,1 , charindex('-',strut1.dmv_father)-1 )

		where aziDeleted = 0 and az.aziiddscformasoc <> 845326 -- escludiamo le RTI e le cessate
GO
