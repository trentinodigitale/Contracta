USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_E_FORMS_CAN29_LOTTI_RESULT]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[OLD_E_FORMS_CAN29_LOTTI_RESULT] ( @idPDA int , @idUser int = 0, 
														@guidOperation varchar(500) = '', 
														@numeroLotto varchar(1000) = '',
														@idDocContrConv int = 0)
AS
BEGIN

	SET NOCOUNT ON

	DECLARE @xmlLotTender nvarchar(4000) = ''
	DECLARE @idRow INT = 0
	DECLARE @statoRiga varchar(100) = ''
	DECLARE @nLotto varchar(100) = ''
	DECLARE @impAggAccQuadro varchar(100) = ''
	DECLARE @totaleImpAggAQ decimal(18,2) = 0
	declare @idRowBuffer INT = 0
	declare @concessione varchar(10) = ''
	declare @tipoScheda varchar(10)

	DECLARE @tipoDocInnesco varchar(200) = ''

	--PER NON AGGIUDICAZIONE, CONTROLLO CHE idPDA NON SIA UN idProc, SE COSì FOSSE USO QUELLO
	DECLARE @idProc int = 0

	IF EXISTS(SELECT id FROM CTL_DOC WITH(NOLOCK) WHERE TipoDoc = 'BANDO_GARA' and Id = @idPDA )
	BEGIN
		SET @idProc = @idPDA
	END

	--SE VENGO DA UN idProc RECUPERO LE INFO CON QUELLO
	IF @idProc <> 0
	BEGIN
		
		select 
			@concessione = isnull(B.concessione,''),
			@tipoScheda = pcp_TipoScheda
			from
				Document_Bando B with(nolock)
				inner join Document_PCP_Appalto A with(nolock) on B.idheader = A.idheader
			where b.idheader = @idProc

	END
	ELSE
	BEGIN
		--Recupero l'informazione sulla concessione dal bando_gara
		select 
			@concessione = isnull(B.concessione,''),
			@tipoScheda = pcp_TipoScheda
			from
				CTL_DOC PDA with(nolock)
					inner join Document_Bando B with(nolock) on PDA.linkedDoc = B.idheader
					inner join Document_PCP_Appalto A with(nolock) on PDA.LinkedDoc = A.idheader
			where PDA.id = @idPDA
	END

	CREATE TABLE #convLotti
	(
		NumeroLotto varchar(100) collate DATABASE_DEFAULT NULL ,
		ValoreRinnoviOpzioni float null,
		Importo float null
	)

	
	--SE VENGO DA UN idProc RECUPERO LE INFO DEI LOTTI CON QUELLO
	IF @idProc <> 0
	BEGIN
		INSERT INTO #convLotti
			select 
				NumeroLotto,
				pcp_ImportoFinanziamento as Importo,
				pcp_SommeOpzioniRinnovi as ValoreRinnoviOpzioni
				--,statoRiga
					from Document_microlotti_dettagli where idheader = @idProc
	END
	ELSE if @idDocContrConv > 0
	BEGIN

		SELECT @tipoDocInnesco = TipoDoc
			from ctl_doc with(nolock)
			where id = @idDocContrConv

		IF @tipoDocInnesco = 'CONVENZIONE'
		BEGIN

			INSERT INTO #convLotti
				select a.NumeroLotto, a.ValoreRinnoviOpzioni, a.Importo 
					from Document_Convenzione_Lotti a with(nolock) 
					where a.idHeader = @idDocContrConv

		END

	END


	DECLARE @vbcrlf varchar(10) = ''

	SELECT ROW_NUMBER() OVER(ORDER BY a.strData1 ASC) AS idRow,
			a.strData1 as numeroLotto,
			strData2 as statoRiga,

			dbo.eFroms_GetIdentifier('RES', strData1,'') AS LOTTO_RESULT_ID, -- OPT-322

			case when strData2 IN ( 'AggiudicazioneDef') then 'selec-w'
				 else 'clos-nw' 
				 end AS LOTTO_RESULT_TENDER_RESULT_CODE, -- BT-142

			isnull('<!-- BT-144 -  Motivo per cui un vincitore non è stato scelto - NotAwardReason - Stato Lotto -->
				<efac:DecisionReason>
					<efbc:DecisionReasonCode listName="non-award-justification">' +
				case when strData2 IN ( 'AggiudicazioneDef') then NULL
					 when strData2 IN ( 'Deserta') then 'no-rece'
					 when strData2 IN ( 'NonAggiudicabile', 'NonGiudicabile') then 'all-rej'
					 when strData2 IN ( 'Revocato', 'interrotto') then 'chan-need'
					 else NULL end --concatenando null il risultato finale sarà stringa vuota. è un blocco xml ozionale
				+ '</efbc:DecisionReasonCode>
				</efac:DecisionReason>','') as LOTTO_RESULT_NO_ENCODE_DECISION_REASON,

			case when strData2 = 'AggiudicazioneDef' then '
							<efac:SettledContract>
								<!-- OPT-315 - Contract Identifier Reference Del tipo CON-XXXX -->
								<cbc:ID>' + dbo.eFroms_GetIdentifier('CON', strData1,'') + '</cbc:ID>
							</efac:SettledContract>'
				 else '' end AS LOTTO_RESULT_NO_ENCODE_SETTLED_CONTRACT,

			dbo.eFroms_GetIdentifier('LOT', strData1,'') as LOTTO_RESULT_TENDER_LOT_ID, -- BT-13713

			-- in caso di multi aggiudicazione, quindi accordo quadro ( o di convenzione ) 
			case when impAggM.[Value] <> '' or cl.ValoreRinnoviOpzioni is not null or cl.Importo is not null and @tipoScheda <> 'P1_19'
				then '
							<efac:FrameworkAgreementValues>
							' + CASE when cl.Importo is not null then '
								<!-- BT-709 -->
								<cbc:MaximumValueAmount currencyID=&quot;EUR&quot;>' + ltrim( str( isnull(cl.Importo,0) + isnull(cl.ValoreRinnoviOpzioni,0) , 25 , 2 ) ) + '</cbc:MaximumValueAmount>' 
							    ELSE '
								<!-- BT-709 -->
								<cbc:MaximumValueAmount currencyID=&quot;EUR&quot;>' + ltrim(impAggM.[Value]) + '</cbc:MaximumValueAmount>' 
								END +

								CASE when cl.Importo is not null then '
								<!-- BT-660 -->
								<efbc:ReestimatedValueAmount currencyID=&quot;EUR&quot;>' + ltrim( str(cl.Importo, 25 , 2 ) ) + '</efbc:ReestimatedValueAmount>
								'
								ELSE
							'
								<!-- BT-660 -->
								<efbc:ReestimatedValueAmount currencyID=&quot;EUR&quot;>' + ltrim(impAggM.[Value]) + '</efbc:ReestimatedValueAmount>'
								END + 
							'
							</efac:FrameworkAgreementValues>'
				 else '' end AS LOTTO_RESULT_NO_ENCODE_MAXIMUMVALUEAMOUNT,

			cast('' as nvarchar(4000)) as LOTTO_RESULT_NO_ENCODE_LOT_TENDER,

			ltrim(impAggM.[Value]) as impAggAccordoQuadro,

			a.idRowBuffer

		INTO #tmpLotRes
		FROM Document_E_FORM_BUFFER a WITH(NOLOCK)
				--LEFT JOIN Document_MicroLotti_Dettagli b with(nolock) on b.id = a.idRow
				LEFT JOIN ctl_doc gr with (nolock)	on gr.LinkedDoc = a.idRow and gr.TipoDoc = 'PDA_GRADUATORIA_AGGIUDICAZIONE' and gr.StatoFunzionale = 'Confermato' and gr.Deleted = 0
				LEFT JOIN ctl_doc_value impAggM with(nolock) on impaggm.idheader = gr.id and impAggM.dse_id = 'IMPORTO' and impAggM.dzt_name = 'ImportoAggiudicatoInConvenzione'
				LEFT JOIN #convLotti cl on cl.NumeroLotto = a.strData1 -- join sui dati della sezione &quot;Ripartizione Valore per Lotto&quot; della convenzione
		WHERE a.[guid] = @guidOperation and a.infoType = 'LOTTI_CHIUSI'
		order by strData1 --ord per lotto

	DECLARE cursLotRes CURSOR FAST_FORWARD FOR
		SELECT idRow, numeroLotto, statoRiga, impAggAccordoQuadro, idRowBuffer FROM #tmpLotRes

	OPEN cursLotRes 
	FETCH NEXT FROM cursLotRes INTO @idRow, @nLotto, @statoRiga, @impAggAccQuadro, @idRowBuffer

	WHILE @@FETCH_STATUS = 0   
	BEGIN

		set @xmlLotTender = ''

		IF @statoRiga = 'AggiudicazioneDef'
		BEGIN

			-- aggancio al result l'identificativo dell'offerta. moltiplicità 0 ad n. 0 in caso di non aggiudicazione ed N in caso di multi aggiudicazione
			SELECT @xmlLotTender = @xmlLotTender + '
								<efac:LotTender>
									<!-- OPT-320 -->
									<cbc:ID>' + strData3 + '</cbc:ID>
								</efac:LotTender>'
				FROM Document_E_FORM_BUFFER a WITH(NOLOCK)
				where a.guid = @guidOperation and infoType = 'OFF_WINNER' and strData1 = @nLotto

			update #tmpLotRes
					set LOTTO_RESULT_NO_ENCODE_LOT_TENDER = @xmlLotTender
				where idrow = @idRow

			IF @impAggAccQuadro <> ''
			BEGIN

				declare @convImpAccAQ decimal(25,2) = @impAggAccQuadro
				
				update Document_E_FORM_BUFFER
						set decimalData1 = @convImpAccAQ
					where idRowBuffer = @idRowBuffer
				
			END

		END

		FETCH NEXT FROM cursLotRes INTO @idRow, @nLotto, @statoRiga, @impAggAccQuadro, @idRowBuffer

	END  

	CLOSE cursLotRes   
	DEALLOCATE cursLotRes

	SELECT  LOTTO_RESULT_ID,
			LOTTO_RESULT_TENDER_RESULT_CODE,
			LOTTO_RESULT_NO_ENCODE_DECISION_REASON,
			LOTTO_RESULT_NO_ENCODE_SETTLED_CONTRACT,
			LOTTO_RESULT_TENDER_LOT_ID,
			LOTTO_RESULT_NO_ENCODE_MAXIMUMVALUEAMOUNT,
			LOTTO_RESULT_NO_ENCODE_LOT_TENDER
		FROM #tmpLotRes

	DROP TABLE #convLotti
	DROP TABLE #tmpLotRes

END

GO
