USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[E_FORMS_CAN29_LOT_TENDER]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[E_FORMS_CAN29_LOT_TENDER] ( @idProc int, 
													@idPDA int, 
													@idUser int = 0, 
													@guidOperation varchar(500), 
													@numeroLotto varchar(1000) = '',
													@idDocContrConv int = 0,
													@debug int = 0,
													@uuidFles varchar(100) = '')
AS
BEGIN

	SET NOCOUNT ON

	DECLARE @lotTenderId VARCHAR(100) = ''
	DECLARE @contatore	 INT = 0
	DECLARE @idRow		 INT = 0
	DECLARE @idRowBuffer INT = 0
	DECLARE @concessione VARCHAR(10) = ''
	DECLARE @tipoScheda  VARCHAR(20) = ''

	DECLARE @REVENUE_BUYER_AMOUNT DECIMAL(18,2)
	DECLARE @REVENUE_USER_AMOUNT DECIMAL(18,2)
	DECLARE @VALUE_DESCRIPTION VARCHAR(1000)

	--Recupero l'informazione sulla concessione e tiposcheda dalla procedura
	SELECT  @concessione = isnull(B.concessione,''),
			@tipoScheda = A.pcp_tipoScheda
		FROM CTL_DOC PDA with(nolock)
				inner join Document_Bando B with(nolock) on PDA.LinkedDoc = B.idheader
				inner join Document_PCP_Appalto A with(nolock) on PDA.LinkedDoc = A.idHeader
		WHERE PDA.id = @idPDA

	SELECT ROW_NUMBER() OVER(ORDER BY o.id ASC) AS idRow,
			ltrim( str( b.ValoreImportoLotto  , 25 , 2 ) ) as LOT_TENDER_PAYABLE_AMOUNT,
			org.TENDERING_PARTY_ID as LOT_TENDER_TENDERING_PARTY_ID,
			dbo.eFroms_GetIdentifier('LOT', strData1,'') as LOT_TENDER_TENDER_LOT_ID,
			o.Protocollo + ' - Lotto n.' + strData1 as LOT_TENDER_TENDER_REF_ID,
			'TEN-0000' AS LOT_TENDER_ID,
			strData1 as numeroLotto,
			a.idRowBuffer,
			--Campi Relativi al CAN32
			isnull(b.pcp_entrateUtenza,0) as pcp_entrateUtenza,
			isnull(b.pcp_introitoAttivo,0) as pcp_introitoAttivo,
			isnull(b.pcp_metodoCalcoloProventi,'') as pcp_metodoCalcoloProventi
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

	-- Giro FLES / can38-40
	IF @uuidFles <> ''
	BEGIN

		SELECT  @REVENUE_BUYER_AMOUNT = REVENUE_BUYER_AMOUNT, 
				@REVENUE_USER_AMOUNT = REVENUE_USER_AMOUNT, 
				@VALUE_DESCRIPTION = VALUE_DESCRIPTION 
			FROM FLES_TABLE_MODIFICA_CONTRATTUALE with(nolock)
			WHERE UUID = @uuidFles

	END

	SELECT  LOT_TENDER_ID,

			--BT 720
			case when @tipoScheda <> 'P1_19' then '
					<cac:LegalMonetaryTotal>
						<cbc:PayableAmount currencyID="EUR">' + CONVERT(VARCHAR(50),LOT_TENDER_PAYABLE_AMOUNT) + '</cbc:PayableAmount>
					</cac:LegalMonetaryTotal>' 
				else '' 
			end as LOT_TENDER_NO_ENCODE_LEGAL_MONETARY_TOTAL,
			
			LOT_TENDER_PAYABLE_AMOUNT,
			LOT_TENDER_TENDERING_PARTY_ID,
			LOT_TENDER_TENDER_LOT_ID,
			LOT_TENDER_TENDER_REF_ID,

			case when @tipoScheda <> 'P1_19' then '
					<cbc:RankCode>1</cbc:RankCode>'
				else ''
			end as LOT_TENDER_NO_ENCODE_RANK_CODE,
			case when @tipoScheda <> 'P1_19' then '
					<efbc:TenderRankedIndicator>true</efbc:TenderRankedIndicator>'
				else ''
			end as LOT_TENDER_NO_ENCODE_TENDER_RANKED_INDICATOR,

			--BT 160,162,163 ( CAN "base". non dal giro dell'esecuzione, condizione and isnull(@uuidFles,'') = ''  )
			case when @tipoScheda = 'P1_19' and isnull(@uuidFles,'') = '' then '
					<efac:ConcessionRevenue>
						<efbc:RevenueBuyerAmount currencyID="EUR">' + CONVERT(VARCHAR(50),pcp_introitoAttivo) + '</efbc:RevenueBuyerAmount>
						<efbc:RevenueUserAmount currencyID="EUR">' + CONVERT(VARCHAR(50),pcp_entrateUtenza) + '</efbc:RevenueUserAmount>
						<efbc:ValueDescription languageID="ITA">' + case when pcp_metodoCalcoloProventi = '' then 'NA' else dbo.HTML_Encode(pcp_metodoCalcoloProventi) end + '</efbc:ValueDescription>
					</efac:ConcessionRevenue>'

				 when @tipoScheda = 'P1_19' and isnull(@uuidFles,'') <> '' and ( @REVENUE_BUYER_AMOUNT is not null or @REVENUE_USER_AMOUNT is not null ) then '
					<efac:ConcessionRevenue>' 
					+ case when @REVENUE_BUYER_AMOUNT is not null then '<efbc:RevenueBuyerAmount currencyID="EUR">' + ltrim( str(@REVENUE_BUYER_AMOUNT, 25 , 2 ) ) + '</efbc:RevenueBuyerAmount>' else '' end 
					+ case when @REVENUE_USER_AMOUNT is not null then '<efbc:RevenueUserAmount currencyID="EUR">' + ltrim( str(@REVENUE_USER_AMOUNT, 25 , 2 ) ) + '</efbc:RevenueUserAmount>' else '' end
					+ '
						<efbc:ValueDescription languageID="ITA">' + case when isnull(@VALUE_DESCRIPTION,'') = '' then 'NA' else dbo.HTML_Encode(@VALUE_DESCRIPTION) end + '</efbc:ValueDescription>
					</efac:ConcessionRevenue>'
				 else ''
			end as LOT_TENDER_NO_ENCODE_CONCESSION_REVENUE

		FROM #can29_lot_tender
		order by numeroLotto

END
GO
