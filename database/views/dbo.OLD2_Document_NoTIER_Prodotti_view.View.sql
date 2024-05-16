USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_Document_NoTIER_Prodotti_view]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[OLD2_Document_NoTIER_Prodotti_view] as
	select 

			[IdRow], 
			[IdHeader], 
			[TipoDoc_collegato], 
			[data], 
			[DespatchLine_DeliveredQuantity], 
			[DespatchLine_ID], 
			[DespatchLine_Note], 
			[DespatchLine_OrderQuantity], 
			[DespatchLine_OutstandingQuantity], 
			[DespatchLine_OutstandingReason], 
			[DespatchLine_Shipment_HandlingCode], 
			[DespatchLine_Shipment_ID], 
			[DocumentReference_DocumentType], 
			[DocumentReference_ID], 
			[DocumentReference_IssueDate], 
			[HazardousItem_CategoryName], 
			[HazardousItem_HazardClassID], 
			[HazardousItem_ID], 
			[HazardousItem_TechnicalName], 
			[HazardousItem_UNDGCode], 
			[HazardousRiskIndicator], 
			[Item_AdditionalInformation], 
			[Item_Name], 
			[ItemInstance_SerialID], 
			[LotIdentification_ExpiryDate], 
			[LotIdentification_LotNumberID], 
			[MaximumTemperature_AttributeID], 
			[MaximumTemperature_Measure], 
			[MaximumTemperature_UM_Measure], 
			[MeasurementDimension_AttributeID], 
			[MeasurementDimension_Measure], 
			[MinimumTemperature_AttributeID], 
			[MinimumTemperature_Measure], 
			[MinimumTemperature_UM_Measure], 
			[SellersItemIdentification_ID], 
			[ShippingMarks], 
			[StandardItemIdentification_ID], 
			[Temperature_AttributeID], 
			[Temperature_Measure], 
			[Temperature_UM_Measure], 
			[TransportHandlingUnit_ID], 
			[TransportHandlingUnitTypeCode], 
			[DocumentReference_DocumentType_2], 
			[DocumentReference_ID_2], 
			[DocumentReference_IssueDate_2], 
			[DespatchLine_DeliveredQuantity_unitCode], 
			[DespatchLine_OutstandingQuantity_unitCode], 
			[OrderLine_id], 
			[OrderLine_Quantity], 
			[OrderLine_Quantity_unitCode], 
			[OrderLine_Note], 
			[OrderLine_LineExtensionAmount], 
			[OrderLine_TotalTaxAmount], 
			[OrderLine_AccountingCost], 
			[OrderLine_Price], 
			[OrderLine_CommodityClassification], 
			[OrderLine_CommodityClassification_listID], 
			[OrderLine_ClassifiedTaxCategory_ID], 
			cast( cast( [OrderLine_ClassifiedTaxCategory_Percent] as decimal(10,2)) as int ) as [OrderLine_ClassifiedTaxCategory_Percent], 
			[OrderLine_AdditionalItemProperty_Name], 
			[OrderLine_AdditionalItemProperty_Value], 
			[OrderLine_Price_AllowanceCharge_Amount], 
			[OrderLine_AllowanceCharge_Amount], 
			[OrderLine_AllowanceChargeReason], 
			[OrderLine_Price_AllowanceChargeReason], 
			[RequestedDeliveryPeriod_StartDate], 
			[RequestedDeliveryPeriod_EndDate], 
			[AdditionalDocumentReference_CIG], 
			[AdditionalDocumentReference_CIG_IssueDate], 
			[AdditionalDocumentReference_CUP], 
			[AdditionalDocumentReference_CUP_IssueDate], 
			[AdditionalDocumentReference_CONV_IssueDate], 
			[AdditionalDocumentReference_CONV], 
			[DespatchLineReference_LineID], 
			[OrderLineReference_LineID], 
			[TipoDoc_richiedente], 
			[CodiceAIC], 
			[TIPO_REPERTORIO], 
			[NumeroRepertorio], 
			[InvoiceLine_id], 
			[sorgente_esterna], 
			[CreditNoteLine_id], 
			[BuyersItemIdentification], 
			[TipoRitenuta], 
			[RitenutaPercentuale], 
			[RitenutaImporto], 
			[TipoContributo], 
			[ImponibileContributo], 
			[PercentualeContributo], 
			[ImportoContributo], 
			[TaxExemptionReason], 
			[CPA], 
			[SoggettaRitenutaDacconto], 
			[CPAImponibile], 
			[CPAPercentuale], 
			[CPAImporto], 
			[BaseImponibileRitenuta], 
			[CausalePagamento], 
			[CausalePagamentoContributo], 
			[BaseImponibileRitenutaInput]
	
		from Document_NoTIER_Prodotti
GO
