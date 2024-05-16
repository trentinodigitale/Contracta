USE [AFLink_TND]
GO
/****** Object:  View [dbo].[VIEW_TED_DATI_AMMINISTRAZIONE]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VIEW_TED_DATI_AMMINISTRAZIONE] AS
	select a.IdAzi,	--chiave di ingresso
			left(a.aziRagioneSociale,300) as [TED_OFFICIALNAME], 
			d1.vatValore_FT as [TED_NATIONALID],
			left(a.aziIndirizzoLeg,400) as [TED_ADDRESS], 
			left(a.aziLocalitaLeg,100) as [TED_TOWN],
			case when a.aziLocalitaLeg2 <> '' then dbo.GetColumnValue( a.aziLocalitaLeg2,'-', 7) else dbo.GetColumnValue( a.aziLocalitaLeg2,'-', 7) end as TED_NUTS,
			a.aziCAPLeg as TED_POSTAL_CODE,
			upper(left(a.aziPartitaIVA,2)) as TED_COUNTRY,
			'' as TED_CONTACT_POINT, -- rup della gara. viene popolato dal chiamante
			a.aziTelefono1 as TED_PHONE,
			a.aziFAX as TED_FAX,
			a.aziE_Mail as TED_E_MAIL,
			replace( left( a.aziSitoWeb,250), 'http://','https://') as TED_URL_GENERAL,
			left( a.aziSitoWeb,250) as TED_URL_SA,
			'' as TED_URL_BUYER
		from aziende a with(nolock)
				inner join DM_Attributi d1 with(nolock) on d1.lnk = a.IdAzi and d1.idApp = 1 and d1.dztNome = 'codicefiscale'

GO
