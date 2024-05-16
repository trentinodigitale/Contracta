USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[creditNote_AllowanceCharge]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[creditNote_AllowanceCharge] ( @idDoc int ) 
as
begin

	declare @InvoicePeriodEsigibilitaIVA  varchar(1900) 
	select @InvoicePeriodEsigibilitaIVA = value from ctl_doc_value with(nolock) where dse_id = 'INVOICE' and dzt_name = 'EsigibilitaIVA' and idheader = @idDoc

	select 
			p.IdHeader,
			'true' as ChargeIndicator,
			'ZZZ' as AllowanceChargeReasonCode, 
			p.CPAPercentuale as MultiplierFactorNumeric,

			case 
				when p.OrderLine_ClassifiedTaxCategory_ID = 'O_1' then CPA + '#SI#N1'
				when p.OrderLine_ClassifiedTaxCategory_ID = 'O_2' then CPA + '#SI#N2.2'
				when p.OrderLine_ClassifiedTaxCategory_ID = 'E' then CPA + '#SI#N4'
				else p.CPA + '#SI#'
			end as AllowanceChargeReason,

			p.CPAImporto as Amount,
			p.CPAImponibile as BaseAmount,
			
			case	
				when  p.OrderLine_ClassifiedTaxCategory_ID = 'O_1' then 'Z'
				when p.OrderLine_ClassifiedTaxCategory_ID in (  'O_2' , 'E') then 'E'
				when p.OrderLine_ClassifiedTaxCategory_ID = 'K' then 'K'
				when p.OrderLine_ClassifiedTaxCategory_ID = 'G' then 'G'
				else 
					case 
						when @InvoicePeriodEsigibilitaIVA = 'EP'  then 'B'
						else v.DMV_CodExt
					end
			end as TaxCategoryID,

			p.OrderLine_ClassifiedTaxCategory_Percent as TaxCategoryPercent,
			'VAT' as TaxSchemeID

			from Document_NoTIER_Prodotti p with(nolock)
				inner join LIB_DomainValues v with(nolock) on v.DMV_DM_ID = 'UNCL5305' and v.DMV_Cod = p.OrderLine_ClassifiedTaxCategory_ID 
				inner join CTL_DOC_Value e with(nolock) on p.IdHeader = e.IdHeader and DSE_ID = 'INVOICE' and DZT_Name = 'EsigibilitaIVA'
			where p.idHeader = @idDoc and p.CPA <> '' and p.TipoDoc_collegato in ('NOTA_DI_CREDITO', 'NOTA_DI_CREDITO_PA')
union

	select 
			IdHeader, 

			case 
				when Value = '2.00' then 'false'
				when Value = '0.00' then 'true'
			end as ChargeIndicator,

			case 
				when Value = '2.00' then '95'
				when Value = '0.00' then 'SAE'
			end as AllowanceChargeReasonCode,

			0 as MultiplierFactorNumeric, 
			'BOLLO' as AllowanceChargeReason,
			value as Amount,
			0 as BaseAmount,
			'Z' as TaxCategoryID,
			0 as TaxCategoryPercent, 
			'VAT' as TaxSchemeID
		from ctl_doc_value with(nolock) 
			where IdHeader = @idDoc and DSE_ID = 'INVOICEAMOUNT' 
					and DZT_Name = 'AllowanceChargeAmount_Bollo'
					and value <> ''

end
GO
