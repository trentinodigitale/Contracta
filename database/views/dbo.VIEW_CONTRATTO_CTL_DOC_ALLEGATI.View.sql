USE [AFLink_TND]
GO
/****** Object:  View [dbo].[VIEW_CONTRATTO_CTL_DOC_ALLEGATI]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VIEW_CONTRATTO_CTL_DOC_ALLEGATI] AS

	select idrow, idHeader, Descrizione, Allegato, 
			Obbligatorio, AnagDoc, DataEmissione, Interno, 
			Modified, TipoFile, 
			DataScadenza, DSE_ID, EvidenzaPubblica, RichiediFirma, FirmeRichieste, AllegatoRisposta,

			CASE WHEN FirmeRichieste = 'ente_oe' THEN '' ELSE ' AllegatoRisposta ' END AS NotEditable

		FROM CTL_DOC_ALLEGATI WITH(NOLOCK)
	

 --' CodiceIPA , firmatario , CF_FORNITORE ' as NotEditable
GO
