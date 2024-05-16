USE [AFLink_TND]
GO
/****** Object:  View [dbo].[TS_AEC_CPM_NOMINATIVE]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[TS_AEC_CPM_NOMINATIVE] AS

	select  a.idazi,	--chiave di ingresso
			isnull(azilog,'') as azilog, 
			isnull(aziragionesociale,'') as DescriptionNominative, 
			isnull(aziIndirizzoLeg,'') as [Address], 
			isnull(aziCapLeg,'') as aziCapLeg,
			isnull(aziLocalitaLeg,'') as [Location],
			isnull(aziLocalitaLeg,'') as DescriptionTown,
			isnull(aziPartitaIVA,'') as VatNumber,
			isnull(aziTelefono1,'') as PhoneNumber1,
			isnull(aziTelefono2,'') as PhoneNumber2,
			isnull(aziFax,'') as [FaxNumber],
			isnull(azie_mail,'') as EMail,
			isnull(aziSitoWeb,'') as WebSite,
			isnull(b.vatValore_FT,'') as FiscalCode,
			a.idazi as MnemonicIdNominative,
			dbo.GetPos( azistatoLeg2,'-',4) + '-' + a.aziCAPLeg as MnemonicIdTown, -- CODICE STATO A 3 CARATTERI + "-" + CAP
			'it-IT' as LanguageId,
			'10' as NominativeTypeId, -- 10 – Impresa privata; 20 – Ente pubblico; 30 – Personale interno;40 – Personale esterno; 50 - Studio professionale;60 – Libero professionista;70 – Soggetto privato
			'10' as SenderTypeId, --10 – Mobile; 20 – Subappalto; 30 – CAD; 40 - XCA

			isnull(c.CodiceCatastale,'') as LandRegisterCode,
			isnull(a.aziCAPLeg,'') as PostalCode,
			isnull(c.SiglaAuto,'') as ProvinceCode,
			aziDataCreazione ,
			dbo.GetPos( aziLocalitaLeg2,'-',8) as codComune,	
			dbo.GetPos( azistatoLeg2,'-',4) as codStato
		from aziende a with (nolock) 
				inner join DM_Attributi b with(nolock) on b.lnk = a.idazi and b.dztNome = 'codicefiscale'
				left join TS_AEC_GEO_COMUNE c on c.codIstatAlfa = dbo.GetPos( a.aziLocalitaLeg2,'-',8)

GO
