USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_Documentazione]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[DASHBOARD_VIEW_Documentazione] as

		select Id, Owner, Name, DataCreazione, Protocollo, StatoDoc, DataScadenza, Nome, Note, 
					TipoDocumentazione, VisibilitaDoc, Deleted,	'Documentazione' as open_doc_name

			from [dbo].[Document_Documentazione]

		where deleted=0


GO
