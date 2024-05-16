USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_OCP_ISTANZIA_AGGIUDICAZIONE_CREATE_FROM_ESITO]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









CREATE PROCEDURE [dbo].[OLD2_OCP_ISTANZIA_AGGIUDICAZIONE_CREATE_FROM_ESITO] ( @idGara int , @IdUser int, @popolaDati int = 0 )
AS
BEGIN

	-- IDDOC IN INPUT SARA' SEMPRE L'ID DELLA GARA A PRESCINDERE DAL PUNTO DI INNESCO, CHE PUO' ESSERE :
	--		IL PROCESSO PDA_COMUNICAZIONE_GENERICA-SEND  MA CONDIZIONATO AI JUMP CHECK (  '0-ESITO_DEFINITIVO' , '0-ESITO_DEFINITIVO_MICROLOTTI' ) E ALLA MANCANZA DELLA SPUNTA SU "CONDIZIONATA"
	--		IL PROCESSO PDA_MICROLOTTI-AGG_DEFINITIVA_MONOLOTTO  ( innescato dal comando termina controlli di aggiudicazione ) 
	--		IL PROCESSO PDA_MICROLOTTI-AGG_DEFINITIVA_LOTTO	     ( innescato dal comando termina controlli di aggiudicazione ) 

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
	set @tipoDoc= 'OCP_ISTANZIA_AGGIUDICAZIONE'

	-- SE E' PRESENTE L'ACCOUNT DI LOGIN AI WS, PROCEDIAMO CON LA CREAZIONE
	IF dbo.OCP_getPasswordWS( '' ) <> ''
 	BEGIN

		-- se siamo nel giro di popolamento/recupero dati e non nella prima creazione documento
		IF @popolaDati = 1
		BEGIN
	
			select @newId = max(id) 
				from CTL_DOC with(nolock) 
				where LinkedDoc = @idGara and deleted = 0 and TipoDoc = @tipoDoc and StatoFunzionale = 'RecuperoDati'		

			select * INTO #DATI_GARA from SITAR_DATI_GARA where idGara = @idGara

			--l'idpda ci serve pure dopo
			select @idPDA = idPDA from #DATI_GARA

			-- inseriamo i record [Document_OCP_GARA] e Document_OCP_LOTTI_AGGIUDICATI solo se siamo sulla prima iterazione di completa informazioni
			IF NOT EXISTS ( select top 1 idrow from Document_OCP_GARA with(nolock) where idHeader = @newid )
			BEGIN

				-- INSERISCO I DATI DELLA GARA
				INSERT INTO [Document_OCP_GARA] ([idHeader] ,[W3OGGETTO1] ,[W3IDGARA] ,[W3I_GARA] ,[W3DGURI] ,[W3DSCADB] ,[W9GAMOD_IND],
														[W9GAFLAG_ENT] ,[W3TIPOAPP] ,[W3ID_TIPOL],
														[W9GASTIPULA] ,[CFTEC1] ,[COGTEI] ,[NOMETEI] ,[TELTEC1] ,[G_EMATECI],
														[W3PROFILO1] ,[W3MIN1] ,[W3OSS1] ,[W9CCCODICE] ,[W9CCDENOM], CFEIN,
														W9APOUSCOMP,
														W3PROCEDUR,
														W3PREINFOR,
														W3TERMINE,
														W3RELAZUNIC)
								select @newId ,[W3OGGETTO1] ,[W3IDGARA] ,[W3I_GARA] ,[W3DGURI] ,[W3DSCADB] ,[W9GAMOD_IND],
														[W9GAFLAG_ENT] ,[W3TIPOAPP] ,[W3ID_TIPOL],
														[W9GASTIPULA] ,[CFTEC1] ,[COGTEI] ,[NOMETEI] ,[TELTEC1] ,[G_EMATECI],
														[W3PROFILO1] ,[W3MIN1] ,[W3OSS1] ,[W9CCCODICE] ,[W9CCDENOM], CFEIN,
														W9APOUSCOMP,
														W3PROCEDUR,
														W3PREINFOR,
														W3TERMINE,
														W3RELAZUNIC
									from #DATI_GARA

				-- INSERISCO I DATI DEI LOTTI AGGIUDICATI
				INSERT INTO Document_OCP_LOTTI_AGGIUDICATI([idHeader], [NumeroLotto], [W3OGGETTO2], [W3CIG], [W3MOD_IND], [W3IMPR_AMM], [W3IMPR_OFF], [W3DVERB], [W3DSCAPO], [W3IMP_AGGI], [W3PERC_RIB], [W3FLAG_RIC], [W3OFFE_MAX], [W3OFFE_MIN], [W3I_SUBTOT], [W9APDATA_STI], W3PERC_OFF, W3I_FINANZ, W3ID_FINAN )
					SELECT @newId, s.[NumeroLotto], d.descrizione, isnull(d.cig,t.CIG) , [W3MOD_IND], [W3IMPR_AMM], [W3IMPR_OFF], [W3DVERB], [W3DSCAPO], [W3IMP_AGGI], [W3PERC_RIB], [W3FLAG_RIC], [W3OFFE_MAX], [W3OFFE_MIN], [W3I_SUBTOT], [W9APDATA_STI], W3PERC_OFF, W3I_FINANZ, W3ID_FINAN 
						FROM document_microlotti_dettagli d with(nolock)
								inner join Document_PDA_TESTATA t with(nolock) on t.idHeader = d.IdHeader
								inner join SITAR_DATI_LOTTO s on s.numerolotto = d.NumeroLotto  and idPDA = d.IdHeader
						where d.idheader = @idPDA and tipodoc in ( 'PDA_MICROLOTTI' ) and voce = 0 and statoriga = 'AggiudicazioneDef' 
						

			END


			CREATE TABLE #raggruppamenti
			(
				[id] [int] IDENTITY(1,1) NOT NULL,
				indice [INT] NULL
			)

			-- mettiamo nella tabella temporanea tutti i lotti, sia quelli con datiOK a null che ad 1 
			select idRow, NumeroLotto, datiOK into #LOTTI_AGGIUDICATI from Document_OCP_LOTTI_AGGIUDICATI with(nolock) where idHeader = @newId 

			DECLARE curs CURSOR STATIC FOR     
				select top 20 idRow, NumeroLotto from #LOTTI_AGGIUDICATI where datiOK is null order by idRow asc -- Prendiamo tutti i lotti da completare a blocchi di 20

			OPEN curs 
			FETCH NEXT FROM curs INTO @idRow, @numerolotto

			WHILE @@FETCH_STATUS = 0   
			BEGIN  

				-- CREO IL NUOVO DOCUMENTO CTL_DOC PER GLI AGGIUDICATARI DEL LOTTO SUL QUALE STIAMO ITERANDO
				INSERT INTO CTL_DOC (IdPfu,  TipoDoc  , idpfuincharge ,Azienda ,body,LinkedDoc, prevdoc, StatoFunzionale )
					select  @IdUser, 'OCP_IMPRESE_AGGIUDICATARIE' , @IdUser ,Azienda,'',@idRow, 0, 'ConDettaglio'
						from ctl_doc with(nolock)
						where id = @idGara
			
				set @newIdColleato = SCOPE_IDENTITY()

				-- INSERISCO I DATI DELLE IMPRESE AGGIUDICATARIE
				INSERT INTO Document_OCP_IMPRESE_AGGIUDICATARIE ( [idHeader], idAzi, [CFIMP], [NOMIMP], [W3AGIDGRP], [W3ID_TIPOA], [W3RUOLO], [W3FLAG_AVV], [G_NAZIMP], [INDIMP], [NCIIMP], [LOCIMP], [TELIMP], [FAXIMP], [EMAI2IP], [NCCIAA], AGGAUS, CAPIMP, CFIMP_AUSILIARIA, W3AGIMP_AGGI, W3AGPERC_OFF, W3AGPERC_RIB)
						select @newIdColleato, idAzi, [CFIMP], [NOMIMP], [W3AGIDGRP], [W3ID_TIPOA], [W3RUOLO], [W3FLAG_AVV], [G_NAZIMP], [INDIMP], [NCIIMP], [LOCIMP], [TELIMP], [FAXIMP], [EMAI2IP], [NCCIAA], AGGAUS, CAPIMP, CFIMP_AUSILIARIA, W3AGIMP_AGGI, W3AGPERC_OFF, W3AGPERC_RIB
							from GET_AZI_AGGIUDICATARIE_DEF 
							where idPDA = @idPDA and numerolotto = @numerolotto
					
				truncate table #raggruppamenti

				-- PER OGNI INDICE UNVOCO CREATO SOPRA, INSERIAMO UN RECORD NELLA TABELLA TEMPORANEA,PER OGNI RECORD COSI' OTTEREMO UN INTERO CRESCENTE A PARTIRE DA 1.
				--	FACCIAMO QUESTO PERCHE' IL GRUPPO DEL SITAR CI HA INDICATO DI MANDARE UN RANGE ORIENTATIVO CHE VA DA 1 A 999
				insert into #raggruppamenti( indice ) select distinct [W3AGIDGRP] from Document_OCP_IMPRESE_AGGIUDICATARIE with(nolock) where idHeader = @newIdColleato

				-- ASSOCIAMO A TUTTI I MEMBRI DELL'RTI, INDENTIFICATI DALL'INDICE, IL NUOVO PROGRESSIVO
				update Document_OCP_IMPRESE_AGGIUDICATARIE
						set W3AGIDGRP = b.id
					from Document_OCP_IMPRESE_AGGIUDICATARIE a
							inner join #raggruppamenti b on b.indice = a.[W3AGIDGRP]
					where a.idHeader = @newIdColleato
					

				-- INSERISCO I DATI DEI RAPPRESENTANTI LEGALI, SEMPRE LEGATI AL DOCUMENTO OCP_IMPRESE_AGGIUDICATARIE MA RELAZIONATI PER IDAZI CON LA Document_OCP_IMPRESE_AGGIUDICATARIE
					-- + NELLO STEP SUCCESSIVO DEL COMPLETA INFORMAZIONI VERRA' INVOCATA IN LOOP LA PAGINA ASP PER COMPLETARE I RECORD Document_OCP_LEGALI_RAPPRESENTANTI CHIAMANDO ADRIER / Registro Imprese
					--		QUESTO PER I RECORD CON DATIOK A 0, cioè per rapleg non recuperati dal db
				INSERT INTO Document_OCP_LEGALI_RAPPRESENTANTI ( [idHeader],idazi, [CFTIM], [COGTIM], [NOMETIM], datiOK, esitoRI )
						select b.idRow, b.idAzi, [CFTIM], [COGTIM], [NOMETIM] , case when a.idAzi is null then 0 else 1 end, case when a.idazi is null then null else 'Dati recuperati dal DB' end
							from Document_OCP_IMPRESE_AGGIUDICATARIE b
									left join GET_AZI_RAP_LEG a with(Nolock) on b.idAzi = a.idAzi
							where b.idHeader = @newIdColleato
			
			
				UPDATE #LOTTI_AGGIUDICATI
						set datiOK = 1
					where idRow = @idRow

				FETCH NEXT FROM curs INTO @idRow, @numerolotto

			END  

			CLOSE curs   
			DEALLOCATE curs

			-- ALLINEIAMO L'AVANZAMENTO DATI SULLA TABELLA DEI LOTTI
			UPDATE Document_OCP_LOTTI_AGGIUDICATI
					set datiOK = b.datiOK
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
				--EXEC INSERT_SERVICE_REQUEST 'OCP', 'istanziaAggiudicazione', @IdUser , @newId

				DECLARE curs2 CURSOR STATIC FOR     
					select idRow from #LOTTI_AGGIUDICATI order by idRow asc

				OPEN curs2 
				FETCH NEXT FROM curs2 INTO @idRow

				WHILE @@FETCH_STATUS = 0   
				BEGIN  

					-- INSERISCO LA SENTINELLA PER FAR SCATTARE L'INTEGRAZIONE ( tabella Services_Integration_Request ) PER SINGOLO LOTTO
					EXEC INSERT_SERVICE_REQUEST 'OCP', 'istanziaAggiudicazioneLotti', @IdUser , @idRow

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
