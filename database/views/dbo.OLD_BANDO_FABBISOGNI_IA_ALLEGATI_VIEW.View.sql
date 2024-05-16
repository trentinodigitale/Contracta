USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_BANDO_FABBISOGNI_IA_ALLEGATI_VIEW]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[OLD_BANDO_FABBISOGNI_IA_ALLEGATI_VIEW] as
SELECT
	CD.idrow as Idheader,ISNULL(CA.idrow,0) as idrow, Descrizione, Allegato, Obbligatorio, AnagDoc, DataEmissione, Interno, Modified, NotEditable, TipoFile, DataScadenza, DSE_ID, EvidenzaPubblica, RichiediFirma
from CTL_DOC_Destinatari CD 
	inner join CTL_DOC_ALLEGATI CA on CD.idHeader=CA.idHeader

GO
