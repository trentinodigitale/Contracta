USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_E_FORMS_CAN29_LOTTI_CONTRACT]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[OLD2_E_FORMS_CAN29_LOTTI_CONTRACT] ( @idPDA int , 
							@idUser int = 0, 
							@guidOperation varchar(500) = '', 
							@numeroLotto varchar(1000) = '',
							@idDocContrConv int = 0)
AS
BEGIN

	SET NOCOUNT ON

	-- la variabile in input @numeroLotto dovrebbe essere inutile perchè i dati li prendiamo dalla Document_E_FORM_BUFFER dove 
	--		se era richiesto un filtro per numero lotto è stato già applicato

	--WAITFOR DELAY '00:00:05';

	DECLARE @vbcrlf varchar(10) = '
'
	DECLARE @titoloProcedura nvarchar(1000) = ''
	DECLARE @idProc int = 0
	DECLARE @FinancingIdentifier nvarchar(2000) = ''
	DECLARE @FundingProgramCode varchar(500) = ''
	DECLARE @FundingProgramDescr nvarchar(2000) = ''

	DECLARE @idRow INT = 0
	DECLARE @statoRiga varchar(100) = ''
	DECLARE @nLotto varchar(100) = ''
	DECLARE @xmlLotTender nvarchar(4000) = ''

	DECLARE @tipoDocInnesco varchar(200) = ''
	DECLARE @bContratto int = 0
	DECLARE @regSisDoc varchar(100) = ''
	DECLARE @ContractReferenceID varchar(1000) = NULL

	select  @titoloProcedura = gara.titolo,
			@idProc = gara.Id,
			@FinancingIdentifier = i.cn16_Funding_FinancingIdentifier,
			@FundingProgramCode = i.cn16_FundingProgramCode, --campo a dominio, tipologica "eu_programme" / eu-funded
			@FundingProgramDescr = i.cn16_FundingProgram_Description
		from ctl_doc pda with(nolock)
				inner join ctl_doc gara with(nolock) on gara.id = pda.LinkedDoc
				inner join Document_E_FORM_CONTRACT_NOTICE i with(nolock) on i.idHeader = gara.id
		where pda.id = @idPDA

	if @idDocContrConv > 0
	BEGIN

		select @tipoDocInnesco = TipoDoc,
				@regSisDoc = Protocollo
			from ctl_doc with(nolock) 
			where id = @idDocContrConv

		IF @tipoDocInnesco IN ( 'CONTRATTO_GARA', 'SCRITTURA_PRIVATA' )
		BEGIN
			SET @bContratto = 1
			set @ContractReferenceID = 'Registro di sistema contratto : ' + isnull(@regSisDoc,'')
		END
		ELSE
		BEGIN
			-- convenzione
			select @ContractReferenceID = 'Numero Convenzione : ' + isnull(NumOrd,'')
				from Document_Convenzione with(nolock)
				where id = @idDocContrConv
		END

	END



	CREATE TABLE #LottiConv
	(
		NumeroLotto varchar(100) collate DATABASE_DEFAULT NULL ,
		CIG varchar(100) null,
		IdConv int null,
		DataStipulaConvenzione datetime null
	)

	IF @idDocContrConv > 0 and @tipoDocInnesco = 'CONVENZIONE'
	BEGIN

		--Se l'innesco è sulla convenzione allora filtro tutto partendo da quella
		INSERT INTO #LottiConv
			SELECT distinct LottiAgg.strData1 as NumeroLotto,DETT_CONV.CIG,CONV.Id as IdConv ,DATASTIP.DataStipulaConvenzione	
				FROM Document_E_FORM_BUFFER LottiAgg with(nolock) 
						inner join Document_MicroLotti_Dettagli DETT_CONV with(nolock) 
										on DETT_CONV.TipoDoc='CONVENZIONE' and DETT_CONV.NumeroLotto=LottiAgg.strData1 --and DETT_CONV.Voce=0
						inner join CTL_DOC CONV  with(nolock) on CONV.Id=DETT_CONV.IdHeader and CONV.TipoDoc='CONVENZIONE' and CONV.Deleted =0
						inner join Document_Convenzione DATASTIP with(nolock) on DATASTIP.ID=CONV.id 
				WHERE conv.id = @idDocContrConv and LottiAgg.[guid] = @guidOperation and infoType = 'LOTTI_CHIUSI' and strData2 = 'AggiudicazioneDef' 


	END
	ELSE
	BEGIN

		--POPOLO LA TABELLA TEMPORANEA CON LOTTI E CIG DELLE CONVENZIONI PUBBLICATE CON I LOTTI INTERESSATI A NOI DELLA NOSTRA GARA (STRDATA1)
		INSERT INTO #LottiConv
			SELECT distinct LottiAgg.strData1 as NumeroLotto,DETT_CONV.CIG,CONV.Id as IdConv ,DATASTIP.DataStipulaConvenzione
				FROM Document_E_FORM_BUFFER LottiAgg with(nolock) 
						inner join Document_MicroLotti_Dettagli DETT_CONV with(nolock) 
										on DETT_CONV.TipoDoc='CONVENZIONE' and DETT_CONV.NumeroLotto=LottiAgg.strData1 --and DETT_CONV.Voce=0
						inner join CTL_DOC CONV  with(nolock) on CONV.Id=DETT_CONV.IdHeader and CONV.TipoDoc='CONVENZIONE' and CONV.Deleted =0
											and CONV.StatoFunzionale = 'Pubblicato'
						inner join Document_Convenzione DATASTIP with(nolock) on DATASTIP.ID=CONV.id and DATASTIP.idBando = @idProc
				WHERE LottiAgg.[guid] = @guidOperation and infoType = 'LOTTI_CHIUSI' and strData2 = 'AggiudicazioneDef' 

	END


	SELECT  
			ROW_NUMBER() OVER(ORDER BY a.strData1 ASC) AS idRow,
			a.strData1 as numeroLotto,
			a.strData2 as statoRiga,
	
			dbo.eFroms_GetIdentifier('CON', strData1,'') AS NOTICE_RESULT_SETTLED_CONTRACT_ID, -- OPT-316 

			dbo.eFroms_GetStrDateOrTimeUTCfromITA( isnull(  CAST(ltVa.value AS datetime) , ed.datainvio) , 0) AS NOTICE_RESULT_SETTLED_CONTRACT_AWARD_DATE,

			--resituisce il primo non null in sequenza
			--anche retro compatibile con prec gestione
			dbo.eFroms_GetStrDateOrTimeUTCfromITA(
						coalesce( cast(DTSTIPULA.value as datetime), LottiConv.DataStipulaConvenzione,  CAST(ltVa.value AS datetime) , ed.datainvio ) 
						, 0) AS NOTICE_RESULT_SETTLED_CONTRACT_ISSUE_DATE,

			ISNULL( @ContractReferenceID, 
					'Lotto n.' +  LEFT(a.strData1,100) + ' - ' + LEFT(@titoloProcedura,100) + ' - ' + 
			
						case when a.strData3 in (  'monofornitore' , '' ) then LEFT(isnull(aziRagioneSociale,''), 100)
							 when a.strData3 not in (  'monofornitore' , '' ) then 'Aggiudicatari multipli'
							 else '' 
						end 
				) AS NOTICE_RESULT_CONTRACT_REFERENCE_ID,

			case when @FinancingIdentifier <> '' then '
			<efac:Funding>
				<!-- BT-5011 - Identificativo dei fondi UE -->
				<efbc:FinancingIdentifier>' + dbo.HTML_Encode(@FinancingIdentifier) + '</efbc:FinancingIdentifier>'
				+ case when @FundingProgramCode <> '' then '<!-- BT-722 - Programma Fondi UE --><cbc:FundingProgramCode listName="eu-funded">' + dbo.HTML_Encode(@FundingProgramCode) + '</cbc:FundingProgramCode>' else '' end + 
				+ case when @FundingProgramDescr <> '' then '<!-- BT-6110 - Dettagli Fondi UE --><cbc:Description languageID="ITA">' + dbo.HTML_Encode(@FundingProgramDescr) + '</cbc:Description>' else '' end + 
			'</efac:Funding>' else '' end as NOTICE_RESULT_NO_ENCODE_CONTRACT_FINANCINGIDENTIFIER,

			cast('' as nvarchar(4000)) as NOTICE_RESULT_NO_ENCODE_LOT_TENDER
		INTO #can29_lot_contract
		FROM Document_E_FORM_BUFFER a WITH(NOLOCK)

				-- prendiamo la comunicazione di aggiudicazione
				INNER JOIN CTL_Doc ed WITH (NOLOCK) on ed.LinkedDoc = @idPDA and ed.deleted = 0 and ed.TipoDoc = 'PDA_COMUNICAZIONE_GENERICA' AND ed.StatoDoc = 'Sended' AND ed.JumpCheck = '0-ESITO_DEFINITIVO_MICROLOTTI'

				-- restringiamo per il lotto aggiudicato ( se è monolotto è 1 ed andranno sempre in match )
				INNER JOIN Document_comunicazione_StatoLotti ced WITH (NOLOCK) ON ced.IdHeader = ed.Id and ced.deleted = 0 and ced.NumeroLotto = a.strData1

				--salgo sul contratto valido (legato alla comunicazione di esito definitivo)
				left join CTL_DOC CONTR with (nolock) on ( 
							CONTR.LinkedDoc = ed.Id  
							and CONTR.TipoDoc in ('CONTRATTO_GARA' , 'SCRITTURA_PRIVATA') and CONTR.Deleted=0
							and CONTR.StatoFunzionale not in ('Rifiutato','inlavorazione')
							and @bContratto = 0 --se bContratto è 0 vuol dire che non mi è stato passato l'id del contratto in input oppure l'idDoc collegato non è di un contratto
						)
						--se mi viene passato l'id del contratto in input allora vado su quell'id in modo netto.
						OR
						(
							@bContratto = 1
							and
							contr.Id = @idDocContrConv 
						)
						--and ( ( @bContratto = 1 and contr.Id = @idDocContrConv ) or ( @bContratto = 0 ) )

				--recupero data stipula del contratto o della scrittura privata (rdo)
				left join ctl_doc_value DTSTIPULA with (nolock) on DTSTIPULA.idheader = CONTR.Id and DTSTIPULA.DSE_ID='CONTRATTO' and DTSTIPULA.DZT_Name='DataStipula'

				--salgo sulla convenzione per il caso gara in convezione
				left join #LottiConv LottiConv on LottiConv.NumeroLotto = a.strData1 

				-- se l'aggiudicazione era condizionata, la data di agg non è l'invio della comunicazione ma andiamo a recuperare la data di conferma			
				LEFT JOIN Document_Microlotti_DOC_Value ltVa with(nolock) ON ltVa.idheader = a.idRow and ltVa.dse_id = 'INVIO_FINE_AGG_CONDIZ' and ltVa.DZT_Name = 'DataInvio' and isnull(ltVa.value,'') <> ''

				LEFT JOIN aziende az with(nolock) on az.idazi = a.intData1

		WHERE a.[guid] = @guidOperation and infoType = 'LOTTI_CHIUSI' and strData2 = 'AggiudicazioneDef'
			-- andando sulla Document_E_FORM_BUFFER non serve filtrare per numero lotto ( nel caso fosse stato richiesto dal chiamante ) perchè è già stata popolata filtrata

	DECLARE cursLotContr CURSOR FAST_FORWARD FOR
		SELECT idRow, numeroLotto, statoRiga FROM #can29_lot_contract

	OPEN cursLotContr 
	FETCH NEXT FROM cursLotContr INTO @idRow, @nLotto, @statoRiga

	WHILE @@FETCH_STATUS = 0   
	BEGIN

		set @xmlLotTender = ''

		IF @statoRiga = 'AggiudicazioneDef'
		BEGIN

			-- aggancio al contract l'identificativo dell'offerta. moltiplicità 0 ad n. 0 in caso di non aggiudicazione ed N in caso di multi aggiudicazione
			SELECT @xmlLotTender = @xmlLotTender + '
								<efac:LotTender>
									<!-- BT-3202 -->
									<cbc:ID>' + strData3 + '</cbc:ID>
								</efac:LotTender>'
				FROM Document_E_FORM_BUFFER a WITH(NOLOCK)
				where a.guid = @guidOperation and infoType = 'OFF_WINNER' and strData1 = @nLotto

			update #can29_lot_contract
					set NOTICE_RESULT_NO_ENCODE_LOT_TENDER = @xmlLotTender
				where idrow = @idRow

		END

		FETCH NEXT FROM cursLotContr INTO @idRow, @nLotto, @statoRiga

	END  

	CLOSE cursLotContr   
	DEALLOCATE cursLotContr

	SELECT DISTINCT 
			NOTICE_RESULT_SETTLED_CONTRACT_ID,
			NOTICE_RESULT_SETTLED_CONTRACT_AWARD_DATE,
			NOTICE_RESULT_SETTLED_CONTRACT_ISSUE_DATE,
			NOTICE_RESULT_CONTRACT_REFERENCE_ID,
			NOTICE_RESULT_NO_ENCODE_CONTRACT_FINANCINGIDENTIFIER,
			NOTICE_RESULT_NO_ENCODE_LOT_TENDER
		FROM #can29_lot_contract

	drop table #LottiConv
	drop table #can29_lot_contract

END
GO
