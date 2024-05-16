USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[RICHIESTA_CIG_CREATE_FROM_VERIFICA_INFORMAZIONI]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[RICHIESTA_CIG_CREATE_FROM_VERIFICA_INFORMAZIONI] ( @idDoc int , @IdUser int, @makeDocFrom int = 0 )
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
        ELSE IF ( 'RICHIESTA_CIG' IN (SELECT TipoDoc FROM CTL_DOC WHERE LinkedDoc=@idDoc AND Deleted = 0 AND StatoFunzionale NOT IN ('Annullato', 'Errore', 'RicevutoErrore')) 
					AND isnull(@RichiestaCigSimog,'no') = 'si' )
        BEGIN
            -- TODO: i seguenti annullamenti per operazioneRichiesta = a 'consultaNumeroGaraGgap' oppure = a 'consultaCigGgap' bisogna capire se lasciarli
            --      entrambi o rimuoverli a seconda di coma funziona la chiamata su GGAP; Se basta il numeroGara e ottengo tutte le info, sia riguardo alla gara
            --      che a tutti i lotti, allora si lascia solo l'annullamento per 'consultaNumeroGaraGgap'; Se invece per ottenere i dati sui lotti o su singolo lotto
            --      bisogna fare una chiamata a GGAP (passando il CIG) separata da quella per la gara allora è necessario lasciare entrambi gli annullamenti.
            --      A tal riguardo bisogna anche controllare la vista VIEW_Service_SIMOG_Requests per decidere se lasciare entrambi i seguenti case o 1 solo:
            --              WHEN operazioneRichiesta = 'consultaNumeroGaraGgap' THEN 'LeggiDatiProcedura'
            --              WHEN operazioneRichiesta = 'consultaCigGgap' THEN 'LeggiDatiProcedura'


            -- Recupero i dati della sezione GGAP: codiceProceduraSceltaContraente e unita organizzative
	        --DECLARE @codiceProceduraSceltaContraente AS INT
	        --DECLARE @ggapUnitaOrganizzative AS INT
         --   SELECT @codiceProceduraSceltaContraente=[Value] FROM CTL_DOC_Value WITH(NOLOCK) WHERE IdHeader=@idDoc AND DSE_ID='GGAP' AND DZT_Name='codiceProceduraSceltaContraente'
         --   SELECT @ggapUnitaOrganizzative=[Value] FROM CTL_DOC_Value WITH(NOLOCK) WHERE IdHeader=@idDoc AND DSE_ID='GGAP' AND DZT_Name='GgapUnitaOrganizzative'
            

            DECLARE @idDocRichiestaCig INT -- Contiene l'id della RICHIESTA_CIG corrrente
            
                SELECT TOP(1) @idDocRichiestaCig = Id
                    FROM CTL_DOC
                    WHERE LinkedDoc = @idDoc AND Deleted = 0 AND TipoDoc = 'RICHIESTA_CIG' AND StatoFunzionale NOT IN ('Annullato', 'Errore', 'RicevutoErrore')
                
                --SELECT @idDocRichiestaCig


		    -- Annulliamo tutte le eventuali richieste in pending per consultaNumeroGaraGgap e consultaCigGgap
            UPDATE Service_SIMOG_Requests
                SET isOld = 1--, statoRichiesta = 'Annullato'
                FROM Service_SIMOG_Requests R
                WHERE idRichiesta IN (@idDocRichiestaCig)
                        AND operazioneRichiesta IN ('consultaNumeroGaraGgap','consultaCigGgap')
                        AND R.isOld = 0 AND statoRichiesta NOT IN ('Annullato', 'Errore', 'RicevutoErrore')


            UPDATE Service_SIMOG_Requests
                SET isOld = 1--, statoRichiesta = 'Annullato'
                FROM Service_SIMOG_Requests R
                WHERE idRichiesta IN (SELECT Id FROM CTL_DOC
                                        WHERE LinkedDoc = @idDoc AND Deleted = 1 AND TipoDoc = 'RICHIESTA_CIG' AND StatoFunzionale IN ('Annullato', 'Errore', 'RicevutoErrore'))
                        AND operazioneRichiesta IN ('consultaNumeroGaraGgap','consultaCigGgap')
                        AND R.isOld = 0 AND statoRichiesta NOT IN ('Annullato', 'Errore', 'RicevutoErrore')


            IF(@cig_numero_gara = '')
                SET @cig_numero_gara = null


		    -- Se monolotto ==> questo significa che ci sarà un solo lotto che posso già imbastire dove poi integro i dati recuperati da GGAP chiamando l'end-point LeggiDatiProcedura
		    --IF @divisioneLotti = '0'
		    --BEGIN              
			
               -- -- Inseriamo la sentinella di recuperato dati del lotto.
               -- INSERT INTO Service_SIMOG_Requests (idRichiesta, operazioneRichiesta, statoRichiesta, idPfuRup)
               --     VALUES (@idDocRichiestaCig, 'consultaNumeroGaraGgap', 'Inserita', @Rup)

		    --END
		    --ELSE -- Altrimenti è multi-lotto ==> questo significa che devo prendere i lotti (tutti) da GGAP chiamando l'end-point LeggiDatiProcedura
		    --BEGIN               


               -- -- Inseriamo la sentinella di recuperato dati della gara.
               -- INSERT INTO Service_SIMOG_Requests (idRichiesta, operazioneRichiesta, statoRichiesta, idPfuRup)
               --     VALUES (@idDocRichiestaCig, 'consultaNumeroGaraGgap', 'Inserita', @Rup)
		    --END

			INSERT INTO Service_SIMOG_Requests (idRichiesta, operazioneRichiesta, statoRichiesta, idPfuRup)
                    VALUES (@idDocRichiestaCig, 'consultaNumeroGaraGgap', 'Inserita', @Rup)

            -- Utilizzato come flag di controllo nel processo BANDO_GARA-LOAD_PRODOTTI_SUB (passo 65, DescrStep 'SIMOG. Se richiesto invoco il recupero dei dati') affinché 
            --  si possa invocare la richiesta dati simog (cioè eseguire questa SP, la RICHIESTA_CIG_CREATE_FROM_VERIFICA_INFORMAZIONI)
            --  Il delete è eseguito anche nel web service SimogGGAP alla fine della richiesta LeggiDatiProcedura cosi che posso invocare nuovamente questa SP.
		    DELETE FROM CTL_DOC_Value where IdHeader = @idDoc AND DSE_ID = 'SIMOG_GET' AND DZT_Name = 'FLAG_SYNC'
		    INSERT INTO CTL_DOC_Value( IdHeader, DSE_ID, DZT_Name, value ) values (@idDoc,'SIMOG_GET','FLAG_SYNC', 'InCorso')

        END
		ELSE IF ( isnull(@RichiestaCigSimog,'no') = 'no' AND LTRIM(RTRIM(isnull(@cig_numero_gara, ''))) <> '' )
		begin
			---------------------------------------------------------------------------------------------------------
			-- caso della richiesta dati simog che si attiva se richiesta cig = NO e Numero gara digitato da utente
			---------------------------------------------------------------------------------------------------------
			DECLARE @idDocumentoRicCig INT 
			declare @versioneGGAP varchar(50)

			select top 1 @versioneGGAP = DZT_ValueDef from LIB_Dictionary with(nolock) where DZT_Name = 'SYS_VERSIONE_SIMOG'

			 SELECT TOP(1) @idDocumentoRicCig = Id
                    FROM CTL_DOC
                    WHERE LinkedDoc = @idDoc AND Deleted = 0 AND TipoDoc = 'RICHIESTA_CIG' 
						AND StatoFunzionale NOT IN ('Annullato', 'Errore', 'RicevutoErrore')
                

			UPDATE Service_SIMOG_Requests
                SET isOld = 1--, statoRichiesta = 'Annullato'
                FROM Service_SIMOG_Requests R
                WHERE idRichiesta IN (@idDocumentoRicCig)
                        AND operazioneRichiesta IN ('recuperaNumeroGaraGgap')
                        AND R.isOld = 0 AND statoRichiesta NOT IN ('Annullato', 'Errore', 'RicevutoErrore')

            UPDATE Service_SIMOG_Requests
                SET isOld = 1--, statoRichiesta = 'Annullato'
                FROM Service_SIMOG_Requests R
                WHERE idRichiesta IN (SELECT Id FROM CTL_DOC
                                        WHERE LinkedDoc = @idDoc AND Deleted = 1 AND TipoDoc = 'RICHIESTA_CIG' AND StatoFunzionale IN ('Annullato', 'Errore', 'RicevutoErrore'))
                        AND operazioneRichiesta IN ('recuperaNumeroGaraGgap')
                        AND R.isOld = 0 AND statoRichiesta NOT IN ('Annullato', 'Errore', 'RicevutoErrore')


			-- annulliamo tutti i documenti di RICHIESTA_CIG precedentemente inviati
			UPDATE CTL_DOC 
					set StatoFunzionale = 'Annullato', deleted = 1
				where LinkedDoc = @idDoc and deleted = 0 and TipoDoc in (  'RICHIESTA_CIG'  ) 
							and StatoFunzionale <> 'Annullato' and versione = @versioneGGAP	
										
			INSERT INTO CTL_DOC (IdPfu,  TipoDoc  , idpfuincharge ,Azienda ,body,LinkedDoc, Versione, StatoFunzionale )
			        	SELECT  @IdUser, 'RICHIESTA_CIG', @IdUser, Azienda, Body, @idDoc, @versioneGGAP, 'InvioInCorso'
			        		FROM CTL_DOC WITH(NOLOCK)
			        		WHERE Id=@idDoc

			--set @newId = SCOPE_IDENTITY()
			SET @idDocumentoRicCig = SCOPE_IDENTITY()

            
            -- Recupero i dati della sezione GGAP: codiceProceduraSceltaContraente e unita organizzative
	        --DECLARE @codiceProceduraSceltaContraente AS INT
	        DECLARE @ggapUnitaOrganizzative AS INT
            --SELECT @codiceProceduraSceltaContraente=[Value] FROM CTL_DOC_Value WITH(NOLOCK) WHERE IdHeader=@idDoc AND DSE_ID='GGAP' AND DZT_Name='codiceProceduraSceltaContraente'
            SELECT @ggapUnitaOrganizzative=[Value] FROM CTL_DOC_Value WITH(NOLOCK) WHERE IdHeader=@idDoc AND DSE_ID='GGAP' AND DZT_Name='GgapUnitaOrganizzative'
            

			--se monolotto
			IF @divisioneLotti = '0'
			BEGIN
				-- non conosciamo l'idgara
				insert into Document_SIMOG_GARA ( idHeader, id_gara, idpfuRup, AzioneProposta, StatoRichiestaGARA, indexCollaborazione)
					values ( @idDocumentoRicCig, '' , @Rup, 'Insert', 'InvioInCorso', @ggapUnitaOrganizzative )

                -- TODO: commentato perchè finché GGAP non torna i dati non si sa quanti lotti ci sono, perciò quando GGAP torna i dati si dovrebbe fare 
                --          un solo update e n insert (a seconda di quanti lotti ci sono) e comunque anchè se é monolotto nel servizio con C# (SimogGgap)
                --          dovrei fare una distinzione tra monolotto (update) e multilotto (n insert). Siccome questo insert qua non contiene molto peso
                --          preferisco commentarlo e gestire solo insert latto C#.
				---- conosciamo il cig
				--insert into Document_SIMOG_LOTTI( idHeader, CIG )
				--	values ( @idDocumentoRicCig, @cig_numero_gara )

				--set @idRow = SCOPE_IDENTITY()

				-- inseriamo la sentinella di recuperato dati partendo dal CIG. la stessa richiesta CIG recupererà con 1 sola chiamata anche i dati della gara
				--insert into Service_SIMOG_Requests ( [idRichiesta], [operazioneRichiesta], [statoRichiesta], idPfuRup )
				--	values ( @idRow, 'consultaCIG' , 'Inserita' , @Rup )
			END
			ELSE
			BEGIN
				-- conosciamo l'idgara
				insert into Document_SIMOG_GARA ( idHeader, id_gara, idpfuRup, AzioneProposta, StatoRichiestaGARA, indexCollaborazione )
					values ( @idDocumentoRicCig, @cig_numero_gara , @Rup, 'Insert', 'InvioInCorso', @ggapUnitaOrganizzative )

				--set @idRow = SCOPE_IDENTITY()

				-- inseriamo la sentinella di recuperato dati partendo dal CIG. la stessa richiesta CIG recupererà con 1 sola chiamata anche i dati della gara
				--insert into Service_SIMOG_Requests ( [idRichiesta], [operazioneRichiesta], [statoRichiesta], idPfuRup )
				--	values ( @idRow, 'consultaNumeroGara' , 'Inserita' , @Rup )
			END

			INSERT INTO Service_SIMOG_Requests (idRichiesta, operazioneRichiesta, statoRichiesta, idPfuRup)
                VALUES (@idDocumentoRicCig, 'recuperaNumeroGaraGgap', 'Inserita', @Rup)


			DELETE FROM CTL_DOC_Value where IdHeader = @idDoc and DSE_ID = 'SIMOG_GET' and DZT_Name = 'FLAG_SYNC'
			INSERT INTO CTL_DOC_Value( IdHeader, DSE_ID, DZT_Name, value ) values (@idDoc,'SIMOG_GET','FLAG_SYNC', 'InCorso')
		END   --ELSE IF ( 'RICHIESTA_CIG' IN (SELECT TipoDoc FROM CTL_DOC WHERE LinkedDoc=@idDoc AND Deleted = 0 AND StatoFunzionale NOT IN ('Annullato', 'Errore', 'RicevutoErrore')) 
					--and isnull(@RichiestaCigSimog,'no') = 'no' AND LTRIM(RTRIM(isnull(@cig_numero_gara, ''))) <> '' )

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
