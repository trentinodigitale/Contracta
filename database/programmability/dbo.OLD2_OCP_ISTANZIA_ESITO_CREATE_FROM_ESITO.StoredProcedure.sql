USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_OCP_ISTANZIA_ESITO_CREATE_FROM_ESITO]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE [dbo].[OLD2_OCP_ISTANZIA_ESITO_CREATE_FROM_ESITO] ( @idGara int , @IdUser int, @popolaDati int = 0 )
AS
BEGIN

	-- IDDOC IN INPUT SARA' SEMPRE L'ID DELLA GARA A PRESCINDERE DAL PUNTO DI INNESCO, CHE PUO' ESSERE :
	--		1. IL MOMENTO IN CUI LA GARA PASSA A "CHIUSO"
	--		2. AL PROCESSO DI TERMINE DELLA FASE AMMINSTRATIVA
	--		3. (NON PIU') Alla comunicazione di aggiudicazione definitiva non condizionata 
	--		4. Nel processo di termina controlli
	--		5. Revoca Lotto  ( tramite il documento specifico )
	--		6. Revoca Gara   ( tramite la comunicazione con jump check revoca bando )

	SET NOCOUNT ON

	declare @Id      INT
	declare @Idazi   INT
	declare @Errore  NVARCHAR(2000)
	declare @newid   INT
	declare @newIdColleato   INT
	declare @prevDoc INT
	declare @idPDA   INT
	declare @tipoDoc VARCHAR(100)
	declare @idRow INT
	declare @numeroLotto VARCHAR(10)
	declare @dataTaglio		VARCHAR(100)
	declare @dataInvioGara  VARCHAR(100)

	set @Errore=''	
	set @prevDoc = 0
	set @newid = null
	SET @dataTaglio = null
	SET @dataInvioGara = null
	set @newIdColleato = null
	set @numeroLotto = ''
	set @tipoDoc= 'OCP_ISTANZIA_ESITO'

	-- SE E' PRESENTE L'ACCOUNT DI LOGIN AI WS, PROCEDIAMO CON LA CREAZIONE
	IF dbo.OCP_getPasswordWS( '' ) <> ''
 	BEGIN

		-- se siamo nel giro di popolamento/recupero dati e non nella prima creazione documento
		IF @popolaDati = 1
		BEGIN
	
			select @newId = max(id) 
				from CTL_DOC with(nolock) 
				where LinkedDoc = @idGara and deleted = 0 and TipoDoc = @tipoDoc and StatoFunzionale = 'RecuperoDati'		

			-- inseriamo i record [Document_OCP_GARA] e Document_OCP_LOTTI_AGGIUDICATI solo se siamo sulla prima iterazione di completa informazioni
			IF NOT EXISTS ( select top 1 idrow from Document_OCP_GARA with(nolock) where idHeader = @newid )
			BEGIN


				-- INSERISCO I DATI DELLA GARA
				INSERT INTO [Document_OCP_GARA] ([idHeader] ,[W3OGGETTO1] ,[W3IDGARA] ,[W3I_GARA] ,[W3DGURI] ,[W3DSCADB] ,[W9GAMOD_IND],
														[W9GAFLAG_ENT] ,[W3TIPOAPP] ,[W3ID_TIPOL],
														[W9GASTIPULA] ,[CFTEC1] ,[COGTEI] ,[NOMETEI] ,[TELTEC1] ,[G_EMATECI],
														[W3PROFILO1] ,[W3MIN1] ,[W3OSS1] ,[W9CCCODICE] ,[W9CCDENOM], CFEIN)
								select @newId ,[W3OGGETTO1] ,[W3IDGARA] ,[W3I_GARA] ,[W3DGURI] ,[W3DSCADB] ,[W9GAMOD_IND],
														[W9GAFLAG_ENT] ,[W3TIPOAPP] ,[W3ID_TIPOL],
														[W9GASTIPULA] ,[CFTEC1] ,[COGTEI] ,[NOMETEI] ,[TELTEC1] ,[G_EMATECI],
														[W3PROFILO1] ,[W3MIN1] ,[W3OSS1] ,[W9CCCODICE] ,[W9CCDENOM], CFEIN
									from SITAR_DATI_GARA 
									where idGara = @idGara

				-- DOMINIO SITAR PER LO L'ESITO
				--	1	Aggiudicata
				--	2	Annullata/Revocata successivamente alla pubblicazione
				--  3	Deserta
				--  4   Senza esito a seguito di offerte irregolari/inammissibili, non congrue o non appropriate

				-- 5    Annullata/Revocata prima dell'apertura delle buste amministrative
				-- 6    Annullata/Revocata dopo l'apertura delle buste amministrative

				-- questa select deve prendere tutti i lotti "completati" fino a questo momento, non tutti, in quanto la gara/pda potrebbe avanzare nel tempo
				--		a seconda del punto di innesco di questa stored. nella tabella Document_OCP_LOTTI_AGGIUDICATI non devo entrare lotti ancora non "conclusi"
				
				-- vede se per la gara è stata aperta almeno una busta amministrativa
				declare @IdRow2 int
				declare @StatoRevoca varchar(10)

				set @IdRow2 = null
				
				select top 1 @IdRow2=idrow
					from ctl_doc a with (nolock)
						inner join Document_PDA_OFFERTE_VIEW with (nolock) on idheader = a.id and bReadDocumentazione = 0
							where a.LinkedDoc = @idGara
									and a.deleted=0 
									and a.tipodoc = 'PDA_MICROLOTTI'

				if @IdRow2 is null
					set @StatoRevoca = '5' --Annullata/Revocata prima dell'apertura delle buste amministrative
				else
					set @StatoRevoca = '6' --Annullata/Revocata dopo l'apertura delle buste amministrative

				-- al posto del vecchio stato 2 adesso mettiamo @StatoRevoca (5 o 6)

				-- INSERISCO I DATI DEI LOTTI AGGIUDICATI
				INSERT INTO Document_OCP_LOTTI_AGGIUDICATI([idHeader], [NumeroLotto], [W3OGGETTO2], [W3CIG], W9LOESIPROC )
					SELECT @newId, cd.numerolotto, cd.descrizione, isnull(cd.cig,db.CIG) 

							-- attenzione : l'ordine dei 'when' è importantissimo
						, case when c.StatoFunzionale = 'Revocato' then @StatoRevoca --'2'	-- se la gara è revocata tutti i suoi lotti sono revocati
								when cd.statoriga = 'Revocato' or d2.StatoRiga = 'Revocato' then @StatoRevoca --'2'	-- revoca del singolo lotto lato gara o lato pda
								when isnull(noff.totOfferte,0) = 0 then '3'										-- tutta la gara è andata deserta
								when d2.statoriga = 'AggiudicazioneDef' then '1'							-- aggiudicazione definitiva del lotto
								when d2.statoriga = 'Deserta' then '3'									-- lotto deserto
								when d2.StatoRiga IN ( 'Interrotto', 'NonAggiudicabile', 'NonGiudicabile' ) then '4'
								else NULL
							end
						FROM CTL_doc c with(nolock)
								inner join document_bando db with(nolock) on db.idHeader = c.id
								--lotti della gara
								inner join document_microlotti_dettagli cd with(nolock) ON cd.IdHeader = c.Id and cd.TipoDoc = c.TipoDoc and cd.voce = 0

								--offerte ( per verificare lo stato di deserta anche senza la pda )
								left join ( select LinkedDoc, count(linkeddoc) as totOfferte from ctl_doc with(nolock) where LinkedDoc = @idGara and tipodoc = 'OFFERTA' and deleted = 0 and StatoFunzionale = 'Inviato' group by linkeddoc ) noff on noff.LinkedDoc = c.Id

								--pda e lotti
								left join ctl_doc c2 with(nolock) on c2.LinkedDoc = c.id and c2.tipodoc = 'PDA_MICROLOTTI' and c2.deleted = 0
								left join document_microlotti_dettagli d2 with(nolock) on d2.IdHeader = c2.id and d2.TipoDoc = c2.TipoDoc and d2.NumeroLotto = cd.NumeroLotto and d2.Voce = 0 and d2.statoriga in ('AggiudicazioneDef','Interrotto', 'Deserta', 'NonAggiudicabile', 'NonGiudicabile','Revocato' )

						where c.id = @idGara and c.tipodoc in ( 'BANDO_GARA', 'BANDO_SEMPLIFICATO' ) and ( d2.id is not null or isnull(noff.totOfferte,0) = 0 or c.StatoFunzionale = 'Revocato' or cd.statoriga = 'Revocato' )

				-- i lotti con W9LOESIPROC is null or W9LOESIPROC NOT IN ( '1', '2' ) non hanno bisogno di un completamento dati
				UPDATE Document_OCP_LOTTI_AGGIUDICATI
						set datiOK = 1
					where idHeader = @newId and ( W9LOESIPROC is null or W9LOESIPROC NOT IN ( '1', '2', '5', '6' ) )

				-- vede se esiste un documento precedente OCP_ISTANZIA_ESITO contenente lotti con statoriga 5
				-- se si deve rimettere 5 anche nel nuovo perchè quel lotto è stato revocato prima
				declare @OCP_Prev int

				set @OCP_Prev = null

				select top 1  @OCP_Prev = id
					from CTL_DOC with (nolock)
						where LinkedDoc =  @idGara 
									and Deleted=0
									and TipoDoc = 'OCP_ISTANZIA_ESITO'
									--and StatoFunzionale = 'Inviato'
									and Id < @newId

							order by id desc

				if @OCP_Prev is not null
				begin
					
					--- vede se ci sono lotti con statoriga = 5
					if exists(select  NumeroLotto  from Document_OCP_LOTTI_AGGIUDICATI	with (nolock)
								where idHeader = @OCP_Prev and W9LOESIPROC = '5' )
					begin

						update a set W9LOESIPROC = '5'							
							from Document_OCP_LOTTI_AGGIUDICATI a with (nolock)
								inner join Document_OCP_LOTTI_AGGIUDICATI prev with (nolock) on a.NumeroLotto=prev.NumeroLotto 
									where a.idHeader = @newId 
											and prev.idHeader = @OCP_Prev
											and prev.W9LOESIPROC = '5'
											and a.W9LOESIPROC = '6'
											--and isnull(a.NumeroLotto,'')<>''

					end

				end


			END

			select idRow, NumeroLotto,W9LOESIPROC,datiOK,FILE_ALLEGATO into #LOTTI_AGGIUDICATI from Document_OCP_LOTTI_AGGIUDICATI with(nolock) where [idHeader] = @newId 

			/*		A PARTIRE DALL'ATTIVITA 402055 NON MANDIAMO PIU' L'ALLEGATO CON L'ISTANZIA ESITO, MA SOLO CON L'ISTANZIA DOCUMENTAZIONE  ( IstanziaPubblicazioneDocumenti )


			-- PER I LOTTI CON STATO AD 'AggiudicazioneDef' cerchiamo la comunicazione di aggiudicazione definitiva e mettiamo nella colonna
			-- FILE_ALLEGATI, quanto presete nella riga degli allegati della comunicazione per la riga con descrizione 'Determina'

			-- PER I LOTTI CON STATO REVOCATO :
				--	Nel caso della revoca del lotto, inviare al SITAR come allegato del documento Istanzia Esito il file inserito nel documento di revoca lotto.
				--	Nel caso della revoca della gara, inviare al SITAR come allegato del documento Istanzia Esito il primo allegato inserito nel documento di revoca della gara nella tabella degli allegati.

			DECLARE @allegato nvarchar(2000)
			DECLARE @statoOCP varchar(10)
			
			DECLARE curs CURSOR STATIC FOR     
				select top 50 idRow, NumeroLotto,W9LOESIPROC from #LOTTI_AGGIUDICATI  where datiOK is null and W9LOESIPROC IN ( '1', '2' ) order by idRow asc -- Prendiamo tutti i lotti da completare a blocchi di 50

			OPEN curs 
			FETCH NEXT FROM curs INTO @idRow, @numeroLotto,@statoOCP
			
			WHILE @@FETCH_STATUS = 0   
			BEGIN  

				set @allegato = ''

				if @statoOCP = '1' -- aggiudicazione def
				begin

					select top 1 @allegato = a.Allegato
						from ctl_doc g with(nolock)
								inner join ctl_doc p with(nolock) on p.LinkedDoc = g.id and p.TipoDoc = 'PDA_MICROLOTTI' and p.Deleted = 0
								inner join ctl_doc c with(nolock) on c.LinkedDoc = p.Id and c.tipodoc = 'PDA_COMUNICAZIONE_GENERICA' and c.JumpCheck = '0-ESITO_DEFINITIVO_MICROLOTTI' and c.StatoFunzionale in ( 'Inviato', 'InProtocollazione' )
								inner join Document_comunicazione_StatoLotti L with(nolock) on L.idheader = C.Id  and l.deleted = 0 and l.NumeroLotto = @numeroLotto
								inner join CTL_DOC_ALLEGATI a with(nolock) on a.idHeader = c.Id and a.Descrizione = 'Determina' and a.Allegato <> ''
						where g.id = @idGara
						order by c.id desc, a.idrow asc

				end
				else if @statoOCP = '2' --revoca
				begin
					
					--se l'intera gara è revocata
					if exists ( select id from ctl_doc with(nolock) where id = @idGara and StatoFunzionale = 'Revocato' )
					begin

						select top 1 @allegato = a.Allegato
							from ctl_doc c with(nolock)
									inner join CTL_DOC_ALLEGATI a with(nolock) on a.idHeader = c.Id and a.Allegato <> ''
							where c.LinkedDoc = @idGara and c.tipodoc = 'PDA_COMUNICAZIONE_GENERICA' and c.JumpCheck = '0-REVOCA_BANDO' and c.StatoFunzionale in ( 'Inviato', 'InProtocollazione' ) 
							order by a.idrow asc

						
					end
					else
					begin

						select top 1 @allegato = c.SIGN_ATTACH
							from ctl_doc c with(nolock)
									inner join Document_MicroLotti_Dettagli d2 with(nolock) on d2.IdHeader = c.id and d2.TipoDoc = c.TipoDoc and d2.NumeroLotto = @numeroLotto
							where c.LinkedDoc = @idGara and c.tipodoc = 'BANDO_REVOCA_LOTTO' and c.StatoFunzionale in ( 'Inviato', 'InProtocollazione' ) 

					end

				end
				
				IF @allegato <> ''
				BEGIN

					UPDATE #LOTTI_AGGIUDICATI
							set FILE_ALLEGATO = @allegato
						where idrow = @idRow
				
				END

				UPDATE #LOTTI_AGGIUDICATI
						set datiOK = 1
					where idRow = @idRow


				FETCH NEXT FROM curs INTO @idRow, @numeroLotto,@statoOCP

			END  


			CLOSE curs   
			DEALLOCATE curs

			*/

			-- NON AVENDO PIU ALLEGATI DA RECUPERARE LI METTIAMO TUTTI COME OK. NON CI SERVIRA' PIU RECUPERARLI A BLOCCHI
			UPDATE #LOTTI_AGGIUDICATI
						set datiOK = 1

			-- ALLINEIAMO L'AVANZAMENTO DATI SULLA TABELLA DEI LOTTI
			UPDATE Document_OCP_LOTTI_AGGIUDICATI
					set datiOK = b.datiOK,
						FILE_ALLEGATO = b.FILE_ALLEGATO
				from Document_OCP_LOTTI_AGGIUDICATI a
						INNER JOIN #LOTTI_AGGIUDICATI b on b.idRow = a.idRow


			-- se tutti i lotti sono stati completati cambiamo lo stato al documento e richiediamo l'invio
			IF NOT EXISTS ( select idrow from #LOTTI_AGGIUDICATI where datiOK is null )
			BEGIN

				UPDATE ctl_doc 
						SET statofunzionale = 'InvioInCorso', 
							datainvio = getdate()
					WHERE id = @newId

				-- vecchia sentinella per inviare insieme tutti i lotti
				--EXEC INSERT_SERVICE_REQUEST 'OCP', 'istanziaEsito', @IdUser , @newId

				DECLARE curs2 CURSOR STATIC FOR     
					select idRow from #LOTTI_AGGIUDICATI order by idRow asc

				OPEN curs2 
				FETCH NEXT FROM curs2 INTO @idRow

				WHILE @@FETCH_STATUS = 0   
				BEGIN  

					-- INSERISCO LA SENTINELLA PER FAR SCATTARE L'INTEGRAZIONE ( tabella Services_Integration_Request ) E CAMBIO LO STATO DEL DOCUMENTO IN 'INVIO IN CORSO'
					EXEC INSERT_SERVICE_REQUEST 'OCP', 'istanziaEsitoLotti', @IdUser, @idRow

					FETCH NEXT FROM curs2 INTO @idRow

				END  

				CLOSE curs2   
				DEALLOCATE curs2

			END
			ELSE
			BEGIN
				
				-- se ci sono ancora dati da recuperare rischeduliamo il completa informazioni
				INSERT INTO CTL_Schedule_Process ( IdDoc, IdUser, DPR_DOC_ID, DPR_ID)
									  values ( @idGara, @IdUser, @tipoDoc, 'COMPLETA_INFORMAZIONI' )

			END

		END
		ELSE
		BEGIN
		
			select @dataTaglio = left(d.vatValore_FT, 10)
				from profiliutente p with(nolock)
						inner join DM_Attributi d with(nolock) on d.lnk = p.pfuIdAzi and d.dztNome = 'DataAttivazioneOCP'
				where p.idpfu = @IdUser

			if isnull(@dataTaglio,'') <> ''
			begin
			
				select @dataInvioGara = left( convert(varchar,DataInvio, 126), 10)
					from ctl_doc with(nolock)
					where id = @idGara

			end

			-- RIMUOVIAMO EVENTUALI VECCHIE SENTINELLE
			DELETE FROM CTL_DOC_VALUE where idheader = @idGara and dse_id = 'OCP'

			--------------------------------------------------------------------------------------------------
			-- SE LA DATA DI INVIO DELLA GARA è MAGGIORE O UGUALE DELLA DATA DI INIZIO ATTIVAZIONE OCP  ------
			--------------------------------------------------------------------------------------------------
			IF isnull(@dataTaglio,'') <> '' and @dataInvioGara >= @dataTaglio
			BEGIN

				DECLARE @ProceduraGara varchar(10)
				DECLARE @TipoBandoGara varchar(10)

				select  @ProceduraGara = ProceduraGara,
						@TipoBandoGara = TipoBandoGara
					from Document_Bando with(nolock)
					where idHeader = @idGara

				--------------------------------------------------------------------------------------------------
				-- SE LA PROCEDURA E' UNA MONOLOTTO PRIVA DELL'INTEGRAZIONE CON IL SIMOG ( QUINDI NON SIAMO IN GRADO DI RECUPERARE
				--	L'ID GARA ) ALLORA BLOCCHIAMO L'INVIO AL SITAR ------
				-- OPPURE BLOCCHIAMO SE SIAMO SU UN GIRO DI BANDO RISTRETA O NEGOZIATA CON AVVISO ( QUINDI NEL PRIMO GIRO DI UNA PROCEDURA IN 2 FASI )
						-- BANDO - RISTRETTA
						--			ProceduraGara : 15477
						--			TipoBandoGara : 2
						--	NEGOZIATA CON AVVISO
						--			ProceduraGara : 15478
						--			TipoBandoGara : 1
				--------------------------------------------------------------------------------------------------
				IF NOT EXISTS ( select idGara from SITAR_DATI_GARA where W3IDGARA = 'NO_INTEGRAZIONE' and idGara =  @idGara )
						AND
					NOT ( @ProceduraGara = '15477' and @TipoBandoGara = '2' ) 
						AND
					NOT ( @ProceduraGara = '15478' and @TipoBandoGara = '1' ) 
				BEGIN

					-- CREIAMO IL DOCUMENTO SE ABBIAMO DEI LOTTI 'TERMINATI' DA INVIARE, ALTRIMENTI BLOCCHIAMO 
					--  aggiungiamo questo controllo perchè essendo stato richiesto l'innesco della stored anche per il termina fase amministrativa e non ci sono lotti deserti, allora
					--	è la normalità che non ci siano lotti "conclusi"
					IF EXISTS ( select c.id
									FROM CTL_doc c with(nolock)
										inner join document_bando db with(nolock) on db.idHeader = c.id
										--lotti della gara
										inner join document_microlotti_dettagli cd with(nolock) ON cd.IdHeader = c.Id and cd.TipoDoc = c.TipoDoc and cd.voce = 0

										--offerte ( per verificare lo stato di deserta anche senza la pda )
										left join ( select LinkedDoc, count(linkeddoc) as totOfferte from ctl_doc with(nolock) where LinkedDoc = @idGara and tipodoc = 'OFFERTA' and deleted = 0 and StatoFunzionale = 'Inviato' group by linkeddoc ) noff on noff.LinkedDoc = c.Id

										--pda e lotti
										left join ctl_doc c2 with(nolock) on c2.LinkedDoc = c.id and c2.tipodoc = 'PDA_MICROLOTTI' and c2.deleted = 0
										left join document_microlotti_dettagli d2 with(nolock) on d2.IdHeader = c2.id and d2.TipoDoc = c2.TipoDoc and d2.NumeroLotto = cd.NumeroLotto and d2.Voce = 0 and d2.statoriga in ('AggiudicazioneDef','Interrotto', 'Deserta', 'NonAggiudicabile', 'NonGiudicabile','Revocato' )

								where c.id = @idGara and c.tipodoc in ( 'BANDO_GARA', 'BANDO_SEMPLIFICATO' ) and ( d2.id is not null or isnull(noff.totOfferte,0) = 0 or c.StatoFunzionale = 'Revocato' or cd.statoriga = 'Revocato' )
					)
					BEGIN
					
						-- Cerco l'ultimo documento, non annullato, precedente a questo
						select @prevDoc = max(id) 
							from CTL_DOC with(nolock) 
							where LinkedDoc = @idGara and deleted = 0 and TipoDoc = @tipoDoc and StatoFunzionale <> 'Annullato'
			
						-- CREO IL DOCUMENTO
						INSERT into CTL_DOC (IdPfu,  TipoDoc  , idpfuincharge ,Azienda ,body,LinkedDoc, prevdoc, StatoFunzionale )
							select  @IdUser, @tipoDoc , @IdUser ,Azienda,'',@idGara, isnull(@prevDoc,0), 'RecuperoDati'
								from ctl_doc with(nolock)
								where id = @idGara		

						set @newId = SCOPE_IDENTITY()

						-- scheduliamo la richiesta di completamento informazioni per il documento appena creato
						INSERT INTO CTL_Schedule_Process ( IdDoc, IdUser, DPR_DOC_ID, DPR_ID)
												  values ( @idGara, @IdUser, @tipoDoc, 'COMPLETA_INFORMAZIONI' )

					END
					ELSE
					BEGIN

						set @Errore = 'Invio bloccato per gara priva di lotti in uno stato terminale'

					END

				END
				ELSE
				BEGIN
					
					set @Errore = 'Invio bloccato per gara monolotto senza integrazione simog o primo giro di una procedura in 2 fasi'

					INSERT INTO CTL_DOC_VALUE  ( IdHeader, DSE_ID, DZT_Name, value )
									VALUES ( @idGara, 'OCP', 'MonoLottoSenzaSimog', '1')

				END

			END
			ELSE
			BEGIN

				set @Errore = 'Data inizio integrazione non raggiunta'
				
				INSERT INTO CTL_DOC_VALUE  ( IdHeader, DSE_ID, DZT_Name, value )
									VALUES ( @idGara, 'OCP', 'DataTaglioNonRaggiunta', '1')

			END

		END

	END
	ELSE
	BEGIN
		set @Errore = 'Account di login OCP non presente'
	END

	IF ISNULL(@newId,0) <> 0
	BEGIN

		-- avendo creato una nuova istanzia aggiudicazione annulliamo la precedente, se presente
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

		select 'Errore' as id , @Errore as Errore

	END

	
END





GO
