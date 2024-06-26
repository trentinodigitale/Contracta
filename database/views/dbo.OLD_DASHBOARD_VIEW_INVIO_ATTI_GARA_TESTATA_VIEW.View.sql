USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_DASHBOARD_VIEW_INVIO_ATTI_GARA_TESTATA_VIEW]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [dbo].[OLD_DASHBOARD_VIEW_INVIO_ATTI_GARA_TESTATA_VIEW] as
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
      , codicefiscale
      , PartitaIva
      , Titolo
      , SedeEdile 
      , IndirizzoEdile 
      , Allegato
      , LinkedDoc
	  ,IdPfu

from CTL_DOC with(NOLOCK)

		left outer join  Document_Richiesta_Atti with(NOLOCK) on LinkedDoc = IdHeader 
			

where TipoDoc = 'INVIO_ATTI_GARA'
	and Deleted=0

 --where [StatoDoc]='Evasa'




GO
