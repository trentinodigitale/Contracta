USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_NOTIER_ORDINE_CREATE_FROM_LISTA]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








CREATE PROCEDURE [dbo].[OLD2_NOTIER_ORDINE_CREATE_FROM_LISTA] ( @IdDoc int  , @idUser int, @varia int = 0 )
AS
BEGIN

	SET NOCOUNT ON

	declare @id INT
	declare @Errore as nvarchar(2000)
	declare @IdAzi as int
	declare @ragSoc as nvarchar(4000)
	declare @cf as varchar(100)
	declare @piva as varchar(100)

	declare @idNotier varchar(500)
	declare @pid varchar(500)

	set @Id = 0
	set @Errore=''
	set @idNotier = ''
	set @pid = ''
	
	select   @IdAzi=pfuidazi 
			,@idNotier = isnull(d1.vatValore_FT,'')
			,@ragSoc = aziRagioneSociale 
			,@cf = d2.vatValore_FT 
			,@piva = aziPartitaIVA
			,@pid = d3.vatValore_FT
		from profiliutente with(nolock)
				left join aziende with(nolock) ON pfuidazi=idazi
				left join DM_Attributi d1 with(nolock) ON d1.lnk = idazi and d1.dztNome = 'IDNOTIER' and d1.idApp = 1
				left join DM_Attributi d2 with(nolock) ON d2.lnk = idazi and d2.dztNome = 'codicefiscale' and d2.idApp = 1
				left join DM_Attributi d3 with(nolock) ON d3.lnk = idazi and d3.dztNome = 'participantid' and d3.idApp = 1
		where idpfu=@idUser  

	select * into #ipa 
		from Document_NoTIER_Destinatari a with(nolock) 
			--inner join ProfiliUtenteAttrib b with(nolock) on b.IdPfu = @idUser and b.dztNome = 'CodiceIPA_Notier' and b.attValue = a.ID_IPA 
		where piva_cf = @cf and bDeleted = 0

	IF EXISTS ( select id from #ipa ) and NOT EXISTS ( select id from #ipa where Peppol_Invio_Ordine = '1' )
	BEGIN
		set @Errore = 'Creazione Ordine non consentita. La registrazione Peppol è stata effettuata senza l''opzione ''Invio Ordine''' 
	END

	if @Errore = '' 
		and ( 
				@idNotier <> ''
					OR
				exists ( select id from #ipa )
		)
	begin

		DECLARE @titolo nvarchar(1000)
		DECLARE @prevDoc int
		DECLARE @numeroOrdinePrev varchar(1000)

		DECLARE @numeroOrdineNuovo varchar(1000)

		DECLARE @dataOrdinePrev varchar(100)
		DECLARE @tipoOrdinePrev varchar(1000)
		declare @statoFunzionalePrev varchar(1000)
		declare @oldPrevDoc int

		declare @versione varchar(100)

		set @titolo = 'Ordine NoTI-ER'
		set @prevDoc = 0

		set @numeroOrdinePrev = ''
		set @dataOrdinePrev = ''
		set @tipoOrdinePrev = ''
		set @statoFunzionalePrev = ''
		set @versione = ''

		IF @varia = 1
		BEGIN

			set @prevDoc = @IdDoc

			select  @titolo = titolo,
					@numeroOrdinePrev = a.Value,
					@dataOrdinePrev = b.value,
					@tipoOrdinePrev = b.Value,
					@statoFunzionalePrev = StatoFunzionale,
					@oldPrevDoc = isnull(PrevDoc,0),
					@versione = Versione
				from ctl_doc with(nolock)
						inner join ctl_doc_value a with(nolock) on a.idheader = id and a.dse_id = 'ORDER' and a.DZT_Name = 'Order_ID'
						inner join ctl_doc_value b with(nolock) on b.idheader = id and b.dse_id = 'ORDER' and b.DZT_Name = 'Order_IssueDate'
						inner join ctl_doc_value c with(nolock) on c.idheader = id and c.dse_id = 'ORDER' and c.DZT_Name = 'OrderTypeCode'
				where id = @IdDoc and tipodoc = 'NOTIER_ORDINE'

			IF EXISTS ( select id from ctl_doc with(nolock) where id = @IdDoc and TipoDoc <> 'NOTIER_ORDINE' )
			BEGIN
				
				set @Errore = 'La variazione è consentita a partire solo dai documenti di tipo Ordine'

			END 
			ELSE IF @versione <> '3.0' 
			BEGIN

				set @Errore = 'La variazione è consentita a partire solo dai documenti creati con l''ultima versione attualmente disponibile'
				
			END
			ELSE IF @statoFunzionalePrev <> 'Inviato'
			BEGIN
				
				set @Errore = 'E'' possibile variare i soli ordini inviati'

			END
			ELSE
			BEGIN

				declare @numeroOccorrenze int
				declare @progressivo int

				set @numeroOrdineNuovo = @numeroOrdinePrev

				--- modifico il numero ordine accodandoci un incrementale
				IF @oldPrevDoc <> 0
				BEGIN
					
					BEGIN TRY

						set @numeroOccorrenze = len(@numeroOrdinePrev) - len(replace(@numeroOrdinePrev, '_', ''))

						if @numeroOccorrenze > 0
						begin
							set @progressivo = cast(  dbo.GetPos(@numeroOrdinePrev, '_',@numeroOccorrenze+1) as int )
							set @numeroOrdineNuovo = replace( @numeroOrdinePrev, '_' + cast(@progressivo as varchar), '_' + cast( (@progressivo + 1) as varchar) )
						end
						else
						begin
							set @numeroOrdineNuovo = @numeroOrdinePrev + '_1'
						end

					END TRY  
					BEGIN CATCH
						set @numeroOrdineNuovo = @numeroOrdinePrev + '_1'
					END CATCH


				END
				ELSE
				BEGIN

					set @numeroOrdineNuovo = @numeroOrdinePrev + '_1'

				END

			END

		END

		IF @Errore = ''
		BEGIN

			--inserisco nella ctl_doc		
			insert into CTL_DOC ( IdPfu, TipoDoc, StatoDoc, Titolo, Body, Azienda,Destinatario_Azi,  ProtocolloRiferimento,  Fascicolo,LinkedDoc, StatoFunzionale,IdPfuInCharge, jumpcheck, PrevDoc, Versione )
				values			( @idUser, 'NOTIER_ORDINE', 'Saved' ,@titolo  , '' , @IdAzi , null ,''  , '' ,NULL,'InLavorazione', @idUser , '', @prevDoc, '3.0')

			set @Id = SCOPE_IDENTITY()		

			insert into Document_dati_protocollo (idHeader)	values	(@id)

			IF @varia = 0
			BEGIN

				insert into Document_NoTIER_Totali (idHeader)	values	(@id)

				---------------------------
				-- ACQUIRENTE / MITTENTE --
				---------------------------
				INSERT INTO CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, value )
								   values ( @Id, 'BUYERCUSTOMERPARTY', 0,'PartyTaxScheme_CompanyID', @piva) 

				INSERT INTO CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, value )
								   values ( @Id, 'BUYERCUSTOMERPARTY', 0,'PartyName', @ragSoc) 

				-- se ho una sola IPA/UFFICIO collegato, preavvaloro l'identificativo con il codice ipa, altrimenti utilizziamo il cf
				declare @totIPA as INT
				set @totIPA = 0

				select @totIPA = count(*) from #ipa

				if @totIPA = 1
				begin

					declare @ipa nvarchar(100)
					
					select @ipa = a.ID_IPA, @pid = a.ID_PEPPOL from #ipa a

					INSERT INTO CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, value )
								   values ( @Id, 'BUYERCUSTOMERPARTY', 0,'PartyIdentification_ID', @ipa) 

					INSERT INTO CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, value )
								   values ( @Id, 'BUYERCUSTOMERPARTY', 0,'schemeID', 'IT:IPA') 

					INSERT INTO CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, value )
								   values ( @Id, 'BUYERCUSTOMERPARTY', 0,'PARTICIPANTID_MITTENTE', @pid) 

					INSERT INTO CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, value )
								   values ( @Id, 'NOTIER', 0,'PARTICIPANTID_MITTENTE', @pid) 

					INSERT INTO CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, value )
								   values ( @Id, 'BUYERCUSTOMERPARTY', 0,'Not_Editable', ' PartyIdentification_ID schemeID PARTICIPANTID_MITTENTE ' )

				end
				else
				begin

					if @totIPA = 0
					begin

						INSERT INTO CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, value )
								   values ( @Id, 'BUYERCUSTOMERPARTY', 0,'PartyIdentification_ID', @cf) 

						INSERT INTO CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, value )
								   values ( @Id, 'BUYERCUSTOMERPARTY', 0,'schemeID', 'IT:CF') 

						INSERT INTO CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, value )
								   values ( @Id, 'BUYERCUSTOMERPARTY', 0,'PARTICIPANTID_MITTENTE', @pid) 

						--INSERT INTO CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, value )
						--		   values ( @Id, 'BUYERCUSTOMERPARTY', 0,'Not_Editable', ' PARTICIPANTID_MITTENTE ' )	   

						INSERT INTO CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, value )
								   values ( @Id, 'BUYERCUSTOMERPARTY', 0,'Not_Editable', ' PartyIdentification_ID schemeID PARTICIPANTID_MITTENTE ' )

					end

				end


				


				---------------------------
				-- INTESTATARIO FATTURA  --
				---------------------------
				INSERT INTO CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, value )
								   values ( @Id, 'ACCOUNTINGCUSTOMERPARTY', 0,'PartyTaxScheme_CompanyID', @piva) 

				INSERT INTO CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, value )
								   values ( @Id, 'ACCOUNTINGCUSTOMERPARTY', 0,'PartyName', @ragSoc) 

				INSERT INTO CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, value )
								   values ( @Id, 'ACCOUNTINGCUSTOMERPARTY', 0,'PartyIdentification_ID', @cf) 
	
				--lato ente sarà vuoto
				INSERT INTO CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, value )
								   values ( @Id, 'ACCOUNTINGCUSTOMERPARTY', 0,'PARTICIPANTID', @pid) 

				INSERT INTO CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, value )
								   values ( @Id, 'ACCOUNTINGSUPPLIERPARTY', 0,'StatoLiquidazione', '') 

				INSERT INTO CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, value )
								   values ( @Id, 'ACCOUNTINGSUPPLIERPARTY', 0,'SocioUnico', '') 

				INSERT INTO CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, value )
								   values ( @Id, 'ACCOUNTINGSUPPLIERPARTY', 0,'CapitaleSociale', '')

			END
			ELSE
			BEGIN
			
				insert into ctl_doc_value ( idheader, DSE_ID, row, DZT_Name, value )
					select @Id, DSE_ID, row, DZT_Name, value 
						from CTL_DOC_Value with(nolock) 
						where idheader = @IdDoc and dse_id not in ( 'XML_LOG_NOTIER' , 'NOTIER', 'NOTIER_ERROR' )


				UPDATE ctl_doc_value
						SET value = @numeroOrdineNuovo
					where idheader = @Id and dse_id = 'ORDER' and DZT_Name = 'Order_ID'

				---------------------------
				-- DATI ORDINE PRECEDENTE -
				---------------------------
				INSERT INTO CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, value )
								   values ( @Id, 'ORDER', 0,'OrderReference_ID', @numeroOrdinePrev) 

				INSERT INTO CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, value )
								   values ( @Id, 'ORDER', 0,'OrderReference_IssueDate', @dataOrdinePrev) 

				INSERT INTO CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, value )
								   values ( @Id, 'ORDER', 0,'OrderReference_OrderTypeCode', @tipoOrdinePrev) 

				-- SEZIONE TOTALI
				insert into Document_NoTIER_Totali ( IdHeader, AnticipatedMonetaryTotal_LineExtensionAmount, AnticipatedMonetaryTotal_TaxExclusiveAmount, AnticipatedMonetaryTotal_TaxInclusiveAmount, AnticipatedMonetaryTotal_PayableAmount )
								select @Id, AnticipatedMonetaryTotal_LineExtensionAmount, AnticipatedMonetaryTotal_TaxExclusiveAmount, AnticipatedMonetaryTotal_TaxInclusiveAmount, AnticipatedMonetaryTotal_PayableAmount
								from Document_NoTIER_Totali with(nolock) where IdHeader = @IdDoc

				-- PRODOTTI
				insert into Document_NoTIER_Prodotti ( IdHeader, TipoDoc_collegato, data, DespatchLine_DeliveredQuantity, DespatchLine_ID, DespatchLine_Note, DespatchLine_OrderQuantity, DespatchLine_OutstandingQuantity, DespatchLine_OutstandingReason, DespatchLine_Shipment_HandlingCode, DespatchLine_Shipment_ID, DocumentReference_DocumentType, DocumentReference_ID, DocumentReference_IssueDate, HazardousItem_CategoryName, HazardousItem_HazardClassID, HazardousItem_ID, HazardousItem_TechnicalName, HazardousItem_UNDGCode, HazardousRiskIndicator, Item_AdditionalInformation, Item_Name, ItemInstance_SerialID, LotIdentification_ExpiryDate, LotIdentification_LotNumberID, MaximumTemperature_AttributeID, MaximumTemperature_Measure, MaximumTemperature_UM_Measure, MeasurementDimension_AttributeID, MeasurementDimension_Measure, MinimumTemperature_AttributeID, MinimumTemperature_Measure, MinimumTemperature_UM_Measure, SellersItemIdentification_ID, ShippingMarks, StandardItemIdentification_ID, Temperature_AttributeID, Temperature_Measure, Temperature_UM_Measure, TransportHandlingUnit_ID, TransportHandlingUnitTypeCode, DocumentReference_DocumentType_2, DocumentReference_ID_2, DocumentReference_IssueDate_2, DespatchLine_DeliveredQuantity_unitCode, DespatchLine_OutstandingQuantity_unitCode, OrderLine_id, OrderLine_Quantity, OrderLine_Quantity_unitCode, OrderLine_Note, OrderLine_LineExtensionAmount, OrderLine_TotalTaxAmount, OrderLine_AccountingCost, OrderLine_Price, OrderLine_CommodityClassification, OrderLine_CommodityClassification_listID, OrderLine_ClassifiedTaxCategory_ID, OrderLine_ClassifiedTaxCategory_Percent, OrderLine_AdditionalItemProperty_Name, OrderLine_AdditionalItemProperty_Value, OrderLine_Price_AllowanceCharge_Amount, OrderLine_AllowanceCharge_Amount, OrderLine_AllowanceChargeReason, OrderLine_Price_AllowanceChargeReason )
					select @Id, TipoDoc_collegato, data, DespatchLine_DeliveredQuantity, DespatchLine_ID, DespatchLine_Note, DespatchLine_OrderQuantity, DespatchLine_OutstandingQuantity, DespatchLine_OutstandingReason, DespatchLine_Shipment_HandlingCode, DespatchLine_Shipment_ID, DocumentReference_DocumentType, DocumentReference_ID, DocumentReference_IssueDate, HazardousItem_CategoryName, HazardousItem_HazardClassID, HazardousItem_ID, HazardousItem_TechnicalName, HazardousItem_UNDGCode, HazardousRiskIndicator, Item_AdditionalInformation, Item_Name, ItemInstance_SerialID, LotIdentification_ExpiryDate, LotIdentification_LotNumberID, MaximumTemperature_AttributeID, MaximumTemperature_Measure, MaximumTemperature_UM_Measure, MeasurementDimension_AttributeID, MeasurementDimension_Measure, MinimumTemperature_AttributeID, MinimumTemperature_Measure, MinimumTemperature_UM_Measure, SellersItemIdentification_ID, ShippingMarks, StandardItemIdentification_ID, Temperature_AttributeID, Temperature_Measure, Temperature_UM_Measure, TransportHandlingUnit_ID, TransportHandlingUnitTypeCode, DocumentReference_DocumentType_2, DocumentReference_ID_2, DocumentReference_IssueDate_2, DespatchLine_DeliveredQuantity_unitCode, DespatchLine_OutstandingQuantity_unitCode, OrderLine_id, OrderLine_Quantity, OrderLine_Quantity_unitCode, OrderLine_Note, OrderLine_LineExtensionAmount, OrderLine_TotalTaxAmount, OrderLine_AccountingCost, OrderLine_Price, OrderLine_CommodityClassification, OrderLine_CommodityClassification_listID, OrderLine_ClassifiedTaxCategory_ID, OrderLine_ClassifiedTaxCategory_Percent, OrderLine_AdditionalItemProperty_Name, OrderLine_AdditionalItemProperty_Value, OrderLine_Price_AllowanceCharge_Amount, OrderLine_AllowanceCharge_Amount, OrderLine_AllowanceChargeReason, OrderLine_Price_AllowanceChargeReason
					from Document_NoTIER_Prodotti with(nolock) where IdHeader = @IdDoc


			END

			--IF @varia = 1
			--BEGIN

			--	-- SETTO IL PRECEDENTE ORDINE A VARIATO
			--	UPDATE CTL_DOC
			--			SET StatoFunzionale = 'Variato'
			--		WHERE ID = @IdDoc and tipodoc = 'NOTIER_ORDINE'

			--END

		END


	end
	else
	begin

		if @errore = ''
			set @errore = 'Nessun ID NoTI-ER associato all''utenza'

	end
	

	if @Errore=''
	begin
		select @Id as id , @Errore as Errore
	end
	else
	begin
		select 'Errore' as id , @Errore as Errore
	end


END












GO
