USE [AFLink_TND]
GO
/****** Object:  View [dbo].[document_view_datiProtocolloEstesi]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[document_view_datiProtocolloEstesi] as
	select * 
		from ctl_doc doc
				LEFT JOIN Document_dati_protocollo prot ON doc.Id = prot.idHeader

GO
