USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[RICHIESTA_CIG_CREATE_FROM_GGAP_MODIFICA]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[RICHIESTA_CIG_CREATE_FROM_GGAP_MODIFICA] (@idDoc INT, @IdUser INT)
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @Id AS INT
	DECLARE @Idazi AS INT
	DECLARE @Errore AS NVARCHAR(2000)
	DECLARE @newId AS INT
	DECLARE @idr AS INT
	DECLARE @Bando AS INT
	DECLARE @Rup VARCHAR(50)
	DECLARE @COD_LUOGO_ISTAT VARCHAR(50)
	DECLARE @CODICE_CPV VARCHAR(50)
	DECLARE @Body NVARCHAR(max)
	DECLARE @CF_AMMINISTRAZIONE VARCHAR(20)
	DECLARE @CF_UTENTE VARCHAR(20)
	DECLARE @NumLotti INT
	DECLARE @TYPE_TO VARCHAR(200)
	DECLARE @bloccaOutput INT
	DECLARE @TipoAppaltoGara AS VARCHAR(50)
	DECLARE @versioneSimog VARCHAR(100)
	DECLARE @docVersione VARCHAR(100)
	DECLARE @statoFunzDoc VARCHAR(100)
	DECLARE @Tipo_Rup AS VARCHAR(100)

	SET @TYPE_TO = 'RICHIESTA_CIG'
	SET @bloccaOutput = 0
	SET @Errore = ''
	SET @versioneSimog = '3.4.2'

	SELECT TOP 1 @versioneSimog = DZT_ValueDef
	FROM LIB_Dictionary WITH (NOLOCK)
	WHERE DZT_Name = 'SYS_VERSIONE_SIMOG'

	---CERCO UNA RICHIESTA di modifica IN CORSO CREATA DA QUEL DOCUMENTO
	SELECT @newId = max(Id)
	    FROM CTL_DOC WITH (NOLOCK)
	    WHERE LinkedDoc = @idDoc AND Deleted = 0 AND TipoDoc IN ('RICHIESTA_CIG') AND StatoFunzionale NOT IN ('Inviato', 'Annullato', 'Invio_con_errori') AND JumpCheck = 'MODIFICA'

    -- TODO: Remove visto che non si trattano le RICHIESTA_SMART_CIG    ??
	-- SE NON C'E' UNA RICHIESTA_CIG PROVO A CERCARE UNA RICHIESTA_SMART_CIG
	IF @newId IS NULL
	BEGIN
		SELECT @newId = max(Id)
		    FROM CTL_DOC WITH (NOLOCK)
		    WHERE LinkedDoc = @idDoc AND Deleted = 0 AND TipoDoc IN ('RICHIESTA_SMART_CIG') AND StatoFunzionale NOT IN ('Inviato', 'Annullato') AND JumpCheck = 'MODIFICA'

		IF @newId IS NOT NULL
			SET @TYPE_TO = 'RICHIESTA_SMART_CIG'
	END

    -- Se non esiste il doc di modifica
	IF @newId IS NULL
	BEGIN
        -- TODO: Remove visto che non si trattano le RICHIESTA_SMART_CIG    ??
        -- Doc RICHIESTA_SMART_CIG in stato Inviato
		IF EXISTS (SELECT Id
				    FROM CTL_DOC WITH (NOLOCK)
				    WHERE LinkedDoc = @idDoc AND Deleted = 0 AND TipoDoc IN ('RICHIESTA_SMART_CIG') AND StatoFunzionale = 'Inviato')
		BEGIN
            -- TODO
			--EXEC RICHIESTA_SMART_CIG_CREATE_FROM_BANDO @idDoc, @IdUser, 1
			EXEC RICHIESTA_SMART_CIG_CREATE_FROM_GGAP @idDoc, @IdUser, 1

			SET @bloccaOutput = 1
		END
		ELSE -- Altrimenti doc RICHIESTA_CIG
		BEGIN
			SET @Bando = @idDoc

			-- Prima di creare il documento verifico i requisiti necessari:
			--  1) Deve esistere un precedente documento di richiesta cig nello stato inviato
			--  2) Trovare prodotti senza errori
			--  3) Sia stato selezionato luogo istat e cpv
			--  4) Sia stato inserito l'oggetto
			--  5) Sia presente il RUP
            --  6) Indicare l'Importo Appalto

            -- 1)
			IF NOT EXISTS (SELECT Id
					        FROM CTL_DOC WITH (NOLOCK)
					        WHERE LinkedDoc = @idDoc AND Deleted = 0 AND TipoDoc IN ('RICHIESTA_CIG') AND StatoFunzionale IN ('Inviato', 'Invio_con_errori'))
				SET @Errore = 'Per effettuare la modifica della richiesta dei CIG occorre che prima sia stata eseguita una richiesta CIG'

			IF EXISTS (SELECT Id
					    FROM CTL_DOC WITH (NOLOCK)
					    WHERE LinkedDoc = @idDoc AND Deleted = 0 AND TipoDoc IN ('RICHIESTA_CIG') AND StatoFunzionale = 'InvioInCorso')
				SET @Errore = 'Per effettuare la modifica della richiesta dei CIG occorre che la richiesta CIG abbia terminato l''invio dei dati al SIMOG'

			-- 3) Verifica luogo istat non selezionato
			IF @Errore = ''
			BEGIN
				SELECT @COD_LUOGO_ISTAT = Value
				    FROM CTL_DOC_Value WITH (NOLOCK)
				    WHERE IdHeader = @Bando AND DSE_ID = 'InfoTec_SIMOG' AND DZT_Name = 'COD_LUOGO_ISTAT'

				IF ISNULL(@COD_LUOGO_ISTAT, '') = ''
					SET @Errore = 'Per effettuare la modifica della richiesta dei CIG occorre aver indicato il Luogo ISTAT nella scheda "Informazioni Tecniche"'
			END

			-- 3) Verifica CPV non selezionata
			IF @Errore = ''
			BEGIN
				SELECT @CODICE_CPV = Value
				    FROM CTL_DOC_Value WITH (NOLOCK)
				    WHERE IdHeader = @Bando AND DSE_ID = 'InfoTec_SIMOG' AND DZT_Name = 'CODICE_CPV'

				IF ISNULL(@CODICE_CPV, '') = ''
					SET @Errore = 'Per effettuare la modifica della richiesta dei CIG Occorre aver indicato il Codice identificativo corrispondente al sistema di codifica CPV nella scheda "Informazioni Tecniche"'
			END

			-- 4) Verifica Oggetto
			IF @Errore = ''
			BEGIN
				SELECT @Body = Body
				    FROM CTL_DOC WITH (NOLOCK)
				    WHERE Id = @Bando

				IF ISNULL(@Body, '') = ''
					SET @Errore = 'Per effettuare la modifica della richiesta dei CIG Occorre aver inserito l''oggetto della gara'
			END

			-- 2) errore nei prodotti
			IF @Errore = ''
			BEGIN
				IF EXISTS (SELECT IdRow
						    FROM CTL_DOC_Value WITH (NOLOCK)
						    WHERE IdHeader = @Bando AND DSE_ID = 'TESTATA_PRODOTTI' AND DZT_Name = 'esitoRiga' AND Value LIKE '%State_ERR%')
					SET @Errore = 'Operazione non consentita in quanto sono presenti anomalie da correggere nell''Elenco Prodotti. Prima di procedere con la richiesta, dopo aver cliccato su ok...'
			END

			-- 5) Verifica rup non selezionato
			IF @Errore = ''
			BEGIN
				SELECT @Tipo_Rup = dbo.PARAMETRI('SIMOG', 'TIPO_RUP', 'DefaultValue', 'UserRUP', - 1)

				IF @Tipo_Rup = 'UserRUP'
					SELECT @Rup = Value
					    FROM CTL_DOC_Value WITH (NOLOCK)
					    WHERE IdHeader = @Bando AND DSE_ID = 'InfoTec_comune' AND DZT_Name = @Tipo_Rup
				ELSE
					SELECT @Rup = RupProponente
					    FROM Document_Bando WITH (NOLOCK)
					    WHERE idHeader = @Bando

				IF ISNULL(@Rup, '') = ''
				BEGIN
					IF @Tipo_Rup = 'UserRUP'
						SET @Errore = 'Per effettuare la richiesta dei CIG Occorre aver indicato il RUP'
					ELSE
						SET @Errore = 'Per effettuare la richiesta dei CIG Occorre aver indicato il RUP proponente'
				END
			END

            --  6) Indicare l'Importo Appalto
			IF @Errore = ''
			BEGIN
				IF EXISTS (SELECT idRow
						    FROM Document_Bando WITH (NOLOCK)
						    WHERE idHeader = @Bando AND ISNULL(ImportoBaseAsta, 0) = 0
						)
					SET @Errore = 'Per effettuare la richiesta dei CIG Occorre aver indicato l''Importo Appalto'
			END

			-- Se non sono presenti errori
			IF @Errore = ''
			BEGIN
				DECLARE @OldRichiesta INT
				DECLARE @importoBaseAsta2 FLOAT
				DECLARE @Divisione_lotti VARCHAR(20)
				DECLARE @CIG VARCHAR(50)
				DECLARE @Oggetto NVARCHAR(max)
				DECLARE @OldOggetto NVARCHAR(max)
				DECLARE @idGaraGgap NVARCHAR(20)
				DECLARE @oldStatoFunzionale VARCHAR(100)
                

				-- recupero la precedente richiesta inviata
				SELECT @OldRichiesta = Id
					   , @docVersione = ISNULL(Versione, '')
                       , @idGaraGgap = NumeroDocumento
                       , @oldStatoFunzionale = StatoFunzionale -- Se NumeroDocumento è valorizzato allora lo StatoFunzionale può essere: 'Inviato', 'Invio_con_errori'
				    FROM CTL_DOC WITH (NOLOCK)
				    WHERE LinkedDoc = @idDoc AND Deleted = 0 AND TipoDoc IN ('RICHIESTA_CIG') AND StatoFunzionale IN ('Inviato', 'Invio_con_errori')

				-- EP condiviso con FL e SF per gestire la modifica con la nuova versione se il documento precedente non era stato creato con l'ultima versione del simog.
				-- La modifica cig la continuiamo a fare con la versione precedente.
                -- 
				--  IF @docVersione <> @versioneSimog
				--  BEGIN
				--  	set @versioneSimog = @docVersione
				--  END

				-- CREO IL DOCUMENTO
				INSERT INTO CTL_DOC (IdPfu, TipoDoc, idpfuincharge, Azienda, body, LinkedDoc, JumpCheck, PrevDoc, Caption, versione
                                        , NumeroDocumento)
				    SELECT @IdUser, 'RICHIESTA_CIG', @IdUser, Azienda, body, @idDoc, 'MODIFICA', @OldRichiesta, 'Modifica - Richiesta CIG', @versioneSimog
                            , @idGaraGgap
				        FROM ctl_doc WITH (NOLOCK)
				        WHERE id = @idDoc
				
                SET @newId = SCOPE_IDENTITY()


				IF @versioneSimog < '3.4.6'
				BEGIN
					INSERT INTO CTL_DOC_SECTION_MODEL (IdHeader, DSE_ID, MOD_Name)
					    VALUES (@newid, 'GARA', 'RICHIESTA_CIG_GARA_3_4_5')

					INSERT INTO CTL_DOC_SECTION_MODEL (IdHeader, DSE_ID, MOD_Name)
					    VALUES (@newid, 'LOTTI', 'RICHIESTA_CIG_LOTTI_3_4_5')
				END

				-- Se la versione è 3.4.6 oppure 3.4.7 metto altri modelli
				IF @versioneSimog IN ('3.4.6', '3.4.7')
				BEGIN
					INSERT INTO CTL_DOC_SECTION_MODEL (IdHeader, DSE_ID, MOD_Name)
					    VALUES (@newid, 'GARA', 'RICHIESTA_CIG_GARA_3_4_6_7')

					INSERT INTO CTL_DOC_SECTION_MODEL (IdHeader, DSE_ID, MOD_Name)
					    VALUES (@newid, 'LOTTI', 'RICHIESTA_CIG_LOTTI_3_4_6_7')
				END


				-- Recupero il codice fiscale dell'ente
				SELECT @CF_AMMINISTRAZIONE = vatValore_FT
				    FROM CTL_DOC WITH (NOLOCK)
				        INNER JOIN DM_Attributi WITH (NOLOCK) ON Azienda = lnk AND idApp = 1 AND dztNome = 'codicefiscale'
                    WHERE Id = @Bando


				-- Recupero il CF del RUP
				SELECT @CF_UTENTE = pfuCodiceFiscale
				    FROM ProfiliUtente WITH (NOLOCK)
				    WHERE IdPfu = @Rup

				SELECT @Oggetto = Body
				    FROM CTL_DOC WITH (NOLOCK)
				    WHERE Id = @Bando

				SELECT @OldOggetto = Body
				    FROM CTL_DOC WITH (NOLOCK)
				    WHERE Id = @OldRichiesta

				SELECT @NumLotti = count(*)
				    FROM CTL_DOC b WITH (NOLOCK)
				        INNER JOIN Document_MicroLotti_Dettagli d WITH (NOLOCK) ON d.IdHeader = b.id AND b.TipoDoc = d.TipoDoc AND d.Voce = 0
				    WHERE b.Id = @Bando

				IF ISNULL(@NumLotti, 0) = 0
					SET @NumLotti = 1

				SELECT @importoBaseAsta2 = importoBaseAsta
					   , @Divisione_lotti = Divisione_lotti
                       , @CIG = CIG
                       , @TipoAppaltoGara = CASE 
                                                WHEN TipoAppaltoGara = '1' THEN 'F'
                                                WHEN TipoAppaltoGara = '2' THEN 'L'
                                                WHEN TipoAppaltoGara = '3' THEN 'S'
                                                ELSE ''
                                            END
                       --, @importoBaseAsta2 = importoBaseAsta2
				    FROM Document_Bando WITH (NOLOCK)
				    WHERE idHeader = @Bando


				-- inserisco i dati base della gara
				INSERT INTO Document_SIMOG_GARA (
					    idHeader, indexCollaborazione, ID_STAZIONE_APPALTANTE, DENOM_STAZIONE_APPALTANTE, CF_AMMINISTRAZIONE, DENOM_AMMINISTRAZIONE, CF_UTENTE, IMPORTO_GARA
					    , TIPO_SCHEDA, MODO_REALIZZAZIONE, NUMERO_LOTTI, ESCLUSO_AVCPASS, URGENZA_DL133, CATEGORIE_MERC, ID_SCELTA_CONTRAENTE, EsitoControlli, id_gara
                        , idpfuRup, MOTIVAZIONE_CIG, STRUMENTO_SVOLGIMENTO, ESTREMA_URGENZA, MODO_INDIZIONE, ALLEGATO_IX, DURATA_ACCQUADRO_CONVENZIONE, CIG_ACC_QUADRO
					    , DATA_PERFEZIONAMENTO_BANDO, AzioneProposta, StatoRichiestaGARA, LINK_AFFIDAMENTO_DIRETTO )
				    SELECT @newId AS idHeader
				    	   , indexCollaborazione
				    	   , ID_STAZIONE_APPALTANTE
				    	   , DENOM_STAZIONE_APPALTANTE
				    	   , CF_AMMINISTRAZIONE
				    	   , DENOM_AMMINISTRAZIONE
				    	   , CF_UTENTE
				    	   , @importoBaseAsta2 AS IMPORTO_GARA
				    	   , TIPO_SCHEDA
				    	   , MODO_REALIZZAZIONE
				    	   , @NumLotti AS NUMERO_LOTTI
				    	   , ESCLUSO_AVCPASS
				    	   , URGENZA_DL133
				    	   , CATEGORIE_MERC
				    	   , ID_SCELTA_CONTRAENTE
				    	   , EsitoControlli
				    	   , id_gara
				    	   , idpfuRup
				    	   , MOTIVAZIONE_CIG
				    	   , STRUMENTO_SVOLGIMENTO
				    	   , ESTREMA_URGENZA
				    	   , MODO_INDIZIONE
				    	   , ALLEGATO_IX
				    	   , DURATA_ACCQUADRO_CONVENZIONE
				    	   , CIG_ACC_QUADRO
				    	   , DATA_PERFEZIONAMENTO_BANDO
				    	   , CASE 
				    	   	    WHEN @OldOggetto <> @Oggetto OR dbo.AFS_ROUND(@importoBaseAsta2, 2) <> dbo.AFS_ROUND(IMPORTO_GARA, 2) OR @NumLotti <> NUMERO_LOTTI
				    	   	    	THEN 'Update'
				    	   	    ELSE 'Equal'
				    	   	 END AS AzioneProposta
				    	   , -- Quando AzioneProposta è 'Insert' oppure 'Update' allora lo StatoRichiestaGARA sarà 'InvioInCorso' altrimenti lo stato precedente
                             CASE 
				    	   	    WHEN @OldOggetto <> @Oggetto OR dbo.AFS_ROUND(@importoBaseAsta2, 2) <> dbo.AFS_ROUND(IMPORTO_GARA, 2) OR @NumLotti <> NUMERO_LOTTI
				    	   	    	THEN 'InvioInCorso'
				    	   	    ELSE StatoRichiestaGARA
				    	   	 END AS StatoRichiestaGARA
				    	   --, StatoRichiestaGARA
				    	   , LINK_AFFIDAMENTO_DIRETTO
				    FROM Document_SIMOG_GARA WITH (NOLOCK)
				    WHERE idHeader = @OldRichiesta


                -- Se nel/nei record(s) appena inseriti nella Document_SIMOG_GARA il campo AzioneProposta contiene 'Update' oppure 'Insert' allora
                --  bisogna inserire record(s) nella Service_SIMOG_Requests
                INSERT INTO Service_SIMOG_Requests (idRichiesta, statoRichiesta, idPfuRup, operazioneRichiesta)
                    SELECT G.idrow, 'Inserita', G.idpfuRup
                           , CASE 
		                        WHEN G.AzioneProposta = 'Update' THEN 'garaModificaGgap'
		                        WHEN G.AzioneProposta = 'Insert' THEN 'garaInserisciGgap'
		                     END
                        FROM Document_SIMOG_GARA G
                                LEFT JOIN Service_SIMOG_Requests R WITH (NOLOCK)
                                            ON G.idRow = R.idRichiesta AND R.operazioneRichiesta IN ('garaModificaGgap', 'garaInserisciGgap') AND R.isOld = 0
                                INNER JOIN CTL_DOC D WITH (NOLOCK) ON D.id = idheader
                        WHERE G.idHeader = @newId
                                AND G.AzioneProposta IN ('Update', 'Insert')
                                AND R.idRow IS NULL
                        	    AND (
                        	    	    ( isnull(D.jumpcheck, '') = 'MODIFICA' AND isnull(G.AzioneProposta, '') <> 'Equal' )
                        	    	    OR
                                        ( isnull(D.jumpcheck, '') <> 'MODIFICA' AND isnull(G.id_gara, '') = '' )
                        	    )

                -- Se ho inserito almeno un record nella Service_SIMOG_Requests significa che ci sono dati modificati (o nuovi) per la gara
	            DECLARE @countGara AS INT = -1
                SELECT @countGara = COUNT(*)
                    FROM Service_SIMOG_Requests R WITH(NOLOCK)
                        INNER JOIN Document_SIMOG_GARA G WITH (NOLOCK) ON R.idRichiesta = G.idRow
                    WHERE G.idHeader = @newId AND G.AzioneProposta IN ('Update', 'Insert')


				-- inserisco i dati dei lotti
				INSERT INTO Document_SIMOG_LOTTI (
				    	idHeader, NumeroLotto, OGGETTO, SOMMA_URGENZA, IMPORTO_LOTTO, IMPORTO_SA, IMPORTO_IMPRESA, CPV, ID_SCELTA_CONTRAENTE, ID_CATEGORIA_PREVALENTE
				    	, TIPO_CONTRATTO, FLAG_ESCLUSO, LUOGO_ISTAT, IMPORTO_ATTUAZIONE_SICUREZZA, FLAG_PREVEDE_RIP, FLAG_RIPETIZIONE, FLAG_CUP, CATEGORIA_SIMOG
                        , EsitoControlli, CIG, AzioneProposta, StatoRichiestaLOTTO, MODALITA_ACQUISIZIONE, TIPOLOGIA_LAVORO, ID_ESCLUSIONE, Condizioni, ID_AFF_RISERVATI
                        , FLAG_REGIME, ART_REGIME, FLAG_DL50, PRIMA_ANNUALITA, ANNUALE_CUI_MININF, ID_MOTIVO_COLL_CIG, CIG_ORIGINE_RIP, IMPORTO_OPZIONI, SYNC_LUOGO_NUTS
                        , SYNC_LUOGO_ISTAT, DURATA_ACCQUADRO_CONVENZIONE, DURATA_RINNOVI, CUP, FLAG_PNRR_PNC, ID_MOTIVO_DEROGA, FLAG_MISURE_PREMIALI, ID_MISURA_PREMIALE
                        , FLAG_PREVISIONE_QUOTA, QUOTA_FEMMINILE, QUOTA_GIOVANILE, FLAG_DEROGA_ADESIONE, FLAG_USO_METODI_EDILIZIA, DEROGA_QUALIFICAZIONE_SA
                        , idLottoEsterno)
				    SELECT @newId AS idHeader
				    	   , d.NumeroLotto
				    	   , Descrizione AS OGGETTO
				    	   , SOMMA_URGENZA
				    	   --, d.ValoreImportoLotto    AS IMPORTO_LOTTO, 
				    	   , d.ValoreImportoLotto + ISNULL(d.IMPORTO_ATTUAZIONE_SICUREZZA, 0) + ISNULL(d.IMPORTO_OPZIONI, 0) AS IMPORTO_LOTTO
				    	   , ISNULL(IMPORTO_SA, 0) AS IMPORTO_SA
				    	   , ISNULL(IMPORTO_IMPRESA, 0) AS IMPORTO_IMPRESA
				    	   , ISNULL(l.CPV, @CODICE_CPV) AS CPV
				    	   , ID_SCELTA_CONTRAENTE
				    	   , ID_CATEGORIA_PREVALENTE
				    	   , CASE 
				    	   	    WHEN ISNULL(TIPO_CONTRATTO, '') = '' THEN @TipoAppaltoGara
				    	        ELSE TIPO_CONTRATTO
				    	     END
				    	   , FLAG_ESCLUSO
				    	   , ISNULL(LUOGO_ISTAT, @COD_LUOGO_ISTAT) AS LUOGO_ISTAT
				    	   , d.IMPORTO_ATTUAZIONE_SICUREZZA
				    	   , FLAG_PREVEDE_RIP
				    	   , FLAG_RIPETIZIONE
				    	   , FLAG_CUP
				    	   , CATEGORIA_SIMOG
				    	   , EsitoControlli
				    	   , CASE 
				    	   	    WHEN @Divisione_lotti = 0 THEN @CIG
				    	   	    ELSE d.CIG
				    	     END AS CIG
				    	   , CASE
				    	   	    --WHEN ISNULL(CASE
				    	   	    --			    WHEN @Divisione_lotti = 0 THEN @CIG
				    	   	    --			    ELSE d.CIG
				    	   	    --			END, '') = ''
                                --     THEN 'Insert'
                                WHEN d.Id IS NOT NULL AND l.idRow IS NULL
                                    THEN 'Insert'
				    	   	    WHEN d.Descrizione <> l.OGGETTO
				    	   	    	    OR dbo.AFS_ROUND(d.ValoreImportoLotto, 2) <>
                                                   ( dbo.AFS_ROUND(l.IMPORTO_LOTTO, 2) - ISNULL(l.IMPORTO_OPZIONI, 0) - ISNULL(l.IMPORTO_ATTUAZIONE_SICUREZZA, 0) )
				    	   	    	    --OR @CODICE_CPV <> l.CPV
				    	   	    	    --OR @COD_LUOGO_ISTAT <> l.LUOGO_ISTAT
				    	   	    	    OR dbo.AFS_ROUND(d.IMPORTO_OPZIONI, 2) <> dbo.AFS_ROUND(l.IMPORTO_OPZIONI, 2)
				    	   	    	    OR dbo.AFS_ROUND(d.IMPORTO_ATTUAZIONE_SICUREZZA, 2) <> dbo.AFS_ROUND(l.IMPORTO_ATTUAZIONE_SICUREZZA, 2)
				    	   	    	    --obbligo la variazione se è cambiata la versione del simog
				    	   	    	    OR @versioneSimog <> @docVersione
				    	   	    	THEN 'Update'
				    	   	    ELSE 'Equal'
				    	     END AS AzioneProposta
				    	   , -- Quando AzioneProposta è 'Insert' oppure 'Update' allora lo StatoRichiestaLOTTO sarà 'InvioInCorso' altrimenti lo stato precedente
                             CASE
                                WHEN d.Id IS NOT NULL AND l.idRow IS NULL
                                    THEN 'InvioInCorso'
				    	   	    WHEN d.Descrizione <> l.OGGETTO
				    	   	    	    OR dbo.AFS_ROUND(d.ValoreImportoLotto, 2) <>
                                                   ( dbo.AFS_ROUND(l.IMPORTO_LOTTO, 2) - ISNULL(l.IMPORTO_OPZIONI, 0) - ISNULL(l.IMPORTO_ATTUAZIONE_SICUREZZA, 0) )
				    	   	    	    --OR @CODICE_CPV <> l.CPV
				    	   	    	    --OR @COD_LUOGO_ISTAT <> l.LUOGO_ISTAT
				    	   	    	    OR dbo.AFS_ROUND(d.IMPORTO_OPZIONI, 2) <> dbo.AFS_ROUND(l.IMPORTO_OPZIONI, 2)
				    	   	    	    OR dbo.AFS_ROUND(d.IMPORTO_ATTUAZIONE_SICUREZZA, 2) <> dbo.AFS_ROUND(l.IMPORTO_ATTUAZIONE_SICUREZZA, 2)
				    	   	    	    --obbligo la variazione se è cambiata la versione del simog
				    	   	    	    OR @versioneSimog <> @docVersione
				    	   	    	THEN 'InvioInCorso'
				    	   	    ELSE StatoRichiestaLOTTO
				    	     END AS StatoRichiestaLOTTO
				    	   --, StatoRichiestaLOTTO
				    	   , CASE
				    	   	    WHEN ISNULL(MODALITA_ACQUISIZIONE, '') = '' THEN '1'
				    	        ELSE MODALITA_ACQUISIZIONE
				    	     END
				    	   , TIPOLOGIA_LAVORO
				    	   , ID_ESCLUSIONE
				    	   , Condizioni
				    	   , ID_AFF_RISERVATI
				    	   , FLAG_REGIME
				    	   , ART_REGIME
				    	   , FLAG_DL50
				    	   , PRIMA_ANNUALITA
				    	   , ANNUALE_CUI_MININF
				    	   , ID_MOTIVO_COLL_CIG
				    	   , CIG_ORIGINE_RIP
				    	   , d.IMPORTO_OPZIONI
				    	   , SYNC_LUOGO_NUTS
				    	   , SYNC_LUOGO_ISTAT
				    	   , DURATA_ACCQUADRO_CONVENZIONE
				    	   , DURATA_RINNOVI
				    	   , l.CUP

				    	   --non li devo riprendere dalla gara perchè sulla richiesta cig vengono potenzialmente specializzati per lotto
				    	   , l.FLAG_PNRR_PNC
				    	   , l.ID_MOTIVO_DEROGA
				    	   , l.FLAG_MISURE_PREMIALI
				    	   , l.ID_MISURA_PREMIALE
				    	   , l.FLAG_PREVISIONE_QUOTA
				    	   , l.QUOTA_FEMMINILE
				    	   , l.QUOTA_GIOVANILE
				    	   , l.FLAG_DEROGA_ADESIONE
				    	   , l.FLAG_USO_METODI_EDILIZIA
				    	   , l.DEROGA_QUALIFICAZIONE_SA
                           , l.idLottoEsterno
				    FROM CTL_DOC b WITH (NOLOCK)
				            --INNER JOIN Document_Bando db with(nolock) on db.idHeader = b.Id
				            INNER JOIN Document_MicroLotti_Dettagli d WITH (NOLOCK) ON d.IdHeader = b.id AND b.TipoDoc = d.TipoDoc AND d.Voce = 0
				            LEFT JOIN Document_SIMOG_LOTTI l WITH (NOLOCK)
                                        ON l.idHeader = @OldRichiesta
                                            AND (   ( -- i dati della richiesta precedente vanno accoppiato per CIG
				    		                        	d.CIG <> '' AND l.CIG = CASE 
                                                                                    WHEN @Divisione_lotti = 0 THEN @CIG
                                                                                    ELSE d.CIG
				    		                        		                    END
				    		                        )
				    		                        OR ( -- in assenza di CIG si accoppia per numero lotto
				    		                        	d.CIG = '' AND l.CIG = '' AND l.NumeroLotto = d.NumeroLotto
				    		                        )
				    		                        OR ( --  per le monolotto sulla microlotti dettagli del pregara non andiamo a riportare il cig
				    		                             --  quindi lo confronto con quello riportato in testata del pregara
				    		                        	ISNULL(d.CIG, '') = '' AND l.CIG = @CIG AND @Divisione_lotti = 0
				    		                        )
				    		                    )
				    WHERE b.Id = @Bando
				    ORDER BY d.Id

                
                -- Se nel/nei record(s) appena inseriti nella Document_SIMOG_LOTTI il campo AzioneProposta contiene 'Update' oppure 'Insert' allora
                --  bisogna inserire record(s) nella Service_SIMOG_Requests
	            INSERT INTO Service_SIMOG_Requests (idRichiesta, statoRichiesta, idPfuRup, operazioneRichiesta)
                    SELECT L.idrow, 'Inserita', G.idpfuRup
                           , CASE 
		                        WHEN L.AzioneProposta = 'Update' THEN 'lottoModificaGgap'
		                        WHEN L.AzioneProposta = 'Insert' THEN 'lottoInserisciGgap'
		                     END
                        FROM Document_SIMOG_LOTTI L WITH (NOLOCK)
                                LEFT JOIN Service_SIMOG_Requests R WITH (NOLOCK)
                                            ON R.idRichiesta = L.idRow AND R.operazioneRichiesta IN ('lottoModificaGgap', 'lottoInserisciGgap') AND R.isOld = 0
                                INNER JOIN CTL_DOC D WITH (NOLOCK) ON D.id = idheader
                                INNER JOIN Document_SIMOG_GARA G WITH (NOLOCK) ON G.idHeader = D.Id
                        WHERE L.idHeader = @newId
                                AND L.AzioneProposta IN ('Update', 'Insert')
                        	    AND R.idRow IS NULL
                        	    AND (
                        		        ( D.jumpcheck = 'MODIFICA' AND isnull(L.AzioneProposta, '') <> 'Equal' )
                        		        OR
                                        ( isnull(D.jumpcheck, '') <> 'MODIFICA' AND isnull(L.CIG, '') = '' )
                        		)
                        ORDER BY L.idRow ASC -- inseriamo le richieste nello stesso ordine del documento 

                        
                -- Se ho inserito almeno un record nella Service_SIMOG_Requests significa che ci sono dati modificati o nuovi per i lotti.
	            DECLARE @countLotti AS INT = -1
                SELECT @countLotti = COUNT(*)
                    FROM Service_SIMOG_Requests R WITH(NOLOCK)
                        INNER JOIN Document_SIMOG_LOTTI L WITH (NOLOCK) ON R.idRichiesta = L.idRow
                    WHERE L.idHeader = @newId AND L.AzioneProposta IN ('Update', 'Insert')


				-- per il monolotto mi devo prendere il CIG dalla testata
				--  if @Divisione_lotti = 0
				--  	update Document_SIMOG_LOTTI set CIG =  @CIG where idHeader = @newId


				-- Le gare senza lotti non hanno i cig sulle righe quindi non è necessario aggiungere lotti cancellati
				IF @Divisione_lotti <> 0
				BEGIN
					-- Si aggiungono eventuali CIG precedentemente richiesti e non più presenti nella gara
					INSERT INTO Document_SIMOG_LOTTI (
						idHeader, NumeroLotto, OGGETTO, SOMMA_URGENZA, IMPORTO_LOTTO, IMPORTO_SA, IMPORTO_IMPRESA, CPV, ID_SCELTA_CONTRAENTE, ID_CATEGORIA_PREVALENTE
						, TIPO_CONTRATTO, FLAG_ESCLUSO, LUOGO_ISTAT, IMPORTO_ATTUAZIONE_SICUREZZA, FLAG_PREVEDE_RIP, FLAG_RIPETIZIONE, FLAG_CUP, CATEGORIA_SIMOG
						, EsitoControlli, StatoRichiestaLOTTO, CIG, AzioneProposta, MODALITA_ACQUISIZIONE, TIPOLOGIA_LAVORO, ID_ESCLUSIONE, Condizioni, ID_AFF_RISERVATI
						, FLAG_REGIME, ART_REGIME, FLAG_DL50, PRIMA_ANNUALITA, ANNUALE_CUI_MININF, ID_MOTIVO_COLL_CIG, CIG_ORIGINE_RIP, IMPORTO_OPZIONI, CUP
						, FLAG_DEROGA_ADESIONE, FLAG_USO_METODI_EDILIZIA, DEROGA_QUALIFICAZIONE_SA )
					SELECT @newId AS idHeader
						   , '' AS NumeroLotto
						   , OGGETTO
						   , SOMMA_URGENZA
						   , IMPORTO_LOTTO -- recuperato dopo con query dinamica il campo cambia in funzione del modello
						   , IMPORTO_SA
						   , IMPORTO_IMPRESA
						   , CPV
						   , ID_SCELTA_CONTRAENTE
						   , ID_CATEGORIA_PREVALENTE
						   , CASE 
						   	    WHEN ISNULL(TIPO_CONTRATTO, '') = '' THEN @TipoAppaltoGara
						   	    ELSE TIPO_CONTRATTO
						   	 END
						   , FLAG_ESCLUSO
						   , LUOGO_ISTAT
						   , l.IMPORTO_ATTUAZIONE_SICUREZZA
						   , FLAG_PREVEDE_RIP
						   , FLAG_RIPETIZIONE
						   , FLAG_CUP
						   , CATEGORIA_SIMOG
						   , EsitoControlli
						   , StatoRichiestaLOTTO
						   , l.CIG
						   , 'Delete' AS AzioneProposta
						   , CASE 
						        WHEN ISNULL(MODALITA_ACQUISIZIONE, '') = '' THEN '1'
						        ELSE MODALITA_ACQUISIZIONE
						   	 END
						   , TIPOLOGIA_LAVORO
						   , ID_ESCLUSIONE
						   , Condizioni
						   , ID_AFF_RISERVATI
						   , FLAG_REGIME
						   , ART_REGIME
						   , FLAG_DL50
						   , PRIMA_ANNUALITA
						   , ANNUALE_CUI_MININF
						   , ID_MOTIVO_COLL_CIG
						   , CIG_ORIGINE_RIP
						   , l.IMPORTO_OPZIONI
						   , l.CUP
						   , l.FLAG_DEROGA_ADESIONE
						   , l.FLAG_USO_METODI_EDILIZIA
						   , l.DEROGA_QUALIFICAZIONE_SA
					FROM Document_SIMOG_LOTTI l WITH (NOLOCK)
					        INNER JOIN CTL_DOC b WITH (NOLOCK) ON b.Id = @Bando
					        LEFT JOIN Document_MicroLotti_Dettagli d WITH (NOLOCK) ON d.IdHeader = b.id AND b.TipoDoc = d.TipoDoc AND d.Voce = 0 AND d.CIG = l.CIG
					WHERE l.idHeader = @OldRichiesta
                            AND ISNULL(d.CIG, '') = '' -- is null
						    AND l.AzioneProposta <> 'Delete'
						    AND ISNULL(l.CIG, '') <> ''
					ORDER BY l.idRow
				END


                -- Se NON ci sono record inseriti nella Service_SIMOG_Requests significa che non c'è stato nessun cambiamento, perciò:
                IF NOT (ISNULL(@countGara,-1) > 0 OR ISNULL(@countLotti,-1) > 0 )
                BEGIN
                    -- 1) Controllo se esiste l'id che GGAP ritorna per quanto riguarda la gara
                    IF (ISNULL(@idGaraGgap,'') = '') -- Se non esiste
                    BEGIN
                        --  Annullo e Cancello logicamente la nuova RICHIESTA_CIG
                        UPDATE CTL_DOC
                            SET StatoFunzionale='Annullato', Deleted=1
                            WHERE Id = @newId AND TipoDoc='RICHIESTA_CIG' --AND JumpCheck='MODIFICA'
                    END
                    ELSE -- Se esiste
                    BEGIN
                        -- Annullo e Cancello logicamente la vecchia RICHIESTA_CIG
                        UPDATE CTL_DOC
                            SET StatoFunzionale='Annullato', Deleted=1
				            WHERE Id = @OldRichiesta AND TipoDoc = 'RICHIESTA_CIG' AND StatoFunzionale IN ('Inviato', 'Invio_con_errori')
                            
                        -- Aggiorno lo stato della nuova RICHIESTA_CIG cosicché
                        --  nella UI quando premo il comando "Richiesta CIG" riesco ad andare nella pagina di atterraggio
                        UPDATE CTL_DOC
                            SET StatoFunzionale=@oldStatoFunzionale -- Se @idGaraGgap esiste, lo StatoFunzionale può essere: 'Inviato', 'Invio_con_errori'
                            WHERE Id = @newId AND TipoDoc='RICHIESTA_CIG' --AND JumpCheck='MODIFICA'
                    END

                    ----  2) Ritorno un messaggio di errore che indica che non si può fare la modifica perchè nessun dato riguardo alla gara o al lotto è cambiato
                    --SET @Errore = 'Non è possibile eseguire la modifica della richiesta perchè i dati della gara o dei lotti non sono cambiati'

                    ----  3) Imposto @newId uguale a zero cosi viene visualizzato il messaggio di errore
                    --SET @newId = 0
                END
                ELSE -- Altrimenti se ci sono record inseriti nella Service_SIMOG_Requests
                BEGIN
                    -- Annullo e Cancello logicamente la vecchia RICHIESTA_CIG perché siccome ho record nella Service_SIMOG_Requests allora sara il servizio SimogGgap a
                    --  cambiare il valore dello StatoFunzionale nella nuova RICHIESTA_CIG
                    UPDATE CTL_DOC
                        SET StatoFunzionale='Annullato', Deleted=1
				        WHERE Id = @OldRichiesta AND TipoDoc = 'RICHIESTA_CIG' AND StatoFunzionale IN ('Inviato', 'Invio_con_errori')
                END

			END -- IF PER CHIAMARE LA STORED DI CREAZIONE RICHIESTA CIG
		END
	END
	ELSE -- Altrimenti se esiste già il documento di modifica
	BEGIN
		SELECT @docVersione = versione
			   , @statoFunzDoc = statoFunzionale
		    FROM CTL_DOC WITH (NOLOCK)
		    WHERE Id = @newid

		-- se il documento è ancora in lavorazione e rispetto alla sua creazione, la versione simog è avanzata, la rettifichiamo
		--	UPD: LA VERSIONE DEL DOCUMENTO IN LAVORAZIONE DEVE RIMANERE, NON DOBBIAMO AGGIORNARLO ALL'ULTIMA IN ESSERE
        --
		-- if @statoFunzDoc = 'InLavorazione' and @docVersione <> @versioneSimog
		-- begin
		-- 	 update ctl_doc
		-- 	 		set versione = @versioneSimog
		-- 	 	where id = @newid
        --   
		--   -- cancelliamo il modello per la versione "vecchia" così da lasciare il default
		--   delete from CTL_DOC_SECTION_MODEL where idheader = @newid and DSE_ID IN ( 'GARA', 'LOTTI' )
		-- end


		IF @statoFunzDoc = 'InLavorazione' AND @docVersione < '3.4.6' AND NOT EXISTS (SELECT IdRow
                                                                                        FROM CTL_DOC_SECTION_MODEL WITH (NOLOCK)
		                                                                                WHERE IdHeader = @newid AND DSE_ID IN ('GARA', 'LOTTI'))
		BEGIN
			INSERT INTO CTL_DOC_SECTION_MODEL (IdHeader, DSE_ID, MOD_Name)
			    VALUES (@newid, 'GARA', 'RICHIESTA_CIG_GARA_3_4_5')

			INSERT INTO CTL_DOC_SECTION_MODEL (IdHeader, DSE_ID, MOD_Name)
			    VALUES (@newid, 'LOTTI', 'RICHIESTA_CIG_LOTTI_3_4_5')
		END
	END



	IF @bloccaOutput = 0
	BEGIN
		IF ISNULL(@newId, 0) <> 0
		BEGIN
			-- rirorna l'id del doc da aprire
			SELECT @newId AS id, @TYPE_TO AS TYPE_TO
		END
		ELSE
		BEGIN
			SELECT 'Errore' AS id, @Errore AS Errore
		END
	END
END
GO
