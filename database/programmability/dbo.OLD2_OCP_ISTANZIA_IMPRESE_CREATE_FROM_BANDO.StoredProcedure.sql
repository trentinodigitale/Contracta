USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_OCP_ISTANZIA_IMPRESE_CREATE_FROM_BANDO]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE [dbo].[OLD2_OCP_ISTANZIA_IMPRESE_CREATE_FROM_BANDO] ( @idGara int , @IdUser int, @popolaDati int = 0, @silentMode int = 0 )
AS
BEGIN

	-- IDDOC IN INPUT SARA' SEMPRE L'ID DELLA GARA A PRESCINDERE DAL PUNTO DI INNESCO, CHE PUO' ESSERE :
	--		AL MOMENTO DELLA CREAZIONE DELLA PDA
	--		ALLA CHIUSURA GARA, per coprire le gare deserte senza PDA dove però ci sono gli invitati che altrimenti si perderebbero

	SET NOCOUNT ON

	declare @Id      INT
	declare @Idazi   INT
	declare @Errore  NVARCHAR(2000)
	declare @newid   INT
	declare @newIdColleato   INT
	declare @prevDoc INT
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
	set @tipoDoc= 'OCP_ISTANZIA_IMPRESE'

	-- SE E' PRESENTE L'ACCOUNT DI LOGIN AI WS, PROCEDIAMO CON LA CREAZIONE
	IF dbo.OCP_getPasswordWS( '' ) <> ''
 	BEGIN

		-- se siamo nel giro di popolamento/recupero dati e non nella prima creazione documento
		IF @popolaDati = 1
		BEGIN
	
			select @newId = max(id) 
				from CTL_DOC a with(nolock) 
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

				-- INSERISCO I DATI DEI LOTTI DELLA GARA
				INSERT INTO Document_OCP_LOTTI([idHeader], [NumeroLotto], [W3OGGETTO2], [W3CIG] )
					SELECT @newId, idRiga, W3OGGETTO2 ,W3CIG 
						from SITAR_LISTA_LOTTI 
						where idGara = @idGara

			END

			select idRow, NumeroLotto, datiOK into #LOTTI from Document_OCP_LOTTI with(nolock) where idHeader = @newId

			DECLARE curs CURSOR FAST_FORWARD FOR
				select top 10 idRow, NumeroLotto from #LOTTI where datiOK is null order by idRow asc -- Prendiamo tutti i lotti da completare a blocchi di 50

			OPEN curs
			FETCH NEXT FROM curs INTO @idRow, @numerolotto

			WHILE @@FETCH_STATUS = 0   
			BEGIN  

				-- CREO IL NUOVO DOCUMENTO CTL_DOC PER I PARTECIPANTI/INVITATI DEL LOTTO SUL QUALE STIAMO ITERANDO
				INSERT INTO CTL_DOC (IdPfu,  TipoDoc  , idpfuincharge ,Azienda ,body,LinkedDoc, prevdoc, StatoFunzionale )
					select  @IdUser, 'OCP_IMPRESE_LOTTO' , @IdUser ,Azienda,'',@idRow, 0, 'ConDettaglio'
						from ctl_doc with(nolock)
						where id = @idGara	
			
				set @newIdColleato = SCOPE_IDENTITY()

				-- CREIAMO UN INTERO UNIVOCO ASSOCIATO ALL'RTI, GENERATO PARTENDO DALL'INSIEME DELLE RAGIONI SOCIALI DEL RAGGRUPPAMENTO
				select distinct *, case when isRTI = '1' then checksum(RagioneSocialeRTI) else NULL end as indice, cast(NULL as int) as W3AGIDGRP INTO #imprse
					from Gare_Elenco_Invitati_Partecipanti e
					where idBando = @idGara and numerolotto = @numerolotto

				CREATE TABLE #raggruppamenti
				(
					[id] [int] IDENTITY(1,1) NOT NULL,
					indice [INT] NULL
				)

				-- PER OGNI INDICE UNVOCO CREATO SOPRA, INSERIAMO UN RECORD NELLA TABELLA TEMPORANEA,PER OGNI RECORD COSI' OTTEREMO UN INTERO CRESCENTE A PARTIRE DA 1.
				--	FACCIAMO QUESTO PERCHE' IL GRUPPO DEL SITAR CI HA INDICATO DI MANDARE UN RANGE ORIENTATIVO CHE VA DA 1 A 999
				insert into #raggruppamenti( indice ) select distinct indice from #imprse where indice is not null

				-- ASSOCIAMO A TUTTI I MEMBRIU DELL'RTI, INDENTIFICATI DALL'INDICE, IL NUOVO PROGRESSIVO
				update #imprse
						set W3AGIDGRP = b.id
					from #imprse a
						inner join #raggruppamenti b on b.indice = a.indice

				drop table #raggruppamenti

				-- INSERISCO I DATI DELLE IMPRESE. la vista funziona sia per le invitate che per le partecipanti
				INSERT INTO Document_OCP_IMPRESE_GARA( [idHeader], idAzi, W9IMPARTEC,  [CFIMP], [NOMIMP], [W3AGIDGRP], GNATGIUI, [W3ID_TIPOA], [W3RUOLO], [G_NAZIMP], [INDIMP], [NCIIMP], [LOCIMP], [TELIMP], [FAXIMP], [EMAI2IP], [NCCIAA], CAPIMP)
						select @newIdColleato, 
								idAzienda, 
								case when idOfferta is null then 2 else 1 end as W9IMPARTEC, 
								CodiceFiscale,
								RagioneSociale,
								W3AGIDGRP, --INT. numero univoco associato al raggruppamento e uguale per tutti i suoi membri
								dv.DMV_Cod as GNATGIUI,
								dbo.OCP_getTipologiaSoggetto( isRTI,  aziIdDscFormaSoc) as W3ID_TIPOA,
								dbo.OCP_getRuoloRTI (isRTI, RuoloPartecipante ) as W3RUOLO,
								t.ValOut as G_NAZIMP,
								azi.aziIndirizzoLeg,
								azi.aziNumeroCivico,
								azi.aziLocalitaLeg,
								azi.aziTelefono1,
								azi.aziFAX,
								azi.aziE_Mail,
								dz2.vatValore_FT as IscrCCIAA,
								azi.aziCAPLeg
							from #imprse e
									inner join aziende azi with(nolock) on azi.idazi = e.idAzienda
									left join LIB_DomainValues dv with(nolock) on dv.DMV_DM_ID = 'G_043' and DMV_CodExt = azi.aziIdDscFormaSoc
									left join GEO_Elenco_Stati_ISO_3166_1 g with(nolock) on g.ISO_3166_1_3_LetterCode = dbo.GetPos( azi.azistatoleg2, '-', 4)
									left join CTL_Transcodifica t with(nolock) on t.dztNome = 'G_NAZIMP' and t.Sistema = 'SITAR' and t.ValIn = g.ISO_3166_1_2_LetterCode
									left join dm_attributi dz2 with(nolock) on dz2.idApp = 1 and dz2.lnk = azi.idazi and dz2.dztNome = 'IscrCCIAA'

				drop table #imprse	

				-- INSERISCO I DATI DEI RAPPRESENTANTI LEGALI, SEMPRE LEGATI AL DOCUMENTO OCP_IMPRESE_LOTTO MA RELAZIONATI PER IDAZI CON LA Document_OCP_IMPRESE_GARA
				--	entriamo con idRow negativo per non andare in conflitto di ID nella relazione che la tabella Document_OCP_LEGALI_RAPPRESENTANTI ha anche con la tabella
				--	delle imprese aggiudicatarie
				INSERT INTO Document_OCP_LEGALI_RAPPRESENTANTI ( [idHeader],idazi, [CFTIM], [COGTIM], [NOMETIM] )
						select -b.idRow, a.idAzi, [CFTIM], [COGTIM], [NOMETIM]  
							from GET_AZI_RAP_LEG a
									inner join Document_OCP_IMPRESE_GARA b with(nolock) on b.idAzi = a.idAzi
							where b.idHeader = @newIdColleato


				UPDATE #LOTTI
						set datiOK = 1
					where idRow = @idRow

				FETCH NEXT FROM curs INTO @idRow, @numerolotto

			END  

			CLOSE curs   
			DEALLOCATE curs

			-- ALLINEIAMO L'AVANZAMENTO DATI SULLA TABELLA DEI LOTTI
			UPDATE Document_OCP_LOTTI
					set datiOK = b.datiOK
				from Document_OCP_LOTTI a
						INNER JOIN #LOTTI b on b.idRow = a.idRow


			IF NOT EXISTS ( select idrow from #LOTTI where datiOK is null )
			BEGIN

				UPDATE ctl_doc 
						SET statofunzionale = 'InvioInCorso', 
							datainvio = getdate()
					WHERE id = @newId

				-- vecchia sentinella per inviare insieme tutti i lotti
				--EXEC INSERT_SERVICE_REQUEST 'OCP', 'istanziaImprese', @IdUser , @newId

				DECLARE curs2 CURSOR STATIC FOR     
					select idRow from #LOTTI order by idRow asc

				OPEN curs2 
				FETCH NEXT FROM curs2 INTO @idRow

				WHILE @@FETCH_STATUS = 0   
				BEGIN  

					
					-- INSERISCO LA SENTINELLA PER FAR SCATTARE L'INTEGRAZIONE ( tabella Services_Integration_Request ) E CAMBIO LO STATO DEL DOCUMENTO IN 'INVIO IN CORSO'
					EXEC INSERT_SERVICE_REQUEST 'OCP', 'istanziaImpreseLotti', @IdUser, @idRow

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
		
			-- se esiste per questa gara il documento OCP_ISTANZIA_GARA vuol dire che il flusso prevede l'integrazione
			IF EXISTS ( select top 1 id from CTL_DOC with(nolock) where LinkedDoc = @idGara and deleted = 0 and TipoDoc = 'OCP_ISTANZIA_GARA')
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

		-- se la chiamata a questa stored viene da un contesto ( come la creazione della PDA ) dove non devono essere ritornate select ( per non dare fastidio all'output già previsto dal chiamante )
		if @silentMode = 0
			-- rirorna l'id del doc da aprire
			select @newId as id
	
	END
	ELSE
	BEGIN

		if @Errore <> '' and @silentMode = 0
			select 'Errore' as id , @Errore as Errore

	END

	
END





GO
