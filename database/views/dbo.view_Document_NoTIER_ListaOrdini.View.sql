USE [AFLink_TND]
GO
/****** Object:  View [dbo].[view_Document_NoTIER_ListaOrdini]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[view_Document_NoTIER_ListaOrdini] as
	select ordine.*,
			c.idpfu as [owner],
			v.value as URN,

			CASE 
				when ordine.TipoDoc = 'NOTIER_INVOICE' or ordine.TipoDoc = 'NOTIER_CREDIT_NOTE' then ISNULL(v10.value, '')
				when ordine.TipoDoc = 'NOTIER_DDT' then ISNULL(dest.denominazione,'')
				else v2.value
			END as PartyName,

			CASE 
				when ordine.TipoDoc = 'NOTIER_INVOICE' or ordine.TipoDoc = 'NOTIER_CREDIT_NOTE' then ISNULL(v11.value, '')
				when ordine.TipoDoc = 'NOTIER_DDT' then ISNULL(dest.piva_cf,'')
				else v3.value
			END as PartyIdentification_ID,
	
			CASE 
				when ordine.TipoDoc = 'NOTIER_INVOICE' or ordine.TipoDoc = 'NOTIER_CREDIT_NOTE' then ISNULL(v8.value, '')
				else isnull(v4.value, v6.value)
			END as Order_ID,

			CASE 
				when ordine.TipoDoc = 'NOTIER_INVOICE' or ordine.TipoDoc = 'NOTIER_CREDIT_NOTE' then ISNULL(v9.value, '')
				else 
					case 
						when isnull( isnull(v5.value, v7.value) ,'') = '' then '' 
						else isnull(v5.value, v7.value) + ' 00:00:00' 
					end
			END as Order_IssueDate,
			
			ordine.TipoDoc as TIPO_DOC_AF_PEPPOL,
			ordine.TipoDoc as OPEN_DOC_NAME

		from CTL_DOC ordine with(nolock)

				INNER JOIN aziende b  with(nolock) ON ordine.azienda = b.idazi
				INNER JOIN profiliutente c  with(nolock) ON c.pfuidazi = b.idazi

				LEFT JOIN ctl_doc_value v with(nolock) ON v.IdHeader = ordine.id and v.dse_id = 'NOTIER' and v.DZT_Name = 'URN'
				LEFT JOIN ctl_doc_value v2 with(nolock) ON v2.IdHeader = ordine.id and v2.dse_id = 'SELLERSUPPLIERPARTY' and v2.DZT_Name = 'PartyName'
				LEFT JOIN ctl_doc_value v3 with(nolock) ON v3.IdHeader = ordine.id and v3.dse_id = 'SELLERSUPPLIERPARTY' and v3.DZT_Name = 'PartyIdentification_ID'

				LEFT JOIN ctl_doc_value v4 with(nolock) ON v4.IdHeader = ordine.id and v4.dse_id = 'ORDER' and v4.DZT_Name = 'Order_ID'
				LEFT JOIN ctl_doc_value v5 with(nolock) ON v5.IdHeader = ordine.id and v5.dse_id = 'ORDER' and v5.DZT_Name = 'Order_IssueDate'
				
				LEFT JOIN ctl_doc_value v6 with(nolock) ON v6.IdHeader = ordine.id and v6.dse_id = 'DESPATCHADVICE' and v6.DZT_Name = 'DespatchAdvice_ID'
				LEFT JOIN ctl_doc_value v7 with(nolock) ON v7.IdHeader = ordine.id and v7.dse_id = 'DESPATCHADVICE' and v7.DZT_Name = 'DespatchAdvice_IssueDate'
				
				LEFT JOIN ctl_doc_value v8 with(nolock) ON v8.IdHeader = ordine.id and v8.dse_id = 'INVOICE' and v8.DZT_Name = 'Order_ID'
				LEFT JOIN ctl_doc_value v9 with(nolock) ON v9.IdHeader = ordine.id and v9.dse_id = 'INVOICE' and v9.DZT_Name = 'Order_IssueDate'
				
				LEFT JOIN ctl_doc_value v10 with(nolock) ON v10.IdHeader = ordine.id and v10.dse_id = 'ACCOUNTINGCUSTOMERPARTY' and v10.DZT_Name = 'PartyName'
				LEFT JOIN ctl_doc_value v11 with(nolock) ON v11.IdHeader = ordine.id and v11.dse_id = 'ACCOUNTINGCUSTOMERPARTY' and v11.DZT_Name = 'PartyIdentification_ID'

				left Join ctl_doc_value v12 with(nolock) ON v12.IdHeader = ordine.id and v12.DSE_ID = 'DELIVERYCUSTOMERPARTY' and v12.DZT_Name = 'EndpointID_Destinatario'
				left join Document_NoTIER_Destinatari dest with(nolock) on v12.Value = UPPER(dest.ID_PEPPOL) and (dest.sorgente <> 'OE' or dest.sorgente is null) and dest.ID_PEPPOL <> ''

		where ordine.tipodoc in ( 'NOTIER_ORDINE', 'NOTIER_DDT', 'NOTIER_INVOICE', 'NOTIER_CREDIT_NOTE' ) and ordine.deleted = 0



GO
