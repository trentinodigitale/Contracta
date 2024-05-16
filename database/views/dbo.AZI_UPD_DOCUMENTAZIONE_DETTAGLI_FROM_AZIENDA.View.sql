USE [AFLink_TND]
GO
/****** Object:  View [dbo].[AZI_UPD_DOCUMENTAZIONE_DETTAGLI_FROM_AZIENDA]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[AZI_UPD_DOCUMENTAZIONE_DETTAGLI_FROM_AZIENDA]
AS
SELECT  AZ.IdAzi AS ID_FROM
     ,  AZ.IdAzi
     ,  AZ.IdAzi as Azienda
     ,  idRow
     , idChainDocStory
     , AnagDoc
     , Descrizione
     , Allegato
     , DataEmissione
     , DataInserimento
     , A.LinkedDoc
     , A.TipoDoc
     , StatoDocumentazione     
     , DataSollecito
     , Interno
     , CASE   WHEN   AnagDoc <> '' THEN ' Descrizione ' END as NotEditable
	 , NULLIF ( a.DataScadenza  , '1900-01-01 00:00:00.000' ) as DataScadenza
      
     
 FROM Aziende AZ

inner join dbo.Aziende_Documentazione A on A.idazi= AZ.IdAzi and A.deleted=0




GO
