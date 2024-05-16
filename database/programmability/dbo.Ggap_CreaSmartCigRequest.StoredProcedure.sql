USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[Ggap_CreaSmartCigRequest]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[Ggap_CreaSmartCigRequest] ( @idSmartCig int )
AS
BEGIN

    --DECLARE @idUnitaOrganizzativa INT = 17 --> può restare vuoto
    --DECLARE @codFattispecie NVARCHAR(MAX) = '04' --> non serve
    --DECLARE @idMotivoRichiestaCig INT = 3 --> è opzionale
    --DECLARE @idMotivoRichiestaCigComune INT = 2 --> è opzionale
    --DECLARE @listaIdCategorieMerceologiche NVARCHAR(MAX) = '1###2######3###'

    -- Sono obbligatori:
    --                  codiceRiferimentoGara  --> CTL_DOC.Protocollo, no ==> Document_SIMOG_SMART_CIG.codiceClassificazioneGara
    --                  codiceRiferimentoLotto --> CTL_DOC.Protocollo
    --                  connectedUserAlias     --> ProfiliUtente.pfulogin + '_' + Aziende.azilog
    --                  connectedUserIdUo      --> Document_SIMOG_SMART_CIG.indexCollaborazione
    --                  idSmartCig             --> CTL_DOC.NumeroDocumento
    --                  flagNoCig              --> sempre valorizzato a FALSE
    --                  oggetto                --> CTL_DOC.Body

    -- Sono necessari per evitare gli errori di validazione lato GGAP:
    --                  codProceduraSceltaContraente  --> Document_SIMOG_SMART_CIG.codiceProceduraSceltaContraente
    --                  codFattispecie                --> Document_SIMOG_SMART_CIG.codiceFattispecieContrattuale ==> Non va passato alcun valore ed il dato verrà gestito in GGAP
    --                  idMotivoRichiestaCig          --> Document_SIMOG_SMART_CIG.motivo_rich_cig_catmerc ==> da lasciare vuoto, è opzionale
    --                  idMotivoRichiestaCigComune    --> Document_SIMOG_SMART_CIG.motivo_rich_cig_comuni ==> da lasciare vuoto, è opzionale
    --                  listaIdCategorieMerceologiche --> Document_SIMOG_SMART_CIG.CATEGORIE_MERC ==> può rimanere vuoto
    
	SET NOCOUNT ON

    --DECLARE @idSmartCig INT = 477942
    DECLARE @idDoc INT

    DECLARE @flagNoCig BIT = 0 --> Nota: Non essendo una funzione gestita in SATFVG potete passare sempre il valore FALSE
    DECLARE @idSmartCigGgap INT
    DECLARE @oggetto NVARCHAR(MAX)
    DECLARE @connectedUserIdUo INT --> è int oppure string?
    DECLARE @userAlias VARCHAR(MAX) --DECLARE @connectedUserAlias VARCHAR(MAX) = 'wsApp'
    DECLARE @codProceduraSceltaContraente NVARCHAR(MAX)
    DECLARE @protocollo NVARCHAR(MAX) -- per il codiceRiferimentoGara e codiceRiferimentoLotto sara sempre il Protocollo
	DECLARE @tipoAppaltoGara NVARCHAR(50)


    -- Prendo l'id della gara e l'oggetto
    SELECT @idSmartCigGgap = CAST(CASE WHEN NumeroDocumento NOT LIKE '%[^0-9]%' THEN NumeroDocumento END AS INT)
           --, @idSmartCigGgap = (CASE
           --                       WHEN NumeroDocumento IS NOT NULL OR NumeroDocumento <> '' THEN CAST(NumeroDocumento AS INT) --CONVERT(INT, NumeroDocumento)
           --                       ELSE NULL
           --                    END)
           , @oggetto = Body
           , @idDoc = LinkedDoc
        FROM CTL_DOC WITH (NOLOCK)
        WHERE Id=@idSmartCig
              AND
              TipoDoc = 'RICHIESTA_SMART_CIG'

    -- Prendo il protocollo (ossia codiceRiferimentoGara e codiceRiferimentoLotto per GGAP)
    SELECT @protocollo = Protocollo
        FROM CTL_DOC WITH (NOLOCK)
        WHERE Id=@idDoc


    -- Prendo l'id dell'unità organizzativa (connectedUserIdUo) e il codiceProceduraSceltaContraente
    SELECT @connectedUserIdUo = indexCollaborazione
           , @codProceduraSceltaContraente = codiceProceduraSceltaContraente
        FROM Document_SIMOG_SMART_CIG WITH (NOLOCK)
        WHERE idHeader=@idSmartCig

        
    -- Costruisco lo userAlias/connectedUserAlias
    DECLARE @pfulogin VARCHAR(MAX)
    DECLARE @azilog VARCHAR(MAX)

        SELECT @pfulogin=pfulogin
               , @azilog=azilog
            FROM ProfiliUtente WITH (NOLOCK)
                    INNER JOIN Aziende WITH (NOLOCK) ON pfuidazi = idazi
            WHERE IdPfu = (SELECT idpfu FROM ctl_doc WHERE Id = @idSmartCig)

        SET @userAlias = CAST(@pfulogin AS NVARCHAR(MAX)) + '_' + CAST(@azilog AS NVARCHAR(MAX)) -- E_SABATO_FERRARO_5_ER000AA
        -- SET @userAlias = 'wsApp' -- 'E_CORRADO_VERSOLATO_FV000AA' -- TODO: rimuovere, è solo per test

    
    -- Recupero il Tipo Appalto nella codifica ANAC
    SELECT @tipoAppaltoGara = CASE
                                WHEN DB.TipoAppaltoGara = '1' THEN 'F' -- Forniture
                                WHEN DB.TipoAppaltoGara = '2' THEN 'L' -- Lavori (pubblici)
                                WHEN DB.TipoAppaltoGara = '3' THEN 'S' -- Servizi
                                ELSE ''
                              END
        FROM Document_Bando DB WITH (NOLOCK)
                INNER JOIN CTL_DOC S WITH (NOLOCK) ON DB.idHeader = S.LinkedDoc
        WHERE S.Id = @idSmartCig


    -- Aggiorno questo valore perché si perdono quando si esegue il comando "Richiesta Smart Cig" a causa del reload della pagina: il fatto che quando si eseguono dei
    --  processi dietro al comando comporta il salvataggio dei dati e questo in combinazione con il fatto che c'è di mezzo una chiamata http (nel onLoad della pagina dove
    --  si prende la lista delle unita organizzative) che restituisce i dati più lentamente del reload e salvataggio della pagina comporta la sovrascrittura dei dati.
    UPDATE CTL_DOC_Value
        SET [Value] = @connectedUserIdUo
        WHERE IdHeader=@idDoc AND DSE_ID='GGAP' AND DZT_Name='GgapUnitaOrganizzative'



    -- Restituisco i dati
    SELECT @flagNoCig               AS flagNoCig --si
           ,@idSmartCigGgap         AS idSmartCigGgap --si
           ,@oggetto                AS oggetto --si
           ,@connectedUserIdUo      AS connectedUserIdUo --si
           ,@userAlias              AS userAlias --si
           ,@protocollo             AS protocollo --si usato per codiceRiferimentoGara e codiceRiferimentoLotto
           -- AND
           --,@idUnitaOrganizzativa           AS idUnitaOrganizzativa --facoltativo
           ,@codProceduraSceltaContraente   AS codProceduraSceltaContraente --si
           --,@codFattispecie                 AS codFattispecie --da eliminare
           --,@idMotivoRichiestaCig           AS idMotivoRichiestaCig --è opzionale
           --,@idMotivoRichiestaCigComune     AS idMotivoRichiestaCigComune --è opzionale
           --,@listaIdCategorieMerceologiche  AS ListaIdCategorieMerceologicheAsString --sarà opzionale
           ,@tipoAppaltoGara    AS tipoAppaltoGara

END

GO
