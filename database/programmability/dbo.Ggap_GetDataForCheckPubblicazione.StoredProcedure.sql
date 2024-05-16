USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[Ggap_GetDataForCheckPubblicazione]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- @tipoDiRicerca indica se si tratta di Gara o SmartCig ==> Tipo di ricerca: 1 - SIMOG (Standard), 2 - SmartCIG/NoCIG
--    In questo caso è @tipoDiRicerca = 1
-- @operation = garaAggiornaPubblicazioneGgap
CREATE PROCEDURE [dbo].[Ggap_GetDataForCheckPubblicazione] ( @idBando INT, @idRichiestaCig INT, @operation NVARCHAR(50), @tipoDiRicerca INT )
AS
BEGIN
    -- Sono necessari: 
    --                  connectedUserAlias  --> ProfiliUtente.pfulogin + _ + Aziende.azilog
    --                  connectedUserIdUo   --> Document_SIMOG_GARA.indexCollaborazione
    --                  tipoRicerca         --> Dipende se si arriva da una richiesta per la Gara o Lotto/i, comunque arriva in ingresso
    --
    -- Campi non previsti per tipoRicerca = 2 (cioè SmartCIG/NoCIG): 
    --                  idAppalto       -->
    --                  oggettoAppalto  -->
    --                  idGara          --> CTL_DOC.NumeroDocumento (per TipoDoc='RICHIESTA_CIG')
    --                  oggettoGara     --> CTL_DOC.Body
    -- 
    -- Necessari per tipoRicerca = 2 (cioè SmartCIG/NoCIG): 
    --                  cigSmartCigNoCig            --> Document_SIMOG_LOTTI.CIG    oppure  Document_SIMOG_SMART_CIG.smart_cig
    --                                                   No Document_SIMOG_GARA.id_gara (cioe numeroGara)
    -- 
    -- Altri campi: 
    --                  idLottoSmartCigNoCig        --> ??? Document_SIMOG_LOTTI.idLottoEsterno  vs  CTL_DOC.NumeroDocumento (per TipoDoc='RICHIESTA_SMART_CIG')
    --                  oggettoLottoSmartCigNoCig   --> ??? Document_SIMOG_LOTTI.OGGETTO  vs  CTL_DOC.Body (per TipoDoc='RICHIESTA_SMART_CIG')
    --                  rfxId                       --> ??? ...
    --                  rfxReferenceId              --> ??? ...
    --                  tenderCode                  --> ??? ...
    --                  tenderReferenceCode         --> ??? ...

    
	SET NOCOUNT ON

    --DECLARE @idBando INT = 478556
    --DECLARE @idRichiestaCig INT = 478562
    --DECLARE @tipoDiRicerca INT = 1
    
    --DECLARE @cigSmartCigNoCig VARCHAR(50)
    DECLARE @connectedUserIdUo INT
    DECLARE @pfulogin VARCHAR(MAX)
    DECLARE @azilog VARCHAR(MAX)
    DECLARE @userAlias VARCHAR(MAX)
	--DECLARE @codiceProceduraSceltaContraente AS INT
	--DECLARE @ggapUnitaOrganizzative AS INT

    --DECLARE @idLottoGgap INT -- Usato nel caso di lotti, però in questo caso non ci serve un singolo lotto => sempre null
    --DECLARE @oggettoLotto VARCHAR(MAX) -- Usato nel caso di lotti, però in questo caso non ci serve un singolo lotto => sempre null


    -- Non può essere il numeroGara (CIG della gara) ma solo un CIG del lotto: arrivato a questa conclusione dopo aver testato la chiamata a GGAP.
    -- Non testato per SmartCig.
    --SELECT TOP (1) @cigSmartCigNoCig = G.id_gara
    --    FROM Document_SIMOG_GARA G WITH (NOLOCK)
    --                INNER JOIN CTL_DOC docBando WITH (NOLOCK)
    --                        ON G.idHeader = docBando.Id AND docBando.StatoFunzionale = 'Inviato' AND G.StatoRichiestaGARA = 'Inviato'
    --    WHERE docBando.Id = @idRichiestaCig


    -- Costruisco lo userAlias/connectedUserAlias
    SELECT @pfulogin=PU.pfulogin
           , @azilog=A.azilog
        FROM ProfiliUtente PU WITH (NOLOCK)
                INNER JOIN Aziende A WITH (NOLOCK) ON pfuidazi = idazi
        WHERE IdPfu = (SELECT idpfu FROM ctl_doc WHERE Id = @idBando)

    SET @userAlias = CAST(@pfulogin AS NVARCHAR(MAX)) + '_' + CAST(@azilog AS NVARCHAR(MAX)) -- E_SABATO_FERRARO_5_ER000AA
        -- SET @userAlias = 'wsApp' -- SET @userAlias = 'E_CORRADO_VERSOLATO_FV000AA' -- TODO: rimuovere, è solo per test
    

    -- Prendo l'id dell'unità organizzativa ossia connectedUserIdUo (e l'id della sceltà contraente)
    SELECT @connectedUserIdUo = indexCollaborazione  -- l'id dell'unità organizzativa
           --, @codiceProceduraSceltaContraente = ID_SCELTA_CONTRAENTE
        FROM Document_SIMOG_GARA WITH (NOLOCK)
        WHERE idHeader=@idRichiestaCig


    -- Prendo l'id della gara che GGAP fornisce
    DECLARE @idGaraGgap INT

        SELECT @idGaraGgap = CAST(CASE WHEN NumeroDocumento NOT LIKE '%[^0-9]%' THEN NumeroDocumento END AS INT)
            FROM CTL_DOC
            WHERE Id = @idRichiestaCig AND TipoDoc='RICHIESTA_CIG'
        

    -- Prendo l'oggetto della gara
    DECLARE @oggetto NVARCHAR(MAX)

        SELECT @oggetto = Body
            FROM CTL_DOC WITH (NOLOCK)
            WHERE Id=@idBando



    -- Restituisco i dati
    SELECT @userAlias           AS userAlias -- connectedUserAlias
           , @connectedUserIdUo AS connectedUserIdUo
           , @tipoDiRicerca     AS tipoDiRicerca
           , @idGaraGgap        AS idGaraGgap
           , @oggetto           AS oggettoGara

           --, @codiceProceduraSceltaContraente   AS codiceProceduraSceltaContraente
           --, CASE
           --     WHEN ISNULL(@cigSmartCigNoCig,'') = '' THEN NULL
           --     ELSE @cigSmartCigNoCig
           --  END AS cigSmartCigNoCig
           --, @idLottoGgap       AS idLottoSmartCigNoCig
           --, @oggettoLotto      AS oggettoLottoSmartCigNoCig
        
END

GO
