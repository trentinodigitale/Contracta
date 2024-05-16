USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DOCUMENT_DOCUMENTAZIONE_VIEW]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[DOCUMENT_DOCUMENTAZIONE_VIEW]
AS
SELECT     ctl_doc.*, Protocollo AS Protocol,Data as aziDataCreazione,aziRagioneSociale,aziPArtitaIva,Descrizione,Allegato
FROM         ctl_doc 
inner join Aziende on Azienda=IdAzi
left join CTL_DOC_ALLEGATI on idHeader=id
GO
