USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_ISTANZA_CREATE_FROM_TEMPLATE_GARA]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[OLD_ISTANZA_CREATE_FROM_TEMPLATE_GARA] (@idOrigin AS INT, @idPfu AS INT = - 20, @newId AS INT OUTPUT)
AS
BEGIN
  --Versione=1&data=2014-09-22&Attivita=63141&Nominativo=Federico
  --BEGIN TRAN
  SET NOCOUNT ON

  DECLARE @output AS NVARCHAR(max)
  DECLARE @tabella AS VARCHAR(1000)
  DECLARE @model AS VARCHAR(1000)
  DECLARE @fascicolo AS VARCHAR(1000)
  DECLARE @linkedDoc AS INT
  DECLARE @prevDoc AS INT
  DECLARE @richiestaFirma AS VARCHAR(100)
  DECLARE @sign_lock AS INT
  DECLARE @sign_attach AS VARCHAR(400)
  DECLARE @protocolloRiferimento AS VARCHAR(1000)
  DECLARE @strutturaAziendale AS VARCHAR(4000)
  DECLARE @body AS NVARCHAR(max)
  DECLARE @azienda AS VARCHAR(100)
  DECLARE @DataScadenza AS DATETIME
  DECLARE @Destinatario_Azi AS INT
  DECLARE @Destinatario_User AS INT
  DECLARE @jumpCheck AS VARCHAR(1000)
  DECLARE @Modello VARCHAR(500)
  DECLARE @ModelloTec VARCHAR(500)
  DECLARE @Tipodoc VARCHAR(500)
  DECLARE @excel VARCHAR(500)
  DECLARE @CodiceModello VARCHAR(500)
  DECLARE @MOD_OffertaInd VARCHAR(500)
  DECLARE @MOD_OffertaINPUT VARCHAR(500)
  DECLARE @Divisione_lotti VARCHAR(1)

  SELECT @fascicolo = Fascicolo
    , @linkedDoc = LinkedDoc
    , @prevDoc = 0
    , @richiestaFirma = RichiestaFirma
    , @sign_lock = ''
    , @sign_attach = ''
    , @protocolloRiferimento = protocolloRiferimento
    , @strutturaAziendale = strutturaAziendale
    , @body = Body
    , @azienda = Azienda
    , @DataScadenza = DataScadenza
    , @Destinatario_Azi = Destinatario_Azi
    , @Destinatario_User = Destinatario_User
    , @jumpCheck = JumpCheck
    , @CodiceModello = TipoBando
    , @Divisione_lotti = Divisione_lotti
  FROM OFFERTA_TESTATA_FROM_TEMPLATE_GARA
  WHERE id_from = @idOrigin
    AND idpfu = @idpfu

  --nel caso della creazione della domnda chiamo una stored specifica
  IF EXISTS (
      SELECT *
      FROM document_bando
      WHERE idheader = @idOrigin
        AND ProceduraGara = '15477'
        AND TipoBandoGara = '2'
      )
  BEGIN
    EXEC DOMANDA_PARTECIPAZIONE_CREATE_FROM_BANDO_GARA @idOrigin, @idPfu, @newId OUTPUT
  END
  ELSE
  BEGIN
    INSERT INTO CTL_DOC (
      idpfu
      , TipoDoc
      , StatoDoc
      , Data
      , Protocollo
      , PrevDoc
      , Deleted
      , fascicolo
      , linkedDoc
      , richiestaFirma
      , sign_lock
      , sign_attach
      , protocolloRiferimento
      , strutturaAziendale
      , Body
      , Azienda
      , DataScadenza
      , Destinatario_Azi
      , Destinatario_User
      , JumpCheck
      , idPfuInCharge
      , Titolo
      )
    SELECT @idPfu
      , 'OFFERTA'
      , 'Saved' AS StatoDoc
      , getdate() AS Data
      , '' AS Protocollo
      , 0 AS PrevDoc
      , 0 AS Deleted
      , @fascicolo
      , @linkedDoc
      , @richiestaFirma
      , @sign_lock
      , @sign_attach
      , @protocolloRiferimento
      , @strutturaAziendale
      , @body
      , @azienda
      , @DataScadenza
      , @Destinatario_Azi
      , @Destinatario_User
      , @jumpCheck
      , @idPfu
      , 'Senza Titolo'

    IF @@ERROR <> 0
    BEGIN
      RAISERROR ('Errore creazione record in ctl_doc.  ', 16, 1) --, CAST(@@ERROR AS NVARCHAR(4000)))
      --rollback tran
      RETURN 99
    END

    SET @newId = SCOPE_IDENTITY() --@@identity
    SET @tabella = 'OFFERTA_TESTATA_PRODOTTI_FROM_BANDO_GARA'
    SET @model = 'OFFERTA_TESTATA_PRODOTTI_SAVE'

    EXEC GENERATE_INSERT_VERTICAL_FROM_VIEW_AND_MODEL @tabella
      , @model
      , @newId
      , @idOrigin
      , 'TESTATA_PRODOTTI'
      , ''
      , @idPfu
      , @output OUTPUT

    EXEC (@output)

    -- sezione DOCUMENTAZIONE	
    INSERT INTO CTL_DOC_ALLEGATI (
      descrizione
      , allegato
      , obbligatorio
      , anagDoc
      , idHeader
      , TipoFile
      , RichiediFirma
      , NotEditable
      )
    SELECT descrizione
      , allegato
      , obbligatorio
      , anagDoc
      , @newId AS idHeader
      , TipoFile
      , RichiediFirma
      , NotEditable
    FROM OFFERTA_ALLEGATI_FROM_BANDO_GARA
    WHERE id_from = @idOrigin
    ORDER BY idrow

    -----------------------------------------------------------------------------------
    -- precarico i modelli da usare con le sezioni
    -----------------------------------------------------------------------------------
    SET @Modello = 'MODELLI_LOTTI_' + @CodiceModello + '_MOD_Offerta'
    SET @ModelloTec = 'MODELLI_LOTTI_' + @CodiceModello + '_MOD_OffertaTec'
    SET @MOD_OffertaINPUT = 'MODELLI_LOTTI_' + @CodiceModello + '_MOD_OffertaINPUT'

    --Nella busta di compilazione dei prodotti è stato associato il modello coerente con la tipologia di gara
    --Quando una gara prevede la busta tecnica il modello per la compilazione è l'unione della busta tecnica ed economica altrimenti solo la parte economica
    -- si estende verificando 
    --if exists (Select * from Document_Bando where idheader=@linkedDoc and ( CriterioAggiudicazioneGara='15532' or Conformita <> 'no') )
    IF EXISTS (
        SELECT b.id
        FROM ctl_doc b -- BANDO
        INNER JOIN document_bando ba WITH (NOLOCK) ON ba.idheader = b.id
        INNER JOIN document_microlotti_dettagli lb WITH (NOLOCK) ON b.id = lb.idheader
          AND lb.tipodoc = b.Tipodoc
        LEFT OUTER JOIN Document_Microlotti_DOC_Value v1 WITH (NOLOCK) ON v1.idheader = lb.id
          AND v1.DZT_Name = 'CriterioAggiudicazioneGara'
          AND v1.DSE_ID = 'CRITERI_AGGIUDICAZIONE'
        LEFT OUTER JOIN Document_Microlotti_DOC_Value v2 WITH (NOLOCK) ON v2.idheader = lb.id
          AND v2.DZT_Name = 'Conformita'
          AND v2.DSE_ID = 'CRITERI_AGGIUDICAZIONE'
        WHERE b.id = @linkedDoc
          AND (
            isnull(v1.Value, CriterioAggiudicazioneGara) = '15532'
            OR isnull(v1.Value, CriterioAggiudicazioneGara) = '25532'
            OR isnull(v2.Value, Conformita) <> 'No'
            )
        )
    BEGIN
      INSERT INTO CTL_DOC_SECTION_MODEL (IdHeader, DSE_ID, MOD_Name)
      VALUES (@newId, 'PRODOTTI', @MOD_OffertaINPUT)
    END
    ELSE
    BEGIN
      INSERT INTO CTL_DOC_SECTION_MODEL (IdHeader, DSE_ID, MOD_Name)
      VALUES (@newId, 'PRODOTTI', @Modello)
    END

    INSERT INTO CTL_DOC_SECTION_MODEL (IdHeader, DSE_ID, MOD_Name)
    VALUES (@newId, 'BUSTA_ECONOMICA', @Modello)

    INSERT INTO CTL_DOC_SECTION_MODEL (IdHeader, DSE_ID, MOD_Name)
    VALUES (@newId, 'BUSTA_TECNICA', @ModelloTec)

    --se non supero soglia MAX_NUMROW_IMPORT_FROM_BANDO
    DECLARE @MAX_ROW_CREATE AS INT

    SELECT @MAX_ROW_CREATE = dbo.PARAMETRI('DOCUMENTO-OFFERTA', 'MAX_ROW_CREATE', 'DefaultValue', '10', - 1)

    --recupero numero righe del bando
    DECLARE @NumRowBando AS INT

    SELECT @NumRowBando = count(*)
    FROM Document_MicroLotti_Dettagli WITH (NOLOCK)
    WHERE idheader = @idOrigin
      AND TipoDoc = 'TEMPLATE_GARA'

    DECLARE @numlotti AS INT

    SET @numlotti = 0

    -- recupero il numero di Lotti GARA
    SELECT @numlotti = count(*)
    FROM dbo.Document_MicroLotti_Dettagli D
    WHERE Voce = 0
      AND idheader = @idOrigin
    GROUP BY idheader

    IF @NumRowBando <= @MAX_ROW_CREATE
      OR @Divisione_lotti = 0
      OR @numlotti = 1
    BEGIN

      DECLARE @Filter AS VARCHAR(500)
      DECLARE @DestListField AS VARCHAR(500)

      SET @Filter = ' Tipodoc=''TEMPLATE_GARA'' '
      SET @DestListField = ' ''OFFERTA'' as TipoDoc, '''' as EsitoRiga '

      EXEC INSERT_RECORD_NEW 'Document_MicroLotti_Dettagli'
        , @idOrigin
        , @newId
        , 'IdHeader'
        , ' Id,IdHeader,TipoDoc,EsitoRiga '
        , @Filter
        , ' TipoDoc, EsitoRiga '
        , @DestListField
        , ' id '
    END

    -- setto il warning sull'esito complessivo
    INSERT INTO ctl_doc_value (idheader, DSE_ID, DZT_Name, value)
    VALUES (@newId, 'TESTATA_PRODOTTI', 'EsitoRiga', 'E necessario compilare la scheda prodotti ed eseguire il comando "Verifica Informazioni"')

    --se sul bando è richiesta la terna per il subappalto inserisco le 3 righe sulla griglia del subappalto
    IF EXISTS (
        SELECT *
        FROM Document_Bando
        WHERE idHeader = @idOrigin
          AND ISNULL(Richiesta_terna_subappalto, '') = '1'
        )
    BEGIN
      INSERT INTO Document_Offerta_Partecipanti (
        IdHeader
        , TipoRiferimento
        , IdAzi
        , RagSoc
        , CodiceFiscale
        , IndirizzoLeg
        , LocalitaLeg
        , ProvinciaLeg
        )
      SELECT @newId
        , 'SUBAPPALTO'
        , ''
        , ''
        , ''
        , ''
        , ''
        , ''

      INSERT INTO Document_Offerta_Partecipanti (
        IdHeader
        , TipoRiferimento
        , IdAzi
        , RagSoc
        , CodiceFiscale
        , IndirizzoLeg
        , LocalitaLeg
        , ProvinciaLeg
        )
      SELECT @newId
        , 'SUBAPPALTO'
        , ''
        , ''
        , ''
        , ''
        , ''
        , ''

      INSERT INTO Document_Offerta_Partecipanti (
        IdHeader
        , TipoRiferimento
        , IdAzi
        , RagSoc
        , CodiceFiscale
        , IndirizzoLeg
        , LocalitaLeg
        , ProvinciaLeg
        )
      SELECT @newId
        , 'SUBAPPALTO'
        , ''
        , ''
        , ''
        , ''
        , ''
        , ''
    END

    --ALLA CREAZIONE VALORIZZO I CAMPI ESITO COMPLESSIVO
    INSERT INTO CTL_DOC_Value (
      IdHeader
      , DSE_ID
      , DZT_Name
      , Value
      )
    SELECT @newId
      , 'TESTATA_DOCUMENTAZIONE'
      , 'EsitoRiga'
      , '<img src="../images/Domain/State_Warning.gif"><br/>E'' necessario eseguire il comando "Verifica Informazioni"'

    INSERT INTO CTL_DOC_Value (
      IdHeader
      , DSE_ID
      , DZT_Name
      , Value
      )
    SELECT @newId
      , 'TESTATA_PRODOTTI'
      , 'EsitoRiga'
      , '<img src="../images/Domain/State_Err.gif"><br/>E'' necessario eseguire il comando "Verifica Informazioni"'

    -- Nel caso di rilancio competitivo viene ripresa la RTI eventualmente presente nell'offerta dei lotti fatta sull'AQ
    IF EXISTS (
        SELECT *
        FROM Document_Bando
        WHERE idHeader = @idOrigin
          AND ISNULL(TipoProceduraCaratteristica, '') = 'RilancioCompetitivo'
        )
    BEGIN
      EXEC OFFERTA_INIT_FROM_AQ @idOrigin
        , @newId
    END
  END
END
GO
