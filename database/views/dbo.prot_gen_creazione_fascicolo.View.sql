USE [AFLink_TND]
GO
/****** Object:  View [dbo].[prot_gen_creazione_fascicolo]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[prot_gen_creazione_fascicolo] as 
	select	  id
			 , Azienda as ID_AZI_ENTE
			 , 'Procedura "' + doc.Titolo + '"'  as OGGETTO_FASCICOLO
			 , 'Procedura "' + doc.Titolo + '"'  as NOTE_FASCICOLO
		from ctl_doc doc with(nolock)
				inner join Document_dati_protocollo prot with(nolock) ON doc.id = prot.idheader 


GO
