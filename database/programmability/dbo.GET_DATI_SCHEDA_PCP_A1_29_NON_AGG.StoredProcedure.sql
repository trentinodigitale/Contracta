USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[GET_DATI_SCHEDA_PCP_A1_29_NON_AGG]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  PROCEDURE [dbo].[GET_DATI_SCHEDA_PCP_A1_29_NON_AGG] 
	( @IdGara int , @Contesto varchar(100) )
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @TipoAppaltoGara INT 
	DECLARE @Divisione_lotti INT
	DECLARE @afferenteInvestimentiPNRR INT
	DECLARE @CIG varchar(50)


	SELECT 
		@TipoAppaltoGara = TipoAppaltoGara,
		@Divisione_lotti = Divisione_lotti,
		@CIG = CIG,
		@afferenteInvestimentiPNRR =
		case 
			when isnull(Appalto_PNRR,'no') = 'si' or isnull(Appalto_PNC,'no') = 'si' then 1
			else 0 
		end
			FROM DOCUMENT_BANDO WITH(NOLOCK)
			INNER JOIN CTL_DOC ON Id = idHeader
				WHERE idHeader = @idGara


	IF @contesto = 'LOTTI'
	BEGIN
		--LOTTI DELLA GARA
		SELECT 
			numeroLotto,
			case 
				when @Divisione_lotti = 0 then @CIG
				else CIG
			end as CIG,
			case
				when @TipoAppaltoGara=2 then ValoreImportoLotto
				else 0
			end as impLavori,
			case
				when @TipoAppaltoGara=3 then ValoreImportoLotto
				else 0
			end as impServizi,
			case
				when @TipoAppaltoGara=1 then ValoreImportoLotto
				else 0
			end as impForniture,
			ltrim( str(isnull(IMPORTO_ATTUAZIONE_SICUREZZA,0), 25 , 2 ) ) as impTotaleSicurezza,
			ltrim( str( isnull(pcp_UlterioriSommeNoRibasso,0) , 25 , 2 ) ) as ulterioriSommeNoRibasso,
			ltrim( str( isnull(impProgettazione ,0), 25 , 2 ) ) as impProgettazione,
			ltrim( str( isnull(pcp_SommeOpzioniRinnovi,0) , 25 , 2 ) ) as sommeOpzioniRinnovi,
			ltrim( str( isnull(pcp_SommeADisposizione,0) , 25 , 2 ) ) as sommeADisposizione ,
			ltrim( str( isnull(pcp_SommeRipetizioni,0) , 25 , 2 ) ) as sommeRipetizioni,
			--DA CAPIRE
			'0.00' as valoreSogliaAnomalia, -- ???
			--salgo da id dell lotto sull apda al doc verifica anomlia e nella doc_value il campo sogliaanomalia

			0 as numeroOfferteAmmesse,

			@afferenteInvestimentiPNRR as afferenteInvestimentiPNRR,
			
			case
				when isnull(@Divisione_lotti,'0') = '0' then 	
					case 
						when CUP <> '' then 'true'
						else 'false'
					end
				else 
					case 
						when CUP <> '' then 'true'
						else 'false'
					end
				end as acquisizioneCup,
				TIPO_FINANZIAMENTO,
				pcp_ImportoFinanziamento
				FROM Document_MicroLotti_Dettagli WITH(NOLOCK) WHERE IdHeader = @idGara and TipoDoc='BANDO_GARA' AND Voce = 0

	END

	IF @contesto = 'OFFERTE'
	BEGIN
	
		DECLARE @IdOFFE INT

		DECLARE Crypt CURSOR FOR 
			SELECT Id as IdOFFE FROM CTL_DOC WITH(NOLOCK)
				WHERE LinkedDoc = @idGara and TipoDoc='OFFERTA' and Deleted=0 
					and StatoFunzionale = 'Inviato'

		OPEN Crypt
		FETCH NEXT FROM Crypt INTO @IdOFFE

		WHILE @@FETCH_STATUS = 0
		BEGIN
			--DECIFRO LE OFFERTE
			EXEC START_OFFERTA_CHECK_PRODUCT @IdOFFE , 45208

			FETCH NEXT FROM Crypt INTO @IdOFFE
		END

		CLOSE Crypt  
		DEALLOCATE Crypt



		SELECT 
			NumeroLotto,
			case 
				when @Divisione_lotti = 0 then @CIG
				else CIG
			end as CIG,
			GUID AS idPartecipante,
			ValoreImportoLotto AS importo,
			0 AS aggiudicatario,
			'non applicabile' as ccnl
			FROM CTL_DOC OFFERTA WITH(NOLOCK)
			INNER JOIN Document_MicroLotti_Dettagli DETT WITH(NOLOCK) on IdHeader = OFFERTA.Id
				WHERE LinkedDoc = @idGara and DETT.TipoDoc='OFFERTA' and Deleted=0 AND Voce = 0
				and StatoFunzionale = 'Inviato'




		DECLARE Crypt2 CURSOR FOR 
			SELECT Id as IdOFFE FROM CTL_DOC WITH(NOLOCK)
				WHERE LinkedDoc = @idGara and TipoDoc='OFFERTA' and Deleted=0 
					and StatoFunzionale = 'Inviato'

		OPEN Crypt2
		FETCH NEXT FROM Crypt2 INTO @IdOFFE

		WHILE @@FETCH_STATUS = 0
		BEGIN
			--DECIFRO LE OFFERTE
			EXEC END_OFFERTA_CHECK_PRODUCT @IdOFFE , 45208

			FETCH NEXT FROM Crypt2 INTO @IdOFFE
		END

		CLOSE Crypt2 
		DEALLOCATE Crypt2


	END

END






GO
