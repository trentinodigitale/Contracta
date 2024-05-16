USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_view_Document_NoTIER_ListaDocumenti_DDT]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[OLD2_view_Document_NoTIER_ListaDocumenti_DDT] AS
	select  a.Id,
			a.DataInvio,
			'DDT' as CHIAVE_TIPODOCUMENTO,
			a1.Value as CHIAVE_NUMERO,
			c.idpfu as idOwner, 
			a3.denominazione as aziRagioneSociale,
			a3.piva_cf as CHIAVE_CODICEFISCALEMITTENTE
		from CTL_DOC a with(nolock)
				INNER JOIN aziende b with(nolock) ON a.Azienda = b.idazi 
				INNER JOIN profiliutente c with(nolock) ON c.pfuidazi = b.idazi

				inner join ctl_doc_value a1 with(nolock) on a1.idheader = a.id and a1.DSE_ID = 'DESPATCHADVICE' and a1.DZT_Name = 'DespatchAdvice_ID'
				inner join ctl_doc_value a2 with(nolock) on a2.idheader = a.id and a2.DSE_ID = 'DELIVERYCUSTOMERPARTY' and a2.DZT_Name = 'EndpointID_Destinatario'

				left join Document_NoTIER_Destinatari a3 with(nolock) on ID_PEPPOL = a2.Value

		where a.tipodoc = 'NOTIER_DDT' and StatoFunzionale in ( 'Inviato', 'Consegnato' ) and a.deleted = 0

GO
