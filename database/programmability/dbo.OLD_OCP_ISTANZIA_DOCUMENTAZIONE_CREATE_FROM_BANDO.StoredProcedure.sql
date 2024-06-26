USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_OCP_ISTANZIA_DOCUMENTAZIONE_CREATE_FROM_BANDO]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[OLD_OCP_ISTANZIA_DOCUMENTAZIONE_CREATE_FROM_BANDO] ( @idDoc int , @IdUser int, @popolaDati int = 0, @tipoDocumentazione int = null, @numeroLotto int = null, @techValueAttach nvarchar(max) = null, @statoLotto varchar(100) = null, @descrizioneAllegato nvarchar(max) = null)
AS
BEGIN 

	SET NOCOUNT ON

	BEGIN TRY

		INSERT INTO CTL_TRACE( CONTESTO, descrizione) values ( '[OCP_ISTANZIA_DOCUMENTAZIONE_CREATE_FROM_BANDO]', '@idDoc:' + cast( isnull(@idDoc,0) as varchar ) + ' @IdUser:' + cast( isnull(@IdUser,0) as varchar) + ' @popolaDati:' + cast(isnull(@popolaDati,'') as varchar) + ' @tipoDocumentazione:' + cast ( isnull(@tipoDocumentazione,0) as varchar) + ' @numeroLotto:' + cast( isnull(@numeroLotto,0) as varchar) + ' @techValueAttach:' + isnull(@techValueAttach,'')  + ' @statoLotto:' + isnull( @statoLotto,'') )

	END TRY
	BEGIN CATCH
	END CATCH

	-- QUESTA STORED VIENE CHIAMATA : 
	--	1. nel processo di finalizzazione OCP avvenuto con successo per il documento di istanzia gara
	--	2. Processo di invio della comunicazione di aggiudicazione ( PDA_COMUNICAZIONE_GENERICA-SEND step 190 )
	--	3. nel processo di conferma della decadenza
	--  4. Nella revoca del lotto e della gara
	--  5. nella stored di verifica chiusura gare
	--  6. nella chiusura valutazione tecnica sia per il singolo lotto che per la gara
	--  7. nel processo di VALUTAZIONE_LOTTI della pda

	-- IDDOC IN INPUT SARA' :
	--	* L'ID DELLA GARA QUANDO SI CHIEDERA' LA CREAZIONE DEL DOCUMENTO
	--	* L'ID DEL DOCUMENTO DI OCP_ISTANZIA_DOCUMENTAZIONE SE SI STA RICHIEDENDO UN REINVIO
	--	* L'ID DEL DOCUMENTO DI OCP_ISTANZIA_DOCUMENTAZIONE SE SIAMO NEL COMPLETA INFORMAZIONI LEGATO AL DOC CREATO NELLA PRIMA INVOCAZIONE A QUESTA STORED	

	--Quando si crea un documento come nuova versione di uno esistente il precedente deve essere annullato.
	--La combinatoria per prendere una versione esistente è riferita a questa combinatoria: 
	--	Linkeddoc  ( id della gara ), JumpCheck ( GARA/LOTTO ) , numeroDocumento ( numero del lotto ) , W9PBTIPDOC ( tipo documentazione / va su ctl_doc.idDoc )

	--Dati aggiuntivi passati in input : @techValueAttach su ctl_doc.sign_attach, @statoLotto su ctl_doc.VersioneLinkedDoc

	declare @Id				INT
	declare @Idazi			INT
	declare @Errore			NVARCHAR(2000)
	declare @newid			INT
	declare @prevDoc		INT
	declare @cfRUP			VARCHAR(100)
	declare @tipoDoc		VARCHAR(100)
	declare @Destinatario_Azi int
	

	set @Errore=''	
	set @prevDoc = 0
	set @newid = null
	set @tipoDoc = 'OCP_ISTANZIA_DOCUMENTAZIONE'


	-- SE I NUOVI PARAMETRI DI INPUT ALLA STORED VENGONO PASSATI NULL ( PILOTA LA VARIABILE @tipoDocumentazione ) VUOL DIRE CHE SIAMO SU UN COMANDO DI MAKE DOC FROM DEL REINVIO SUL DOCUMENTO STESSO DI DOCUMENTAZIONE.
	--		QUINDI LI RECUPERIAMO DALLA CTL_DOC
	IF @tipoDocumentazione IS NULL
	BEGIN
		if (dbo.PARAMETRI('SICOPAT','ATTIVA_IMPLEMENTAZIONE','ATTIVA','NO','-1') = 'SI')
			begin 

				select @tipoDocumentazione = isnull(IdDoc,1), --se è null ( vecchio giro ) passiamo 1. essendo il vecchio giro innescato solo nell'invio gara
					@numeroLotto = NumeroDocumento,
					@techValueAttach = SIGN_ATTACH,
					@idDoc = case when @popolaDati = 0 then LinkedDoc else id end
				from ctl_doc with(nolock)
				where id = @idDoc and tipodoc = @tipoDoc

			end 
		else
			begin 

				select @tipoDocumentazione = isnull(IdDoc,3), --se è null ( vecchio giro ) passiamo 3. essendo il vecchio giro innescato solo nell'invio gara
					@numeroLotto = NumeroDocumento,
					@techValueAttach = SIGN_ATTACH,
					@idDoc = case when @popolaDati = 0 then LinkedDoc else id end
				from ctl_doc with(nolock)
				where id = @idDoc and tipodoc = @tipoDoc

			end
		

	END

	-- se siamo nel giro di popolamento/recupero dati e non nella prima creazione documento
	IF @popolaDati = 1
	BEGIN
		declare @datainvio datetime
		declare @idGara INT = 0

		select @idGara = linkedDoc, @datainvio = DataInvio from ctl_doc with(nolock) where id = @idDoc
			
		--insert into CTL_TRACE( contesto, descrizione) values ( '[OCP_ISTANZIA_DOCUMENTAZIONE_CREATE_FROM_BANDO]', 'PopolaDati per gara : ' + cast(@idGara AS VARCHAR) )

		-- INSERISCO I DATI DELLA GARA
		if (dbo.PARAMETRI('SICOPAT','ATTIVA_IMPLEMENTAZIONE','ATTIVA','NO','-1') = 'SI')
			begin 
				INSERT INTO [Document_OCP_GARA] ([idHeader] ,[W3OGGETTO1] ,[W3IDGARA] ,[W3I_GARA] ,[W3DGURI] ,[W3DSCADB] ,[W9GAMOD_IND],
														[W9GAFLAG_ENT] ,[W3TIPOAPP] ,[W3ID_TIPOL],
														[W9GASTIPULA] ,[CFTEC1] ,[COGTEI] ,[NOMETEI] ,[TELTEC1] ,[G_EMATECI],
														[W3PROFILO1] ,[W3MIN1] ,[W3OSS1] ,[W9CCCODICE] ,[W9CCDENOM], CFEIN, W9GADURACCQ, AllegatoPerOCP, DataIndizione, 
														W9PBDATAPUBB, 
														W9PBDATASCAD)
								select @idDoc ,[W3OGGETTO1] ,[W3IDGARA] ,[W3I_GARA] ,[W3DGURI] ,[W3DSCADB] ,[W9GAMOD_IND],
														[W9GAFLAG_ENT] ,[W3TIPOAPP] ,[W3ID_TIPOL],
														[W9GASTIPULA] ,[CFTEC1] ,[COGTEI] ,[NOMETEI] ,[TELTEC1] ,[G_EMATECI],
														[W3PROFILO1] ,[W3MIN1] ,[W3OSS1] ,[W9CCCODICE] ,[W9CCDENOM], CFEIN, W9GADURACCQ, AllegatoPerOCP, 
														case when @tipoDocumentazione in (1,6) then DataIndizione 
															 when @tipoDocumentazione = 3 then @datainvio 
															 else getDate() 
														end, 
														case when @tipoDocumentazione in (1,6) then W9PBDATAPUBB else null end, 
														case when @tipoDocumentazione in (1,6) then W9PBDATASCAD else null end
									from SITAR_DATI_GARA 
									where idGara = @idGara
			end
		else
			begin 
				INSERT INTO [Document_OCP_GARA] ([idHeader] ,[W3OGGETTO1] ,[W3IDGARA] ,[W3I_GARA] ,[W3DGURI] ,[W3DSCADB] ,[W9GAMOD_IND],
													[W9GAFLAG_ENT] ,[W3TIPOAPP] ,[W3ID_TIPOL],
													[W9GASTIPULA] ,[CFTEC1] ,[COGTEI] ,[NOMETEI] ,[TELTEC1] ,[G_EMATECI],
													[W3PROFILO1] ,[W3MIN1] ,[W3OSS1] ,[W9CCCODICE] ,[W9CCDENOM], CFEIN, W9GADURACCQ, AllegatoPerOCP, DataIndizione, 
													W9PBDATAPUBB, 
													W9PBDATASCAD)
							select @idDoc ,[W3OGGETTO1] ,[W3IDGARA] ,[W3I_GARA] ,[W3DGURI] ,[W3DSCADB] ,[W9GAMOD_IND],
													[W9GAFLAG_ENT] ,[W3TIPOAPP] ,[W3ID_TIPOL],
													[W9GASTIPULA] ,[CFTEC1] ,[COGTEI] ,[NOMETEI] ,[TELTEC1] ,[G_EMATECI],
													[W3PROFILO1] ,[W3MIN1] ,[W3OSS1] ,[W9CCCODICE] ,[W9CCDENOM], CFEIN, W9GADURACCQ, AllegatoPerOCP, 
													case when @tipoDocumentazione in (3,6) then DataIndizione else getDate() end, 
													case when @tipoDocumentazione in (3,6) then W9PBDATAPUBB else null end, 
													case when @tipoDocumentazione in (3,6) then W9PBDATASCAD else null end
								from SITAR_DATI_GARA 
								where idGara = @idGara
			end
		

		IF @numeroLotto is null
		BEGIN

			IF @tipoDocumentazione = 17
			BEGIN

				-- INSERISCO I DATI DEI LOTTI	
				INSERT INTO [Document_OCP_LOTTI] ([idHeader] ,[NumeroLotto] ,[W3OGGETTO2] ,[W3CIG])
							select @idDoc,idRiga ,[W3OGGETTO2] ,[W3CIG]
								from SITAR_LISTA_LOTTI_CON_REVOCATI 
								where idGara = @idGara

			END
			ELSE
			BEGIN

				-- INSERISCO I DATI DEI LOTTI	
				INSERT INTO [Document_OCP_LOTTI] ([idHeader] ,[NumeroLotto] ,[W3OGGETTO2] ,[W3CIG])
							select @idDoc,idRiga ,[W3OGGETTO2] ,[W3CIG]
								from SITAR_LISTA_LOTTI 
								where idGara = @idGara

			END

		END
		ELSE
		BEGIN

			IF @tipoDocumentazione = 17
			BEGIN

				--se 17 bisogna recuperare anche i lotti nello stato di revocato
				INSERT INTO [Document_OCP_LOTTI] ([idHeader] ,[NumeroLotto] ,[W3OGGETTO2] ,[W3CIG])
						select @idDoc ,idRiga ,[W3OGGETTO2] ,[W3CIG]
							from SITAR_LISTA_LOTTI_CON_REVOCATI 
							where idGara = @idGara and idRiga = @numeroLotto

			END
			ELSE
			BEGIN

				INSERT INTO [Document_OCP_LOTTI] ([idHeader] ,[NumeroLotto] ,[W3OGGETTO2] ,[W3CIG])
					select @idDoc ,idRiga ,[W3OGGETTO2] ,[W3CIG]
						from SITAR_LISTA_LOTTI 
						where idGara = @idGara and idRiga = @numeroLotto

			END

		END

		-- INSERISCO LA SENTINELLA PER FAR SCATTARE L'INTEGRAZIONE ( tabella Services_Integration_Request ) E CAMBIO LO STATO DEL DOCUMENTO IN 'INVIO IN CORSO'

		EXEC INSERT_SERVICE_REQUEST 'OCP', 'istanziaDocumentazione', @IdUser , @idDoc

		UPDATE ctl_doc 
				SET statofunzionale = 'InvioInCorso', 
					datainvio = getdate()
			WHERE id = @idDoc

	END
	ELSE
	BEGIN
	
		--se il tipodocumento è 9, 10, 12 l'iddoc è l'id della comunicazione, quindi risaliamo al bando
		if @tipoDocumentazione in (9, 10, 12)
		begin
			select 
				@idGara = g.Id, 
				@Destinatario_Azi = comG.Destinatario_Azi
					from ctl_doc comG with(nolock)
						inner join ctl_doc com with(nolock) on comG.LinkedDoc = com.Id and com.TipoDoc = 'PDA_COMUNICAZIONE' and com.StatoDoc <> 'Invalidate'
						inner join ctl_doc pda with(nolock) on com.LinkedDoc = pda.Id 
						inner join CTL_DOC g with(nolock) on pda.LinkedDoc = g.Id
					where comG.id = @idDoc
		end

		-- controllo valido per tutte le tipologie documentali. Se c'è l'istanzia gara facciamo partire la documentazione, altrimenti no
		IF (EXISTS ( select top 1 id from ctl_doc with(nolock) where tipodoc = 'OCP_ISTANZIA_GARA' and LinkedDoc = @idDoc )) or 
			(exists( select top 1 id from ctl_doc with(nolock) where tipodoc = 'OCP_ISTANZIA_GARA' and LinkedDoc = @idGara ))
		--if 1 = 1
		BEGIN
			
			declare @titolo nvarchar(4000) = ''
			declare @jumpcheck nvarchar(200) = ''
			declare @NumeroDocumento int = NULL

			declare @bloccaCreazione int = 1
			
			if (dbo.PARAMETRI('SICOPAT','ATTIVA_IMPLEMENTAZIONE','ATTIVA','NO','-1') = 'SI') -- W9PBTIPDOC = 1   ( Invio Gara )
				begin
					IF @tipoDocumentazione = 1
					BEGIN
					
						set @titolo = 'Bando di gara'
						set @jumpcheck = 'GARA'
						set @NumeroDocumento = NULL
						set @techValueAttach = NULL

						-- se presente l'allegato da inviare +
						-- Non inviare il documento OCP_ISTANZIA_DOCUMENTAZIONE alla pubblicazione della gara nei seguenti casi: 
						-- O è un BANDO_GARA con il campo document_bando.ProceduraGara in ( 15478, 15583,15479, 15477, 15585)  (  “NEGOZIATA” , Richiesta di preventivo , affidamento diretto, ristretta , consultazione preliminare di mercato)  
						-- Oppure bando semplificato.
						--In pratica resta solo per le gare aperte  
						IF EXISTS ( select idrow from ctl_doc_value with(nolock) where IdHeader = @idDoc and dse_id = 'PARAMETRI' and DZT_Name = 'AllegatoPerOCP' and [value] <> '' )
								and
							NOT EXISTS ( select id from ctl_doc a with(nolock) inner join Document_Bando b with(nolock) on b.idHeader = a.Id where a.id = @idDoc and a.TipoDoc = 'BANDO_GARA' and b.ProceduraGara in ( 15478, 15583,15479, 15477, 15585)  )
								and
							NOT EXISTS ( select id from ctl_doc a with(nolock) where a.id = @idDoc and a.tipodoc = 'BANDO_SEMPLIFICATO' )
						BEGIN

							set @bloccaCreazione = 0

						END
	
					END --IF @tipoDocumentazione = 1 sicopat
				end
			else
				begin
					IF @tipoDocumentazione = 3 -- W9PBTIPDOC = 3   ( Invio Gara )
						BEGIN

							set @titolo = 'Bando di gara'
							set @jumpcheck = 'GARA'
							set @NumeroDocumento = NULL
							set @techValueAttach = NULL

							-- se presente l'allegato da inviare +
							-- Non inviare il documento OCP_ISTANZIA_DOCUMENTAZIONE alla pubblicazione della gara nei seguenti casi: 
							-- O è un BANDO_GARA con il campo document_bando.ProceduraGara in ( 15478, 15583,15479, 15477, 15585)  (  “NEGOZIATA” , Richiesta di preventivo , affidamento diretto, ristretta , consultazione preliminare di mercato)  
							-- Oppure bando semplificato.
							--In pratica resta solo per le gare aperte  
							IF EXISTS ( select idrow from ctl_doc_value with(nolock) where IdHeader = @idDoc and dse_id = 'PARAMETRI' and DZT_Name = 'AllegatoPerOCP' and [value] <> '' )
									and
								NOT EXISTS ( select id from ctl_doc a with(nolock) inner join Document_Bando b with(nolock) on b.idHeader = a.Id where a.id = @idDoc and a.TipoDoc = 'BANDO_GARA' and b.ProceduraGara in ( 15478, 15583,15479, 15477, 15585)  )
									and
								NOT EXISTS ( select id from ctl_doc a with(nolock) where a.id = @idDoc and a.tipodoc = 'BANDO_SEMPLIFICATO' )
							BEGIN

								set @bloccaCreazione = 0

							END
	
						END --IF @tipoDocumentazione = 3
				end			
			
			if @tipoDocumentazione = 2
			begin
				set @titolo = 'Avviso per manifestazione di interesse'
				set @jumpcheck = 'OK'
				set @NumeroDocumento = NULL
				set @techValueAttach = NULL

				IF EXISTS ( select idrow from ctl_doc_value with(nolock) where IdHeader = @idDoc and dse_id = 'PARAMETRI' and DZT_Name = 'AllegatoPerOCP' and [value] <> '' )
					and
				NOT EXISTS ( select id from ctl_doc a with(nolock) inner join Document_Bando b with(nolock) on b.idHeader = a.Id where a.id = @idDoc and a.TipoDoc = 'BANDO_GARA' and b.TipoBandoGara = 1 and b.ProceduraGara = 15478  ) --avviso di negoziata
					BEGIN
						set @bloccaCreazione = 0
					END
			end

			--W9PBTIPDOC = 6 (invio Esito - comunicazione di aggiudicazione )
			IF @tipoDocumentazione = 6
			BEGIN

				set @titolo = 'Lettera di invito'
				set @jumpcheck = 'GARA'
				set @NumeroDocumento = NULL
				set @techValueAttach = NULL

				if (dbo.PARAMETRI('SICOPAT','ATTIVA_IMPLEMENTAZIONE','ATTIVA','NO','-1') = 'SI')
					begin
						--Se c'è l'allegato da inviare e non c'è già un documento di tipo lettera di invito per la stessa gara 
						-- ( Il tipo 6 non viene creato all'invio della gara ma quando si invia la comunicazione di aggiudicazione, siccome le aggiudicazioni sono per lotti occorre evitare di creare un documento successivo se già esiste. )
						IF EXISTS ( select idrow from ctl_doc_value with(nolock) where IdHeader = @idDoc and dse_id = 'PARAMETRI' and DZT_Name = 'AllegatoPerOCP' and [value] <> '' )
								AND
							NOT EXISTS ( select id from CTL_DOC with(nolock) where LinkedDoc = @idDoc and deleted = 0 and TipoDoc = @tipoDoc and StatoFunzionale not IN ('Invio_con_errori','Annullato') and JumpCheck = @jumpcheck and IdDoc in ( 1,6 ) )
						BEGIN
							set @bloccaCreazione = 0
						END
					end
				else
					begin
						--Se c'è l'allegato da inviare e non c'è già un documento di tipo lettera di invito per la stessa gara 
						-- ( Il tipo 6 non viene creato all'invio della gara ma quando si invia la comunicazione di aggiudicazione, siccome le aggiudicazioni sono per lotti occorre evitare di creare un documento successivo se già esiste. )
						IF EXISTS ( select idrow from ctl_doc_value with(nolock) where IdHeader = @idDoc and dse_id = 'PARAMETRI' and DZT_Name = 'AllegatoPerOCP' and [value] <> '' )
								AND
							NOT EXISTS ( select id from CTL_DOC with(nolock) where LinkedDoc = @idDoc and deleted = 0 and TipoDoc = @tipoDoc and StatoFunzionale not IN ('Invio_con_errori','Annullato') and JumpCheck = @jumpcheck and IdDoc in ( 3,6 ) )
						BEGIN
							set @bloccaCreazione = 0
						END
					end
				

			END --IF @tipoDocumentazione = 6

			if @tipoDocumentazione = 7
			begin 
				set @titolo = 'Provvedimento di ammissione / esclusione amministrativa'
				set @bloccaCreazione = 0
			end

			if @tipoDocumentazione = 9
			begin 
				set @titolo = 'Provvedimento per eventuali esclusioni a seguito verifica offerte tecniche'
				set @bloccaCreazione = 0
			end

			if @tipoDocumentazione = 10
			begin 
				set @titolo = 'Provvedimento per eventuali esclusioni a seguito apertura offerte economiche'
				set @bloccaCreazione = 0
			end

			if @tipoDocumentazione = 12
			begin 
				set @titolo = 'Provvedimento per eventuale esclusione offerta anomala'
				set @bloccaCreazione = 0
			end

			if @tipoDocumentazione = 28
			BEGIN
				set @bloccaCreazione = 0
			END

			--W9PBTIPDOC = 20 (invio Esito - comunicazione di aggiudicazione ) 
			IF @tipoDocumentazione = 20
			BEGIN
				
				set @titolo = 'Determina di aggiudicazione'
				set @jumpcheck = 'LOTTO'
				set @NumeroDocumento = @numeroLotto

				
				IF isnull(@techValueAttach,'') <> ''
					set @bloccaCreazione = 0

			END --IF @tipoDocumentazione = 20

			--W9PBTIPDOC = 17 (Provvedimento di gara non aggiudicata o deserta)
			IF @tipoDocumentazione = 17
			BEGIN
			
				set @titolo = 'Provvedimento di gara non aggiudicata o deserta'
				--jumpcheck = “LOTTO” (per lotto deserto ), "GARA" ( per gara deserta )
				set @jumpcheck = case when @numeroLotto is null then 'GARA' else 'LOTTO' end
				set @NumeroDocumento = @numeroLotto
				
				-- L'ALLEGATO DA INVIARE AL SITAR VERRA' GENERATO AUTOMATICAMENTE AL MOMENTO DEL COMPLETA INFORMAZIONI

				select * into #docCheck
							from ctl_doc with(nolock) 
							where LinkedDoc = @idDoc and deleted = 0 and TipoDoc = @tipoDoc 

				-- Se esiste un altro documento OCP a parità di tipo/statoLotto non ne creiamo un altro
				--	( serve per non creare N istanzia documentazione uguali. lo facciamo solo se c'è un cambio di stato. evitare ad esempio invii multipli dal servizio di chiusura gare per la deserta )
				IF NOT EXISTS ( select id 
									from #docCheck
									where StatoFunzionale not IN ('Invio_con_errori','Annullato') and JumpCheck = @jumpcheck 
											and isnull(NumeroDocumento,-1) = isnull(@NumeroDocumento,-1) and IdDoc = @tipoDocumentazione 
											and isnull(VersioneLinkedDoc,'') = isnull(@statoLotto,'')
							)
				BEGIN
					set @bloccaCreazione = 0
				END

				drop table #docCheck

			END --IF @tipoDocumentazione = 17

			--W9PBTIPDOC = 16 (Provvedimento di revoca dell'aggiudicazione o dell'adesione)
			IF @tipoDocumentazione = 16
			BEGIN
				
				set @titolo = 'Provvedimento di revoca dell''aggiudicazione o dell''adesione'
				--jumpcheck = “LOTTO” (per gare a lotti), "GARA" ( per gara monolotto )
				set @jumpcheck = case when @numeroLotto is null then 'GARA' else 'LOTTO' end
				set @NumeroDocumento = @numeroLotto
				
				-- L'ALLEGATO DA INVIARE AL SITAR VERRA' GENERATO AUTOMATICAMENTE AL MOMENTO DEL COMPLETA INFORMAZIONI

				set @bloccaCreazione = 0

			END --IF @tipoDocumentazione = 16

			IF @bloccaCreazione = 0
			BEGIN

				set @prevDoc = 0

				--setto il titolo documento se è presente
				if (@descrizioneAllegato is not null)
					begin
						set @titolo = @descrizioneAllegato
					end		
					
				if @tipoDocumentazione in (9, 10, 12)
				begin
					select * into #prevDocComunicazione
						from CTL_DOC with(nolock) 
						where LinkedDoc = @idGara and deleted = 0 and TipoDoc = @tipoDoc 

					-- Cerco l'ultimo documento, non annullato, precedente a questo
					--Linkeddoc  ( id della gara ), JumpCheck ( GARA/LOTTO ) , numeroDocumento ( numero del lotto ) , W9PBTIPDOC ( tipo documentazione / va su ctl_doc.idDoc )
					select @prevDoc = max(id) 
						from #prevDocComunicazione
						where StatoFunzionale <> 'Annullato' and JumpCheck = @jumpcheck and isnull(NumeroDocumento,-1) = isnull(@NumeroDocumento,-1) and IdDoc = @tipoDocumentazione

					drop table #prevDocComunicazione

					-- CREO IL DOCUMENTO
					INSERT into CTL_DOC (IdPfu,  TipoDoc  , idpfuincharge ,Azienda ,body,LinkedDoc, prevdoc, StatoFunzionale, JumpCheck, NumeroDocumento, IdDoc, titolo, SIGN_ATTACH, VersioneLinkedDoc, Destinatario_Azi )
						select  @IdUser, @tipoDoc , @IdUser ,Azienda,'',@idGara, isnull(@prevDoc,0), 'RecuperoDati', @jumpcheck, @NumeroDocumento, @tipoDocumentazione, @titolo, @techValueAttach, @statoLotto, @Destinatario_Azi
							from ctl_doc with(nolock)
							where id = @idGara		

					set @newId = SCOPE_IDENTITY()
				end
				else
				begin
					select * into #prevDoc
						from CTL_DOC with(nolock) 
						where LinkedDoc = @idDoc and deleted = 0 and TipoDoc = @tipoDoc 

					-- Cerco l'ultimo documento, non annullato, precedente a questo
					--Linkeddoc  ( id della gara ), JumpCheck ( GARA/LOTTO ) , numeroDocumento ( numero del lotto ) , W9PBTIPDOC ( tipo documentazione / va su ctl_doc.idDoc )
					select @prevDoc = max(id) 
						from #prevDoc
						where StatoFunzionale <> 'Annullato' and JumpCheck = @jumpcheck and isnull(NumeroDocumento,-1) = isnull(@NumeroDocumento,-1) and IdDoc = @tipoDocumentazione

					drop table #prevDoc

					-- CREO IL DOCUMENTO
					INSERT into CTL_DOC (IdPfu,  TipoDoc  , idpfuincharge ,Azienda ,body,LinkedDoc, prevdoc, StatoFunzionale, JumpCheck, NumeroDocumento, IdDoc, titolo, SIGN_ATTACH, VersioneLinkedDoc, Destinatario_Azi )
						select  @IdUser, @tipoDoc , @IdUser ,Azienda,'',@idDoc, isnull(@prevDoc,0), 'RecuperoDati', @jumpcheck, @NumeroDocumento, @tipoDocumentazione, @titolo, @techValueAttach, @statoLotto, @Destinatario_Azi
							from ctl_doc with(nolock)
							where id = @idDoc		

					set @newId = SCOPE_IDENTITY()
				end
							
				IF isnull(@prevDoc,0) <> 0 
				BEGIN

					declare @W9PBCOD_PUBB varchar(100) = ''
					select @W9PBCOD_PUBB = value from ctl_doc_value p with(nolock) where p.IdHeader = @prevDoc and p.DSE_ID = 'OCP' and p.DZT_Name = 'W9PBCOD_PUBB'

					IF isnull(@W9PBCOD_PUBB,'') <> ''
					BEGIN

						INSERT INTO CTL_DOC_VALUE ( IdHeader, DSE_ID, DZT_Name, [Value] )
									   VALUES ( @newId, 'OCP', 'W9PBCOD_PUBB', @W9PBCOD_PUBB )

					END

				END

				if @tipoDocumentazione in (9, 10, 12)
				begin
					INSERT INTO CTL_DOC_VALUE ( IdHeader, DSE_ID, DZT_Name, [Value] )
							VALUES ( @newId, 'SICOPAT', 'ID_Comunicazione', @idDoc )
				END

				-- scheduliamo la richiesta di completamento informazioni per il documento appena creato
				INSERT INTO CTL_Schedule_Process ( IdDoc, IdUser, DPR_DOC_ID, DPR_ID)
							values ( @newid, @IdUser, @tipoDoc, 'COMPLETA_INFORMAZIONI' )											

			END

		END -- if su OCP_ISTANZIA_GARA

	END



	IF ISNULL(@newId,0) <> 0
	BEGIN

		-- avendo creato una nuova istanzia gara annulliamo la precedente, se presente
		IF isnull(@prevDoc,0) <> 0 
		BEGIN

			update ctl_doc
					set StatoFunzionale = 'Annullato'
				where Id = @prevDoc

		END

		-- rirorna l'id del doc da aprire
		select @newId as id
	
	END
	ELSE
	BEGIN

		if isnull(@Errore,'') <> ''
			select 'Errore' as id , @Errore as Errore
		else
			select 'Errore' as id , 'Istanzia Documentazione non consentito' as Errore

	END

	
END





GO
