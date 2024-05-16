USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_view_addfrom_Document_NoTIER_Prodotti]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE VIEW [dbo].[OLD2_view_addfrom_Document_NoTIER_Prodotti] AS

	select idRow as indRow,
		    isnull(TipoDoc_richiedente, 'DDT') as TipoDoc_collegato,
			IdRow, IdHeader, DespatchLine_DeliveredQuantity, 
			case when TipoDoc_richiedente = 'FATTURA_PA' then 'NA' else DespatchLine_ID end as DespatchLine_ID, 
			case when TipoDoc_richiedente = 'FATTURA_PA' then DespatchLine_ID else OrderLine_id end as OrderLine_id,

			DespatchLine_Note, DespatchLine_OrderQuantity, 
			DespatchLine_OutstandingQuantity, DespatchLine_OutstandingReason, DespatchLine_Shipment_HandlingCode, DespatchLine_Shipment_ID, 
			DocumentReference_DocumentType, DocumentReference_ID, 
			case when DocumentReference_IssueDate = '' then null else DocumentReference_IssueDate end as DocumentReference_IssueDate , 
			HazardousItem_CategoryName, HazardousItem_HazardClassID, HazardousItem_ID, HazardousItem_TechnicalName, HazardousItem_UNDGCode,
			HazardousRiskIndicator, Item_AdditionalInformation, Item_Name, ItemInstance_SerialID, 
			case when LotIdentification_ExpiryDate = '' then null else LotIdentification_ExpiryDate end as LotIdentification_ExpiryDate , 
			LotIdentification_LotNumberID, MaximumTemperature_AttributeID, MaximumTemperature_Measure, MaximumTemperature_UM_Measure, 
			MeasurementDimension_AttributeID, MeasurementDimension_Measure, MinimumTemperature_AttributeID, MinimumTemperature_Measure, 
			MinimumTemperature_UM_Measure, SellersItemIdentification_ID, ShippingMarks, StandardItemIdentification_ID, Temperature_AttributeID, 
			Temperature_Measure, Temperature_UM_Measure, TransportHandlingUnit_ID, TransportHandlingUnitTypeCode,[DocumentReference_DocumentType_2],
			[DocumentReference_ID_2],[DocumentReference_IssueDate_2], DespatchLine_DeliveredQuantity_unitCode,DespatchLine_OutstandingQuantity_unitCode,
			[AdditionalDocumentReference_CIG],

			case when AdditionalDocumentReference_CIG_IssueDate = '' then null else AdditionalDocumentReference_CIG_IssueDate end as AdditionalDocumentReference_CIG_IssueDate , 

			[AdditionalDocumentReference_CUP],

			case when AdditionalDocumentReference_CUP_IssueDate = '' then null else AdditionalDocumentReference_CUP_IssueDate end as AdditionalDocumentReference_CUP_IssueDate , 

			case when AdditionalDocumentReference_CONV_IssueDate = '' then null else AdditionalDocumentReference_CONV_IssueDate end as AdditionalDocumentReference_CONV_IssueDate,

			[AdditionalDocumentReference_CONV],

			OrderLine_Quantity,
			OrderLine_Quantity_unitCode,

			OrderLine_ClassifiedTaxCategory_ID,
			OrderLine_ClassifiedTaxCategory_Percent,
			OrderLine_LineExtensionAmount,
			OrderLine_TotalTaxAmount, 
			OrderLine_Price,
			--0 AS CreditNoteLine_id,
			--NULL AS InvoiceLine_id,
			--case when TipoDoc_collegato = 'FATTURA' then InvoiceLine_id else NULL end InvoiceLine_id,
			'1' as sorgente_esterna

		from Document_NoTIER_Prodotti with(nolock)
		where TipoDoc_collegato IN ( 'ORDINE', 'FATTURA' )
GO
