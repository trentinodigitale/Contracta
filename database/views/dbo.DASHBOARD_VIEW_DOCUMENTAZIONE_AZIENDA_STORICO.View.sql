USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_DOCUMENTAZIONE_AZIENDA_STORICO]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[DASHBOARD_VIEW_DOCUMENTAZIONE_AZIENDA_STORICO] as

select 
     LinkedDoc as ID,
     idAzi,
     idChainDocStory,
     AnagDoc,
     Descrizione,
     Allegato,
     DataEmissione,
     DataInserimento,
     LinkedDoc,
     TipoDoc,
     StatoDocumentazione,
     deleted,
     DataSollecito,
     Interno,
     TipoDoc as OPEN_DOC_NAME

from Aziende_Documentazione
GO
