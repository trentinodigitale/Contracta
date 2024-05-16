USE [AFLink_TND]
GO
/****** Object:  View [dbo].[TEMPLATE_TipologiaAtti]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[TEMPLATE_TipologiaAtti]
AS

  SELECT C.ID
         , C.id AS indrow
         , C.Titolo AS Descrizione
         , C.Titolo AS DescrAttach
         , cast(C.Body AS NVARCHAR(4000)) AS DescrizioneRichiesta
         , ' DescrizioneRichiesta , Descrizione ' AS NotEditable
         , C.Titolo AS AnagDoc
         , 1 AS Interno
         , Allegato AS TemplateAllegato
         , Allegato AS AllegatoRichiesto
         , ContestoUsoDoc
  FROM CTL_DOC C
       LEFT JOIN [Document_Anag_documentazione] ON C.ID = IDHEader
  WHERE C.TipoDoc = 'ANAG_DOCUMENTAZIONE'
        AND C.Deleted = 0
        AND c.statofunzionale = 'Pubblicato'

GO
