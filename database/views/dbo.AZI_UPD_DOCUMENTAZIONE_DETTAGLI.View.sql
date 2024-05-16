USE [AFLink_TND]
GO
/****** Object:  View [dbo].[AZI_UPD_DOCUMENTAZIONE_DETTAGLI]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[AZI_UPD_DOCUMENTAZIONE_DETTAGLI]
AS
 SELECT distinct
 CA.IdHeader,
 CA.IdRow,
 A.idAzi,
 A.idChainDocStory,
 A.AnagDoc,
 A.Descrizione,
 A.Allegato,
 A.DataEmissione,
 A.DataInserimento,
 A.LinkedDoc,
 A.TipoDoc,
 A.StatoDocumentazione,
 A.DataSollecito,
 A.Interno
 
 FROM CTL_DOC
 inner join Aziende AZ on Azienda=AZ.IdAzi
 inner join CTL_DOC_ALLEGATI CA on CTL_DOC.ID=CA.IdHeader
 left join dbo.Aziende_Documentazione A on A.idazi= AZ.IdAzi and A.AnagDoc=CA.AnagDoc and A.deleted=0
GO
