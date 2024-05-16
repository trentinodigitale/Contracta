USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_Invoice_UBLExtensions]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[OLD2_Invoice_UBLExtensions] ( @idDoc int ) 
as
begin

select *
	from (
				select 
					1 as ordinamento, 
					IdHeader,
					case 
						when Value = 380 then 'TD01'
					end as TypeCode,
					case 
						when Value = 380 then 'urn:fdc:agid.gov.it:fatturapa:TipoDocumento'
					end as ExtensionURI
				from CTL_DOC_Value with(nolock)
					where DSE_ID = 'INVOICE' and DZT_Name = 'InvoiceTypeCode' and IdHeader = @idDoc

			union 

				select 
					2 as ordinamento,
					IdHeader, 
					TipoContributo as TypeCode, 
					'urn:fdc:agid.gov.it:fatturapa:TipoRitenuta::' as ExtensionURI
				from Document_NoTIER_Prodotti with(nolock)
					where IdHeader = @idDoc and TipoContributo <> 'NA' and TipoContributo <> '' and TipoDoc_collegato in ('FATTURA', 'FATTURA_PA')

			union

				select 
					3 as ordinamento,
					IdHeader, 
					TipoRitenuta as TypeCode, 
					'urn:fdc:agid.gov.it:fatturapa:TipoRitenuta::' as ExtensionURI
				from Document_NoTIER_Prodotti with(nolock)
					where IdHeader = @idDoc and TipoRitenuta <> 'NA' and TipoRitenuta <> '' and TipoDoc_collegato in ('FATTURA', 'FATTURA_PA')

	) as a
	order by ordinamento

end
GO
