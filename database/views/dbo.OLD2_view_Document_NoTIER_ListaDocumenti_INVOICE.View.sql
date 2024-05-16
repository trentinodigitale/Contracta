USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_view_Document_NoTIER_ListaDocumenti_INVOICE]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[OLD2_view_Document_NoTIER_ListaDocumenti_INVOICE] AS
	select  a.Id,
			a.DataInvio,
			'FATTURA' as CHIAVE_TIPODOCUMENTO,
			a1.Value as CHIAVE_NUMERO,
			c.idpfu as idOwner, 
			a3.value as aziRagioneSociale,
			a4.value as CHIAVE_CODICEFISCALEMITTENTE
		from CTL_DOC a with(nolock)
				INNER JOIN aziende b with(nolock) ON a.Azienda = b.idazi 
				INNER JOIN profiliutente c with(nolock) ON c.pfuidazi = b.idazi

				inner join ctl_doc_value a1 with(nolock) on a1.idheader = a.id and a1.DSE_ID = 'INVOICE' and a1.DZT_Name = 'Order_ID' --numero fattura
				inner join ctl_doc_value a2 with(nolock) on a2.idheader = a.id and a2.DSE_ID = 'ACCOUNTINGCUSTOMERPARTY' and a2.DZT_Name = 'AccountingCustomerParty_EndpointID'
				inner join ctl_doc_value a3 with(nolock) on a3.idheader = a.id and a3.DSE_ID = 'ACCOUNTINGCUSTOMERPARTY' and a3.DZT_Name = 'PartyName'
				inner join ctl_doc_value a4 with(nolock) on a4.idheader = a.id and a4.DSE_ID = 'ACCOUNTINGCUSTOMERPARTY' and a4.DZT_Name = 'PartyIdentification_ID'

		where a.tipodoc = 'NOTIER_INVOICE' and StatoFunzionale in ( 'Inviato', 'Consegnato' ) and a.deleted = 0

GO
