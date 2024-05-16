USE [AFLink_TND]
GO
/****** Object:  View [dbo].[AZI_UPD_DOCUMENTAZIONE_DETTAGLI_FORN_VIEW]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[AZI_UPD_DOCUMENTAZIONE_DETTAGLI_FORN_VIEW] as 
select   CA.idrow,
		 CA.idHeader, 
		 CA.Descrizione, 
		 CA.Allegato, 
		 CA.Obbligatorio, 
		 CA.AnagDoc, 
		 CA.DataEmissione, 
		 CA.Interno, 
		 CA.Modified, 
		 CA.NotEditable,
		 AD.StatoDocumentazione,
		 AD.idChainDocStory
		 
from CTL_DOC_ALLEGATI CA
     inner join CTL_DOC CD on CA.idheader=CD.id		 
     inner join Aziende_Documentazione AD on CD.Azienda=AD.idazi and CA.AnagDoc=AD.AnagDoc and AD.Deleted=0
GO
