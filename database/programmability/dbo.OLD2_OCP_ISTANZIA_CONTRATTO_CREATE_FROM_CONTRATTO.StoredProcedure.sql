USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_OCP_ISTANZIA_CONTRATTO_CREATE_FROM_CONTRATTO]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[OLD2_OCP_ISTANZIA_CONTRATTO_CREATE_FROM_CONTRATTO] ( @idGara int , @IdUser int, @popolaDati int = 0 )
AS
BEGIN

--	declare @idGara int , @IdUser int, @popolaDati int = 0

	--set @idGara = 328882
	--set @iduser = 42727
	--SET @popolaDati = 1

	-- IDDOC IN INPUT SARA' SEMPRE L'ID DELLA GARA A PRESCINDERE DAL PUNTO DI INNESCO, CHE PUO' ESSERE :
	--		1.	Convenzione Completa	( la pubblicazione lato ente ) 
	--		2.	Contratto da RdO		( conferma da parte dell'o.e. )
	--		3.	Contratto da Gara		( conferma da parte dell'o.e. )

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
	set @tipoDoc= 'OCP_ISTANZIA_CONTRATTO'

	-- SE E' PRESENTE L'ACCOUNT DI LOGIN AI WS, PROCEDIAMO CON LA CREAZIONE
	IF dbo.OCP_getPasswordWS( '' ) <> ''
 	BEGIN

		-- l'idpfu che viene passato alla stored ( per i contratti ) è quello dell'oe e non va bene
		select @IdUser = idpfu from ctl_doc with(nolock) where id = @idGara

		-- se siamo nel giro di popolamento/recupero dati e non nella prima creazione documento
		IF @popolaDati = 1
		BEGIN
	
			select @newId = max(id) 
				from CTL_DOC with(nolock) 
				where LinkedDoc = @idGara and deleted = 0 and TipoDoc = @tipoDoc and StatoFunzionale = 'RecuperoDati'		

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

			declare @generaConvenzione varchar(10)
			declare @divisioneLotti varchar(10)

			select  @generaConvenzione = b.GeneraConvenzione,
					@divisioneLotti = b.Divisione_lotti
				FROM ctl_doc gara with(nolock)
						inner join Document_Bando b with(nolock) ON b.idHeader = gara.id
				where gara.id = @idGara
		
			--  W3DATA_STI ( Data Stipula Contratto) : Dal documento SCRITTURA_PRIVATA e CONTRATTO_GARA prendere DataStipula , Documento CONVENZIONE prendere DataStipulaConvenzione
			--  W9INDECO ( Data decorrenza contrattuale ) : Dal documento SCRITTURA_PRIVATA e CONTRATTO_GARA prendere DataStipula , Documento CONVENZIONE prendere DataInizio
			--	W9INSCAD ( Data scadenza contrattuale ) : Dal documento SCRITTURA_PRIVATA e CONTRATTO_GARA prendere DataScadenza , Documento CONVENZIONE prendere DataFine
			
			-- per le gare che non sfociano in convenzione andiamo a prendere i contratti ( gare aperte ed rdo )
			IF ISNULL(@generaConvenzione,'0') <> '1'
			BEGIN

				-- per le multilotto
				IF @divisioneLotti <> '0'
				BEGIN

					--PRENDO TUTTI I LOTTI CON CONTRATTI ( IL LEGAME È IL CIG )
					INSERT INTO Document_OCP_LOTTI([idHeader], [NumeroLotto], [W3OGGETTO2], [W3CIG], W3DATA_STI, W9INDECO, W9INSCAD )
						SELECT DISTINCT @newId, l.idRiga, l.[W3OGGETTO2] , l.W3CIG , CONVERT(DATETIME, left(c2.Value,10), 102) ,CONVERT(DATETIME, left(c2.Value,10), 102), CONVERT(DATETIME, left(c3.Value,10), 102)
							from ctl_doc cont with(nolock)
									left join ctl_doc_value c2 with(nolock) on c2.IdHeader = cont.id and c2.DSE_ID = 'CONTRATTO' and c2.DZT_Name = 'DataStipula'
									left join ctl_doc_value c3 with(nolock) on c3.IdHeader = cont.id and c3.DSE_ID = 'CONTRATTO' and c3.DZT_Name = 'DataScadenza'
									inner join Document_MicroLotti_Dettagli lottiC with(nolock) ON lottiC.idheader = cont.id and lottic.TipoDoc in ( 'CONTRATTO_GARA', 'SCRITTURA_PRIVATA')  and isnull(lottiC.Voce,0) = 0
									inner join SITAR_LISTA_LOTTI l on l.W3CIG = lottic.CIG
							where l.idGara = @idGara and cont.Tipodoc in ( 'CONTRATTO_GARA', 'SCRITTURA_PRIVATA') and cont.Deleted = 0 and cont.StatoFunzionale <> 'InLavorazione'

				END
				ELSE
				BEGIN

					-- per le monolotto
					INSERT INTO Document_OCP_LOTTI([idHeader], [NumeroLotto], [W3OGGETTO2], [W3CIG], W3DATA_STI, W9INDECO, W9INSCAD )
						select distinct @newId, lp.NumeroLotto, lp.Descrizione, b.CIG, CONVERT(DATETIME, left(c2.Value,10) , 102) ,CONVERT(DATETIME, left(c2.Value,10) , 102), CONVERT(DATETIME, left( c3.Value,10) , 102)
							from ctl_doc pda with(nolock)
									inner join document_bando b with(nolock) on b.idheader = pda.linkeddoc
									inner join ctl_doc com with(nolock) ON com.LinkedDoc = pda.id and com.tipodoc = 'PDA_COMUNICAZIONE_GENERICA' and com.JumpCheck like '%-ESITO_DEFINITIVO_MICROLOTTI' and com.Deleted = 0 AND COM.STATOFUNZIONALE = 'Inviato'
									inner join Document_comunicazione_StatoLotti L with(nolock) on L.idheader = COM.Id  and l.deleted = 0 
									inner join document_microlotti_dettagli LP with(nolock) on LP.idheader = pda.ID and LP.tipodoc = 'PDA_MICROLOTTI' and LP.voce = 0 and LP.numeroLotto =  L.numerolotto 
									inner join ctl_doc cont with(nolock) ON cont.LinkedDoc = com.id and cont.tipodoc in ( 'CONTRATTO_GARA', 'SCRITTURA_PRIVATA') and cont.Deleted = 0 and cont.StatoFunzionale <> 'InLavorazione'
									left join ctl_doc_value c2 with(nolock) on c2.IdHeader = cont.id and c2.DSE_ID = 'CONTRATTO' and c2.DZT_Name = 'DataStipula'
									left join ctl_doc_value c3 with(nolock) on c3.IdHeader = cont.id and c3.DSE_ID = 'CONTRATTO' and c3.DZT_Name = 'DataScadenza'
							where pda.LinkedDoc = @idGara and pda.Deleted = 0 and PDA.TipoDoc = 'PDA_MICROLOTTI'

				END

			END
			ELSE
			BEGIN

				IF @divisioneLotti <> '0'
				BEGIN

					INSERT INTO Document_OCP_LOTTI([idHeader], [NumeroLotto], [W3OGGETTO2], [W3CIG], W3DATA_STI, W9INDECO, W9INSCAD )
						select distinct  @newId, lg.NumeroLotto, lg.descrizione, lg.CIG,  dc.DataStipulaConvenzione, dc.DataInizio, dc.DataFine
							from ctl_doc pda with(nolock) 
									inner join Document_MicroLotti_Dettagli lg with(nolock) ON pda.id = lg.IdHeader and lg.tipodoc = 'PDA_MICROLOTTI' and isnull(lg.voce,0) = 0 --and lg.StatoRiga = 'AggiudicazioneDef'
									inner join Document_MicroLotti_Dettagli lc with(nolock) ON lc.cig = lg.cig and lc.tipodoc = 'CONVENZIONE'-- and isnull(lc.voce,0) = 0
									inner join ctl_doc conv with(nolock) ON conv.id = lc.idheader and conv.TipoDoc = 'CONVENZIONE' and conv.deleted = 0 and conv.statofunzionale <> 'InLavorazione' 
									inner join Document_Convenzione dc with(nolock) on dc.id = conv.id 
							where pda.LinkedDoc = @idGara and pda.Deleted = 0 and PDA.TipoDoc = 'PDA_MICROLOTTI'

				END
				ELSE
				BEGIN

					INSERT INTO Document_OCP_LOTTI([idHeader], [NumeroLotto], [W3OGGETTO2], [W3CIG], W3DATA_STI, W9INDECO, W9INSCAD )
						select distinct  @newId, lg.NumeroLotto, lg.descrizione, lg.CIG,  dtConv.DataStipulaConvenzione, dtConv.DataInizio, dtConv.DataFine
							from ctl_doc pda with(nolock) 
									inner join document_bando gara with(nolock) ON gara.idHeader = pda.LinkedDoc
									inner join Document_MicroLotti_Dettagli lg with(nolock) ON pda.id = lg.IdHeader and pda.tipodoc = 'PDA_MICROLOTTI' and isnull(lg.voce,0) = 0 --and lg.StatoRiga = 'AggiudicazioneDef'
									inner join Document_Convenzione dtConv with(nolock) ON dtConv.CIG_MADRE = gara.CIG and dtConv.deleted=0
									inner join ctl_doc conv with(nolock) ON dtConv.id = conv.id and conv.TipoDoc = 'CONVENZIONE' and conv.deleted = 0 and conv.statofunzionale <> 'InLavorazione' 
							where pda.LinkedDoc = @idGara and pda.Deleted = 0 and PDA.TipoDoc = 'PDA_MICROLOTTI'
					

				END


			END

				
			
			-- INSERISCO LA SENTINELLA PER FAR SCATTARE L'INTEGRAZIONE ( tabella Services_Integration_Request ) E CAMBIO LO STATO DEL DOCUMENTO IN 'INVIO IN CORSO'
			EXEC INSERT_SERVICE_REQUEST 'OCP', 'istanziaContratto', @IdUser , @newId

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
