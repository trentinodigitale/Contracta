USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[creditNote_TaxSubtotal]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--exec Invoice_TaxSubtotal 469706



CREATE proc [dbo].[creditNote_TaxSubtotal] ( @idDoc int ) 
as
begin

	declare @InvoicePeriodEsigibilitaIVA  varchar(1900) 
	select @InvoicePeriodEsigibilitaIVA = value from ctl_doc_value with(nolock) where dse_id = 'INVOICE' and dzt_name = 'EsigibilitaIVA' and idheader = @idDoc

	select idHeader , CodiceIVAExt  , Aliquota, TaxExemptionReasonCode , TaxExemptionReason, sum (  TotaleImporto ) as  TotaleImporto, sum(TotaleTasse) as TotaleTasse

		from ( 
			select 
					idHeader,
					case 
						when  p.OrderLine_ClassifiedTaxCategory_ID = 'O_1' --Escluse ex Art. 15 D.P.R. 633/72
								then  'Z'
						when p.OrderLine_ClassifiedTaxCategory_ID in (  'O_2' , 'E') -- "Non Soggette" o "Esente Art.10 D.P.R. 633/72"
								then 'E'
						when p.OrderLine_ClassifiedTaxCategory_ID = 'K' then 'K'
						when p.OrderLine_ClassifiedTaxCategory_ID = 'G' then 'G'
						else 
							case when @InvoicePeriodEsigibilitaIVA = 'EP'  then 'B'
								else v.DMV_CodExt
								end
						end as CodiceIVAExt,
					v.dmv_father as Aliquota,
					
					p.OrderLine_LineExtensionAmount + ISNULL(CPAImporto, 0.00) as TotaleImporto,
					
					case 
						when  p.OrderLine_ClassifiedTaxCategory_ID = 'E' then 'vatex-eu-132'
						when  p.OrderLine_ClassifiedTaxCategory_ID = 'O_2' then 'vatex-eu-132'
						when  p.OrderLine_ClassifiedTaxCategory_ID = 'G' then 'vatex-eu-g'
						when  p.OrderLine_ClassifiedTaxCategory_ID = 'k' then 'vatex-eu-ic'
						when  p.OrderLine_ClassifiedTaxCategory_ID = 'AE' then 'vatex-eu-ae'					
						else ''
						end as TaxExemptionReasonCode,
					
					case 
						when  TaxExemptionReason = '' and p.OrderLine_ClassifiedTaxCategory_ID = 'O_2' then 'N2.2'
						when  p.OrderLine_ClassifiedTaxCategory_ID = 'E' then  'N4#' + TaxExemptionReason
						when  p.OrderLine_ClassifiedTaxCategory_ID = 'O_2' then 'N2.2#' + TaxExemptionReason
						else ''
						end as TaxExemptionReason,
						OrderLine_TotalTaxAmount as TotaleTasse

				from Document_NoTIER_Prodotti as p with(nolock) 
					inner join LIB_DomainValues v with(nolock) on v.DMV_DM_ID = 'UNCL5305' and v.DMV_Cod = p.OrderLine_ClassifiedTaxCategory_ID and p.TipoDoc_collegato in ('NOTA_DI_CREDITO', 'NOTA_DI_CREDITO_PA')
	
				where idHeader =@idDoc

			union

			-- union per la riga del bollo
			select 
					IdHeader, 
					'Z', 
					0, 
					case
						when cast( Value as float ) <> 0.0 then -2 
						else 0 
					end as TotaleImporto ,
					'' as TaxExemptionReasonCode,
					'' as TaxExemptionReason,
					0 as TotaleTasse
	
				from ctl_doc_value with(nolock) 

				where IdHeader = @idDoc and DSE_ID = 'INVOICEAMOUNT' 
					and DZT_Name = 'AllowanceChargeAmount_Bollo'
					and value <> ''
		) as a

		group by idHeader , CodiceIVAExt  , Aliquota , TaxExemptionReasonCode , TaxExemptionReason

end

GO
