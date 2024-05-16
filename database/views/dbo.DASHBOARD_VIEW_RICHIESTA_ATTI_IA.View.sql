USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_RICHIESTA_ATTI_IA]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [dbo].[DASHBOARD_VIEW_RICHIESTA_ATTI_IA] as
	

	-- recupera la visibilità del RUP
	select 

			TipoDoc 
		  , StatoDoc 
		  , StatoDoc  as  StatoRichiestaAtti
		  , Id
		  , DataInvio
		  , DataProtocolloGenerale
		  , Protocollo 
		  , ProtocolloRiferimento
		  , ProtocolloGenerale
		  , Fascicolo
		  , aziRagioneSociale
		  , cast(codicefiscale as varchar(max)) as codicefiscale
		  , cast(PartitaIva as varchar(max)) as PartitaIva
		  , Titolo
		  , cast(SedeEdile as varchar(max)) as SedeEdile
		  , cast(IndirizzoEdile as varchar(max)) as IndirizzoEdile
		  , Allegato	  
		  , cv.Value as idpfu
	from CTL_DOC with(nolock)
				inner join Document_Richiesta_Atti with(nolock) on id = idHeader
				---filtro la visibilità solo al RUP del bando per cui è stata fatta la richiesta
				inner join CTL_DOC_Value CV with(nolock) on CV.idHeader=LinkedDoc and DZT_Name='UserRup' and DSE_ID='InfoTec_comune'
				--left join profiliutenteattrib as p on p.dztnome = 'Tipo_Appalto' and attvalue = Tipo_Appalto

	WHERE     (StatoDoc <> 'Saved') and tiPodoc = 'RICHIESTA_ATTI_GARA'

	UNION 

	-- recupera la visibilità dei riferimenti Bandi / Inviti
	select 

			TipoDoc 
		  , StatoDoc 
		  , StatoDoc  as  StatoRichiestaAtti
		  , Id
		  , DataInvio
		  , DataProtocolloGenerale
		  , Protocollo 
		  , ProtocolloRiferimento
		  , ProtocolloGenerale
		  , Fascicolo
		  , aziRagioneSociale
		  , cast(codicefiscale as varchar(max)) as codicefiscale
		  , cast(PartitaIva as varchar(max)) as PartitaIva
		  , Titolo
		  , cast(SedeEdile as varchar(max)) as SedeEdile
		  , cast(IndirizzoEdile as varchar(max)) as IndirizzoEdile
		  , Allegato	  
		  , R.idpfu
	from CTL_DOC with(nolock)
				inner join Document_Richiesta_Atti with(nolock) on id = idHeader

				---filtro la visibilità ai riferimenti del bando per cui è stata fatta la richiesta
				inner join Document_Bando_Riferimenti R on R.idheader = LinkedDoc  and RuoloRiferimenti = 'Bando'


	WHERE     (StatoDoc <> 'Saved') and tiPodoc = 'RICHIESTA_ATTI_GARA'

	UNION 

	-- la richiesta che hanno il profilo Monitoraggio Accesso Atti
	select 
			RICHIESTA.TipoDoc 
		  , RICHIESTA.StatoDoc 
		  , RICHIESTA.StatoDoc  as  StatoRichiestaAtti
		  , RICHIESTA.Id
		  , RICHIESTA.DataInvio
		  , RICHIESTA.DataProtocolloGenerale
		  , RICHIESTA.Protocollo 
		  , RICHIESTA.ProtocolloRiferimento
		  , RICHIESTA.ProtocolloGenerale
		  , RICHIESTA.Fascicolo
		  , aziRagioneSociale
		  , cast(codicefiscale as varchar(max)) as codicefiscale
		  , cast(PartitaIva as varchar(max)) as PartitaIva
		  , RICHIESTA.Titolo
		  , cast(SedeEdile as varchar(max)) as SedeEdile
		  , cast(IndirizzoEdile as varchar(max)) as IndirizzoEdile
		  , Allegato	  
		  , p5.IdPfu as idpfu
	from CTL_DOC RICHIESTA with(nolock)
			inner join Document_Richiesta_Atti with(nolock)  on id = idHeader
			---filtro per consentire la visualizzazione agli utenti di tutte le richieste di accesso agli atti della stessa P.A del BANDO a cui fa riferimento 
			-- la richiesta che hanno il profilo Monitoraggio Accesso Atti
			inner join ctl_doc BANDO with(nolock) on BANDO.Id=RICHIESTA.LinkedDoc
			inner join ProfiliUtente P with(nolock) on P.pfuIdAzi=BANDO.Azienda and P.pfuDeleted=0
			inner join ProfiliUtenteAttrib p5 with(nolock) on p5.dztNome = 'profilo' and p5.attvalue = 'Monit_Accesso_Atti' and P.IdPfu=p5.IdPfu
	
	WHERE     (RICHIESTA.StatoDoc <> 'Saved') and RICHIESTA.tiPodoc = 'RICHIESTA_ATTI_GARA'


GO
