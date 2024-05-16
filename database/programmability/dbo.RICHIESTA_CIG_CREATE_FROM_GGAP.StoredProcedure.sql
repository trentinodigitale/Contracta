USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[RICHIESTA_CIG_CREATE_FROM_GGAP]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[RICHIESTA_CIG_CREATE_FROM_GGAP] ( @idDoc int , @IdUser int )
AS
BEGIN

	SET NOCOUNT ON

	declare @Id as INT
	declare @Idazi as INT
	declare @Errore as nvarchar(2000)
	declare @newid as int
	declare @idr as int
	declare @Bando as int
	declare @Rup varchar(50)
	declare @COD_LUOGO_ISTAT varchar(50)
	declare @CODICE_CPV varchar(50)
	declare @Body nvarchar( max )

	declare @CF_AMMINISTRAZIONE varchar(20)
	declare @CF_UTENTE varchar(20)
	declare @NumLotti int
	declare @TipoAppaltoGara as varchar(50)

	declare @versioneSimog varchar(100)
	declare @docVersione varchar(100)
	declare @statoFunzDoc varchar(100)
	declare @Tipo_Rup as varchar(100)

	set @Errore=''	
	set @versioneSimog = '3.4.2' 
    
    -- Versione dei WS simog. settata sul documento RICHIESTA_CIG. Utile per rilasciare aggiornamenti retrocompatibili in produzione
	select top 1 @versioneSimog = DZT_ValueDef from LIB_Dictionary with(nolock) where DZT_Name = 'SYS_VERSIONE_SIMOG'

	--- CERCO UNA RICHIESTA CIG NON ANNULLATA
	select @newId = max(id) from CTL_DOC  with(nolock)
        where LinkedDoc = @idDoc and Deleted = 0 and TipoDoc in (  'RICHIESTA_CIG'  ) and StatoFunzionale <> 'Annullato' --and isnull( JumpCheck , '' ) = ''

	if @newId is null -- Se la RICHIESTA_CIG manca o è nello stato di Annullato
	begin

		set @Bando = @idDoc

		-- Prima di creare il documento verifico i requisiti necessari:
			-- 1) Trovare prodotti senza errori
			-- 2) Sia stato selezionato luogo istat e cpv
			-- 3) Sia stato inserito l'oggetto
			-- 4) Sia presente il RUP
			-- 5) Controllo l'Importo Appalto
            -- 6) Controllo per anomalie/errori nella sezione PRODOTTI/TESTATA_PRODOTTI
            -- 7) Verfifica dell'unità organizzativa
		
		-- 1) Trovare prodotti senza errori
		IF EXISTS ( select Id from CTL_DOC with(nolock) where LinkedDoc = @idDoc and Deleted = 0 and TipoDoc in (  'RICHIESTA_SMART_CIG'  ) and StatoFunzionale <> 'Annullato' )
		BEGIN
			set @Errore = 'Impossibile effettuare una richiesta CIG con una RICHIESTA SMART CIG in corso'
		END
		

		-- 2) Verifico che sia stato selezionato luogo istat e cpv
        IF @Errore = ''
        BEGIN
            DECLARE @tipo_bando AS VARCHAR(500)

            SELECT @tipo_bando = isnull(TipoProceduraCaratteristica, '')
                FROM Document_Bando WITH (NOLOCK)
                WHERE idheader = @idDoc

		    if @tipo_bando <> 'AffidamentoSemplificato'
			begin
				-- verifica luogo istat non selezionato
				if @Errore = ''
				begin
					select @COD_LUOGO_ISTAT = Value from ctl_doc_value  with(nolock) where idheader = @Bando and dse_id = 'InfoTec_SIMOG' and dzt_name = 'COD_LUOGO_ISTAT' 
					if ISNULL( @COD_LUOGO_ISTAT , '' ) = ''
						set @Errore = 'Per effettuare la richiesta dei CIG Occorre aver indicato il Luogo ISTAT nella scheda "Informazioni Tecniche"'
				end

				-- verifica CPV non selezionata
				if @Errore = ''
				begin
					select @CODICE_CPV = Value from ctl_doc_value  with(nolock) where idheader = @Bando and dse_id = 'InfoTec_SIMOG' and dzt_name = 'CODICE_CPV' 
					if ISNULL( @CODICE_CPV , '' ) = '' 
						set @Errore = 'Per effettuare la richiesta dei CIG Occorre aver indicato il Codice identificativo corrispondente al sistema di codifica CPV nella scheda "Informazioni Tecniche"'
				end
			end
        END
		

		-- 3) verifica Oggetto
		if @Errore = ''
		begin

			select @Body = body from CTL_DOC with(nolock) where id = @Bando

			if isnull( @Body , '' ) = '' 
				set @Errore = 'Per effettuare la richiesta dei CIG Occorre aver inserito l''oggetto della gara'

		end


		-- 4) verifica rup non selezionato
		if @Errore = ''
		begin
			select @Tipo_Rup=dbo.PARAMETRI ('SIMOG','TIPO_RUP','DefaultValue','UserRUP',-1) 

			if @Tipo_Rup='UserRUP'
				select @Rup = Value from ctl_doc_value  with(nolock) where idheader = @Bando and dse_id = 'InfoTec_comune' and dzt_name = @Tipo_Rup 
			else
				select @Rup = RupProponente from document_bando  with(nolock) where idheader = @Bando 
			

			if isnull( @Rup , '' ) = '' 
			begin
				if @Tipo_Rup='UserRUP'	
					set @Errore = 'Per effettuare la richiesta dei CIG Occorre aver indicato il RUP'
				else
					set @Errore = 'Per effettuare la richiesta dei CIG Occorre aver indicato il RUP proponente'
			end
		end


        -- 5) Controllo se è valorizzato l'Importo Appalto
		if @Errore = ''
		begin
			if exists ( select idrow from Document_Bando with(nolock) where idHeader = @Bando and isnull(importoBaseAsta,0) = 0 )
				set @Errore = 'Per effettuare la richiesta dei CIG Occorre aver indicato l''Importo Appalto'
		end


        -- 6) Controllo se ci sono anomalie/errori nella sezione PRODOTTI/TESTATA_PRODOTTI (tab Prodotti)
		if @Errore = ''
		begin
			if exists ( select idrow from ctl_doc_value with(nolock) where idheader = @Bando and dse_id = 'TESTATA_PRODOTTI' and dzt_name='esitoRiga' and [value] like '%State_ERR%' )
				set @Errore = 'Operazione non consentita in quanto sono presenti anomalie da correggere nell''Elenco Prodotti. Prima di procedere con la richiesta, dopo aver cliccato su ok...'
		end


        -- 7) Si verifica che sia stata scelta l'unità organizzativa nel caso in cui il campo "Richiesta CIG su SIMOG" sia impostato a si
        IF @Errore = ''
        BEGIN
            DECLARE @ggapUnitaOrganizzativeIndex NVARCHAR(10)
            
                SELECT @ggapUnitaOrganizzativeIndex = [Value]
                    FROM CTL_DOC_Value WITH(NOLOCK) WHERE IdHeader = @Bando AND DSE_ID = 'GGAP' AND DZT_Name = 'GgapUnitaOrganizzative'


            DECLARE @richiestaCigSuSIMOG NVARCHAR(2)

                SELECT @richiestaCigSuSIMOG = RichiestaCigSimog
                    FROM Document_Bando
                    WHERE idHeader = @Bando


            --SELECT @ggapUnitaOrganizzativeIndex, @richiestaCigSuSIMOG

            IF (ISNULL( @ggapUnitaOrganizzativeIndex, '' ) = '' AND @richiestaCigSuSIMOG = 'si')
                SET @Errore = 'Prima di fare la richiesta è necessario scegliere l''unità organizativa.'
        END

		
		-- Se NON sono presenti errori
		if @Errore = ''
		begin
            -- Recupero i dati della sezione GGAP: codiceProceduraSceltaContraente e unita organizzative
            --DECLARE @idDoc AS INT = 472509
	        DECLARE @codiceProceduraSceltaContraente AS INT
	        DECLARE @ggapUnitaOrganizzative AS INT
            SELECT @codiceProceduraSceltaContraente=[Value] FROM CTL_DOC_Value WITH(NOLOCK) WHERE IdHeader=@idDoc AND DSE_ID='GGAP' AND DZT_Name='codiceProceduraSceltaContraente'
            SELECT @ggapUnitaOrganizzative=[Value] FROM CTL_DOC_Value WITH(NOLOCK) WHERE IdHeader=@idDoc AND DSE_ID='GGAP' AND DZT_Name='GgapUnitaOrganizzative'
            --SELECT @codiceProceduraSceltaContraente, @ggapUnitaOrganizzative


			-- CREO IL DOCUMENTO:
            --      A) se non esite già uno lo creo nuovo
            --      B) altrimenti se esiste uno in stato di 'Annullato' o 'Errore' (che magari ha già id fornito da GGAP) creo uno nuovo partendo dal vecchio più recente
            DECLARE @idDocRichiestaCig INT

                SELECT TOP 1 @idDocRichiestaCig = Id
                    FROM CTL_DOC
                    WHERE LinkedDoc = @idDoc AND Deleted = 0 AND TipoDoc = 'RICHIESTA_CIG' AND StatoFunzionale IN ('Annullato', 'Errore', 'RicevutoErrore')
                    ORDER BY Id DESC

                IF (ISNULL(@idDocRichiestaCig, -1) = -1) -- A)
                BEGIN
			        INSERT INTO CTL_DOC (IdPfu,  TipoDoc  , idpfuincharge ,Azienda ,body,LinkedDoc, Versione, StatoFunzionale )
			        	SELECT  @IdUser, 'RICHIESTA_CIG', @IdUser, Azienda, Body, @idDoc, @versioneSimog, 'InvioInCorso'
			        		FROM CTL_DOC WITH(NOLOCK)
			        		WHERE Id=@idDoc

			        SET @newId = SCOPE_IDENTITY()
                END
                ELSE -- B)
                BEGIN
			        INSERT INTO CTL_DOC (IdPfu, TipoDoc, idPfuInCharge, Azienda, Body, LinkedDoc, Versione, StatoFunzionale, NumeroDocumento )
			        	SELECT TOP 1 IdPfu, TipoDoc, idPfuInCharge, Azienda, Body, LinkedDoc, Versione , 'InvioInCorso', NumeroDocumento
			        		FROM CTL_DOC WITH(NOLOCK)
			        		WHERE Id=@idDocRichiestaCig
                            ORDER BY Id DESC

			        SET @newId = SCOPE_IDENTITY()
                END



			if @versioneSimog < '3.4.6'
			begin

				INSERT INTO CTL_DOC_SECTION_MODEL( IdHeader, DSE_ID, MOD_Name)
					VALUES ( @newid, 'GARA', 'RICHIESTA_CIG_GARA_3_4_5' )

				INSERT INTO CTL_DOC_SECTION_MODEL( IdHeader, DSE_ID, MOD_Name)
					VALUES ( @newid, 'LOTTI', 'RICHIESTA_CIG_LOTTI_3_4_5' )
					
			end
			

			-- se la versione è 3.4.6 oppure 3.4.7 metto altri modelli
			if @versioneSimog in ( '3.4.6' , '3.4.7')
			begin

				INSERT INTO CTL_DOC_SECTION_MODEL( IdHeader, DSE_ID, MOD_Name)
					VALUES ( @newid, 'GARA', 'RICHIESTA_CIG_GARA_3_4_6_7' )

				INSERT INTO CTL_DOC_SECTION_MODEL( IdHeader, DSE_ID, MOD_Name)
					VALUES ( @newid, 'LOTTI', 'RICHIESTA_CIG_LOTTI_3_4_6_7' )
					
			end


			-- recupero il codice fiscale dell'ente
			select @CF_AMMINISTRAZIONE = vatValore_FT 
				from ctl_doc with(nolock) 
					inner join DM_Attributi with(nolock) on Azienda = lnk and idApp = 1 and dztNome = 'codicefiscale'
				where id = @Bando
			

            -- Recupero il Tipo Appalto nella codifica ANAC
			select @TipoAppaltoGara= case when TipoAppaltoGara = '1' then 'F' -- Forniture
										  when TipoAppaltoGara = '2' then 'L' -- Lavori (pubblici)
										  when TipoAppaltoGara = '3' then 'S' -- Servizi
										  else ''
									  end				
				from Document_Bando DB with(nolock) 
				where idHeader=@Bando


			-- recupero il CF del RUP
			select @CF_UTENTE = pfucodicefiscale  from ProfiliUtente with(nolock) where idpfu = @Rup 


            -- Recupero il numero dei lotti
			select @NumLotti = count(*)
                from ctl_doc b with(nolock)
                        inner join Document_MicroLotti_Dettagli d with(nolock) on d.IdHeader = b.id and b.TipoDoc = d.TipoDoc and d.voce = 0
                where b.id = @Bando

			if isnull( @NumLotti, 0 ) = 0
				set @NumLotti = 1


			-- inserisco i dati base della gara
			insert into Document_SIMOG_GARA
				( idHeader, indexCollaborazione, ID_STAZIONE_APPALTANTE, DENOM_STAZIONE_APPALTANTE, CF_AMMINISTRAZIONE, DENOM_AMMINISTRAZIONE
                    , CF_UTENTE, IMPORTO_GARA, TIPO_SCHEDA, MODO_REALIZZAZIONE, NUMERO_LOTTI, ESCLUSO_AVCPASS, URGENZA_DL133, CATEGORIE_MERC
                    , ID_SCELTA_CONTRAENTE, StatoRichiestaGARA, EsitoControlli, id_gara, idpfuRup, STRUMENTO_SVOLGIMENTO, AzioneProposta )
				select 
						@newId				                as [idHeader],
						@ggapUnitaOrganizzative             as [indexCollaborazione], 
						''					                as [ID_STAZIONE_APPALTANTE], 
						''					                as [DENOM_STAZIONE_APPALTANTE], 
						@CF_AMMINISTRAZIONE                 as [CF_AMMINISTRAZIONE], 
						''					                as [DENOM_AMMINISTRAZIONE], 
						@CF_UTENTE			                as [CF_UTENTE], 
						b.importoBaseAsta		            as [IMPORTO_GARA], -- comprensivo di oneri e opzioni
						''					                as [TIPO_SCHEDA], 
						''					                as [MODO_REALIZZAZIONE], 
						@NumLotti			                as [NUMERO_LOTTI], 
						''					                as [ESCLUSO_AVCPASS], 
						''					                as [URGENZA_DL133], 
						''					                as [CATEGORIE_MERC],
						@codiceProceduraSceltaContraente    as [ID_SCELTA_CONTRAENTE],
						'InvioInCorso'					    as [StatoRichiestaGARA], 
						''					                as [EsitoControlli], 
						''					                as [id_gara], 
						@Rup				                as [idpfuRup],
						case
                            when a.TipoDoc = 'BANDO_SEMPLIFICATO' then '7'
                            else ''
                        end                                 as STRUMENTO_SVOLGIMENTO --Sistema dinamico di acquisizione
                        , 'Insert' AS AzioneProposta

					from ctl_doc a with(nolock)
							inner join document_bando b with(nolock)  on b.idHeader = a.id
					where a.id = @Bando


            --DECLARE @garaDatoRichiesto VARCHAR(10)

            --    SELECT TOP 1 @garaDatoRichiesto = R.datoRichiesto
            --            FROM Document_SIMOG_GARA G
            --                INNER JOIN Service_SIMOG_Requests R WITH (NOLOCK) ON G.idRow = R.idRichiesta AND R.operazioneRichiesta = 'garaInserisciGgap' AND R.isOld = 0
            --                INNER JOIN CTL_DOC D WITH (NOLOCK) ON D.id = idheader
            --            WHERE G.idHeader = @newId AND ISNULL(R.datoRichiesto,'') <> ''
            --            ORDER BY R.idRow DESC

            
	        -- Inserisco nella Service_SIMOG_Requests le richieste che non sono presenti
            INSERT INTO Service_SIMOG_Requests (idRichiesta, statoRichiesta, idPfuRup, operazioneRichiesta) --, datoRichiesto)
                SELECT G.idrow, 'Inserita', G.idpfuRup, 'garaInserisciGgap' -- , @garaDatoRichiesto
                    FROM Document_SIMOG_GARA G
                        LEFT JOIN Service_SIMOG_Requests R WITH (NOLOCK) ON G.idRow = R.idRichiesta AND R.operazioneRichiesta = 'garaInserisciGgap' AND R.isOld = 0
                        INNER JOIN CTL_DOC D WITH (NOLOCK) ON D.id = idheader
                    WHERE G.idHeader = @newId
                            AND R.idRow IS NULL
                    	    AND (
                    	    	    ( isnull(D.jumpcheck, '') = 'MODIFICA' AND isnull(G.AzioneProposta, '') <> 'Equal' )
                    	    	    OR
                                    ( isnull(D.jumpcheck, '') <> 'MODIFICA' AND isnull(G.id_gara, '') = '' )
                    	    )


			-- inserisco i dati dei lotti:
            --      > se non esistono già le creo nuove
            --      > altrimenti se esistono (che magari hanno già gli id forniti da GGAP) creo nuovi record partendo dai vecchi
            IF (ISNULL(@idDocRichiestaCig, -1) = -1)
            BEGIN
                insert into Document_SIMOG_LOTTI
			    	( idHeader, NumeroLotto, OGGETTO, SOMMA_URGENZA, IMPORTO_LOTTO, IMPORTO_SA, IMPORTO_IMPRESA, CPV, ID_SCELTA_CONTRAENTE
                        , ID_CATEGORIA_PREVALENTE, TIPO_CONTRATTO, FLAG_ESCLUSO, LUOGO_ISTAT, IMPORTO_ATTUAZIONE_SICUREZZA, FLAG_PREVEDE_RIP
                        , FLAG_RIPETIZIONE, FLAG_CUP, CATEGORIA_SIMOG, EsitoControlli, StatoRichiestaLOTTO, CIG, IMPORTO_OPZIONI, CUP, FLAG_PNRR_PNC
                        , ID_MOTIVO_DEROGA, FLAG_MISURE_PREMIALI, ID_MISURA_PREMIALE, FLAG_PREVISIONE_QUOTA, QUOTA_FEMMINILE, QUOTA_GIOVANILE, MODALITA_ACQUISIZIONE
                        , AzioneProposta )
			    	select 
			    			@newId							as [idHeader], 
			    			d.NumeroLotto,
			    			d.Descrizione					as [OGGETTO], 
			    			'N'								as [SOMMA_URGENZA], 
			    			--d.ValoreImportoLotto			as [IMPORTO_LOTTO],
			    			d.ValoreImportoLotto + ISNULL(d.IMPORTO_ATTUAZIONE_SICUREZZA,0) + ISNULL(d.IMPORTO_OPZIONI,0) as [IMPORTO_LOTTO],
			    			0								as [IMPORTO_SA], 
			    			0								as [IMPORTO_IMPRESA], 
			    			@CODICE_CPV						as [CPV], 
			    			--case when b.TipoDoc = 'BANDO_SEMPLIFICATO' then '6' else '' end as [ID_SCELTA_CONTRAENTE],
			    			''                              as [ID_SCELTA_CONTRAENTE],
			    			''								as [ID_CATEGORIA_PREVALENTE], 
			    			@TipoAppaltoGara				as [TIPO_CONTRATTO], 
			    			'N'								as [FLAG_ESCLUSO], 
			    			@COD_LUOGO_ISTAT				as [LUOGO_ISTAT], 
			    			--0								as [IMPORTO_ATTUAZIONE_SICUREZZA], 
			    			d.IMPORTO_ATTUAZIONE_SICUREZZA,
			    			'N'								as [FLAG_PREVEDE_RIP], 
			    			'N'								as [FLAG_RIPETIZIONE], 
			    			'N'								as [FLAG_CUP], 
			    			''								as [CATEGORIA_SIMOG], 
			    			''								as [EsitoControlli], 
			    			'InvioInCorso'					as [StatoRichiestaLOTTO], 
			    			''								as [CIG],
			    			d.IMPORTO_OPZIONI,						
			    			db.CUP

			    			, case when db.Appalto_PNRR_PNC = '1' then 'S' else 'N' end as FLAG_PNRR_PNC
			    			, db.ID_MOTIVO_DEROGA
			    			, db.FLAG_MISURE_PREMIALI
			    			, db.ID_MISURA_PREMIALE
			    			, db.FLAG_PREVISIONE_QUOTA
			    			, db.QUOTA_FEMMINILE
			    			, db.QUOTA_GIOVANILE
			    			, '1' AS [MODALITA_ACQUISIZIONE]
                            , 'Insert' AS AzioneProposta

			    		from ctl_doc b with(nolock) 
			    			inner join document_bando db with(nolock)  on db.idHeader=b.id 
			    			inner join Document_MicroLotti_Dettagli d with(nolock) on d.IdHeader = b.id and b.TipoDoc = d.TipoDoc and d.voce = 0 
			    		where b.id = @Bando
			    		order by d.id
            END
            ELSE
            BEGIN
                INSERT INTO Document_SIMOG_LOTTI
			    	( idHeader, NumeroLotto, OGGETTO, SOMMA_URGENZA, IMPORTO_LOTTO, IMPORTO_SA, IMPORTO_IMPRESA, CPV, ID_SCELTA_CONTRAENTE
                        , ID_CATEGORIA_PREVALENTE, TIPO_CONTRATTO, FLAG_ESCLUSO, LUOGO_ISTAT, IMPORTO_ATTUAZIONE_SICUREZZA, FLAG_PREVEDE_RIP
                        , FLAG_RIPETIZIONE, FLAG_CUP, CATEGORIA_SIMOG, EsitoControlli, StatoRichiestaLOTTO, CIG, IMPORTO_OPZIONI, CUP, FLAG_PNRR_PNC
                        , ID_MOTIVO_DEROGA, FLAG_MISURE_PREMIALI, ID_MISURA_PREMIALE, FLAG_PREVISIONE_QUOTA, QUOTA_FEMMINILE, QUOTA_GIOVANILE, MODALITA_ACQUISIZIONE
                        , idLottoEsterno, AzioneProposta )
                    SELECT TOP (@NumLotti) -- L'istruzione << TOP >> è in combinazione con l'istruzione << ORDER BY L.idRow ASC >>
			    			@newId							as [idHeader], 
			    			d.NumeroLotto,
			    			d.Descrizione					as [OGGETTO], 
			    			'N'								as [SOMMA_URGENZA], 
			    			--d.ValoreImportoLotto			as [IMPORTO_LOTTO],
			    			d.ValoreImportoLotto + ISNULL(d.IMPORTO_ATTUAZIONE_SICUREZZA,0) + ISNULL(d.IMPORTO_OPZIONI,0) as [IMPORTO_LOTTO],
			    			0								as [IMPORTO_SA], 
			    			0								as [IMPORTO_IMPRESA], 
			    			@CODICE_CPV						as [CPV], 
			    			--case when b.TipoDoc = 'BANDO_SEMPLIFICATO' then '6' else '' end as [ID_SCELTA_CONTRAENTE],
			    			''                              as [ID_SCELTA_CONTRAENTE],
			    			''								as [ID_CATEGORIA_PREVALENTE], 
			    			@TipoAppaltoGara				as [TIPO_CONTRATTO], 
			    			'N'								as [FLAG_ESCLUSO], 
			    			@COD_LUOGO_ISTAT				as [LUOGO_ISTAT], 
			    			--0								as [IMPORTO_ATTUAZIONE_SICUREZZA], 
			    			d.IMPORTO_ATTUAZIONE_SICUREZZA,
			    			'N'								as [FLAG_PREVEDE_RIP], 
			    			'N'								as [FLAG_RIPETIZIONE], 
			    			'N'								as [FLAG_CUP], 
			    			''								as [CATEGORIA_SIMOG], 
			    			''								as [EsitoControlli], 
			    			'InvioInCorso'					as [StatoRichiestaLOTTO], 
			    			L.CIG								as [CIG],
			    			d.IMPORTO_OPZIONI,						
			    			db.CUP

			    			, case when db.Appalto_PNRR_PNC = '1' then 'S' else 'N' end as FLAG_PNRR_PNC
			    			, db.ID_MOTIVO_DEROGA
			    			, db.FLAG_MISURE_PREMIALI
			    			, db.ID_MISURA_PREMIALE
			    			, db.FLAG_PREVISIONE_QUOTA
			    			, db.QUOTA_FEMMINILE
			    			, db.QUOTA_GIOVANILE
			    			, '1' AS [MODALITA_ACQUISIZIONE]
                            , idLottoEsterno
                            , 'Insert' AS AzioneProposta

                    FROM CTL_DOC B WITH (NOLOCK)
                            INNER JOIN Document_Bando DB WITH (NOLOCK) ON DB.idHeader = B.id
                            INNER JOIN Document_MicroLotti_Dettagli D WITH (NOLOCK) ON D.IdHeader = B.id AND B.TipoDoc = D.TipoDoc AND D.voce = 0
                            INNER JOIN CTL_DOC RiCig ON B.Id = RiCig.LinkedDoc AND D.IdHeader = RiCig.LinkedDoc AND RiCig.TipoDoc = 'RICHIESTA_CIG'
                            INNER JOIN Document_SIMOG_LOTTI L ON RiCig.Id = L.idHeader
                    WHERE B.id = @Bando AND ( RiCig.Id = @idDocRichiestaCig OR RiCig.Id IS NULL )
                    ORDER BY L.idRow ASC
            END
        

	        -- Inserisco nella Service_SIMOG_Requests le richieste che non sono presenti
	        INSERT INTO Service_SIMOG_Requests (idRichiesta, statoRichiesta, idPfuRup, operazioneRichiesta)
                SELECT L.idrow, 'Inserita', G.idpfuRup, 'lottoInserisciGgap'
                    FROM Document_SIMOG_LOTTI L WITH (NOLOCK)
                            LEFT JOIN Service_SIMOG_Requests R WITH (NOLOCK) ON R.idRichiesta = L.idRow AND R.operazioneRichiesta = 'lottoInserisciGgap' AND R.isOld = 0
                            INNER JOIN CTL_DOC D WITH (NOLOCK) ON D.id = idheader
                            INNER JOIN Document_SIMOG_GARA G WITH (NOLOCK) ON G.idHeader = D.Id
                    WHERE L.idHeader = @newId
                    	    AND R.idRow IS NULL
                    	    AND (
                    		        ( D.jumpcheck = 'MODIFICA' AND isnull(L.AzioneProposta, '') <> 'Equal' )
                    		        OR
                                    ( isnull(D.jumpcheck, '') <> 'MODIFICA' AND isnull(L.CIG, '') = '' )
                    		)
                    ORDER BY L.idRow ASC -- inseriamo le richieste nello stesso ordine del documento 


		end
	end
	else  -- Se esiste già una RICHIESTA_CIG ed è nello stato diverso da Annullato
	begin
		select @docVersione = versione, @statoFunzDoc = statoFunzionale from ctl_doc with(nolock) where id = @newid

		-- se il documento è ancora in lavorazione e rispetto alla sua creazione, la versione simog è avanzata, la rettifichiamo
		if @statoFunzDoc = 'InLavorazione' and @docVersione <> @versioneSimog
		begin
			
			update ctl_doc
					set versione = @versioneSimog
				where id = @newid

			set @docVersione = @versioneSimog

			-- cancelliamo il modello perla versione "vecchia" così da lasciare il default
			delete from CTL_DOC_SECTION_MODEL where idheader = @newid and DSE_ID IN ( 'GARA', 'LOTTI' )

		end
			
		if @statoFunzDoc = 'InLavorazione' and @docVersione < '3.4.6' and NOT EXISTS ( select idrow from CTL_DOC_SECTION_MODEL with(nolock) where idheader = @newid and DSE_ID in ( 'GARA', 'LOTTI' ) )
		begin

				INSERT INTO CTL_DOC_SECTION_MODEL( IdHeader, DSE_ID, MOD_Name)
					VALUES ( @newid, 'GARA', 'RICHIESTA_CIG_GARA_3_4_5' )

				INSERT INTO CTL_DOC_SECTION_MODEL( IdHeader, DSE_ID, MOD_Name)
					VALUES ( @newid, 'LOTTI', 'RICHIESTA_CIG_LOTTI_3_4_5' )
				
		end
	end


	if  ISNULL(@newId,0) <> 0
	begin
		-- rirorna l'id del doc da aprire
		select @newId as id
	end
	else
	begin
		select 'Errore' as id , @Errore as Errore
	end
END

GO
