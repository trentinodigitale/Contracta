USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_INVIO_ATTI_GARA_TESTATA_VIEW]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE view [dbo].[DASHBOARD_VIEW_INVIO_ATTI_GARA_TESTATA_VIEW] as

	select 

			TipoDoc 
		  , StatoDoc 
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
		  , cast(IndirizzoEdile  as varchar(max)) as IndirizzoEdile
		  , Allegato
		  , LinkedDoc
		  , IdPfu

	from CTL_DOC with(NOLOCK)

			left outer join  Document_Richiesta_Atti with(NOLOCK) on LinkedDoc = IdHeader 
			

	where TipoDoc = 'INVIO_ATTI_GARA'
				and Deleted=0

union

	select 

			a.TipoDoc 
		  , a.StatoDoc 
		  , a.Id
		  , a.DataInvio
		  , a.DataProtocolloGenerale
		  , a.Protocollo 
		  , a.ProtocolloRiferimento
		  , a.ProtocolloGenerale
		  , a.Fascicolo
		  , aziRagioneSociale
		  , cast(codicefiscale as varchar(max)) as codicefiscale
		  , cast(PartitaIva as varchar(max)) as PartitaIva
		  , a.Titolo
		  , cast(SedeEdile as varchar(max)) as SedeEdile
		  , cast(IndirizzoEdile  as varchar(max)) as IndirizzoEdile
		  , Allegato
		  , a.LinkedDoc
		  ,cv.IdPfu
		  

	from CTL_DOC a with(NOLOCK)

			
			left outer join ctl_doc b with(NOLOCK) on b.Id=a.LinkedDoc  and b.TipoDoc = 'RICHIESTA_ATTI_GARA' 
																and b.Deleted = 0

			left outer join  Document_Richiesta_Atti with(NOLOCK) on b.id = IdHeader 

			left outer join ctl_doc c with(NOLOCK) on c.Id=b.LinkedDoc 
																and c.TipoDoc in ( 'BANDO_GARA' , 'BANDO_SEMPLIFICATO' ) 
																and c.Deleted = 0

			-- PRENDO SOLO QUEI BANDI CHE HANNO NELLA SEZIONE DEI RIFERIMENTI L'UTENTE COLLEGATO SETTATO COME RUOLO 'Bando'
			inner join Document_Bando_Riferimenti CV with(nolock) on CV.idheader=c.id 
																and RuoloRiferimenti = 'Bando'

	where a.TipoDoc = 'INVIO_ATTI_GARA'
				and a.Deleted=0
 


GO
