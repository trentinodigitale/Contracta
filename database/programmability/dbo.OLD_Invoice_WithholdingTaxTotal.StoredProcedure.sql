USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_Invoice_WithholdingTaxTotal]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [dbo].[OLD_Invoice_WithholdingTaxTotal] ( @idDoc int ) 
as
begin

	select 
			IdHeader,		
			sum( TaxSubtotal_TaxableAmount ) as TaxSubtotal_TaxableAmount,
			sum( TaxSubtotal_TaxAmount ) as TaxSubtotal_TaxAmount,
			TaxCategoryID,
			TaxCategoryPercentuale,
			TaxScheme,
			TaxTypeCode

		from ( 

			select 
					IdHeader,		
					BaseImponibileRitenuta as TaxSubtotal_TaxableAmount,
					RitenutaImporto as TaxSubtotal_TaxAmount,
					'S' as TaxCategoryID,
					RitenutaPercentuale as TaxCategoryPercentuale,
					'SWT' as TaxScheme,

					case
						when CausalePagamento = '' then 'R'
						else CausalePagamento
					end as TaxTypeCode
				from Document_NoTIER_Prodotti p with(nolock)
					where idHeader = @idDoc and TipoRitenuta not in( '', 'NA') and p.TipoDoc_collegato in ('FATTURA', 'FATTURA_PA')

			union 
	 

			select 
					IdHeader,
					ImponibileContributo as TaxSubtotal_TaxableAmount,
					ImportoContributo as TaxSubtotal_TaxAmount,
					'S' as TaxCategoryID,
					PercentualeContributo as TaxCategoryPercentuale,
					'SWT' as TaxScheme,
					case
						when CausalePagamentoContributo = '' then 'R'
						else CausalePagamentoContributo
					end as TaxTypeCode
				from Document_NoTIER_Prodotti with(nolock)				
					where idHeader = @idDoc and TipoContributo not in( '', 'NA') and TipoDoc_collegato in ('FATTURA', 'FATTURA_PA')

		) as a
		group by 
			IdHeader,		
			TaxCategoryID,
			TaxCategoryPercentuale,
			TaxScheme,
			TaxTypeCode



end
GO
