USE [AFLink_TND]
GO
/****** Object:  View [dbo].[VIEW_VISIBILITA_FASCICOLO_GARA]    Script Date: 5/16/2024 2:45:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[VIEW_VISIBILITA_FASCICOLO_GARA] as 

	-- ENTRANDO PER IDPFU DELL'UTENTE COLLEGATO, RITORNO L'ELENCO DEGLI ENTI CHE HANNO IL CODICEFISCALE UGUALE A QUELLO
	-- DELL'ENTE DELL'UTENTE COLLEGATO. OPPURE RITORNO TUTTI GLI ENTI SE L'UTENTE COLLEGATO HA IL PROFILO AVCPADMIN

	select 

		idpfu , id 
			from 
				ctl_doc with (nolock)
			where tipodoc='FASCICOLO_GARA'
	union 
		
		select 

		D.idpfu , id 
			from ctl_doc C with (nolock)
				inner join ctl_doc_destinatari D with (nolock) on D.idheader = C.id 
			where C.tipodoc='FASCICOLO_GARA'



GO
