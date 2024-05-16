USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_DASHBOARD_VIEW_RICHIESTA_ATTI_IA]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[OLD2_DASHBOARD_VIEW_RICHIESTA_ATTI_IA] as
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
      , codicefiscale
      , PartitaIva
      , Titolo
      , SedeEdile 
      , IndirizzoEdile 
      , Allegato	  
	  , cv.Value as idpfu
from CTL_DOC
			inner join Document_Richiesta_Atti  on id = idHeader
			---filtro la visibilità solo al RUP del bando per cui è stata fatta la richiesta
			inner join CTL_DOC_Value CV on CV.idHeader=LinkedDoc and DZT_Name='UserRup' and DSE_ID='InfoTec_comune'
			--left join profiliutenteattrib as p on p.dztnome = 'Tipo_Appalto' and attvalue = Tipo_Appalto

WHERE     (StatoDoc <> 'Saved') and tiPodoc = 'RICHIESTA_ATTI_GARA'




GO
