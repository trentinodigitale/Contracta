USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[Ggap_ModificaLottoRequest]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- @idRowServiceSimogRequests contiene il valore del campo idRow, che si trova nella tabella Service_SIMOG_Requests.
-- Se @isFromCreaGara è true allora @idBando è valorizzato e @idRowServiceSimogRequests contiene il valore per il record della Gara (garaInserisciGgap) 
--  altrimenti contiene il valore per il record del Lotto (lottoInserisciGgap)
CREATE PROCEDURE [dbo].[Ggap_ModificaLottoRequest] ( @idRowServiceSimogRequests INT , @isFromGara BIT, @idBando INT)
AS
BEGIN
    -- Sono obbligatori: 
    --                  connectedUserIdUo       --> Document_SIMOG_GARA.indexCollaborazione
    --                  connectedUserAlias      --> ProfiliUtente.pfulogin + _ + Aziende.azilog
    --                  codiceRiferimentoLotto  --> CTL_DOC.Protocollo + '-' + NumeroLotto
    --                  oggettoLotto            --> Document_SIMOG_LOTTI.OGGETTO
    --                  tipologiaLotto          --> Tipologia Lotto in (L,S,F)
    --                  idTipoProcedura         --> Document_SIMOG_GARA.ID_SCELTA_CONTRAENTE
    --                  importoBaseAsta         --> Document_SIMOG_LOTTI.IMPORTO_LOTTO
    --                  importoSicurezza        --> Document_SIMOG_LOTTI.IMPORTO_ATTUAZIONE_SICUREZZA

    
	SET NOCOUNT ON

    DECLARE @idRichiestaCig INT  

    --DECLARE @idRowServiceSimogRequests INT = 253867
    --DECLARE @isFromGara BIT = 1
    --DECLARE @idBando INT = 478363


    -- Se @isFromCreaGara è false allora recupero l'id del BANDO_GARA utilizzando @idRowServiceSimogRequests che contiene il valore relativo al record del Lotto
    IF (@isFromGara = 0)
    BEGIN
        SELECT  @idBando = D.LinkedDoc -- BANDO_GARA
                --, @idRichiestaCig = D.Id -- RICHIESTA_CIG
                --, @idBando = BANDO.idHeader -- BANDO_GARA
                --*
            FROM Document_SIMOG_LOTTI L WITH (NOLOCK)
                    LEFT OUTER JOIN Service_SIMOG_Requests R WITH (NOLOCK)
                        ON L.idrow = R.idRichiesta
                            AND R.operazioneRichiesta IN ('lottoModificaGgap')
                            AND R.isOld = 0
                    INNER JOIN CTL_DOC D WITH (NOLOCK) ON L.idheader = D.id
                    LEFT JOIN Document_Bando BANDO WITH (NOLOCK) ON D.LinkedDoc = BANDO.idHeader
            WHERE R.idRow = @idRowServiceSimogRequests AND L.AzioneProposta = 'Update'
    END

    
    -- Prendo il protocollo
    DECLARE @Protocollo NVARCHAR(MAX)

        SELECT @Protocollo = Protocollo
            FROM CTL_DOC WITH (NOLOCK)
            WHERE Id=@idBando
              

    -- Prendo l'id della RICHIESTA_CIG
    SELECT TOP 1 @idRichiestaCig = Id
        FROM CTL_DOC WITH (NOLOCK)
        WHERE LinkedDoc=@idBando
              AND TipoDoc = 'RICHIESTA_CIG'
              AND JumpCheck = 'MODIFICA'
              AND StatoFunzionale <> 'Annullato'
        ORDER BY Id DESC


    -- TODO: verificare la necessita
    --DECLARE @NumeroLotti INT
    --SELECT @NumeroLotti = COUNT(*)
    --    FROM ctl_doc b WITH (NOLOCK)
    --            INNER JOIN Document_MicroLotti_Dettagli d WITH (NOLOCK)
    --                ON d.IdHeader = b.id AND b.TipoDoc = d.TipoDoc AND d.voce = 0
    --    WHERE b.id = @idDoc


    -- Costruisco lo userAlias/connectedUserAlias
    DECLARE @pfulogin VARCHAR(MAX)
    DECLARE @azilog VARCHAR(MAX)

        SELECT @pfulogin=PU.pfulogin
               , @azilog=A.azilog
            FROM ProfiliUtente PU WITH (NOLOCK)
                    INNER JOIN Aziende A WITH (NOLOCK) ON pfuidazi = idazi
            WHERE IdPfu = (SELECT idpfu FROM ctl_doc WHERE Id = @idRichiestaCig)

    DECLARE @userAlias VARCHAR(MAX) = CAST(@pfulogin AS NVARCHAR(MAX)) + '_' + CAST(@azilog AS NVARCHAR(MAX)); -- E_SABATO_FERRARO_5_ER000AA
        -- SET @userAlias = 'wsApp' -- 'E_CORRADO_VERSOLATO_FV000AA' -- TODO: rimuovere, è solo per test
    

    -- Prendo l'id dell'unità organizzativa (connectedUserIdUo)     -- e il codiceProceduraSceltaContraente --DECLARE @codProceduraSceltaContraente NVARCHAR(MAX)
    DECLARE @connectedUserIdUo INT
    DECLARE @codProceduraSceltaContraente INT

        SELECT @connectedUserIdUo = indexCollaborazione
               , @codProceduraSceltaContraente = ID_SCELTA_CONTRAENTE
            FROM Document_SIMOG_GARA WITH (NOLOCK)
            WHERE idHeader=@idRichiestaCig

    
    -- Prendo l'id della gara che GGAP fornisce
    -- 
    --DECLARE @idGara INT -- l'id che GGAP ci restituisce
    --SELECT @idGara = (CASE  WHEN ISNULL(NumeroDocumento, '') = '' THEN NumeroDocumento
    --                        ELSE CAST(NumeroDocumento AS INT) --CONVERT(INT, NumeroDocumento)
    --                  END)
    --    FROM CTL_DOC WITH (NOLOCK)
    --    WHERE LinkedDoc=@idDoc AND TipoDoc='RICHIESTA_CIG'


    -- Prendo SIGLA_PROVINCIA LUOGO_ISTAT e CODICE_NUTS
    DECLARE @siglaProvincia NVARCHAR(5)
    DECLARE @luogoIstat NVARCHAR(10)
    --DECLARE @codiceIstatComune NVARCHAR(10)
    DECLARE @codiceNuts NVARCHAR(10)

        SELECT @luogoIstat = (CASE 
                        	           WHEN GEO.DMV_Level = 7 THEN dbo.GetColumnValue(LOT.LUOGO_ISTAT, '-', 8)
                        	           ELSE ''
                        	         END -- Se si è selezionato un nodo di livello comune / 7 prendo il codice istat dalla sua ultima parte dmv_cod
                )
        	    , @codiceNuts = (CASE 
        	                         WHEN GEO.DMV_Level = 6 THEN dbo.GetColumnValue(LOT.LUOGO_ISTAT, '-', 7) -- se si è scelto una provincia prendo il suo codice NUTS
        	                         WHEN GEO.DMV_Level = 5 THEN dbo.GetColumnValue(LOT.LUOGO_ISTAT, '-', 6) -- se si è scelta una regione prendo il suo codice NUTS
        	                         ELSE ''
        	                     END
                )
            FROM Document_SIMOG_LOTTI LOT WITH (NOLOCK)
                    LEFT JOIN LIB_DomainValues GEO WITH (NOLOCK) ON GEO.DMV_DM_ID = 'GEO' AND GEO.DMV_Cod = LOT.LUOGO_ISTAT
            --WHERE LOT.idRow=1318
            WHERE LOT.idHeader = @idRichiestaCig -- OR LOT.idHeader = @idBando
        
        --SELECT @SiglaAuto AS SiglaProvincia, @LuogoIstat AS CodiceIstatComune, @codiceNuts AS CodiceNuts
        --SET @codiceNuts = 'ITH42'
        
        IF (ISNULL(@luogoIstat,'')='')
        BEGIN
            SELECT @siglaProvincia = SiglaAuto -- per GGAP "Sigla provincia"
                   --, @codiceIstatComune = (ISNULL(CodiceProvincia,'') + ISNULL(CodiceComune,''))
        	    FROM GEO_ISTAT_elenco_comuni_italiani
                WHERE CodiceNUTS3_2010 LIKE '%' + @codiceNuts + '%'
        END
        ELSE IF (ISNULL(@codiceNuts,'')='')
        BEGIN
            SELECT @siglaProvincia = SiglaAuto-- per GGAP "Sigla provincia"
                   --, @codiceIstatComune = (ISNULL(CodiceProvincia,'') + ISNULL(CodiceComune,''))
        	    FROM GEO_ISTAT_elenco_comuni_italiani
                WHERE CodiceIstatDelComune_formato_alfanumerico LIKE '%' + @luogoIstat + '%'
        END



    SELECT @connectedUserIdUo                       AS connectedUserIdUo
           , @userAlias                             AS userAlias
           , (@Protocollo + '-' + L.NumeroLotto)    AS codiceRiferimentoLotto
           , L.OGGETTO
           , @codProceduraSceltaContraente          AS codProceduraSceltaContraente
           , L.idLottoEsterno -- l'id che GGAP restituisce
           --, @idGara                              AS idGara -- Id che GGAP fornisce

           , NumeroLotto
           , TIPO_CONTRATTO                 AS tipoContratto
           , L.IMPORTO_LOTTO                AS importoLotto
           , L.IMPORTO_ATTUAZIONE_SICUREZZA AS importoAttuazioneSicurezza
           , L.IMPORTO_OPZIONI              AS importoOpzioni
           , CASE 
                WHEN FLAG_PNRR_PNC = 'N' THEN 0
                WHEN ISNULL(FLAG_PNRR_PNC, '')='' THEN 0
                ELSE 1 -- ossia = 'S'
             END AS flagPnrrPnc

           , @siglaProvincia    AS siglaProvincia
           --, RIGHT('0000' + dbo.GetColumnValue(@luogoIstat, '-', 8), 6)  AS codiceIstatComune
           --, @codiceIstatComune AS codiceIstatComune
           , RIGHT(@luogoIstat, 3) AS codiceIstatComune
           , @codiceNuts        AS listaNutsAsString -- codiceNuts

           --, L.FLAG_PREVISIONE_QUOTA => come trattarlo? ossia come trasformare questa stringa in int? Quindi da S, N oppure Q in intero per GGAP?
           , L.QUOTA_FEMMINILE                      AS quotaFemminile
           , L.QUOTA_GIOVANILE                      AS quotaGiovanile
           , CASE
                WHEN L.FLAG_MISURE_PREMIALI = 'N' THEN 0
                WHEN ISNULL(L.FLAG_MISURE_PREMIALI, '')='' THEN 0
                ELSE 1
             END                                    AS flagMisurePremiali
	       --, ISNULL(CPV.DMV_CodExt, L.CPV)          AS listaCpvAsString
		   --, ISNULL(L.CUP , ISNULL(BANDO.CUP,'') )  AS listaCupAsString
           --, L.ID_MISURA_PREMIALE                 AS listaIdMisurePremialiAsString
           --, L.ID_MOTIVO_DEROGA                   AS listaIdMotiviDerogaAsString

           , L.idRow -- per identificare il record nella tabella per quando si deve fare l'insert/update del idLottoEsterno
           , L.idHeader AS idHeader -- coincide con l'id del doc RICHIESTA_CIG nella CTL_DOC
           , @idBando   AS idBando
           , R.idRow    AS  idRowServiceSimogRequests -- idRow della Service_SIMOG_Requests per identificare il record dell'lotto: è utile quando si prendono i lotti dopo il CreaGara

        FROM Document_SIMOG_LOTTI L WITH (NOLOCK)
                INNER JOIN Service_SIMOG_Requests R WITH(NOLOCK) ON L.idrow = R.idRichiesta
                                                                        AND R.operazioneRichiesta IN ('lottoModificaGgap')
                                                                        AND statoRichiesta='Inserita'
				INNER JOIN CTL_DOC DOC WITH (NOLOCK) ON DOC.id = L.idHeader
	                                                    AND DOC.TipoDoc IN ('RICHIESTA_CIG', 'ANNULLA_RICHIESTA_CIG')
                --LEFT JOIN Document_Bando BANDO WITH (NOLOCK) ON BANDO.idHeader = DOC.LinkedDoc
				--LEFT JOIN LIB_DomainValues CPV WITH (NOLOCK) ON CPV.DMV_DM_ID = 'CODICE_CPV'
	   --                                                         AND CPV.DMV_Deleted = 0
	   --                                                         AND CPV.DMV_Cod = L.CPV
        WHERE L.idHeader = @idRichiestaCig AND L.AzioneProposta = 'Update'

END

GO
