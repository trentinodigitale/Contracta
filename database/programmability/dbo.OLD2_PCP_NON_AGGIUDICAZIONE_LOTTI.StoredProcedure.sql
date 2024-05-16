USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_PCP_NON_AGGIUDICAZIONE_LOTTI]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[OLD2_PCP_NON_AGGIUDICAZIONE_LOTTI]
	@idPfu int, --id della risorsa
	@ListaCIG varchar(max), --elenco dei cig separati da virgola
	@Contesto varchar(max),	--contesto della chiamata
	@IdDocGara int , -- id della gara
	@idDocRichiesta int = 0, --id Documento richiedente puoi non coincidere con id gara
	@TipoSoglia VARCHAR(100)
	
	----------------------------------------------------------------------------------
	--PER ORA INSERIAMO UNA RICHIESTA DI SCHEDA PER OGNI CIG
	----------------------------------------------------------------------------------
	

AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @TipoScheda VARCHAR(100)

	--SE IL PARAMETRO è ATTIVO ESEGUO L'INVIO DELLA SCHEDA 
	IF (dbo.PARAMETRI('PCP_NON_AGGIUDICAZIONE_LOTTI' ,'ATTIVA', 'DefaultValue', 'NO', -1 ) = 'YES')
	BEGIN
		
		--RECUPERO IL TIPO DELLA GARA
		SELECT @TipoScheda = pcp_TipoScheda 
			FROM Document_PCP_Appalto 
				WHERE idHeader = @IdDocGara


		--SE DEVO INVIARE UNA NAG FACCIO UNA RICHIESTA PER OGNI CIG, PER A1_29 INVIO DIRETTAMENTE
		IF @TipoSoglia = 'sotto' OR @TipoScheda = 'P7_1_2'
		BEGIN
			--CREO UNA TABELLA TEMPORANEA PER LA LISTA DEI CIG
			CREATE TABLE #CIGs (CIG varchar(max));

			INSERT INTO #CIGs (CIG)
				SELECT items as CIG
					FROM dbo.Split(@ListaCIG, ',') as result;


			DECLARE @CIGLotto varchar(max);


			DECLARE Lotti CURSOR FOR
				SELECT CIG FROM #CIGs;


			OPEN Lotti;

			FETCH NEXT FROM Lotti INTO @CIGLotto;


			WHILE @@FETCH_STATUS = 0
			BEGIN

				--controllo che non sia stata già stata inviata una nag andata a buon fine
				IF NOT EXISTS(
							SELECT idRow
								FROM Document_PCP_Appalto_Schede 
									WHERE idHeader = @IdDocGara AND IdDoc_Scheda = @idDocRichiesta AND tipoScheda = 'NAG' AND CIG = @CIGLotto  and bDeleted = 0 AND statoScheda NOT IN ('SC_N_CONF','SC_CONF_MAX_RETRY','SC_CONF_NO_ESITO','ErroreCreazione')
							)
				BEGIN						
					exec PCP_SCHEDE_INSERT_REQUEST @IdDocGara , @idPfu, 'NAG', 'CreaScheda', @idDocRichiesta, 0, @CIGLotto, @Contesto
				END

				FETCH NEXT FROM Lotti INTO @CIGLotto;
			END
	

			CLOSE Lotti;
			DEALLOCATE Lotti;


			DROP TABLE #CIGs;
		END
		ELSE --A
		BEGIN
			
			PRINT 'TODO'

			--DECLARE @idDocC INT --ID DEL CONTRATTO O DELLA CONVENZIONE

			--select 
			--	@idDocC = C.Id
			--		FROM CTL_DOC PDA
			--		--DALLA PDA RISALGO ALLA COMUNICAZIONE
			--		JOIN CTL_DOC COM ON COM.LinkedDoc = PDA.Id AND  PDA.Deleted=0 
			--		--DALLA COMUNICAZIONE TROVO CONVENZIONE O CONTRATTO
			--		JOIN CTL_DOC C ON COM.id=C.linkeddoc and COM.Deleted=0 
			--			where PDA.LinkedDoc = @IdDocGara and PDA.TipoDoc = 'PDA_MICROLOTTI' AND C.Deleted = 0 AND C.TipoDoc IN ('CONTRATTO_GARA', 'CONVENZIONE')

			----controllo che non sia stata già stata inviata una A1_29
			--IF NOT EXISTS(
			--			SELECT idRow
			--				FROM Document_PCP_Appalto_Schede 
			--					WHERE idHeader = @IdDocGara AND IdDoc_Scheda = @idDocC AND tipoScheda = 'A1_29'  and bDeleted = 0 AND statoScheda NOT IN ('SC_N_CONF','SC_CONF_MAX_RETRY','SC_CONF_NO_ESITO','ErroreCreazione')
			--			)
			--BEGIN						
			--	exec PCP_SCHEDE_INSERT_REQUEST @IdDocGara , @idPfu, 'A1_29', 'CreaScheda', @idDocC, 0, @ListaCIG, 'NON_AGG'
			--END

		END



	END --IF PARAMETRO YES
END
GO
