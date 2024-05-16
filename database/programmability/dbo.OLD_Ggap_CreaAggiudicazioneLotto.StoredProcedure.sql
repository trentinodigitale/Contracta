USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_Ggap_CreaAggiudicazioneLotto]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- @idDocPda è l'id del documento PDA_MICROLOTTI nella CTL_DOC.
-- @idMicroLotto è l'id di un record nella tabella Document_MicroLotti_Dettagli relativo al documento PDA_MICROLOTTI nella CTL_DOC: 
--      Document_MicroLotti_Dettagli.idHeader = CTL_DOC.Id
CREATE PROCEDURE [dbo].[OLD_Ggap_CreaAggiudicazioneLotto] (@idDocPda INT, @idMicroLotto INT, @operazione VARCHAR(100))
AS
BEGIN
	SET NOCOUNT ON
    
    --DECLARE @idDocPda INT = 479548
    --DECLARE @idMicroLotto INT = 344453 -- 344455 -- 344457
    --DECLARE @idMicroLotto INT = 344455
    --DECLARE @idMicroLotto INT = 344457

    DECLARE @idBando INT
    DECLARE @idRichiestaCig INT
    DECLARE @connectedUserIdUo INT
    DECLARE @pfulogin VARCHAR(100)
    DECLARE @azilog VARCHAR(100)
    DECLARE @userAlias VARCHAR(200)

    DECLARE @idLottoGgap INT
    DECLARE @isAggiudicazione BIT
    DECLARE @dataAggiudicazione DATETIME
    DECLARE @statoRiga VARCHAR(100)
    DECLARE @numeroLotto VARCHAR(50)

    -- Se non l'id della PDA_MICROLOTTI nella CTL_DOC la recupero
    IF (@idDocPda <= -1)
    BEGIN
        SELECT @idDocPda = idHeader FROM Document_MicroLotti_Dettagli WITH (NOLOCK) WHERE Id=@idMicroLotto
    END

    --SELECT @idBando=LinkedDoc FROM CTL_DOC WITH(NOLOCK) WHERE Id = @idDocPda AND TipoDoc = 'PDA_MICROLOTTI'
    --SELECT @idRichiestaCig=Id FROM CTL_DOC WITH(NOLOCK) WHERE LinkedDoc = @idBando AND TipoDoc = 'RICHIESTA_CIG'
    SELECT @idBando=PDA.LinkedDoc
           , @idRichiestaCig=RICH.Id
        FROM CTL_DOC PDA WITH(NOLOCK)
                INNER JOIN CTL_DOC RICH WITH(NOLOCK) ON PDA.LinkedDoc = RICH.LinkedDoc
        WHERE PDA.Id = @idDocPda
                AND PDA.TipoDoc = 'PDA_MICROLOTTI' AND RICH.TipoDoc = 'RICHIESTA_CIG'
                AND PDA.StatoFunzionale NOT IN ('Annullato', 'Errore', 'RicevutoErrore') AND RICH.StatoFunzionale NOT IN ('Annullato', 'Errore', 'RicevutoErrore')
                AND PDA.Deleted = 0 AND RICH.Deleted = 0
    
        --SELECT @idBando idBando, @idRichiestaCig idRichiestaCig


    -- Costruisco lo userAlias/connectedUserAlias
    SELECT @pfulogin=PU.pfulogin
           , @azilog=A.azilog
        FROM ProfiliUtente PU WITH (NOLOCK)
                INNER JOIN Aziende A WITH (NOLOCK) ON pfuidazi = idazi
        WHERE IdPfu = (SELECT idpfu FROM ctl_doc WHERE Id = @idDocPda)
    
        SET @userAlias = CAST(@pfulogin AS NVARCHAR(MAX)) + '_' + CAST(@azilog AS NVARCHAR(MAX))
        -- SET @userAlias = 'wsApp' -- SET @userAlias = 'E_CORRADO_VERSOLATO_FV000AA' -- E_SABATO_FERRARO_5_ER000AA -- TODO: rimuovere, è solo per test
        --SELECT @userAlias userAlias

        
    -- Prendo l'id dell'unità organizzativa ossia connectedUserIdUo (e l'id della sceltà contraente)
    SELECT @connectedUserIdUo = indexCollaborazione  -- l'id dell'unità organizzativa
           --, @codiceProceduraSceltaContraente = ID_SCELTA_CONTRAENTE
        FROM Document_SIMOG_GARA WITH (NOLOCK)
        WHERE idHeader=@idRichiestaCig
        
        --SELECT @connectedUserIdUo connectedUserIdUo

    
    -- Prendo il NumeroLotto
    SELECT @numeroLotto = NumeroLotto
        FROM Document_MicroLotti_Dettagli WITH (NOLOCK)
        WHERE IdHeader = @idDocPda AND Voce = 0 AND TipoDoc = 'PDA_MICROLOTTI' AND Id = @idMicroLotto

        --SELECT @numeroLotto
        

    -- Prendo l'id lotto che GGAP restituisce (la chiave tecnica del lotto per GGAP)
    SELECT @idLottoGgap = L.idLottoEsterno
        FROM CTL_DOC R WITH (NOLOCK)
                INNER JOIN Document_SIMOG_LOTTI L WITH (NOLOCK) ON R.Id = L.idHeader
        WHERE R.Id = @idRichiestaCig AND R.TipoDoc = 'RICHIESTA_CIG' AND R.Deleted = 0

        --SELECT @idLottoGgap idLottoGgap


    -- Prendo lo StatoRiga dalla Document_MicroLotti_Dettagli per NumeroLotto
    SELECT @statoRiga = MD.StatoRiga
        FROM Document_MicroLotti_Dettagli MD WITH (NOLOCK)
        WHERE MD.IdHeader = @idDocPda AND MD.Id = @idMicroLotto AND MD.Voce = 0 AND MD.TipoDoc = 'PDA_MICROLOTTI' AND MD.NumeroLotto = @numeroLotto

        --SELECT @statoRiga statoRiga
        

    ---- Prendo: id lotto GGAP; StatoRiga
    --SELECT @idLottoGgap = L.idLottoEsterno, @statoRiga = MD.StatoRiga
    ----SELECT MD.NumeroLotto, L.NumeroLotto, MD.CIG, L.CIG, L.idLottoEsterno, MD.StatoRiga, *
    --    FROM CTL_DOC PDA WITH (NOLOCK)
    --            INNER JOIN Document_MicroLotti_Dettagli MD WITH (NOLOCK) ON PDA.Id = MD.IdHeader
    --            INNER JOIN CTL_DOC R WITH (NOLOCK) ON PDA.LinkedDoc = R.LinkedDoc
    --            INNER JOIN Document_SIMOG_LOTTI L WITH (NOLOCK) ON R.Id = L.idHeader AND MD.NumeroLotto = L.NumeroLotto
    --    WHERE PDA.Id = 479548 AND MD.Id = 344453 AND R.Id = 479470
    --            AND MD.TipoDoc = 'PDA_MICROLOTTI' AND MD.Voce = 0
    --            AND MD.CIG = L.CIG
    --            AND PDA.Deleted = 0 AND R.Deleted = 0


    -- Se (@isAggiudicazione = 1) allora devo obbligatoriamente valorizzare @dataAggiudicazione il che significa
    --  che se posso mandare @dataAggiudicazione valorizzata allora posso mandare @isAggiudicazione = a true.
    -- Comunque la @dataAggiudicazione va considerata validata se lo @statoRiga ha un valore che corrisponde a lotto aggiudicata.
    IF ( ISNULL(@statoRiga,'') IN ('AggiudicazioneDef', 'Exequo') )
    BEGIN
        SET @dataAggiudicazione = (SELECT DataAperturaOfferte FROM Document_PDA_TESTATA WHERE idheader = @idDocPda)

        IF ( ISNULL(@dataAggiudicazione,'') <> '' )
            SET @isAggiudicazione = 1
    END

    
    -- Prendo i dati per la listaPartecipanti (vedi json da inviare a GGAP) che in realtà è un array ma a GGAP verra 
    --  mandato comunque solo uno elemento (array di 1 elemento)
    -- Restituisco i dati
    SELECT @userAlias               AS userAlias
           , @connectedUserIdUo     AS userIdUo
           , @idLottoGgap           AS idLotto
           , @statoRiga             AS statoRiga
           , @isAggiudicazione      AS isAggiudicazione
           , @dataAggiudicazione    AS dataAggiudicazione
           --
           --, MD.NumeroLotto
    	   , MD.ValoreOfferta
    	   , 0                      AS valoreAumento
    	   , MD.ValoreRibasso
           --
    	   , AZ.aziRagioneSociale
    	   , AZ.aziPartitaIVA
    	   --, AZ.aziStatoLeg --> Nazionalita
           , 1                      AS isAggiudicatario
           --
    	   , TD.tdrCodice        -- AS idTipoSoggetto
           --
    	   , ATT.vatValore_FT    -- AS codiceFiscale
           --
        FROM Document_MicroLotti_Dettagli MD WITH (NOLOCK)
                LEFT JOIN Aziende AZ WITH (NOLOCK) ON AZ.IdAzi = MD.Aggiudicata
                LEFT OUTER JOIN TipiDatiRange TD WITH (NOLOCK) ON TD.tdrIdTid = 131 AND TD.tdrCodice = AZ.aziIdDscFormaSoc
                LEFT OUTER JOIN DM_Attributi ATT WITH (NOLOCK) ON ATT.idApp = 1 AND ATT.dztNome = 'codicefiscale' AND ATT.lnk = AZ.IdAzi
        WHERE MD.IdHeader = @idDocPda AND MD.Voce = 0 AND MD.TipoDoc = 'PDA_MICROLOTTI' AND MD.NumeroLotto = @numeroLotto
END
GO
