USE [AFLink_TND]
GO
/****** Object:  View [dbo].[BANDO_GARA_PORTALE_DOCUMENTAZIONE_VIEW]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[BANDO_GARA_PORTALE_DOCUMENTAZIONE_VIEW] as
	select 
		C.[idrow], 
		C.[idHeader], 
		[Descrizione],
		[Allegato], 
		[Obbligatorio], 
		[AnagDoc], 
		[DataEmissione], 
		[Interno], 
		[Modified], 
		[NotEditable], 
		[TipoFile], 
		[DataScadenza], 
		[DSE_ID], 
		--SE NON SONO INVITI RITORNA SEMPRE "SI" COME EVIDENZA PUBBLICA ALTRIMENTI 
		case when DB.TIPOBANDOGARA <> '3' then 1 else C.[EvidenzaPubblica] end as [EvidenzaPubblica], 
		[RichiediFirma], 
		[FirmeRichieste], 
		[AllegatoRisposta], 
		[EsitoRiga]
	from CTL_DOC_ALLEGATI C with(nolock)
		left join Document_Bando DB with(nolock) on DB.idheader=C.idheader
GO
