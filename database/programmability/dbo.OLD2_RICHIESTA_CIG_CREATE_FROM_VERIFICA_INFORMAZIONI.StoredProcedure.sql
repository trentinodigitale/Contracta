USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_RICHIESTA_CIG_CREATE_FROM_VERIFICA_INFORMAZIONI]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[OLD2_RICHIESTA_CIG_CREATE_FROM_VERIFICA_INFORMAZIONI] ( @idDoc int , @IdUser int, @makeDocFrom int = 0 )
AS
BEGIN

	SET NOCOUNT ON

--	DECLARE @idDoc int 
--	DECLARE @IdUser int 
--	set @idDoc = 402508
--	set @IdUser = 45094
--	DELETE FROM CTL_DOC_Value where IdHeader = @idDoc and DSE_ID = 'SIMOG_GET' and DZT_Name = 'FLAG_SYNC'

	declare @errore nvarchar(max)

	declare @Id as INT
	declare @Idazi as INT
	declare @newid as int
	declare @idr as int
	declare @Rup varchar(50)

	declare @divisioneLotti varchar(10)
	declare @RichiestaCigSimog varchar(10)
	declare @cig_numero_gara varchar(100)
	declare @idRow INT
	declare @FLAG_SYNC_SIMOG varchar(10)
	declare @Tipo_Rup as varchar(100)
	declare @TipoDoc as varchar(100)


	set @errore = ''
	set @FLAG_SYNC_SIMOG = ''
	set @rup = ''

	select  @divisioneLotti = Divisione_lotti,
			@RichiestaCigSimog = RichiestaCigSimog,
			@cig_numero_gara = isnull(CIG,'')	-- per le mono-lotto sarà un cig, per le multi-lotto un numero gara
		from document_bando with(nolock)
		where idheader = @idDoc

	--select @Rup = Value from ctl_doc_value  with(nolock) where idheader = @idDoc and dse_id = 'InfoTec_comune' and dzt_name = 'UserRUP' 
	
	select @Tipo_Rup=dbo.PARAMETRI ('SIMOG','TIPO_RUP','DefaultValue','UserRUP',-1) 

	if @Tipo_Rup='UserRUP'
		select @Rup = Value from ctl_doc_value  with(nolock) where idheader = @idDoc and dse_id = 'InfoTec_comune' and dzt_name = @Tipo_Rup 
	else
		select @Rup = RupProponente from document_bando  with(nolock) where idheader = @idDoc 



	select @FLAG_SYNC_SIMOG = isnull([value],'')
		from CTL_DOC_Value with(nolock)
		where IdHeader = @idDoc and DSE_ID = 'SIMOG_GET' and DZT_Name = 'FLAG_SYNC'


	select @TipoDoc = TipoDoc from CTL_DOC with(nolock) where id = @idDoc
	--select  dbo.PARAMETRI('SIMOG' , 'SIMOG_GET', 'ATTIVO','NO',-1) ,isnull(@RichiestaCigSimog,'no') , isnull(@cig_numero_gara,'')  , @FLAG_SYNC_SIMOG , isnull(@rup,'')


    -- Se esiste il modulo 'SIMOG_GGAP' all'interno della stringa 'SYS_MODULI_GRUPPI'
    --      A. Gestiamo il meccanismo per interagire con GGAP (Insiel): non è molto diverso da quello che si fa quando non si tratta di GGAP
    -- Altrimenti
	--      facciamo scattare una nuova richiesta se 
	--          1. il parametro di attivazione SIMOG_GET è a YES
	--          2. Richiesta cig su simog" è NO
	--          3. il campo CIG in testata è popolato 
	--          4. il flag di sincronizzazione con le richieste di get da simog è vuoto ( quindi se non è stato ancora fatto o se si è chiesto un nuovo recupero )
	--          		oppure è pubblicato.  Cioè non è stata ancora inviata una richiesta oppure è in uno stato "termiale" escluso quello di pubblicato. cioè quando i dati simog sono congelati in quanto la gara è pubblicata
	--          5. se è attivo il login RPNT
	--          6. deve essere stato scelto il rup
	--          7. se è attivo il modulo simog
	--          8. Se in testata non è stato inserito uno SMART CIG
	--      escluse le aste

    -- Per sapere se siamo nel caso di Insiel: - Controllo se esiste il permesso 563 nel 'SYS_MODULI_RESULT' (permesso dietro alla sezione GGAP e nei PERMESSI_CROSS)
    -- SELECT SUBSTRING(DZT_ValueDef, 563, 1) FROM LIB_Dictionary WITH (NOLOCK) WHERE DZT_Name = 'SYS_MODULI_RESULT'
    -- Oppure, - Controllo se esiste il modulo 'SIMOG_GGAP' nella stringa 'SYS_MODULI_GRUPPI'
    IF ( (SELECT CHARINDEX('SIMOG_GGAP', (select DZT_ValueDef from LIB_Dictionary WITH(NOLOCK) where DZT_Name = 'SYS_MODULI_GRUPPI'))) > 0
            -- AND isnull(@RichiestaCigSimog, 'no') = 'no' -- AND LTRIM(RTRIM(isnull(@cig_numero_gara, ''))) <> ''
    )
    BEGIN
        -- Se siamo nel caso di RICHIESTA_SMART_CIG
        IF ( 'RICHIESTA_SMART_CIG' IN (SELECT TipoDoc FROM CTL_DOC WHERE LinkedDoc=@idDoc AND StatoFunzionale NOT IN ('Annullato', 'Errore', 'RicevutoErrore'))
                -- AND SUBSTRING(@cig_numero_gara, 1, 1) IN ('X', 'Y', 'Z')
        )
        BEGIN
            DECLARE @idRichiestaSmartCig INT

            SELECT @idRichiestaSmartCig = Id
                FROM CTL_DOC
                WHERE LinkedDoc=@idDoc AND StatoFunzionale NOT IN ('Annullato', 'Errore', 'RicevutoErrore') AND TipoDoc='RICHIESTA_SMART_CIG'

            -- Inserisci record nella tabella Service_SIMOG_Requests
            IF (ISNULL(@idRichiestaSmartCig, '') <> '')
            BEGIN
                -- Annulliamo tutte le eventuali richieste in pending per consultaSmartCigGgap
                UPDATE Service_SIMOG_Requests
                    SET isOld = 1, statoRichiesta = 'Annullato'
                    FROM Service_SIMOG_Requests R
                    WHERE R.idRichiesta = @idRichiestaSmartCig AND operazioneRichiesta='consultaSmartCigGgap'
                            AND statoRichiesta NOT IN ('Annullato','Errore') AND isOld = 1

                INSERT INTO Service_SIMOG_Requests (idRichiesta, operazioneRichiesta, statoRichiesta, dateIn)
                	VALUES (@idRichiestaSmartCig, 'consultaSmartCigGgap', 'Inserita', GETDATE())
            END
        END -- Altrimenti è il caso di RICHIESTA_CIG
        ELSE IF ( 'RICHIESTA_CIG' IN (SELECT TipoDoc FROM CTL_DOC WHERE LinkedDoc=@idDoc AND Deleted = 0 AND StatoFunzionale NOT IN ('Annullato', 'Errore', 'RicevutoErrore')) )
        BEGIN
            -- TODO: i seguenti annullamenti per operazioneRichiesta = a 'consultaNumeroGaraGgap' oppure = a 'consultaCigGgap' bisogna capire se lasciarli
            --      entrambi o rimuoverli a seconda di coma funziona la chiamata su GGAP; Se basta il numeroGara e ottengo tutte le info, sia riguardo alla gara
            --      che a tutti i lotti, allora si lascia solo l'annullamento per 'consultaNumeroGaraGgap'; Se invece per ottenere i dati sui lotti o su singolo lotto
            --      bisogna fare una chiamata a GGAP (passando il CIG) separata da quella per la gara allora è necessario lasciare entrambi gli annullamenti.
            --      A tal riguardo bisogna anche controllare la vista VIEW_Service_SIMOG_Requests per decidere se lasciare entrambi i seguenti case o 1 solo:
            --              WHEN operazioneRichiesta = 'consultaNumeroGaraGgap' THEN 'LeggiDatiProcedura'
            --              WHEN operazioneRichiesta = 'consultaCigGgap' THEN 'LeggiDatiProcedura'

		    -- -- Annulliamo tutte le eventuali richieste in pending per consultaNumeroGaraGgap
            -- UPDATE Service_SIMOG_Requests
            --     SET isOld = 1
            --     FROM Service_SIMOG_Requests R
            --             INNER JOIN Document_SIMOG_GARA G WITH (NOLOCK)
            --                 ON G.idrow = R.idRichiesta AND R.operazioneRichiesta = 'consultaNumeroGaraGgap' AND R.isOld = 0 AND R.statoRichiesta NOT IN ('Errore', 'Elaborato')
            --             INNER JOIN CTL_DOC D WITH (NOLOCK) ON D.Id = G.idHeader
            --     WHERE D.LinkedDoc = @idDoc
	        --             AND D.Deleted = 0
	        --             AND D.TipoDoc IN ('RICHIESTA_CIG')
	        --             AND D.StatoFunzionale <> 'Annullato'
            -- 
		    -- -- Annulliamo tutte le eventuali richieste in pending per consultaCigGgap
            -- UPDATE Service_SIMOG_Requests
            --     SET isOld = 1
            --     FROM Service_SIMOG_Requests R
            --             INNER JOIN Document_SIMOG_LOTTI L WITH (NOLOCK)
            --                 ON L.idRow = R.idRichiesta AND R.operazioneRichiesta = 'consultaCigGgap' AND R.isOld = 0 AND R.statoRichiesta NOT IN ('Errore', 'Elaborato')
            --             INNER JOIN CTL_DOC D WITH (NOLOCK) ON D.Id = L.idHeader
            --     WHERE D.LinkedDoc = @idDoc
	        --             AND D.Deleted = 0
	        --             AND D.TipoDoc IN ('RICHIESTA_CIG')
	        --             AND D.StatoFunzionale <> 'Annullato'

            -- TODO: da rimuovere?
            -- Annulliamo tutti i documenti di RICHIESTA_CIG precedentemente inviati
            --UPDATE CTL_DOC
            --    SET StatoFunzionale = 'Annullato', Deleted = 1
            --    WHERE LinkedDoc = @idDoc AND Deleted = 0 AND TipoDoc IN ('RICHIESTA_CIG') AND StatoFunzionale <> 'Annullato'

                
            -- TODO: da rimuovere?
            -- Ottengo la versione dei WS simog, SOLO come traccia storica. Settata sul documento RICHIESTA_CIG.
            --DECLARE @versioneSimog VARCHAR(100) = '3.4.2'
            --SELECT TOP 1 DZT_ValueDef FROM LIB_Dictionary WITH (NOLOCK) WHERE DZT_Name = 'SYS_VERSIONE_SIMOG' -- ==> 3.4.9

            
            -- Recupero i dati della sezione GGAP: codiceProceduraSceltaContraente e unita organizzative
            --DECLARE @idDoc AS INT = 472509
	        DECLARE @codiceProceduraSceltaContraente AS INT
	        DECLARE @ggapUnitaOrganizzative AS INT
            SELECT @codiceProceduraSceltaContraente=[Value] FROM CTL_DOC_Value WITH(NOLOCK) WHERE IdHeader=@idDoc AND DSE_ID='GGAP' AND DZT_Name='codiceProceduraSceltaContraente'
            SELECT @ggapUnitaOrganizzative=[Value] FROM CTL_DOC_Value WITH(NOLOCK) WHERE IdHeader=@idDoc AND DSE_ID='GGAP' AND DZT_Name='GgapUnitaOrganizzative'
            --SELECT @codiceProceduraSceltaContraente, @ggapUnitaOrganizzative


            -- TODO: da rimuovere?
            --INSERT INTO CTL_DOC (IdPfu, TipoDoc, idPfuInCharge, Azienda, Body, LinkedDoc, Versione, Caption, StatoFunzionale)
            --    SELECT @IdUser, 'RICHIESTA_CIG', @IdUser, Azienda, Body, @idDoc, @versioneSimog, 'Recupero dati SIMOG da GGAP', 'InvioInCorso'
            --        FROM CTL_DOC WITH (NOLOCK)
            --        WHERE Id = @idDoc
            --SET @newId = SCOPE_IDENTITY()


            DECLARE @idDocRichiestaCig INT -- Contiene l'id della RICHIESTA_CIG corrrente
            --DECLARE @idDocRichiestaCigAnnullato INT -- Contiene l'id della RICHIESTA_CIG precedente e che si trova in stato di Annullato (oppure Errore, RicevutoErrore)
            
                SELECT TOP(1) @idDocRichiestaCig = Id
                    FROM CTL_DOC
                    WHERE LinkedDoc = @idDoc AND Deleted = 0 AND TipoDoc = 'RICHIESTA_CIG' AND StatoFunzionale NOT IN ('Annullato', 'Errore', 'RicevutoErrore')
                
                --SELECT @idDocRichiestaCig


		    -- Annulliamo tutte le eventuali richieste in pending per consultaNumeroGaraGgap e consultaCigGgap
            UPDATE Service_SIMOG_Requests
                SET isOld = 1, statoRichiesta = 'Annullato'
                FROM Service_SIMOG_Requests R
                WHERE idRichiesta IN (@idDocRichiestaCig)
                        AND operazioneRichiesta IN ('consultaNumeroGaraGgap','consultaCigGgap')
                        AND R.isOld = 0 AND statoRichiesta NOT IN ('Annullato', 'Errore', 'RicevutoErrore')


            UPDATE Service_SIMOG_Requests
                SET isOld = 1, statoRichiesta = 'Annullato'
                FROM Service_SIMOG_Requests R
                WHERE idRichiesta IN (SELECT Id FROM CTL_DOC
                                        WHERE LinkedDoc = @idDoc AND Deleted = 1 AND TipoDoc = 'RICHIESTA_CIG' AND StatoFunzionale IN ('Annullato', 'Errore', 'RicevutoErrore'))
                        AND operazioneRichiesta IN ('consultaNumeroGaraGgap','consultaCigGgap')
                        AND R.isOld = 0 AND statoRichiesta NOT IN ('Annullato', 'Errore', 'RicevutoErrore')


            IF(@cig_numero_gara = '')
                SET @cig_numero_gara = null


		    -- Se monolotto ==> questo significa che ci sarà un solo lotto che posso già imbastire dove poi integro i dati recuperati da GGAP chiamando l'end-point LeggiDatiProcedura
		    IF @divisioneLotti = '0'
		    BEGIN
                ---- Non conosciamo l'idGara
                --INSERT INTO Document_SIMOG_GARA (idHeader, id_gara, idpfuRup, ID_SCELTA_CONTRAENTE, indexCollaborazione, StatoRichiestaGARA)
                --    VALUES (@idDocRichiestaCig, NULL, @Rup, @codiceProceduraSceltaContraente, @ggapUnitaOrganizzative, 'RecuperoDatiGgapInCorso')

                --SET @idRow = SCOPE_IDENTITY()

                ---- Inseriamo la sentinella di recuperato dati della gara.
                --INSERT INTO Service_SIMOG_Requests (idRichiesta, operazioneRichiesta, statoRichiesta, idPfuRup)
                --    VALUES (@idRow, 'consultaNumeroGaraGgap', 'Inserita', @Rup)

                ---- Conosciamo il CIG ==> per le mono-lotto @cig_numero_gara conterrà un cig
                --INSERT INTO Document_SIMOG_LOTTI (idHeader, CIG, AzioneProposta, StatoRichiestaLOTTO)
                --    VALUES (@idDocRichiestaCig, @cig_numero_gara, 'Insert', 'RecuperoDatiGgapInCorso')

                --SET @idRow = SCOPE_IDENTITY()

                ---- Inseriamo la sentinella di recuperato dati del lotto.
                --INSERT INTO Service_SIMOG_Requests (idRichiesta, operazioneRichiesta, statoRichiesta, idPfuRup)
                --    VALUES (@idRow, 'consultaCigGgap', 'Inserita', @Rup)


                -- Inseriamo la sentinella di recuperato dati del lotto.
                INSERT INTO Service_SIMOG_Requests (idRichiesta, operazioneRichiesta, statoRichiesta, idPfuRup)
                    VALUES (@idDocRichiestaCig, 'consultaNumeroGaraGgap', 'Inserita', @Rup)

		    END
		    ELSE -- Altrimenti è multi-lotto ==> questo significa che devo prendere i lotti (tutti) da GGAP chiamando l'end-point LeggiDatiProcedura
		    BEGIN
                ---- Conosciamo l'idGara ==> per le multi-lotto @cig_numero_gara conterrà un numero gara
                --INSERT INTO Document_SIMOG_GARA (idHeader, id_gara, idpfuRup, ID_SCELTA_CONTRAENTE, indexCollaborazione, StatoRichiestaGARA)
                --    VALUES (@idDocRichiestaCig, @cig_numero_gara, @Rup, @codiceProceduraSceltaContraente, @ggapUnitaOrganizzative, 'RecuperoDatiGgapInCorso')

                --SET @idRow = SCOPE_IDENTITY()

                ---- Inseriamo la sentinella di recuperato dati della gara.
                --INSERT INTO Service_SIMOG_Requests (idRichiesta, operazioneRichiesta, statoRichiesta, idPfuRup)
                --    VALUES (@idRow, 'consultaNumeroGaraGgap', 'Inserita', @Rup)


                -- Inseriamo la sentinella di recuperato dati della gara.
                INSERT INTO Service_SIMOG_Requests (idRichiesta, operazioneRichiesta, statoRichiesta, idPfuRup)
                    VALUES (@idDocRichiestaCig, 'consultaNumeroGaraGgap', 'Inserita', @Rup)
		    END

            -- Utilizzato come flag di controllo nel processo BANDO_GARA-LOAD_PRODOTTI_SUB (passo 65, DescrStep 'SIMOG. Se richiesto invoco il recupero dei dati') affinché 
            --  si possa invocare la richiesta dati simog (cioè eseguire questa SP, la RICHIESTA_CIG_CREATE_FROM_VERIFICA_INFORMAZIONI)
            --  Il delete è eseguito anche nel web service SimogGGAP alla fine della richiesta LeggiDatiProcedura cosi che posso invocare nuovamente questa SP.
		    DELETE FROM CTL_DOC_Value where IdHeader = @idDoc and DSE_ID = 'SIMOG_GET' and DZT_Name = 'FLAG_SYNC'
		    INSERT INTO CTL_DOC_Value( IdHeader, DSE_ID, DZT_Name, value ) values (@idDoc,'SIMOG_GET','FLAG_SYNC', 'InCorso')

        END

    END -- Altrimenti se non c'è il modulo SIMOG_GGAP: non siamo nel caso dedicato ad Insiel
    ELSE IF dbo.PARAMETRI('SIMOG' , 'SIMOG_GET', 'ATTIVO','NO',-1) = 'YES' and isnull(@RichiestaCigSimog,'no') = 'no' and isnull(@cig_numero_gara,'') <> '' 
            and @FLAG_SYNC_SIMOG IN ( '', 'InErrore' ) --, 'Popolata'  'Popolata' = ( gara recuperati ma gara non pubblicata ).
			AND EXISTS ( select id from SIMOG_LOGIN_RPNT_DATI_WS )
			and isnull(@rup,'') <> ''
			and dbo.attivoSimog() = 1
			and substring(@cig_numero_gara, 1,1) not in ('X','Y','Z')  
			and @Tipodoc <> 'BANDO_ASTA'
	BEGIN
		--annulliamo tutte le eventuali richieste in pending per consultaNumeroGara
		UPDATE Service_SIMOG_Requests
				set isOld = 1
			from Service_SIMOG_Requests r
					inner join Document_SIMOG_GARA g with(nolock) on g.idrow = r.idRichiesta and r.operazioneRichiesta = 'consultaNumeroGara' and r.isOld = 0 and r.statoRichiesta not in ( 'Errore', 'Elaborato' )
					inner join ctl_doc d with(nolock) on d.id = g.idHeader
			where d.LinkedDoc = @idDoc and d.deleted = 0 and d.TipoDoc in (  'RICHIESTA_CIG'  ) and d.StatoFunzionale <> 'Annullato' and d.versione = 'SIMOG_GET' 
		
		--annulliamo tutte le eventuali richieste in pending per consultaCIG
		UPDATE Service_SIMOG_Requests
				set isOld = 1
			from Service_SIMOG_Requests r
					inner join Document_SIMOG_LOTTI g with(nolock) on g.idrow = r.idRichiesta and r.operazioneRichiesta = 'consultaCIG' and r.isOld = 0 and r.statoRichiesta not in ( 'Errore', 'Elaborato' )
					inner join ctl_doc d with(nolock) on d.id = g.idHeader
			where d.LinkedDoc = @idDoc and d.deleted = 0 and d.TipoDoc in (  'RICHIESTA_CIG'  ) and d.StatoFunzionale <> 'Annullato' and d.versione = 'SIMOG_GET' 

		-- annulliamo tutti i documenti di RICHIESTA_CIG precedentemente inviati
		UPDATE CTL_DOC 
				set StatoFunzionale = 'Annullato', deleted = 1
			where LinkedDoc = @idDoc and deleted = 0 and TipoDoc in (  'RICHIESTA_CIG'  ) and StatoFunzionale <> 'Annullato' and versione = 'SIMOG_GET' 

		INSERT into CTL_DOC (IdPfu,  TipoDoc , idpfuincharge ,Azienda ,body,LinkedDoc, Versione, Caption, StatoFunzionale)
			select  @IdUser,'RICHIESTA_CIG' , @IdUser ,Azienda,body,@idDoc, 'SIMOG_GET' , 'Recupero dati SIMOG', 'InvioInCorso'
				from ctl_doc with(nolock)
				where id=@idDoc		

		set @newId = SCOPE_IDENTITY()

		--se monolotto
		IF @divisioneLotti = '0'
		BEGIN
			
			-- non conosciamo l'idgara
			insert into Document_SIMOG_GARA ( [idHeader],[id_gara],[idpfuRup])
				values ( @newId, '' , @Rup )

			-- conosciamo il cig
			insert into Document_SIMOG_LOTTI( idHeader, CIG )
				values ( @newid, @cig_numero_gara )

			set @idRow = SCOPE_IDENTITY()

			-- inseriamo la sentinella di recuperato dati partendo dal CIG. la stessa richiesta CIG recupererà con 1 sola chiamata anche i dati della gara
			insert into Service_SIMOG_Requests ( [idRichiesta], [operazioneRichiesta], [statoRichiesta], idPfuRup )
				values ( @idRow, 'consultaCIG' , 'Inserita' , @Rup )

		END
		ELSE
		BEGIN
			-- conosciamo l'idgara
			insert into Document_SIMOG_GARA ( [idHeader],[id_gara],[idpfuRup])
				values ( @newId, @cig_numero_gara , @Rup )

			set @idRow = SCOPE_IDENTITY()

			-- inseriamo la sentinella di recuperato dati partendo dal CIG. la stessa richiesta CIG recupererà con 1 sola chiamata anche i dati della gara
			insert into Service_SIMOG_Requests ( [idRichiesta], [operazioneRichiesta], [statoRichiesta], idPfuRup )
				values ( @idRow, 'consultaNumeroGara' , 'Inserita' , @Rup )

		END


		DELETE FROM CTL_DOC_Value where IdHeader = @idDoc and DSE_ID = 'SIMOG_GET' and DZT_Name = 'FLAG_SYNC'

		INSERT INTO CTL_DOC_Value( IdHeader, DSE_ID, DZT_Name, value ) values (@idDoc,'SIMOG_GET','FLAG_SYNC', 'InCorso')

	END
    ELSE
    BEGIN
    	SET @errore = 'Requisiti non soddisfatti per l''invio della richiesta'
    END



	IF ISNULL(@makeDocFrom,0) = 1
    BEGIN
    	-- rirorna l'id del doc da aprire
    	SELECT @newId AS id
    END
    ELSE
    BEGIN
    	SELECT 'Errore' AS id, @Errore AS Errore
    END
    
END

GO
