USE [AFLink_TND]
GO
/****** Object:  View [dbo].[VIEW_CTL_DOC_Destinatari_RFQ]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[VIEW_CTL_DOC_Destinatari_RFQ]
as

select 
	--[idrow], 
	[idHeader], dest.[IdPfu], 
	dest.[IdAzi], 
	
	case  StatoFunzionale 
		when 'InLavorazione' then azi.[aziRagioneSociale]
		else dest.[aziRagioneSociale] end as [aziRagioneSociale],
	
	case  StatoFunzionale 
		when 'InLavorazione' then azi.[aziPartitaIVA]
		else dest.[aziPartitaIVA] end as [aziPartitaIVA],
	case  StatoFunzionale 
		when 'InLavorazione' then azi.[aziTelefono1]
		else dest.[aziTelefono1] end as [aziTelefono1],
	case  StatoFunzionale 
		when 'InLavorazione' then azi.[aziCAPLeg]
		else dest.[aziCAPLeg] end as [aziCAPLeg],
	case  StatoFunzionale 
		when 'InLavorazione' then azi.[aziStatoLeg]
		else dest.[aziStatoLeg] end as [aziStatoLeg],
	case  StatoFunzionale 
		when 'InLavorazione' then azi.[aziProvinciaLeg]
		else dest.[aziProvinciaLeg] end as [aziProvinciaLeg],
	case  StatoFunzionale 
		when 'InLavorazione' then azi.[aziLocalitaLeg]
		else dest.[aziLocalitaLeg] end as [aziLocalitaLeg],
	case  StatoFunzionale 
		when 'InLavorazione' then azi.[aziIndirizzoLeg]
		else dest.[aziIndirizzoLeg] end as [aziIndirizzoLeg],
	case  StatoFunzionale 
		when 'InLavorazione' then azi.[aziE_Mail]
		else dest.[aziE_Mail] end as [aziE_Mail],

	case  StatoFunzionale 
		when 'InLavorazione' then azi.[aziDBNumber]
		else dest.[aziDBNumber] end as [aziDBNumber],
	case  StatoFunzionale 
		when 'InLavorazione' then azi.[aziSitoWeb]
		else dest.[aziSitoWeb] end as [aziSitoWeb],
	
	[CDDStato], 
	[Seleziona], 
	[NumRiga], [CodiceFiscale], 
	[StatoIscrizione], [DataIscrizione], [DataScadenzaIscrizione], [DataSollecito], [Id_Doc], [DataConferma], 
	[NumeroInviti], [ordinamento], [Is_Group],
	'SCHEDA_ANAGRAFICA' as OPEN_DOC_NAME,
	dest.idazi as idrow
	
	from CTL_DOC_Destinatari dest with (nolock)
		inner join ctl_doc doc with (nolock) on doc.id=dest.idHeader 
		inner join aziende azi with (nolock) on azi.IdAzi = dest.IdAzi 
GO
