USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OCP_ISTANZIA_GARA_CREATE_FROM_BANDO]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








--exec OCP_ISTANZIA_GARA_CREATE_FROM_BANDO 259814, 45094

CREATE PROCEDURE [dbo].[OCP_ISTANZIA_GARA_CREATE_FROM_BANDO] ( @idDoc int , @IdUser int, @popolaDati int = 0)
AS
BEGIN
	
	-- @idDoc	   : ID DELLA PROCEDURA
	-- @IdUser	   : UTENTE CHE ESEGUE L'OPERAZIONE
	-- @popolaDati : -1 - eseguiamo solo i controlli sulla possibilità di inviareo meno la procedura ad OCP
	--				  0 - Inserisce il documento con lo stato di 'RecuperoDati' 
	--				  1 - Recupera i dati dalle viste di estrazione dati e passo il documento in 'InvioInCorso' dopo aver richiesto la sentinella per l'integrazione con i WS


	-- questa stored viene chiamata : 
	--	1. nel processo di conferma/approvazione di una procedura ( sia semplificato che bando gara )
	--	2. nel processo di conferma bando_modifica

	SET NOCOUNT ON

	declare @Id				INT
	declare @Idazi			INT
	declare @Errore			NVARCHAR(2000)
	declare @newid			INT
	declare @prevDoc		INT
	declare @cfRUP			VARCHAR(100)
	declare @tipoDoc		VARCHAR(100)
	declare @dataTaglio		VARCHAR(100)
	declare @dataInvioGara  VARCHAR(100)

	set @Errore=''	
	set @prevDoc = 0
	set @newid = null
	set @dataTaglio = null
	set @dataInvioGara = null
	set @tipoDoc = 'OCP_ISTANZIA_GARA'
	
	--select @cfRUP = b.pfuCodiceFiscale 
	--	from ctl_doc_value a with(nolock) 
	--			inner join ProfiliUtente b with(nolock) ON cast( b.IdPfu as varchar) = a.Value
	--	where idheader = @idDoc and a.dse_id = 'InfoTec_comune' and a.dzt_name = 'UserRUP' 

	-- SE E' PRESENTE L'ACCOUNT DI LOGIN PER IL RUP ( legato al suo codice fiscale )
	IF dbo.OCP_getPasswordWS('') <> ''
 	BEGIN

		-- se siamo nel giro di popolamento/recupero dati e non nella prima creazione documento
		IF @popolaDati = 1
		BEGIN
	
			select @newId = max(id) 
				from CTL_DOC with(nolock) 
				where LinkedDoc = @idDoc and deleted = 0 and TipoDoc = @tipoDoc and StatoFunzionale = 'RecuperoDati'		

			-- INSERISCO I DATI DELLA GARA
			INSERT INTO [Document_OCP_GARA] ([idHeader] ,[W3OGGETTO1] ,[W3IDGARA] ,[W3I_GARA] ,[W3DGURI] ,[W3DSCADB] ,[W9GAMOD_IND],
													[W9GAFLAG_ENT] ,[W3TIPOAPP] ,[W3ID_TIPOL],
													[W9GASTIPULA] ,[CFTEC1] ,[COGTEI] ,[NOMETEI] ,[TELTEC1] ,[G_EMATECI],
													[W3PROFILO1] ,[W3MIN1] ,[W3OSS1] ,[W9CCCODICE] ,[W9CCDENOM], CFEIN, W9GADURACCQ,
													W9GADPUBB, W3FLAG_SA, W9GACAM, W9SISMA,
													W3NAZ1,W3REG1,W3GUCE1,W3GURI1,W3ALBO1)
							select @newId ,[W3OGGETTO1] ,[W3IDGARA] ,[W3I_GARA] ,[W3DGURI] ,[W3DSCADB] ,[W9GAMOD_IND],
													[W9GAFLAG_ENT] ,[W3TIPOAPP] ,[W3ID_TIPOL],
													[W9GASTIPULA] ,[CFTEC1] ,[COGTEI] ,[NOMETEI] ,[TELTEC1] ,[G_EMATECI],
													[W3PROFILO1] ,[W3MIN1] ,[W3OSS1] ,[W9CCCODICE] ,[W9CCDENOM], CFEIN, W9GADURACCQ,
													W9GADPUBB, W3FLAG_SA, W9GACAM, W9SISMA,
													W3NAZ1,W3REG1,W3GUCE1,W3GURI1,W3ALBO1
								from SITAR_DATI_GARA 
								where idGara = @idDoc

			-- INSERISCO I DATI DEI LOTTI
			INSERT INTO [Document_OCP_LOTTI] ([idHeader] ,[NumeroLotto] ,[W3OGGETTO2] ,[W3CIG] ,[W3I_LOTTO] ,[W3CPV] ,
												[W3ID_SCEL2] ,[W3ID_CATE4] ,[W3MANOLO] ,[W3TIPO_CON] ,[W3MOD_GAR] ,
												[W3LUOGO_IS] ,[W3LUOGO_NU] ,[W3ID_TIPO] ,[W3ID_APP04] ,[W3ID_APP05],
												W3NLOTTO, W3I_ATTSIC, W9CUIINT)
							select @newId ,idRiga ,[W3OGGETTO2] ,[W3CIG] ,[W3I_LOTTO] ,[W3CPV] ,
												[W3ID_SCEL2] ,[W3ID_CATE4] ,[W3MANOLO] ,[W3TIPO_CON] ,[W3MOD_GAR] ,
												[W3LUOGO_IS] ,[W3LUOGO_NU] ,[W3ID_TIPO] ,[W3ID_APP04] ,[W3ID_APP05],
												W3NLOTTO, W3I_ATTSIC, W9CUIINT
								from SITAR_LISTA_LOTTI 
								where idGara = @idDoc
								order by cast(W3NLOTTO as  int )

			-- INSERISCO LA SENTINELLA PER FAR SCATTARE L'INTEGRAZIONE ( tabella Services_Integration_Request ) E CAMBIO LO STATO DEL DOCUMENTO IN 'INVIO IN CORSO'

			EXEC INSERT_SERVICE_REQUEST 'OCP', 'istanziaGara', @IdUser , @newId

			UPDATE ctl_doc 
					SET statofunzionale = 'InvioInCorso', 
						datainvio = getdate()
				WHERE id = @newId

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
					where id = @idDoc

			end

			-- RIMUOVIAMO EVENTUALI VECCHIE SENTINELLE SOLO SE NON CI SONO DOCUMENTI OCP COLLEGATI O SE SI STANNO RICHIEDENDO NUOVI CONTROLLI
			IF @popolaDati = -1 or NOT EXISTS ( select id from ctl_doc with(nolock) where LinkedDoc = @idDoc and deleted = 0 and TipoDoc = @tipoDoc and StatoFunzionale <> 'Annullato' )
				DELETE FROM CTL_DOC_VALUE where idheader = @idDoc and dse_id = 'OCP'

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
					where idHeader = @idDoc

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
				if dbo.PARAMETRI('SICOPAT','ATTIVA_IMPLEMENTAZIONE','ATTIVA','NO','-1') = 'SI'
				begin
					IF NOT ( @ProceduraGara = '15478' and @TipoBandoGara = '1' ) 
					BEGIN

						IF @popolaDati <> -1
						BEGIN

							-- Cerco l'ultimo documento, non annullato, precedente a questo
							select @prevDoc = max(id) 
								from CTL_DOC with(nolock) 
								where LinkedDoc = @idDoc and deleted = 0 and TipoDoc = @tipoDoc and StatoFunzionale <> 'Annullato'

							-- CREO IL DOCUMENTO
							INSERT into CTL_DOC (IdPfu,  TipoDoc  , idpfuincharge ,Azienda ,body,LinkedDoc, prevdoc, StatoFunzionale )
								select  @IdUser, @tipoDoc , @IdUser ,Azienda,'',@idDoc, isnull(@prevDoc,0), 'RecuperoDati'
									from ctl_doc with(nolock)
									where id = @idDoc		

							set @newId = SCOPE_IDENTITY()

							-- scheduliamo la richiesta di completamento informazioni per il documento appena creato
							INSERT INTO CTL_Schedule_Process ( IdDoc, IdUser, DPR_DOC_ID, DPR_ID)
													  values ( @idDoc, @IdUser, @tipoDoc, 'COMPLETA_INFORMAZIONI' )

						END

					END
					ELSE
					BEGIN

						set @Errore = 'Invio bloccato per gara monolotto senza integrazione simog o primo giro di una procedura in 2 fasi'

						IF NOT EXISTS ( select idrow from CTL_DOC_Value with(nolock) where IdHeader =  @idDoc and DSE_ID = 'OCP' and DZT_Name = 'MonoLottoSenzaSimog' )
						BEGIN

							INSERT INTO CTL_DOC_VALUE  ( IdHeader, DSE_ID, DZT_Name, value )
										VALUES ( @idDoc, 'OCP', 'MonoLottoSenzaSimog', '1')

						END

					END
				end
				else
				begin
					IF NOT EXISTS ( select idGara from SITAR_DATI_GARA where W3IDGARA = 'NO_INTEGRAZIONE' and idGara =  @idDoc )
						AND
					NOT ( @ProceduraGara = '15477' and @TipoBandoGara = '2' ) 
						AND
					NOT ( @ProceduraGara = '15478' and @TipoBandoGara = '1' ) 
					BEGIN

						IF @popolaDati <> -1
						BEGIN

							-- Cerco l'ultimo documento, non annullato, precedente a questo
							select @prevDoc = max(id) 
								from CTL_DOC with(nolock) 
								where LinkedDoc = @idDoc and deleted = 0 and TipoDoc = @tipoDoc and StatoFunzionale <> 'Annullato'

							-- CREO IL DOCUMENTO
							INSERT into CTL_DOC (IdPfu,  TipoDoc  , idpfuincharge ,Azienda ,body,LinkedDoc, prevdoc, StatoFunzionale )
								select  @IdUser, @tipoDoc , @IdUser ,Azienda,'',@idDoc, isnull(@prevDoc,0), 'RecuperoDati'
									from ctl_doc with(nolock)
									where id = @idDoc		

							set @newId = SCOPE_IDENTITY()

							-- scheduliamo la richiesta di completamento informazioni per il documento appena creato
							INSERT INTO CTL_Schedule_Process ( IdDoc, IdUser, DPR_DOC_ID, DPR_ID)
													  values ( @idDoc, @IdUser, @tipoDoc, 'COMPLETA_INFORMAZIONI' )

						END

					END
					ELSE
					BEGIN

						set @Errore = 'Invio bloccato per gara monolotto senza integrazione simog o primo giro di una procedura in 2 fasi'

						IF NOT EXISTS ( select idrow from CTL_DOC_Value with(nolock) where IdHeader =  @idDoc and DSE_ID = 'OCP' and DZT_Name = 'MonoLottoSenzaSimog' )
						BEGIN

							INSERT INTO CTL_DOC_VALUE  ( IdHeader, DSE_ID, DZT_Name, value )
										VALUES ( @idDoc, 'OCP', 'MonoLottoSenzaSimog', '1')

						END

					END
				end
				

			END
			ELSE
			BEGIN
				
				set @Errore = 'Data inizio integrazione non raggiunta'

				IF NOT EXISTS ( select idrow from CTL_DOC_Value with(nolock) where IdHeader =  @idDoc and DSE_ID = 'OCP' and DZT_Name = 'DataTaglioNonRaggiunta' )
				BEGIN

					INSERT INTO CTL_DOC_VALUE  ( IdHeader, DSE_ID, DZT_Name, value )
									VALUES ( @idDoc, 'OCP', 'DataTaglioNonRaggiunta', '1')

				END

			END

		END

	END
	ELSE
	BEGIN
		set @Errore = 'Account di login OCP non presente'
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

		select 'Errore' as id , @Errore as Errore

	END

	
END





GO
