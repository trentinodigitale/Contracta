USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[ODC_Process]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ODC_Process] (@IdDoc INT,  @IdUser INT)
AS
	DECLARE @NewIdOrd                               INT
	DECLARE @NewIdBolla                             INT
	DECLARE @KeyRiga                                INT
	DECLARE @IdAzi                                  INT
	DECLARE @Id_Convenzione                         INT
	DECLARE @Prot                                   VARCHAR(50) 
	DECLARE @NumOrd                                 VARCHAR(50) 
	DECLARE @Plant                                  VARCHAR(50)
	DECLARE @CodiceSoc                              VARCHAR(50)
	DECLARE @Fornitore                              INT
	DECLARE @RDA_Utilizzo                           VARCHAR(50)
	DECLARE @adProductType                          VARCHAR(50)
	DECLARE @RDA_Total                              FLOAT
	declare @RicPropBozza							varchar(10)

	set @RicPropBozza = '0'
	select @RicPropBozza = max( RicPropBozza ) 
		from Document_ODC_Product 
			inner join Document_Convenzione_Product on idRow = Id_Product
		where RicPropBozza is not null and RDP_RDA_Id = @IdDoc

	SELECT @Prot = RDA_Protocol
			, @RDA_Total = RDA_Total
			, @Plant = Plant 
			, @IdAzi = RDA_AZI 
			, @Fornitore = RDA_Fornitore 
			, @RDA_Utilizzo = RDA_Utilizzo 
			, @Id_Convenzione = Id_Convenzione 
		FROM Document_ODC 
		WHERE RDA_Id = @IdDoc

	SELECT @Fornitore = RDP_Fornitore 
		FROM Document_ODC_Product 
		WHERE RDP_RDA_Id = @IdDoc

	EXEC CTL_GetNewProtocol  'NumOrd', @Plant, @NumOrd OUTPUT 

	UPDATE Document_Convenzione 
		SET TotaleOrdinato = TotaleOrdinato + @RDA_Total 
		WHERE Id = @Id_Convenzione

	-- chiude la convenzione se è terminato il valore preventivo

	IF EXISTS(SELECT * FROM Document_Convenzione WHERE ROUND(TotaleOrdinato, 2) >= ROUND(Total, 2) AND Id = @Id_Convenzione)
	BEGIN
			--UPDATE Document_Convenzione 
			--	SET StatoConvenzione = 'Chiuso' 
			--	WHERE Id = @Id_Convenzione

			--INSERT INTO CTL_ApprovalSteps (APS_Doc_Type, APS_Id_DOC, APS_State, APS_Note, APS_IdPfu, APS_UserProfile, 
			--							   APS_IsOld, APS_Date) 
			--		VALUES('CONVENZIONE', @Id_Convenzione, 'Chiusura', 'Chiusura automatica per raggiungimento importo',
			--				-10, '', 1, GETDATE())

			exec CONVENZIONE_CHIUDI @Id_Convenzione , 'Chiusura automatica per raggiungimento importo'

	END

	INSERT INTO Document_Ordine (IdMsg, iType, iSubType, DataIns, NumOrd, Protocol, StatoOrdine, StateOrder, Plant, 
								 Name, IdDestinatario, IdAzIdest, IdMittente, Nota, FlagSituazione, STOrderCode, 
								 Deleted, Total, Valuta, IVA, ImpegnoSpesa, TotalIva, Capitolo, NumeroConvenzione, 
								 ReferenteConsegna, ReferenteIndirizzo, ReferenteTelefono, ReferenteEMail,
								 ReferenteRitiro, IndirizzoRitiro, TelefonoRitiro, Id_Convenzione, ODC_PEG, 
								 RitiroEMail, RefOrd, RefOrdInd, RefOrdTel, RefOrdEMail, RicPropBozza , TipoOrdine )
		SELECT RDA_Id, 22, 250, RDA_DataCreazione, @NumOrd, @Prot, 'SendOrder', 5, @Plant, RDA_Name, Utente, 
			   @Fornitore, RDA_Owner, RDA_Object, 0, NEWID(), 0, RDA_Total, RDA_Valuta, Document_ODC.IVA, ImpegnoSpesa, 
			   TotalIva, Capitolo, NumeroConvenzione, ReferenteConsegna, ReferenteIndirizzo, ReferenteTelefono, 
			   ReferenteEMail, ReferenteRitiro, IndirizzoRitiro, TelefonoRitiro, Id_Convenzione, ODC_PEG, RitiroEMail, 
			   RefOrd, RefOrdInd, RefOrdTel, RefOrdEMail, @RicPropBozza ,Document_ODC.TipoOrdine 
			FROM Document_ODC 
				, Document_Convenzione
			WHERE Document_ODC.Id_Convenzione = Document_Convenzione.Id
				AND RDA_Id = @IdDoc

	SET @NewIdOrd = @@IDENTITY

	SELECT @KeyRiga = MIN(RDP_IdRow) 
		FROM Document_ODC_Product 
		WHERE RDP_RDA_Id = @IdDoc

	SET @KeyRiga = @KeyRiga - 1

	INSERT INTO Document_Ordine_Product (IdHeader, KeyRiga, CodArt, SedIdest, CentroDiCosto, VDS, Merc, KeyProgetto, 
										 KeyFornitore, KeyTipoInvestimento, Ticket, CARDescrNonCod, ProtocolRDA, UM,
										 CARCommessa, CARDataConsegnaProdotto, CarValGenerico , CARQuantitaDaOrdinare, 
										 CARUnitMisNonCod, CARUtilizzo, PrzUnOfferta, CPI, RPROT, Allegato, QtMin, Nota
										,PercSconto,CoefCorr,CostoComplessivo,DataUtilizzo , Id_Product )
		SELECT @NewIdOrd, RDP_IdRow - @KeyRiga, RDP_CodArtProd, Plant, NULL, RDP_VDS, RDP_Merceologia, RDP_Progetto, 
				@Fornitore, RDP_TipoInvestimento, RDP_TiketBudget, RDP_Desc, RDA_Protocol, RDP_UMNonCod,
				CASE WHEN RDP_Commessa = '' THEN '0' ELSE RDP_Commessa END , Document_ODC_Product.RDP_DataPrevCons, RDA_Valuta, RDP_Qt,
				RDP_UMNonCod, RDA_Utilizzo, RDP_Importo, RDP_cpi, RDP_rprot, RDP_Allegato, QtMin, Nota
				,PercSconto,CoefCorr,CostoComplessivo,DataUtilizzo , Id_Product
			FROM Document_ODC_Product INNER JOIN Document_ODC ON RDA_Id = RDP_RDA_Id
			WHERE RDA_Id = @IdDoc


	INSERT INTO ASN (asnOrderType, asnOrderCode, asnRowKey, asnProtocol, asnIdAziMitt, asnIdAzIdest, asnIdMp, 
					 asnRequestDate, asnArtCode, asnArtDesc, asnTargetSite, asnRequiredAmount, asnReceivedAmount, 
					 asnRowStatus, asnOrderNumber, asnClassMerc, asnDeleted, asnChangeStatusDate, asnIdPfuMitt) 
		SELECT '1', STOrderCode, KeyRiga, Protocol, @IdAzi, IdAzIdest, 2, 
				CAST(YEAR(CARDataConsegnaProdotto) AS VARCHAR) + 
						RIGHT('00' + CAST(MONTH(CARDataConsegnaProdotto) AS VARCHAR), 2) + 
						RIGHT('00' + CAST(DAY(CARDataConsegnaProdotto) AS VARCHAR ), 2),
				CodArt, CARDescrNonCod, SedIdest, CARQuantitaDaOrdinare, 0, 0, NumOrd, Merc, 0, GETDATE(), IdMittente
			FROM Document_Ordine INNER JOIN Document_Ordine_Product ON Id = IdHeader
			WHERE Id = @NewIdOrd





GO
