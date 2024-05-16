USE [AFLink_TND]
GO
/****** Object:  View [dbo].[MAIL_DOCUMENT_IN_SCADENZA]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[MAIL_DOCUMENT_IN_SCADENZA]
  as
  Select
   IdRow as IDDOC,
   IdRow as ID,
   'I' as LNG,
   Aziende_Documentazione.AnagDoc as Titolo,
   convert(varchar,DateADD(month,NumMesiVal,DataEmissione),103) as DataScadenza
   from Aziende_Documentazione
   inner join CTL_DOC on Aziende_Documentazione.AnagDoc=Titolo
   inner join Document_Anag_documentazione on CTL_DOC.ID=IdHeader
   where Aziende_Documentazione.deleted=0 and Aziende_Documentazione.AnagDoc<>''

GO
