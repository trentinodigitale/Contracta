USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DOCUMENT_VIEW_VARIAZIONE_ANAGRAFICA]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[DOCUMENT_VIEW_VARIAZIONE_ANAGRAFICA] as
	select 
		c.* 
		, case statofunzionale 
			when 'InLavorazione' then ''
			else ' Titolo  Body  Allegato  '
		 end as Not_Editable
		, ca.Allegato
		, ca.IdHeader
		, ca.idrow
		,case when left(aziPartitaIVA,2) <> 'IT' then 1 else 0 end as Estero
		, prot.protocolloGeneraleSecondario 
		, prot.dataProtocolloGeneraleSecondario 
		, case when a.aziPartitaIVA <> '' and left(aziPartitaIVA,2) <> 'IT' then right(d1.vatValore_FT, len(d1.vatValore_FT)-4)  else NULL end as ID_FISCALE_ESTERO --la cella si popola se l'azienda è estera e prendiamo il CF dell'azi  da cui togliamo il prefisso 
		, p.Valore as attivaPdfModuloVarAnag
		, d1.vatValore_ft as codicefiscale
		, par.Valore as filtroAttivo
	from ctl_doc c 
			left join ctl_doc_allegati ca with(nolock) on id=idheader
			inner join aziende a with(nolock) on Azienda=idazi 
			inner join DM_Attributi d1 with(nolock) on d1.lnk = a.IdAzi and d1.dztNome = 'codicefiscale'
			left join Document_dati_protocollo prot with(nolock) ON prot.idheader = c.id 
			left join CTL_Parametri p with(nolock) on p.Contesto = 'VARIAZIONE_ANAGRAFICA' and p.Oggetto = 'PDF' and p.Proprieta = 'DefaultValue'
			left join CTL_Parametri par with(nolock) on par.Contesto = 'REGISTRAZIONE_OE' and par.Oggetto = 'aziIdDscFormaSoc' and par.Proprieta = 'AttivaFiltro'
	where tipodoc='VARIAZIONE_ANAGRAFICA'

GO
