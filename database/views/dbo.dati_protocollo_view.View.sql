USE [AFLink_TND]
GO
/****** Object:  View [dbo].[dati_protocollo_view]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [dbo].[dati_protocollo_view] as
	SELECT isnull(prot.idrow,0) as idRow,
		   doc.id as idHeader,
		   doc.fascicolo,
		   prot.aoo,
		   prot.denomAOO,
		   prot.repertorio,
		   prot.uo,
		   prot.denomUO,
		   prot.titolarioPrimario,
		   prot.titolarioSecondario,
		   prot.fascicoloSecondario,
		   doc.ProtocolloGenerale,
		   doc.DataProtocolloGenerale,
		   doc.FascicoloGenerale ,
		   ISNULL(CONV.NotEditable,'') + ' ' + ISNULL(prot.NotEditable,'')  as NotEditable
		FROM ctl_doc doc with (nolock) 
				LEFT JOIN Document_dati_protocollo prot with (nolock)  ON doc.id = prot.idHeader 
				LEFT JOIN Document_Convenzione CONV  with (nolock) ON CONV.id=DOC.Id



GO
