USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_E_FORMS_CAN29_LOT_TENDER]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[OLD2_E_FORMS_CAN29_LOT_TENDER] ( @idProc int, @idPDA int , @idUser int = 0, 
													@guidOperation varchar(500), 
													@numeroLotto varchar(1000) = '',
													@idDocContrConv int = 0,
													@debug int = 0 )
AS
BEGIN

	SET NOCOUNT ON

	DECLARE @lotTenderId varchar(100) = ''
	DECLARE @contatore INT = 0
	DECLARE @idRow INT = 0
	DECLARE @idRowBuffer INT = 0

	SELECT ROW_NUMBER() OVER(ORDER BY o.id ASC) AS idRow,
			ltrim( str( b.ValoreImportoLotto  , 25 , 2 ) ) as LOT_TENDER_PAYABLE_AMOUNT,
			org.TENDERING_PARTY_ID as LOT_TENDER_TENDERING_PARTY_ID,
			dbo.eFroms_GetIdentifier('LOT', strData1,'') as LOT_TENDER_TENDER_LOT_ID,
			o.Protocollo + ' - Lotto n.' + strData1 as LOT_TENDER_TENDER_REF_ID,
			'TEN-0000' AS LOT_TENDER_ID,
			strData1 as numeroLotto,
			a.idRowBuffer
		INTO #can29_lot_tender
		FROM Document_E_FORM_BUFFER A WITH(NOLOCK)
				inner join ctl_doc o with(nolock) on o.id = a.intData1 -- tipodoc OFFERTA
				inner join Document_MicroLotti_Dettagli b WITH(NOLOCK) on b.id = a.intData2 -- ( il TipoDoc è 'PDA_OFFERTE' )
				inner join Document_E_FORM_ORGANIZATION org with(nolock) on org.operationGuid = a.[guid] and Ruolo_Impresa = 'mandataria' and org.idOfferta = o.Id
		WHERE a.[guid] = @guidOperation and infoType = 'OFF_WINNER' -- dati popolati dalla stored [E_FORMS_CAN29_OE_PARTECIPANTI]

	DECLARE cursTen CURSOR FAST_FORWARD FOR
		SELECT idRow, idRowBuffer FROM #can29_lot_tender order by numeroLotto

	OPEN cursTen 
	FETCH NEXT FROM cursTen INTO @idRow, @idRowBuffer

	WHILE @@FETCH_STATUS = 0   
	BEGIN  

		set @contatore = @contatore + 1

		set @lotTenderId = 'TEN-' + RIGHT('0000' + CAST( @contatore AS NVARCHAR(4)), 4)

		update #can29_lot_tender
				set LOT_TENDER_ID = @lotTenderId
			where idRow = @idRow

		-- conserviamo nel buffer il lot tender id per poterlo utilizzare nel contratto
		update Document_E_FORM_BUFFER 
				set strData3 = @lotTenderId
			where idRowBuffer = @idRowBuffer

		FETCH NEXT FROM cursTen INTO @idRow, @idRowBuffer

	END  

	CLOSE cursTen   
	DEALLOCATE cursTen

	SELECT LOT_TENDER_ID,
			LOT_TENDER_PAYABLE_AMOUNT,
			LOT_TENDER_TENDERING_PARTY_ID,
			LOT_TENDER_TENDER_LOT_ID,
			LOT_TENDER_TENDER_REF_ID
		FROM #can29_lot_tender
		order by numeroLotto

END
GO
