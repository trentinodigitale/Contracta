USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_creditNote_WithholdingTaxTotal]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[OLD_creditNote_WithholdingTaxTotal] ( @idDoc int ) 
as
begin

	select 
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
			where IdHeader = @idDoc and TipoContributo <> 'NA' and TipoContributo <> '' and TipoDoc_collegato in ('NOTA_DI_CREDITO', 'NOTA_DI_CREDITO_PA')

union

	select 
			BaseImponibileRitenuta as TaxSubtotal_TaxableAmount,
			RitenutaImporto as TaxSubtotal_TaxAmount,
			'S' as TaxCategoryID,
			RitenutaPercentuale as TaxCategoryPercentuale,
			'SWT' as TaxScheme,
			case
				when CausalePagamento = '' then 'R'
				else CausalePagamento
			end as TaxTypeCode
		from Document_NoTIER_Prodotti with(nolock)
			where IdHeader = @idDoc and TipoRitenuta <> 'NA' and TipoRitenuta <> '' and TipoDoc_collegato in ('NOTA_DI_CREDITO', 'NOTA_DI_CREDITO_PA')

end
GO
