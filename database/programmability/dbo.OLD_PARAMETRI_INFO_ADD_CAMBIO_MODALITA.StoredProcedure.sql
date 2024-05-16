USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_PARAMETRI_INFO_ADD_CAMBIO_MODALITA]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



--Versione=1&data=2017-06-20&Attivita=155048&Nominativo=Leone
CREATE PROCEDURE [dbo].[OLD_PARAMETRI_INFO_ADD_CAMBIO_MODALITA]( @idDoc int, @idUser int ) 
AS
BEGIN

	SET NOCOUNT ON

	--DECLARE @idDoc INT
	DECLARE @azienda INT
	DECLARE @modalita INT
	DECLARE @livello INT

	DECLARE @prevModalita INT
	DECLARE @prevLivello INT

	select  @modalita = a.modalitaDiScelta,
			@livello = a.livelloBloccato 
		from Document_Parametri_Info_ADD a with(nolock)
		where a.IdHeader = @idDoc

	select @azienda = pfuIdAzi 
		from profiliutente with(nolock)
		where idpfu = @idUser

	--------------------------------------------------------------------------------------------------------------------------------------
	-- SE SI STA SCEGLIENDO LA MODALITÀ 'BLOCCO LIVELLO' PASSO AD EFFETTUARE I CONTROLLI. ALTRIMENTI NON FACCIO NIENTE --
	--		(si sta passando da massima apertura a blocco livello oppure si sta cambiando il livello)
	-------------------------------------------------------------------------------------------------------------------------------------
	-- LO SCOPO ULTIMO DI QUESTA STORED È QUELLO DI PORTARE IN AUTOMATICO TUTTI  I MODELLI PRESENTI AL LIVELLO PRESCELTO		---------
	-------------------------------------------------------------------------------------------------------------------------------------

	set @prevModalita = 0
	set @prevLivello = -1

	select top 1 @prevModalita = modalitaDiScelta,
				 @prevLivello = isnull(livelloBloccato ,-1)
		from Document_Parametri_Info_ADD with(nolock)
		where idHeader <> @idDoc and deleted = 0

	IF @modalita = 1 and @prevLivello <> @livello
	BEGIN

		DECLARE @idModello INT
		DECLARE @ClasseIscriz VARCHAR(1000)
		DECLARE @dmvFatherClasse VARCHAR(1000)
		DECLARE @livelloClasse INT

		DECLARE @nuoveClassi VARCHAR(4000)
		DECLARE @titoloModello VARCHAR(4000)
		DECLARE @occorrenzeModello INT

		---------------------------------------------------------------------------------------------------------------------------------------
		-- RECUPERO L'INSIEME DEI MODELLI PUBBLICATI ANDANDO IN PRODOTTO CARTESIANO SULLE N CLASSI DI ISCRIZIONE SCELTE PER OGNI MODELLO ------
		---------------------------------------------------------------------------------------------------------------------------------------
		select id as idMod, /* b.[Value] as classiModello,*/ classi.items as classe, dom.DMV_Level as livelloClasse, dom.DMV_Father,isnull(uso.totUtilizzi,0) as totUtilizzi, cast('' as varchar(max)) as nuoveClassi INTO #ModificaModelli
				from ctl_doc a with(nolock) 
						inner join ctl_doc_value b with(nolock) on b.IdHeader = a.Id and b.DSE_ID = 'CLASSE' and b.DZT_Name = 'ClasseIscriz'
						cross apply dbo.Split( b.[value], '###') classi
						inner join ClasseIscriz dom with(nolock) ON dom.DMV_Cod = classi.items

						left join (
									select model.MOD_Name, COUNT(model.MOD_Name) as totUtilizzi
										from ctl_doc a with(nolock)
												inner join CTL_DOC_SECTION_MODEL model with(nolock) on model.IdHeader = a.Id and model.dse_id = 'MERC_ADDITIONAL_INFO_CLASSE_DETTAGLI'
										where tipodoc = 'MERC_ADDITIONAL_INFO'
										group by model.MOD_Name  
								) uso ON uso.MOD_Name = 'INFO_ADD_' + a.Titolo + '_MOD_Modello'

				where a.tipodoc = 'CONFIG_MODELLI_MERC_ADDITIONAL_INFO' and a.StatoFunzionale = 'Pubblicato' and a.deleted = 0

		DECLARE curs CURSOR STATIC FOR
			select idMod, classe, livelloClasse, DMV_Father,totUtilizzi from #ModificaModelli order by idMod

		OPEN curs
		FETCH NEXT FROM curs INTO @idModello,@ClasseIscriz,@livelloClasse,@dmvFatherClasse,@occorrenzeModello

		WHILE @@FETCH_STATUS = 0   
		BEGIN

			set @nuoveClassi = ''
			
			-- SE IL LIVELLO DELLA CLASSE SULLA QUALE STIAMO ITERANDO COINCIDE CON IL LIVELLO SCELTO NEI PARAMETRI NON FACCIO NIENTE
			IF @livelloClasse <> @livello
			BEGIN

				--SE IL LIVELLO SCELTO È INFERIORE ( IN TERMINI TECNICI IL LIVELLO E' PIU GRANDE )  A QUELLO DEL MODELLO, PER QUELLA CLASSE, 
				--SPOSTIAMO LA SELEZIONE DELLA CLASSE DI ISCRIZIONE SU TUTTI I "FIGLI" (SUL LIVELLO RISPETTO ) DEL PADRE PRECEDENTE
				IF @livello > @livelloClasse
				BEGIN

					set @nuoveClassi = '' --le classi figlie

					select @nuoveClassi = @nuoveClassi + DMV_Cod + '###' 
						from ClasseIscriz with(nolock)
						where dmv_deleted = 0 
								and left( DMV_Father , len( @dmvFatherClasse )) = @dmvFatherClasse 
								and DMV_Level = @livello
								--and DMV_Level > @livelloClasse 
								--and DMV_Level <= @livello
						ORDER BY DMV_Cod --le concateno ordinate

				END
				ELSE
				BEGIN

					set @nuoveClassi = ''

					--IL LIVELLO PRESCELTO È SUPERIORE A QUELLO DEL MODELLO ( TENICAMENTE IL LIVELLO È PIÙ PICCOLO )
					-- recupero quindi il nodo padre del livello scelto nei parametri rispetto al nodo sul quale sto iterando

					select @nuoveClassi = @nuoveClassi + DMV_Cod + '###' 
						from ClasseIscriz with(nolock)
						where dmv_deleted = 0
								and DMV_Level = @livello
								and DMV_Father = left(@dmvFatherClasse,len(DMV_Father))

				END

				set @nuoveClassi = '###' + @nuoveClassi

				UPDATE #ModificaModelli
						set nuoveClassi = @nuoveClassi
					WHERE idMod = @idModello and classe = @ClasseIscriz

			END

			FETCH NEXT FROM curs INTO @idModello,@ClasseIscriz,@livelloClasse,@dmvFatherClasse,@occorrenzeModello

		END  

		CLOSE curs   
		DEALLOCATE curs

		CREATE TABLE #ATTRIBUTI
		(
			chiave VARCHAR(MAX),
			IdHeader INT, 
			[Row] INT NULL, 
			DZT_Name NVARCHAR(MAX) NULL,
			totUtilizziModello INT NULL,
			usato INT DEFAULT(0), -- 0 non ancora recuperato, 1 recuperato
			tipoAttributo NVARCHAR(MAX) NULL,
			formula NVARCHAR(MAX) NULL,
			descCampo NVARCHAR(4000) NULL,
			cambioNaturaCampo int default(0)
		)

		--- annullo tutti i precedenti modelli pubblicati
		UPDATE CTL_DOC 
				set StatoFunzionale = 'Annullato'
			where tipodoc = 'CONFIG_MODELLI_MERC_ADDITIONAL_INFO' and StatoFunzionale = 'Pubblicato' and deleted = 0

		-- COMPLETATA L'ELABORAZIONE DELLE CLASSI PRE-ESISTENTI PASSIAMO A CAPIRE, PER OGNI NUOVA CLASSE PRESA IN DISTINCT, SE I MODELLI RELATIVI VENGONO SOLO 'SPOSTATI' DI CLASSE
		--	O CREATI PER UNIONE DI PIU' MODELLI		( in entrambi i casi facciamo un nuovo modello e il precedente viene messo ad 'Annullato' così da preservarne la storia )

		DECLARE @newModId INT
		DECLARE @newModKey VARCHAR(4000)
		DECLARE @newModDesc VARCHAR(4000)

		declare @tmpNomeModello VARCHAR(4000)
		declare @nomeNuovoModello VARCHAR(4000)
		declare @nomiVecchiModelli varchar(4000)

		declare @DZT_Name varchar(4000)
		DECLARE @numOccorrenze INT
		DECLARE @totCalcolati INT
		DECLARE @totObbligatori INT
		DECLARE @totScrittura INT
		DECLARE @tipoDztName varchar(4000)

		DECLARE curs2 CURSOR STATIC FOR
			select distinct nuoveClassi from #ModificaModelli --order by idMod

		OPEN curs2
		FETCH NEXT FROM curs2 INTO @nuoveClassi

		WHILE @@FETCH_STATUS = 0   
		BEGIN

			set @newModId = 0
			SET @newModKey = ''
			set @newModDesc = ''
			set @nomiVecchiModelli = '###'

			-- RIPULISCO LA TABELLA DI LAVORO ATTRIBUTI
			TRUNCATE TABLE #ATTRIBUTI

			INSERT INTO #ATTRIBUTI( chiave, IdHeader, DZT_Name, row, totUtilizziModello, tipoAttributo,formula,descCampo )
						select a.nuoveClassi, b.IdHeader, b.Value, b.row, a.totUtilizzi, b1.Value, calc2.[Value], b.Value --mi porto l'idheader per mantenere la relazione con i/il modelli/o 'originale'
							from #ModificaModelli a
									INNER JOIN ctl_doc_Value b with(nolock) on b.IdHeader = a.idMod AND b.DSE_ID = 'MODELLI' and b.DZT_Name = 'DZT_Name'
									LEFT JOIN ctl_doc_Value b1 with(nolock) on b1.IdHeader = a.idMod AND b1.Row = b.Row and b1.DSE_ID = 'MODELLI' and b1.DZT_Name = 'MOD_Modello'
									LEFT JOIN ctl_doc_Value b2 with(nolock) ON b2.IdHeader = a.idMod AND b2.Row = b.Row and b2.DSE_ID = 'MODELLI' and b2.DZT_Name = 'Descrizione'
									LEFT JOIN CTL_DOC_Value calc1 with(nolock) on calc1.IdHeader = a.idMod and calc1.DSE_ID = 'CALCOLI' and calc1.DZT_Name = 'DZT_Name' and calc1.Value = b.Value
									LEFT JOIN CTL_DOC_Value calc2 with(nolock) on calc2.IdHeader = a.idMod and calc2.DSE_ID = 'CALCOLI' and calc2.Row = calc1.Row and isnull(calc2.[Value],'') <> '' AND calc2.DZT_Name = 'Formula'
							where a.nuoveClassi = @nuoveClassi 

			select  @nomiVecchiModelli = @nomiVecchiModelli + 'INFO_ADD_' + b.Titolo + '_MOD_Modello' + '###',
					@newModKey = b.Titolo, -- se ci sono più modelli prenderò il primo titolo (l'ultimo ritornato dalla select)
					@newModDesc = @newModDesc + cast(b.Body as nvarchar(max)) + ' - ' -- la descrizione del nuovo modello sarà la concatenazione delle descrizioni dei modelli usati
				from #ModificaModelli a
							inner join ctl_doc b with(nolock) on b.id = a.idMod
				where a.nuoveClassi = @nuoveClassi
				order by b.Id desc

			set @newModDesc = LEFT( @newModDesc, len(@newModDesc)-3) -- tolgo l'ultimo ' - '

			select @numOccorrenze = count(*) from #ModificaModelli where nuoveClassi = @nuoveClassi

			set @newModKey = @newModKey + '_' + CAST(@numOccorrenze as varchar)

			-- SE LA RISULTANTE E' PRESENTE SU PIÙ DI 1 SOLO MODELLO
			IF @numOccorrenze > 1
			BEGIN

				------------------------------------------------------------------------------------
				-- SE LA RISULTANTE È PRESENTE SU PIU MODELLI, CREO IL NUOVO MODELLO PER UNIONE ----
				------------------------------------------------------------------------------------

				set @numOccorrenze  = @numOccorrenze
				
				------------------------------ COMPORTAMENTO DI FUSIONE MODELLI : ------------------------------------
				--	PRENDO L'UNIONE ESCLUSIVA DEGLI ATTRIBUTI CON LA SEGUENTE REGOLA :
				--	PRENDO MANO MANO TUTTI GLI ATTRIBUTI CHE TROVO AVANZANDO PER DELTA A BLOCCHI DI ATTRIBUTI PER MODELLI.
				--	PARTO DAL MODELLO CON IL MAGGIOR NUMERO DI USI E VADO A SCENDERE. 'FLAGGO' GLI ATTRIBUTI GIA USATI COME 'PRESI'
				--	E VADO AVANTI. IN PIÙ SE TROVO UN NUOVO ATTRIBUTO NON ANCORA INSERITO, DI TIPO CALCOLATO.
				--	ED ALMENO 1 ATTRIBUTO DI QUELLI UTILIZZATI NELLA FORMULA E' GIA STATO PRECEDENTEMENTE RECUPERATO
				--	PRENDO L'ATTRIBUTO USATO COME DESTINAZIONE PER IL CALCOLO, MA NE CAMBIO LA NATURA IN OBBLIGATORIO.
				--  CONSERVANDOMI NELLA TABELLA I VECCHI MODELLI. DOVRO CAMBIARE I DOCUMENTI DEI DATI DI CONSEGUENZA.
				--	ANNULLO IL VECCHIO DOCUMENTO MERC_ADDITIONAL_INFO_CLASSE_DETTAGLI E NE FACCIO UNO NUOVO. COPIANDO I DATI CHE MI SERVONO.
				-----------------------------------------------------------------------------------------------------

				DECLARE @idModCur VARCHAR(1000)
				DECLARE @attrib VARCHAR(1000)
				DECLARE @tipoAttributo VARCHAR(1000)
				declare @formula nvarchar(4000)
				declare @descCampo nvarchar(4000)
				declare @campoFormula nvarchar(4000)
				declare @status int

				DECLARE curs3 CURSOR STATIC FOR     
					SELECT IdHeader, DZT_Name,tipoAttributo, formula
						FROM #ATTRIBUTI
						WHERE chiave = @nuoveClassi
						ORDER BY totUtilizziModello desc, IdHeader desc

				OPEN curs3 
				FETCH NEXT FROM curs3 INTO @idModCur,@attrib,@tipoAttributo,@formula

				WHILE @@FETCH_STATUS = 0
				BEGIN

					-- SE L'ATTRIBUTO E' UN CALCOLATO E CON QUEL DZTNOME NON E' STATO ANCORA RECUPERATO
					IF @tipoAttributo = 'calc' AND NOT EXISTS ( select * from #ATTRIBUTI where DZT_Name = @attrib and usato = 1 )
					BEGIN

						-- ITERO SUI CAMPI GIA USATI MA NON NEL MODELLO CORRENTE.
						-- COSì CHE SE TROVO UN CAMPO DI QUESTI UTILIZZATO NELLA FORMULA. BLOCCO
						DECLARE curs4 CURSOR STATIC FOR     
								select descCampo
									from #ATTRIBUTI
									where usato = 1 and IdHeader <> @idModCur

						OPEN curs4 
						FETCH NEXT FROM curs4 INTO @campoFormula

						set @status = 0

						WHILE @@FETCH_STATUS = 0 and @status = 0
						BEGIN

							IF CHARINDEX( '[' + @campoFormula + ']', @formula) > 0
							BEGIN
								set @status = 1
							END

							FETCH NEXT FROM curs4 INTO @campoFormula

						END

						CLOSE curs4
						DEALLOCATE curs4

						IF @status = 1
						BEGIN

							-- cambio la natura del campo. passando da calcolato ad obbligatorio perchè ho trovato come 'usato'
							-- almeno uno campi usati nella formula
							UPDATE #ATTRIBUTI
									set tipoAttributo = 'obblig', cambioNaturaCampo = 1
								WHERE IdHeader = @idModCur and DZT_Name = @attrib

						END

					END

					
					UPDATE #ATTRIBUTI
							SET usato = 1
						WHERE usato = 0 and DZT_Name = @attrib and IdHeader = @idModCur
									and DZT_Name not in ( select DZT_Name from #ATTRIBUTI where IdHeader <> @idModCur and DZT_Name = @attrib and usato = 1 )


					FETCH NEXT FROM curs3 INTO @idModCur,@attrib,@tipoAttributo,@formula

				END

				CLOSE curs3
				DEALLOCATE curs3

			END
			ELSE
			BEGIN

				-- ESSENDO UNO SPOSTAMENTO DI CLASSI E NON UN UNIONE DI MODELLI. CONSIDERO TUTTI GLI ATTRIBUTI COME BUONI PERCHE' PREVENIENTI DA UN SOLO MODELLO
				UPDATE #ATTRIBUTI
					SET usato = 1

			END

			INSERT INTO CTL_DOC (StatoDoc,data,DataInvio, deleted, titolo,body, statofunzionale, tipodoc,IdPfu,LinkedDoc,Azienda, PrevDoc)
							values ( 'Sended',getdate(),getdate(),0, @newModKey, @newModDesc,'Pubblicato', 'CONFIG_MODELLI_MERC_ADDITIONAL_INFO', @idUser, 0, @azienda, 0 )

			set @newModId = SCOPE_IDENTITY()

			INSERT INTO CTL_DOC_Value ( IdHeader, DSE_ID,Row,DZT_Name,Value )
					select @newModId, b.DSE_ID,b.Row,b.DZT_Name, case when a.cambioNaturaCampo = 1 and b.DZT_Name = 'MOD_Modello' and b.Value = 'calc' then a.tipoAttributo else b.Value end
					from #ATTRIBUTI a
							INNER JOIN CTL_DOC_VALUE b WITH(NOLOCK) ON b.IdHeader = a.IdHeader and b.DSE_ID = 'MODELLI' and b.Row = a.Row --prendo tutte le righe con quella row
					where usato = 1
					order by b.row
					
			-- ASSOCIO AL NUOVO MODELLO IL NUOVO VALORE PER L'ATTRIBUTO ClasseIscriz
			INSERT INTO CTL_DOC_Value ( IdHeader, DSE_ID,Row,DZT_Name,Value )
							values ( @newModId, 'CLASSE', 0, 'ClasseIscriz', @nuoveClassi )

			-- Creo la sezione calcoli
			INSERT INTO CTL_DOC_Value ( IdHeader, DSE_ID,Row,DZT_Name,Value )
					select distinct @newModId, b2.DSE_ID,b2.Row,b2.DZT_Name, b2.Value
					from #ATTRIBUTI a
							INNER JOIN CTL_DOC_VALUE b1 WITH(NOLOCK) ON b1.IdHeader = a.IdHeader and b1.DSE_ID = 'CALCOLI' and b1.DZT_Name = 'DZT_Name' and b1.Value = a.DZT_Name
							INNER JOIN CTL_DOC_VALUE b2 WITH(NOLOCK) ON b2.IdHeader = a.IdHeader and b2.DSE_ID = 'CALCOLI' and b2.Row = b1.Row --prendo tutte le righe con quella row
					where usato = 1 and tipoAttributo = 'calc'
					order by b2.row

			-- SCHEDULO LA RICHIESTA DEL PROTOCOLLO
			INSERT INTO CTL_Schedule_Process( IdDoc, IdUser, DPR_DOC_ID, DPR_ID)
									values ( @newModId, @idUser, 'DOCUMENT', 'PROTOCOLLA_MAN' )

			set @tmpNomeModello = 'INFO_ADD_' + @newModKey
			exec CREA_MODELLI_FROM_CONFIG_MODELLI @tmpNomeModello, 'MOD_Modello' , @newModId, 'INFO_ADD' , 'INFO_ADD'
			set @nomeNuovoModello = 'INFO_ADD_' + @newModKey + '_MOD_Modello'

			-------------------------------------------
			--- CAMBIO I MODELLI SUI CONTESTI D'USO ---
			-------------------------------------------


			--	1. Metto ad 'Annullato' tutti i precedenti documenti di dati per i modelli modificati

			UPDATE CTL_DOC
					SET StatoFunzionale = 'Annullato'
				from ctl_doc a with(nolock)
						inner join CTL_DOC_SECTION_MODEL model with(nolock) on model.IdHeader = a.Id and model.dse_id = 'MERC_ADDITIONAL_INFO_CLASSE_DETTAGLI'
				where tipodoc = 'MERC_ADDITIONAL_INFO' and MOD_Name in ( select items from dbo.split(@nomiVecchiModelli, '###') )

			-- 2. Itero sui vecchi modelli coinvolti alla creazione del nuovo modello

			DECLARE @idOldDocDati INT

			DECLARE curs5 CURSOR STATIC FOR     
					select distinct a.id 
						from ctl_doc a with(nolock)
								inner join CTL_DOC_SECTION_MODEL model with(nolock) on model.IdHeader = a.Id and model.dse_id = 'MERC_ADDITIONAL_INFO_CLASSE_DETTAGLI'
						where tipodoc = 'MERC_ADDITIONAL_INFO' and MOD_Name in ( select items from dbo.split(@nomiVecchiModelli, '###') )

			OPEN curs5
			FETCH NEXT FROM curs5 INTO @idOldDocDati

			WHILE @@FETCH_STATUS = 0
			BEGIN

				DECLARE @newDocDati INT

				-------------------------
				-- 3. Travaso i dati ----
				-------------------------

				INSERT INTO CTL_DOC (StatoDoc,data,DataInvio, deleted, titolo,body, statofunzionale, tipodoc,IdPfu,LinkedDoc,Azienda)
							select StatoDoc,data,DataInvio, deleted, titolo,body, 'InLavorazione', tipodoc,IdPfu,LinkedDoc,Azienda
								from ctl_doc a with(nolock)
								where Id = @idOldDocDati

				set @newDocDati = SCOPE_IDENTITY()

				INSERT INTO CTL_DOC_SECTION_MODEL  ( IdHeader, DSE_ID, MOD_Name )
											values ( @newDocDati, 'MERC_ADDITIONAL_INFO_CLASSE_DETTAGLI', @nomeNuovoModello )

				declare @newDettID INT
				declare @oldDettID INT

				insert into Document_MicroLotti_Dettagli ( IdHeader )
							values(  @newDocDati  )

				SET @newDettID = SCOPE_IDENTITY()

				select top 1 @oldDettID = a.Id from Document_MicroLotti_Dettagli a with(nolock) where IdHeader = @idOldDocDati

				exec COPY_RECORD 'Document_MicroLotti_Dettagli' , @oldDettID , @newDettID , 'Id,IdHeader,'

				INSERT INTO CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
										values ( @newDocDati, 'CLASSE', 0, 'ClasseIscriz', @nuoveClassi )

				INSERT INTO CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
										values ( @newDocDati, 'CLASSE', 0, 'Body', @newModDesc )

				INSERT INTO CTL_ApprovalSteps ( APS_ID_DOC,APS_Doc_Type, APS_State, APS_Note, APS_Allegato, APS_UserProfile, APS_IdPfu, APS_IsOld, APS_Date, APS_APC_Cod_Node, APS_NextApprover)
							select @newDocDati,APS_Doc_Type, APS_State, APS_Note, APS_Allegato, APS_UserProfile, APS_IdPfu, APS_IsOld, APS_Date, APS_APC_Cod_Node, APS_NextApprover
								from CTL_ApprovalSteps a with(nolock)
								where APS_ID_DOC = @idOldDocDati

				FETCH NEXT FROM curs5 INTO @idOldDocDati

			END

			CLOSE curs5   
			DEALLOCATE curs5

			FETCH NEXT FROM curs2 INTO @nuoveClassi

		END

		CLOSE curs2   
		DEALLOCATE curs2

	END	

END


GO
