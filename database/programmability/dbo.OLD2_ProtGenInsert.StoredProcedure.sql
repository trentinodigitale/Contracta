USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_ProtGenInsert]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE [dbo].[OLD2_ProtGenInsert] ( @idDoc varchar(50) , @IdUser int , @tipoDoc varchar(500) )
AS
BEGIN

	SET NOCOUNT ON

	declare @idProtGen INT
	
	declare @jumpCheck varchar(500)
	declare @sottoTipo varchar(500)

	declare @algoritmo varchar(50)
	declare @modalita varchar(2)
	declare @dataDocumento datetime
	declare @oggetto varchar(max)
	declare @idClassificazione varchar(500)
	declare @tipo varchar(2) 
	
	declare @protocolloInterno varchar(500)
	declare @titolo varchar(4000)
	declare @azienda int
	declare @destinatarioUser int
	declare @destinatarioAzi int

	declare @avanzamentoProtocollo int

	DECLARE @docName VARCHAR(1000)
	DECLARE @descrizione VARCHAR(max)
	DECLARE @note VARCHAR(max)

	declare @bloccaProtocollo int

	declare @statoFunzionale varchar(500)
	declare @linkedDoc INT

	declare @contesto varchar(200)
	declare @idDocPrincipale INT

	declare @invito as varchar(100)
	declare @rdo as varchar(100)

	declare @idUtente INT
	DECLARE @tipoDocCollegato varchar(500)
	DECLARE @jumpCheckCollegato varchar(1000)

	DECLARE @fascicoloGenerale varchar(500)
	declare @cf_mittente varchar(100)
	declare @allegatoFirmato nvarchar(4000)

	-- variabili che se valorizzate indicato la presenza di un processo specifico da schedulare ( di solito viene usato per i protocolli in uscita per gestire il giro di finalizza )
	declare @DPR_DOC_ID varchar(200)
	declare @DPR_ID		varchar(200)

	declare @idPfuAOO	INT	-- idpfu dell'utente dal quale recuperare l'AOO ( dal quale capire anche se il documento è da protocollare o meno ). se siamo su un protocollo in uscita è l'utente collegato

	declare @stopIdPfuAOO INT

	-- test base di assenza del fascicolo ( dove richiesto ) quando il linkedDoc corrisponde con il documento sul quale vogliamo il fascicolo imputato
	declare @testAssenzaFascicoloBase INT

	set @stopIdPfuAOO = 0
	set @testAssenzaFascicoloBase = 0
	set @idPfuAOO	= NULL
	set @DPR_DOC_ID = NULL
	set @DPR_ID		= NULL
	set @fascicoloGenerale = ''
	set @tipoDocCollegato = ''
	set @statoFunzionale = ''
	set @idDocPrincipale = -1
	set @invito = ''
	set @rdo = ''

	set @bloccaProtocollo = 0
	set @protocolloInterno = ''
	set @titolo = ''
	set @note = ''
	set @azienda = 0
	set @idUtente = 0
	set @destinatarioUser = -1
	set @destinatarioAzi = -1
	set @avanzamentoProtocollo = 0
	set @algoritmo = ''

	set @jumpCheck = ''
	set @sottoTipo = ''
	set @linkedDoc = -1

	set @contesto = ''

	-- se è attivo il protocollo generale
	IF EXISTS( select id from lib_dictionary with(nolock) where dzt_name = 'SYS_ATTIVA_PROTOCOLLO_GENERALE' and dzt_valuedef = 'YES')
	BEGIN

		-- se stiamo su un chiarimento ( o una risp al chiarimento ) il documento non è imperniato sulla ctl_doc ma sulla document_chiarimenti
		IF @tipoDoc not in ( 'COM_DPE_FORNITORE' ,  'CHIARIMENTI_PORTALE' , 'DETAIL_CHIARIMENTI_BANDO' , 'OFFERTA_BT', 'OFFERTA_BE' )
		BEGIN

			SELECT  @protocolloInterno = isnull(Protocollo,'')
				   ,@titolo = isnull(Titolo,'')
				   ,@azienda = isnull(Azienda,0)
				   ,@destinatarioUser = isnull(Destinatario_User,-1)
				   ,@destinatarioAzi = isnull(Destinatario_Azi,-1)
				   ,@oggetto = cast( body as varchar(max))
				   ,@note    = cast( note as varchar(max))
				   ,@statoFunzionale = StatoFunzionale
				   ,@linkedDoc = linkedDoc
				   ,@idUtente = idpfu
				   ,@idPfuAOO = idpfu -- per i protocolli in uscita @idPfuAOO verrà valorizzato con @IdUser ( idpfu utente collegato ), altrimenti viene lasciato idpfu di default a meno di una gestione specifica presente nei case sotto
				   ,@allegatoFirmato = isnull(sign_attach,'')
				FROM ctl_doc with(nolock) 
				where id = @idDoc
				
			-- Se l'azienda non è stata valorizzata perchè il documento configurato non lo prevedeva, la vado a recuperare a partire dall'idpfu
			IF @azienda = 0
			BEGIN

				select @azienda = pfu.pfuIdAzi 
					from profiliutente pfu with(nolock) 
					where pfu.idpfu = @idUtente
				
			END

		END
		ELSE
		BEGIN

			IF @tipoDoc in ( 'OFFERTA_BT', 'OFFERTA_BE' )
			BEGIN

				SELECT  @protocolloInterno = isnull(Protocollo,'')
					   ,@titolo = isnull(Titolo,'')
					   ,@azienda = isnull(Azienda,0)
					   ,@destinatarioUser = isnull(Destinatario_User,-1)
					   ,@destinatarioAzi = isnull(Destinatario_Azi,-1)
					   ,@oggetto = cast( body as varchar(max))
					   ,@note    = cast( note as varchar(max))
					   ,@statoFunzionale = StatoFunzionale
					   ,@linkedDoc = linkedDoc
					   ,@idUtente = idpfu
					   ,@idPfuAOO = idpfu
					   --,@allegatoFirmato = case when @tipoDoc = 'OFFERTA_BE' then d2.F1_SIGN_ATTACH else F2_SIGN_ATTACH end
				FROM Document_MicroLotti_Dettagli d with(nolock)
						inner join ctl_doc c with(nolock) ON c.Id = d.IdHeader and c.TipoDoc = 'OFFERTA'
				where d.id = @idDoc

			END

			IF @tipoDoc in ('COM_DPE_FORNITORE')
			BEGIN
				
				SELECT  @protocolloInterno = isnull(Protocollo,'')
					   ,@titolo = isnull(Name,'')
					   ,@azienda = isnull(P.pfuIdAzi,0)
					   ,@destinatarioUser = -1
					   ,@destinatarioAzi = isnull(d.idazi,0)
					   ,@oggetto = cast( Notacom as varchar(max))
					   ,@note    = cast( Notacom as varchar(max))
					   ,@statoFunzionale = StatoComFor
					   ,@linkedDoc = c.IdCom
					   ,@idUtente = idpfu
					   ,@idPfuAOO = idpfu
					   --,@allegatoFirmato = case when @tipoDoc = 'OFFERTA_BE' then d2.F1_SIGN_ATTACH else F2_SIGN_ATTACH end
				FROM Document_Com_DPE_Fornitori d with(nolock)
						inner join Document_Com_DPE  c with(nolock) ON c.IdCom  = d.IdCom 
						inner join ProfiliUtente P with(nolock) on P.IdPfu=c.Owner
				where d.IdComFor  = @idDoc
			END

			IF @tipoDoc in ('COM_DPE_ENTE')
			BEGIN
				
				SELECT  @protocolloInterno = isnull(Protocollo,'')
					   ,@titolo = isnull(Name,'')
					   ,@azienda = isnull(P.pfuIdAzi,0)
					   ,@destinatarioUser = -1
					   ,@destinatarioAzi = isnull(d.idazi,0)
					   ,@oggetto = cast( Notacom as varchar(max))
					   ,@note    = cast( Notacom as varchar(max))
					   ,@statoFunzionale = StatoComFor
					   ,@linkedDoc = c.IdCom
					   ,@idUtente = idpfu
					   ,@idPfuAOO = idpfu
					   --,@allegatoFirmato = case when @tipoDoc = 'OFFERTA_BE' then d2.F1_SIGN_ATTACH else F2_SIGN_ATTACH end
				FROM Document_Com_DPE_Enti d with(nolock)
						inner join Document_Com_DPE  c with(nolock) ON c.IdCom  = d.IdCom 
						inner join ProfiliUtente P with(nolock) on P.IdPfu=c.Owner
				where d.IdComEnte  = @idDoc
			END
		END

		-- SE è presente un altro record a parità di tipodocumento e id e non è stato ancora protocollato.
		-- invalido il precedente e inserisco il nuovo.
		declare @old_id INT
		set @old_id = -1

		select @old_id=id from v_protgen with(nolock) where appl_id_evento = @idDoc and appl_sigla = @tipoDoc and prot_acquisito <= 2 and flag_annullato = '0'

		IF @old_id > 0
		BEGIN
			
			update v_protgen
				set flag_annullato = '1'
			WHERE id = @old_id

		END

		-- se è presente un record a parità di ID e tipoDoc ed è in corso la protocollazione o è stato gia protocollato..
		-- non inserisco niente
		IF NOT EXISTS( select id from v_protgen with(nolock) where appl_id_evento = @idDoc and appl_sigla = @tipoDoc and prot_acquisito >= 3 and flag_annullato = '0' )
		BEGIN

			SET @tipo = 'G'
			SET @dataDocumento = getdate()

			IF @tipoDoc = 'CONTRATTO_CONVENZIONE'
			BEGIN
				
				
				----PER IL GIRO DI STIPULA FORMA PUBB= SI arrivo con id delle conveznione non il del contratto_convenzione visto che non esiste
				if exists ( select ID from CTL_DOC with(nolock) where Id=@idDoc AND TipoDoc='CONVENZIONE' )
				BEGIN
					select 
						@destinatarioAzi=AZI_Dest,
						@destinatarioUser=ReferenteFornitore--,
						--@idPfuAOO=ReferenteFornitore,
						--@idUtente=ReferenteFornitore
					from  document_convenzione with(nolock) where Id=@idDoc
					
				END




				SET @modalita = 'I' -- I = Ingresso  U = Uscita

				-- INIZIO settaggio delle variabili chiave per entrare sulla tabella di configurazione 'Document_protocollo_docER'				
				SET @jumpCheck = ''
				SET @sottoTipo = ''
				set @contesto = ''
				-- FINE settaggio --
		

				SET @descrizione = @titolo + @protocolloInterno

				SELECT  @oggetto = isnull(DescrizioneEstesa,'')
						,@docName = isnull(DOC_Name,'')
					FROM Document_Convenzione conv with(nolock) where conv.id = @idDoc

				SET @oggetto = @docName + @oggetto

				--IC richiede di aggiungere, all’atto dell’invio a DOC-ER, all’oggetto protocollo/registrazione la tipologia del documento (Convenzione, Listino,etc).
				set @oggetto = 'CONVENZIONE - ' + @oggetto

			END
			ELSE IF @tipoDoc = 'LISTINO_CONVENZIONE'
			BEGIN

				SET @modalita = 'I' -- I = Ingresso  U = Uscita

				-- per attività numero : 169735
				--	la protocollazione del listino viene bloccata, protocollando sempre e solo il CONTRATTO_CONVENZIONE 

				set @bloccaProtocollo = 1

			END
			ELSE IF @tipoDoc = 'CONVENZIONE_VALORE'
			BEGIN

				SET @modalita = 'I'

				-- INIZIO settaggio delle variabili chiave per entrare sulla tabella di configurazione 'Document_protocollo_docER'				
				SET @jumpCheck = ''
				SET @sottoTipo = ''
				set @contesto = ''
				-- FINE settaggio --

				SET @descrizione = @titolo + @protocolloInterno

			END
			ELSE IF @tipoDoc in ('VERIFICA_REGISTRAZIONE', 'VERIFICA_REGISTRAZIONE_FORN')
			BEGIN

				--- PER LA RICHIESTA DI REGISTRAZIONE E LA MODIFICA REGISTRAZIONE

				SET @modalita = 'I'

				-- INIZIO settaggio delle variabili chiave per entrare sulla tabella di configurazione 'Document_protocollo_docER'				
				SET @jumpCheck = ''
				SET @sottoTipo = ''
				set @contesto = ''
				-- FINE settaggio --

				-- IN QUESTO CASO IL DESTINATARIO DEL DOCUMENTO E' IMPLICITAMENTE L'AZIMASTER
				set @idPfuAOO = -1

				SET @descrizione = @titolo + ' ' + @protocolloInterno

				IF @oggetto is null
				BEGIN
					set @oggetto = 'Registrazione operatore economico' 
				END

				IF isnull(@allegatoFirmato,'') = '' AND NOT EXISTS ( select idrow from CTL_DOC_ALLEGATI with(nolock) where idHeader = @idDoc and isnull(Allegato,'') <> '' )
				BEGIN
					SET @bloccaProtocollo = 1
				END


			END
			ELSE IF @tipoDoc = 'VERIFICA_REGISTRAZIONE_ACCETTA'
			BEGIN

				--- DOCUMENTO DI APPROVAZIONE PER IL FORNITORE

				SET @modalita = 'U'

				-- INIZIO settaggio delle variabili chiave per entrare sulla tabella di configurazione 'Document_protocollo_docER'				
				SET @jumpCheck = ''
				SET @sottoTipo = ''
				set @contesto = ''
				-- FINE settaggio --

				SET @descrizione = @titolo + ' ' + @protocolloInterno

				IF @oggetto is null
				BEGIN
					set @oggetto = 'Accettazione Dati OE' 
				END

				-- PROCESSO CHE VERRA' SCHEDULATO IMMEDIATAMENTE SE NON CI SARA' IL GIRO DI PROTOCOLLO GENERALE
				set @DPR_DOC_ID = 'VERIFICA_REGISTRAZIONE'
				set @DPR_ID = 'APPROVA_FINALIZZA'

			END
			ELSE IF @tipoDoc = 'CAMBIO_RAPLEG' -- + CAMBIO_RAPLEG_INAPPROVE , ma il tipoDoc sulla ctl_doc resta comunque CAMBIO_RAPLEG
			BEGIN

				SET @modalita = 'I' --StatoFunzionale : InValutazione

				-- INIZIO settaggio delle variabili chiave per entrare sulla tabella di configurazione 'Document_protocollo_docER'				
				SET @jumpCheck = ''
				SET @sottoTipo = ''
				set @contesto = ''
				-- FINE settaggio --

				-- IN QUESTO CASO IL DESTINATARIO DEL DOCUMENTO E' IMPLICITAMENTE L'AZIMASTER
				set @idPfuAOO = -1

				SET @descrizione = @titolo + @protocolloInterno

				IF @statoFunzionale = 'InValutazione'
				BEGIN
					IF @oggetto is null
					BEGIN
						set @oggetto = 'Richiesta Cambio Rappresentante Legale' 
					END					
				END

				IF @statoFunzionale = 'Confermato'
				BEGIN

					SET @modalita = 'U'

					IF @oggetto is null
					BEGIN
						set @oggetto = 'Approvazione cambio Rappresentante Legale' 
					END	
				END

				IF @statoFunzionale = 'NotApproved'
				BEGIN

					SET @modalita = 'U'

					IF @oggetto is null
					BEGIN
						set @oggetto = 'Rifiuto cambio Rappresentante Legale' 
					END	
				END

			END
			ELSE IF @tipoDoc like 'ISTANZA_Albo%'
			BEGIN

				SET @modalita = 'I'

				-- INIZIO settaggio delle variabili chiave per entrare sulla tabella di configurazione 'Document_protocollo_docER'				
				SET @jumpCheck = ''
				SET @sottoTipo = ''
				SET @contesto = ''
				-- FINE settaggio --

				-- PRENDO L'IDPFU DESTINATARIO DALL'ALBO
				select @idPfuAOO = idpfu
					from ctl_doc with(nolock)
					where id = @linkedDoc

				SET @descrizione = @titolo + @protocolloInterno

				IF @oggetto is null
				BEGIN
					set @oggetto = 'Istanza di abilitazione' 
				END

				-- Se è un invio base
				IF exists( Select id from CTL_DOC with(nolock) where id = @idDoc and isnull( Jumpcheck , '' ) = '' )
				BEGIN
					set @descrizione = @descrizione + ' - Invio'
				END

				-- Se è un invio con conferma automatica
				IF exists( Select id from CTL_DOC with(nolock) where id = @idDoc and isnull( Jumpcheck , '' ) <> '' )
				BEGIN
					set @descrizione = @descrizione + ' - Invio/Conferma'
				END

				set @testAssenzaFascicoloBase = 1

			END
			ELSE IF @tipoDoc in ( 'COM_DPE_RISPOSTA','COM_DPE_RISPOSTA_ENTE')
			BEGIN
				
				SET @modalita = 'I'
				
				--if @tipoDoc = 'COM_DPE_RISPOSTA_ENTE'
				--	SET @modalita = 'L'

				-- INIZIO settaggio delle variabili chiave per entrare sulla tabella di configurazione 'Document_protocollo_docER'				
				SET @jumpCheck = ''
				SET @sottoTipo = ''
				SET @contesto = ''
				-- FINE settaggio --

				-- PRENDO L'IDPFU DESTINATARIO DELLA COM_DPE
				select @idPfuAOO = Owner
					from Document_Com_DPE with(nolock)
					where IdCom = @linkedDoc

				SET @descrizione = @titolo + ' ' + @protocolloInterno

				IF @oggetto is null
				BEGIN
					set @oggetto = 'Risposta alla comunicazione' 
				END			

			END
			ELSE IF @tipoDoc = 'CONFERMA_ISCRIZIONE'
			BEGIN

				SET @modalita = 'U'

				-- INIZIO settaggio delle variabili chiave per entrare sulla tabella di configurazione 'Document_protocollo_docER'				
				SET @jumpCheck = ''
				SET @sottoTipo = ''
				SET @contesto = ''
				-- FINE settaggio --

				-- PRENDO L'IDPFU DAL BANDO PERCHÈ PER LE CONFERME AUTOMATICHE L'IDPFU NON ERA VALORIZZATO CON L'UTENTE DELL'ENTE MA CON IL FORNITORE
				select @idPfuAOO = ban.IdPfu
					from ctl_doc ist with(nolock)
							inner join ctl_doc ban with(nolock) on ban.id = ist.LinkedDoc
					where ist.id = @linkedDoc

				-- Valorizzo la variabile @stopIdPfuAOO ad 1 per far sovrascrivere @idPfuAOO con idUser essendo questo un caso anomalo
				set @stopIdPfuAOO = 1

				-- PROCESSO CHE VERRA' SCHEDULATO IMMEDIATAMENTE SE NON CI SARA' IL GIRO DI PROTOCOLLO GENERALE
				set @DPR_DOC_ID = 'CONFERMA_ISCRIZIONE'
				set @DPR_ID = 'SEND_FINALIZZA'

				SET @descrizione = @titolo + @protocolloInterno

				IF @oggetto is null
				BEGIN
					set @oggetto = 'Conferma di abilitazione' 
				END

			END

			ELSE IF @tipoDoc = 'ESITO_CONTROLLI_OE'
			BEGIN

				SET @modalita = 'U'

				-- INIZIO settaggio delle variabili chiave per entrare sulla tabella di configurazione 'Document_protocollo_docER'				
				SET @jumpCheck = ''
				SET @sottoTipo = ''
				SET @contesto = 'ME-RDO'
				-- FINE settaggio --

				-- PRENDO L'IDPFU DAL DOCUMENTO
				select @idPfuAOO = IdPfu
					from ctl_doc  with(nolock)							
					where id = @idDoc

					

				select  @linkedDoc=prot.idheader -- @fascicoloGenerale=fascicolosecondario
					from CTL_DOC C with(nolock)  --ESITO_CONTROLLI
						inner join CTL_DOC D with(nolock) on D.Id=C.LinkedDoc  --CONTROLLI_OE
						inner join CTL_DOC F with(nolock) on F.Id=D.LinkedDoc  --CONTROLLI_OE CAPPELLO
						inner join Document_dati_protocollo prot with(nolock) ON prot.idheader = F.LinkedDoc
					where C.Id=@idDoc

				-- PROCESSO CHE VERRA' SCHEDULATO IMMEDIATAMENTE SE NON CI SARA' IL GIRO DI PROTOCOLLO GENERALE
				set @DPR_DOC_ID = 'ESITO_CONTROLLI_OE'
				set @DPR_ID = 'SEND_FINALIZZA'

				SET @descrizione = @titolo + @protocolloInterno

				IF @oggetto is null
				BEGIN
					set @oggetto = 'Esito Controlli O.E.' 
				END

			END

			ELSE IF @tipoDoc = 'CONFERMA_ISCRIZIONE_LAVORI'
			BEGIN

				SET @modalita = 'U'

				-- INIZIO settaggio delle variabili chiave per entrare sulla tabella di configurazione 'Document_protocollo_docER'				
				SET @jumpCheck = ''
				SET @sottoTipo = ''
				SET @contesto = ''
				-- FINE settaggio --

				select @idPfuAOO = ban.IdPfu
					from ctl_doc ist with(nolock)
							inner join ctl_doc ban with(nolock) on ban.id = ist.LinkedDoc
					where ist.id = @linkedDoc

				-- Valorizzo la variabile @stopIdPfuAOO ad 1 per far sovrascrivere @idPfuAOO con idUser essendo questo un caso anomalo
				set @stopIdPfuAOO = 1

				-- PROCESSO CHE VERRA' SCHEDULATO IMMEDIATAMENTE SE NON CI SARA' IL GIRO DI PROTOCOLLO GENERALE
				set @DPR_DOC_ID = 'CONFERMA_ISCRIZIONE'
				set @DPR_ID = 'SEND_FINALIZZA'

				SET @descrizione = @titolo + @protocolloInterno

				IF @oggetto is null
				BEGIN
					set @oggetto = 'Conferma di abilitazione' 
				END
				
			END
			ELSE IF @tipoDoc = 'SCARTO_ISCRIZIONE'
			BEGIN

				SET @modalita = 'U'

				-- INIZIO settaggio delle variabili chiave per entrare sulla tabella di configurazione 'Document_protocollo_docER' --
				SET @jumpCheck = ''
				SET @sottoTipo = ''
				SET @contesto = ''
				-- FINE settaggio --

				-- PROCESSO CHE VERRA' SCHEDULATO IMMEDIATAMENTE SE NON CI SARA' IL GIRO DI PROTOCOLLO GENERALE
				set @DPR_DOC_ID = 'SCARTO_ISCRIZIONE'
				set @DPR_ID = 'SEND_FINALIZZA'

				SET @descrizione = @titolo + @protocolloInterno

				IF @oggetto is null
				BEGIN
					set @oggetto = 'Rigetto di abilitazione' 
				END
			
			END
			ELSE IF @tipoDoc = 'SCARTO_ISCRIZIONE_LAVORI'
			BEGIN

				SET @modalita = 'U'

				-- INIZIO settaggio delle variabili chiave per entrare sulla tabella di configurazione 'Document_protocollo_docER' --
				SET @jumpCheck = ''
				SET @sottoTipo = ''
				SET @contesto = ''
				-- FINE settaggio --

				-- PROCESSO CHE VERRA' SCHEDULATO IMMEDIATAMENTE SE NON CI SARA' IL GIRO DI PROTOCOLLO GENERALE
				set @DPR_DOC_ID = 'SCARTO_ISCRIZIONE'
				set @DPR_ID = 'SEND_FINALIZZA'

				SET @descrizione = @titolo + @protocolloInterno

				IF @oggetto is null
				BEGIN
					set @oggetto = 'Rigetto di abilitazione' 
				END
				
			END
			ELSE IF @tipoDoc = 'INTEGRA_ISCRIZIONE'
			BEGIN
				
				select @tipoDocCollegato = b.tipodoc,
					   @jumpCheckCollegato = isnull(b.JumpCheck,'')
					from ctl_doc a	with(nolock)				     						--INTEGRA_ISCRIZIONE
							inner join ctl_doc ist with(nolock) on ist.id = a.LinkedDoc
							inner join ctl_doc b with(nolock)    ON b.id = ist.linkeddoc		--BANDO ME o LAVORI
					where a.id = @idDoc

				SET @modalita = 'U'

				-- INIZIO settaggio delle variabili chiave per entrare sulla tabella di configurazione 'Document_protocollo_docER' --
				SET @jumpCheck = ''
				SET @sottoTipo = ''

				IF @tipoDocCollegato = 'BANDO' and @jumpCheckCollegato = '' -- solo se bando ME ( no bando lavori o altro)
				BEGIN					
					set @contesto = 'ME-BANDO'
				END
				ELSE IF @tipoDocCollegato = 'BANDO' and @jumpCheckCollegato like 'BANDO_ALBO%'
				BEGIN
					set @contesto = 'BANDO-LAVORI'
				END
				ELSE IF @tipoDocCollegato = 'BANDO_ASTA'
				BEGIN
					set @contesto = 'ASTE'
				END
				ELSE
				BEGIN
					set @contesto = 'altro'
				END
				-- FINE settaggio --

				-- PROCESSO CHE VERRA' SCHEDULATO IMMEDIATAMENTE SE NON CI SARA' IL GIRO DI PROTOCOLLO GENERALE
				set @DPR_DOC_ID = 'INTEGRA_ISCRIZIONE'
				set @DPR_ID = 'SEND_FINALIZZA'

				SET @descrizione = @titolo + @protocolloInterno

				IF @oggetto is null
				BEGIN
					set @oggetto = 'Richiesta integrativa' 
				END


			END
			ELSE IF @tipoDoc = 'INTEGRA_ISCRIZIONE_RIS'
			BEGIN

				select @tipoDocCollegato = b.tipodoc,
					   @jumpCheckCollegato = isnull(b.JumpCheck,''),
					   @idPfuAOO = b.IdPfu
					from ctl_doc a	with(nolock)	
							inner join ctl_doc integra with(nolock) on integra.id = a.LinkedDoc   		--INTEGRA_ISCRIZIONE
							inner join ctl_doc ist with(nolock) on ist.id = integra.LinkedDoc			-- ISTANZA
							inner join ctl_doc b with(nolock)    ON b.id = ist.linkeddoc			    --BANDO ME o LAVORI
					where a.id = @idDoc

				SET @modalita = 'I'

				-- INIZIO settaggio delle variabili chiave per entrare sulla tabella di configurazione 'Document_protocollo_docER' --
				SET @jumpCheck = ''
				SET @sottoTipo = ''

				IF @tipoDocCollegato = 'BANDO' and @jumpCheckCollegato = '' -- solo se bando ME ( no bando lavori o altro)
				BEGIN
					set @contesto = 'ME-BANDO'
				END
				ELSE IF @tipoDocCollegato = 'BANDO' and @jumpCheckCollegato = 'BANDO_ALBO_LAVORI'
				BEGIN
					set @contesto = 'BANDO-LAVORI'
				END
				ELSE IF @tipoDocCollegato = 'BANDO_ASTA'
				BEGIN
					set @contesto = 'ASTE'
				END
				ELSE
				BEGIN
					set @contesto = 'altro'
				END
				-- FINE settaggio --

				SET @descrizione = @titolo + @protocolloInterno

				IF @oggetto is null
				BEGIN
					set @oggetto = 'Risposta richiesta integrativa' 
				END

			END
			ELSE IF @tipoDoc = 'INTEGRA_ISCRIZIONE_RIS_SDA'
			BEGIN

				SET @modalita = 'I'

				-- INIZIO settaggio delle variabili chiave per entrare sulla tabella di configurazione 'Document_protocollo_docER' --
				SET @jumpCheck = ''
				SET @sottoTipo = ''
				SET @contesto = ''
				-- FINE settaggio --

				set @idPfuAOO = @destinatarioUser

				SET @descrizione = @titolo + @protocolloInterno

				IF @oggetto is null
				BEGIN
					set @oggetto = 'Risposta richiesta integrativa' 
				END

			END
			ELSE IF @tipoDoc like 'ISTANZA_SDA%'
			BEGIN

				SET @modalita = 'I'

				-- INIZIO settaggio delle variabili chiave per entrare sulla tabella di configurazione 'Document_protocollo_docER' --
				SET @jumpCheck = ''
				SET @sottoTipo = ''
				SET @contesto = ''
				-- FINE settaggio --
				
				SET @descrizione = isnull(@titolo,'') + ' - ' + isnull(@protocolloInterno,'')
					
				SELECT @oggetto = isnull(Titolo, '')
						,@idPfuAOO = IdPfu
					FROM ctl_doc with(nolock) 
					where id = @LinkedDoc --recupero il titolo del bando

				set @oggetto = 'Istanza di ammissione SDA – ' + @oggetto

				-- Se è un invio base
				IF exists( Select id from CTL_DOC with(nolock) where id = @idDoc and isnull( Jumpcheck , '' ) = '' )
				BEGIN
					set @descrizione = @descrizione + ' - Invio'
				END

				-- Se è un invio con conferma automatica
				IF exists( Select id from CTL_DOC with(nolock) where id = @idDoc and isnull( Jumpcheck , '' ) <> '' )
				BEGIN
					set @descrizione = @descrizione + ' - Invio/Conferma'
				END

				set @testAssenzaFascicoloBase = 1


			END
			ELSE IF @tipoDoc = 'CONFERMA_ISCRIZIONE_SDA'
			BEGIN

				SET @modalita = 'U'

				-- INIZIO settaggio delle variabili chiave per entrare sulla tabella di configurazione 'Document_protocollo_docER' --
				SET @jumpCheck = ''
				SET @sottoTipo = ''
				SET @contesto = ''
				-- FINE settaggio --

				-- PROCESSO CHE VERRA' SCHEDULATO IMMEDIATAMENTE SE NON CI SARA' IL GIRO DI PROTOCOLLO GENERALE
				set @DPR_DOC_ID = 'CONFERMA_ISCRIZIONE_SDA'
				set @DPR_ID = 'SEND_FINALIZZA'

				SET @descrizione = @titolo + @protocolloInterno

				IF @oggetto is null
				BEGIN
					set @oggetto = 'Comunicazione di ammissione' 
				END

			END
			ELSE IF @tipoDoc = 'SCARTO_ISCRIZIONE_SDA'
			BEGIN

				SET @modalita = 'U'

				-- INIZIO settaggio delle variabili chiave per entrare sulla tabella di configurazione 'Document_protocollo_docER' --
				SET @jumpCheck = ''
				SET @sottoTipo = ''
				SET @contesto = ''
				-- FINE settaggio --

				-- PROCESSO CHE VERRA' SCHEDULATO IMMEDIATAMENTE SE NON CI SARA' IL GIRO DI PROTOCOLLO GENERALE
				set @DPR_DOC_ID = 'SCARTO_ISCRIZIONE'
				set @DPR_ID = 'SEND_FINALIZZA'

				SET @descrizione = @titolo + @protocolloInterno

				IF @oggetto is null
				BEGIN
					set @oggetto = 'Comunicazione rigetto richiesta' 
				END


			END
			ELSE IF @tipoDoc = 'INTEGRA_ISCRIZIONE_SDA'
			BEGIN

				SET @modalita = 'U'

				-- INIZIO settaggio delle variabili chiave per entrare sulla tabella di configurazione 'Document_protocollo_docER' --
				SET @jumpCheck = ''
				SET @sottoTipo = ''
				SET @contesto = ''
				-- FINE settaggio --

				-- PROCESSO CHE VERRA' SCHEDULATO IMMEDIATAMENTE SE NON CI SARA' IL GIRO DI PROTOCOLLO GENERALE
				set @DPR_DOC_ID = 'INTEGRA_ISCRIZIONE'
				set @DPR_ID = 'SEND_FINALIZZA'

				SET @descrizione = @titolo + @protocolloInterno

				IF @oggetto is null
				BEGIN
					set @oggetto = 'Risposta richiesta integrativa' 
				END

			END
			ELSE IF @tipoDoc = 'ODC-ACCETTATO' -- Conferma Ordinativo di fornitura ( ACCETTA )
			BEGIN

				--'ODC-ACCETTATO'. Protocollo in entrata
				
				-- INIZIO settaggio delle variabili chiave per entrare sulla tabella di configurazione 'Document_protocollo_docER' --
				SET @jumpCheck = ''
				SET @sottoTipo = ''
				SET @contesto = ''
				-- FINE settaggio --

				SET @modalita = 'I'
				SET @descrizione = @titolo + @protocolloInterno

				-- prendo l'utente destinatario dalla convenzione
				select @idPfuAOO = idpfu
					from ctl_doc with(nolock)
					where id = @linkedDoc

				IF @oggetto is null
				BEGIN
					set @oggetto = 'Ordinativo di fornitura' 
				END
				ELSE
				BEGIN
					set @oggetto = 'Ordinativo di fornitura - ' + @oggetto
				END

				set @oggetto = @oggetto + ' - Conferma'


			END
			ELSE IF @tipoDoc = 'ODC-RIFIUTATO' -- Conferma Ordinativo di fornitura ( ACCETTA )
			BEGIN

				--'ODC-RIFIUTATO'. Protocollo in entrata
				SET @modalita = 'I'

				-- INIZIO settaggio delle variabili chiave per entrare sulla tabella di configurazione 'Document_protocollo_docER' --
				SET @jumpCheck = ''
				SET @sottoTipo = ''
				SET @contesto = ''
				-- FINE settaggio --

				-- prendo l'utente destinatario dalla convenzione
				--select @idPfuAOO = idpfu
				--	from ctl_doc with(nolock)
				--	where id = @linkedDoc

				SET @descrizione = @titolo + @protocolloInterno

				IF @oggetto is null
				BEGIN
					set @oggetto = 'Ordinativo di fornitura' 
				END
				ELSE
				BEGIN
					set @oggetto = 'Ordinativo di fornitura - ' + @oggetto
				END

				set @oggetto = @oggetto + ' - Rifiuto'


			END
			ELSE IF @tipoDoc = 'ODC' -- Ordinativo di fornitura ( SEND_FORNITORE )
			BEGIN

				 -- 'ODC'. Protocollo in uscita

				 SET @modalita = 'U'

				-- INIZIO settaggio delle variabili chiave per entrare sulla tabella di configurazione 'Document_protocollo_docER' --
				SET @jumpCheck = ''
				SET @sottoTipo = ''
				SET @contesto = ''
				-- FINE settaggio --

				-- PROCESSO CHE VERRA' SCHEDULATO IMMEDIATAMENTE SE NON CI SARA' IL GIRO DI PROTOCOLLO GENERALE
				set @DPR_DOC_ID = 'ODC'
				set @DPR_ID = 'SEND_FORNITORE_FINALIZZA'

				SET @descrizione = @titolo + @protocolloInterno

				IF exists ( select rda_id from Document_ODC with(nolock) where rda_id = @idDoc and isnull(IdDocRidotto,0) > 0 )
				BEGIN
					set @oggetto = 'Riduzione Ordinativo di fornitura' 
				END
				ELSE
				BEGIN
					set @oggetto = 'Ordinativo di fornitura' 
				END

				IF not @oggetto is null
				BEGIN
					set @oggetto = @oggetto + ' - ' + @oggetto
				END


			END
			ELSE IF @tipoDoc = 'ANNULLA_ORDINATIVO'
			BEGIN

				-------------------------------
				--- ANNULLAMENTO ODF ----------
				-------------------------------

				SET @modalita = 'U'

				-- INIZIO settaggio delle variabili chiave per entrare sulla tabella di configurazione 'Document_protocollo_docER' --
				SET @jumpCheck = ''
				SET @sottoTipo = ''
				SET @contesto = ''
				-- FINE settaggio --

				select @idPfuAOO = ord.IdPfu
					from ctl_doc ord with(nolock)
					where ord.id = @linkedDoc

				-- Valorizzo la variabile @stopIdPfuAOO ad 1 per far sovrascrivere @idPfuAOO con idUser essendo questo un caso anomalo
				set @stopIdPfuAOO = 1
				
				SET @descrizione = @titolo + @protocolloInterno

				IF @oggetto is null
				BEGIN
					set @oggetto = 'Annullamento OdF' 
				END
				ELSE
				BEGIN
					set @oggetto = 'Annullamento OdF - ' + @oggetto
				END

			END
			ELSE IF @tipoDoc = 'CHIARIMENTI_PORTALE'
			BEGIN

				----------------------------
				-- INSERIMENTO QUESITO -----
				----------------------------

				SET @modalita = 'I'

				SELECT   @protocolloInterno = isnull(c.Protocol,'')
						, @azienda = isnull(doc.Azienda,-1)
						, @destinatarioUser = null
						, @destinatarioAzi = isnull(doc.Azienda,-1)
						--,@oggetto = cast( c.Domanda as varchar(max))
						, @oggetto = doc.titolo + ' - richiesta di chiarimenti' --Titolo Procedura– richiesta di chiarimenti
						, @linkedDoc = c.ID_ORIGIN
						, @tipoDocCollegato = isnull(c.Document,'')
						, @jumpCheckCollegato = isnull(doc.jumpcheck,'')
						, @idPfuAOO = doc.IdPfu
					FROM document_chiarimenti c with(nolock) 
							INNER JOIN profiliutente p with(nolock) ON c.UtenteDomanda = p.idpfu
							LEFT JOIN CTL_DOC doc with(nolock) ON doc.id = c.ID_ORIGIN 
					WHERE c.id = @idDoc

				-- INIZIO settaggio delle variabili chiave per entrare sulla tabella di configurazione 'Document_protocollo_docER' --
				SET @jumpCheck = ''
				SET @sottoTipo = ''

				IF @tipoDocCollegato = 'BANDO' and @jumpCheckCollegato = '' -- solo se bando ME ( no bando lavori o altro)
				BEGIN
					set @contesto = 'ME-BANDO'
				END
				ELSE IF @tipoDocCollegato = 'BANDO' and @jumpCheckCollegato like 'BANDO_ALBO%'
				BEGIN
					set @contesto = 'BANDO-LAVORI'
				END
				ELSE IF @tipoDocCollegato = 'BANDO_SDA'
				BEGIN				
					set @contesto = 'SDA'
				END
				ELSE IF @tipoDocCollegato = 'BANDO_SEMPLIFICATO'
				BEGIN
					set @contesto = 'SEMPLIFICATO'
				END
				ELSE IF @tipoDocCollegato = 'BANDO_ASTA'
				BEGIN
					set @contesto = 'ASTE'
				END
				ELSE
				BEGIN

					-- se il bando collegato è un RDO
					IF EXISTS( select idRow from document_bando with(nolock) where tipoProceduraCaratteristica = 'RDO' AND idheader = @linkedDoc )
					BEGIN

						set @contesto = 'me-rdo'

					END
					ELSE IF EXISTS( select idRow from document_bando with(nolock) where isnull(tipoProceduraCaratteristica,'') = '' AND idheader = @linkedDoc )
					BEGIN

						set @contesto = 'GARE'

					END
					ELSE
					BEGIN

						-- DA AGGIUNGERE IN QUEST'ELSE GLI ALTRI CONTESTI, QUANDO VERRANNO IMPLEMENTATI
						set @contesto = 'altro-contesto'

					END

				END

				-- FINE settaggio --


				SET @descrizione = 'Quesito '  + @protocolloInterno

				IF @oggetto is null
				BEGIN
					set @oggetto = 'Quesito' 
				END

				set @testAssenzaFascicoloBase = 1

			END
			ELSE IF @tipoDoc = 'DETAIL_CHIARIMENTI_BANDO'
			BEGIN

				---------------------------
				-- RISPOSTA A QUESITO -----
				---------------------------

				SET @modalita = 'U'

				SELECT   @protocolloInterno = isnull(c.Protocol,'')
						,@azienda = isnull(doc.Azienda,-1)
						,@destinatarioUser = isnull(p.idpfu,-1)
						,@destinatarioAzi = isnull(p.pfuidazi,-1)
						--,@oggetto = cast( isnull(Risposta,'') as varchar(max))
						,@oggetto = doc.titolo + ' - risposta richiesta di chiarimenti' --Titolo Procedura – risposta richiesta di chiarimenti
						,@linkedDoc = c.ID_ORIGIN
						,@tipoDocCollegato = c.Document
						,@jumpCheckCollegato = isnull(doc.jumpcheck,'')
						,@idPfuAOO = doc.IdPfu
					FROM document_chiarimenti c with(nolock)
							INNER JOIN profiliutente p with(nolock) ON c.UtenteDomanda = p.idpfu
							LEFT JOIN CTL_DOC doc with(nolock) ON doc.id = c.ID_ORIGIN 
					WHERE c.id = @idDoc


				-- INIZIO settaggio delle variabili chiave per entrare sulla tabella di configurazione 'Document_protocollo_docER' --
				SET @jumpCheck = ''
				SET @sottoTipo = ''

				IF @tipoDocCollegato = 'BANDO' and @jumpCheckCollegato = '' -- solo se bando ME ( no bando lavori o altro)
				BEGIN
					set @contesto = 'ME-BANDO'
				END
				--ELSE IF @tipoDocCollegato = 'BANDO' and @jumpCheckCollegato = 'BANDO_ALBO_LAVORI'
				ELSE IF @tipoDocCollegato = 'BANDO' and @jumpCheckCollegato like 'BANDO_ALBO%'
				BEGIN
					set @contesto = 'BANDO-LAVORI'
				END
				ELSE IF @tipoDocCollegato = 'BANDO_SDA'
				BEGIN				
					set @contesto = 'SDA'
				END
				ELSE IF @tipoDocCollegato = 'BANDO_SEMPLIFICATO'
				BEGIN
					set @contesto = 'SEMPLIFICATO'
				END
				ELSE IF @tipoDocCollegato = 'BANDO_ASTA'
				BEGIN
					set @contesto = 'ASTE'
				END
				ELSE
				BEGIN

					-- se il bando collegato è un RDO
					IF EXISTS( select idRow from document_bando with(nolock) where tipoProceduraCaratteristica = 'RDO' AND idheader = @linkedDoc )
					BEGIN

						set @contesto = 'me-rdo'

					END
					ELSE IF EXISTS( select idRow from document_bando with(nolock) where isnull(tipoProceduraCaratteristica,'') = '' AND idheader = @linkedDoc )
					BEGIN

						set @contesto = 'GARE'

					END
					ELSE
					BEGIN

						-- DA AGGIUNGERE IN QUEST'ELSE GLI ALTRI CONTESTI, QUANDO VERRANNO IMPLEMENTATI
						set @contesto = 'altro-contesto'

					END

				END

				-- FINE settaggio --

				-- PROCESSO CHE VERRA' SCHEDULATO IMMEDIATAMENTE SE NON CI SARA' IL GIRO DI PROTOCOLLO GENERALE
				set @DPR_DOC_ID = 'DETAIL_CHIARIMENTI'
				set @DPR_ID = 'EVADI'

				SET @descrizione = 'Risposta a Quesito '  + @protocolloInterno

				IF @oggetto is null
				BEGIN
					set @oggetto = 'Risposta a Quesito' 
				END

				set @testAssenzaFascicoloBase = 1

			END
			ELSE IF @tipoDoc = 'CANCELLA_ISCRIZIONE'
			BEGIN

				SET @modalita = 'U'

				select @tipoDocCollegato = b.tipodoc,
					   @jumpCheckCollegato = isnull(b.JumpCheck,''),
					   @azienda = pfu.pfuidazi,
					   @idPfuAOO = b.IdPfu
					from ctl_doc a	with(nolock)				     						--CANCELLA_ISCRIZIONE
							inner join ctl_doc b with(nolock)    ON b.id = a.linkeddoc		--BANDO ME O BANDO SDA
							inner join profiliutente pfu with(Nolock) on a.idpfu = pfu.idpfu
					where a.id = @idDoc

				-- INIZIO settaggio delle variabili chiave per entrare sulla tabella di configurazione 'Document_protocollo_docER' --
				SET @jumpCheck = ''
				SET @sottoTipo = ''

				IF @tipoDocCollegato = 'BANDO' and @jumpCheckCollegato = '' -- solo se bando ME ( no bando lavori o altro)
				BEGIN
					
					set @contesto = 'ME-BANDO'

				END
				--ELSE IF @tipoDocCollegato = 'BANDO' and @jumpCheckCollegato = 'BANDO_ALBO_LAVORI'
				ELSE IF @tipoDocCollegato = 'BANDO' and @jumpCheckCollegato like 'BANDO_ALBO%'
				BEGIN
					set @contesto = 'BANDO-LAVORI'
				END
				ELSE IF @tipoDocCollegato = 'BANDO_SDA'
				BEGIN
					set @contesto = 'SDA'
				END
				ELSE IF @tipoDocCollegato = 'BANDO_ASTA'
				BEGIN
					set @contesto = 'ASTE'
				END
				ELSE
				BEGIN
					set @contesto = 'altro-contesto'
				END

				-- FINE settaggio --

				-- PROCESSO CHE VERRA' SCHEDULATO IMMEDIATAMENTE SE NON CI SARA' IL GIRO DI PROTOCOLLO GENERALE
				set @DPR_DOC_ID = 'CANCELLA_ISCRIZIONE'
				set @DPR_ID = 'SEND_FINALIZZA'

				SET @descrizione = @titolo + ' ' + @protocolloInterno

				IF @oggetto is null
				BEGIN
					set @oggetto = 'Cancellazione Iscrizione' 
				END

			END
			ELSE IF @tipoDoc = 'SCRITTURA_PRIVATA'
			BEGIN

				SET @modalita = 'U'

				select @idDocPrincipale = gara.id 
						, @idPfuAOO = gara.IdPfu
					from ctl_doc a	with(nolock)				     						--SCRITTURA_PRIVATA
							inner join ctl_doc b with(nolock)    ON b.id = a.linkeddoc		--PDA_COMUNICAZIONE_GENERICA 
							inner join ctl_doc pda with(nolock) ON pda.id = b.linkeddoc	    --PDA_MICROLOTTI
							inner join ctl_doc gara with(nolock) ON gara.id = pda.linkeddoc --GARA
					where a.id = @idDoc

				-- INIZIO settaggio delle variabili chiave per entrare sulla tabella di configurazione 'Document_protocollo_docER' --
				SET @jumpCheck = ''
				SET @sottoTipo = ''

				-- se il bando collegato è un RDO
				IF EXISTS( select idRow from document_bando with(nolock) where tipoProceduraCaratteristica = 'RDO' AND idheader = @idDocPrincipale )
				BEGIN
					set @contesto = 'me-rdo'
				END
				ELSE
				BEGIN
					-- DA AGGIUNGERE IN QUEST'ELSE GLI ALTRI CONTESTI, QUANDO VERRANNO IMPLEMENTATI
					set @contesto = 'altro-contesto'
				END

				-- FINE settaggio --

				-- PROCESSO CHE VERRA' SCHEDULATO IMMEDIATAMENTE SE NON CI SARA' IL GIRO DI PROTOCOLLO GENERALE
				set @DPR_DOC_ID = 'SCRITTURA_PRIVATA'
				set @DPR_ID = 'SEND_FINALIZZA'

				SET @descrizione = @titolo + @protocolloInterno

				IF @oggetto is null
				BEGIN
					set @oggetto = 'Stipula contratto' 
				END

				-- se c'è il controllo del fascicolo
				IF EXISTS( select id from Document_protocollo_docER with(nolock) where tipodoc = @tipoDoc and isnull(contesto,'') = @contesto and aoo = dbo.getAOO( @idPfuAOO ) and isnull(verificaFascicolo,1) = 1 )
				BEGIN

					-------------------------------------------------------------------------------------------------
					-- SE IL FASCICOLO GENERALE NON E' PRESENTE SULLA GARA VUOL DIRE
					-- CHE LA GARA E' DI UN GIRO VECCHIO, PRECEDENTE ALL'ATTIVAZIONE DELLA PROTOCOLLAZIONE PER IL FLUSSO
					-- QUINDI NON PROTOCOLLO QUESTO DOCUMENTO 
					-------------------------------------------------------------------------------------------------

					set @fascicoloGenerale = ''

					-- recupero il fascicolo dalla gara 
					select  @fascicoloGenerale = isnull(fascicoloSecondario,'')
						from ctl_doc doc with(nolock) 
								inner join Document_dati_protocollo prot with(nolock) ON prot.idheader = doc.id 
						where doc.id = @idDocPrincipale

					IF @fascicoloGenerale = ''
					BEGIN
						select @fascicoloGenerale = isnull(FascicoloGenerale,'') from ctl_doc with(nolock) where id = @idDocPrincipale
					END

					IF @fascicoloGenerale = ''
					BEGIN
						set @bloccaProtocollo = 1
					END

				END


			END
			ELSE IF @tipoDoc = 'PDA_COMUNICAZIONE_GARA'
			BEGIN

				SET @modalita = 'U'
				SET @descrizione = @titolo + @protocolloInterno
				SET @idPfuAOO = @IdUser
				SET @oggetto = isnull(@oggetto,'')
				SET @idDocPrincipale = -1

				IF EXISTS ( Select id from ctl_doc with(nolock) where id = @idDoc and jumpcheck like '%-COMUNICAZIONE_FORNITORE_CONVENZIONE' )				
				BEGIN

						select 	@idDocPrincipale = b.id ,
								@azienda = a.Azienda ,
								@tipoDocCollegato = b.TipoDoc
							from ctl_doc a	with(nolock)				     							--pda_comunicazione_gara
									inner join ctl_doc b with(nolock)    ON b.id = a.linkeddoc			--CONVENZIONE							
							where a.id = @idDoc

				END
				ELSE
				BEGIN
					
					select 	@idDocPrincipale = case when bando.TipoDoc = 'PDA_MICROLOTTI' then bando2.id
													 else bando.id
												end ,

							@azienda = case when bando.TipoDoc = 'PDA_MICROLOTTI' then bando2.azienda
													 else bando.azienda
										end ,

							@tipoDocCollegato = case when bando.TipoDoc = 'PDA_MICROLOTTI' then bando2.TipoDoc 
													 else bando.TipoDoc
												 end 

						from ctl_doc a	with(nolock)				     							--pda_comunicazione_gara
								inner join ctl_doc b with(nolock)    ON b.id = a.linkeddoc			--PDA_COMUNICAZIONE_GENERICA (oppure il documento che ha generato la comunicazione)
								inner join ctl_doc bando with(nolock) ON bando.id = b.linkeddoc		-- BANDO o PDA
								left join  ctl_doc bando2 with(nolock) ON bando2.id = bando.linkeddoc  -- livello 2 se l'alias bando corrisponde con una PDA e non con un bando
						where a.id = @idDoc

				end
				-- in base al jumpCheck cambia la tipologia di comunicazione
				IF EXISTS ( Select id from ctl_doc with(nolock) where id = @idDoc and jumpcheck like '%-GENERICA' )
				BEGIN

					set @jumpCheck = 'GENERICA'
					set @sottoTipo = ''
					set @oggetto = @oggetto + ' - Comunicazione generica'

					IF @tipoDocCollegato = 'BANDO_SEMPLIFICATO'
					BEGIN
						set @contesto = 'SEMPLIFICATO'
					END
					ELSE IF @tipoDocCollegato = 'BANDO_ASTA'
					BEGIN
						set @contesto = 'ASTE'
					END
					ELSE
					BEGIN

						IF EXISTS( select idRow from document_bando with(nolock) where tipoProceduraCaratteristica = 'RDO' AND idheader = @idDocPrincipale )
						BEGIN
							set @contesto = 'me-rdo'
						END
						ELSE IF EXISTS( select idRow from document_bando with(nolock) where isnull(tipoProceduraCaratteristica,'') = '' AND idheader = @idDocPrincipale )
						BEGIN
							set @contesto = 'GARE'
						END
						ELSE
						BEGIN
							set @contesto = 'altro-contesto'
						END

					END


				END
				-- in base al jumpCheck cambia la tipologia di comunicazione
				ELSE IF EXISTS ( Select id from ctl_doc with(nolock) where id = @idDoc and jumpcheck like '%-GARA_COMUNICAZIONE_GENERICA' )
				BEGIN

					set @jumpCheck = 'GARA_COMUNICAZIONE_GENERICA'
					set @sottoTipo = ''


					select 	@idDocPrincipale = bando.id ,
							@azienda = bando.Azienda ,
							@tipoDocCollegato = bando.TipoDoc,
							 @oggetto = @oggetto + ' - ' + B.titolo					
						from ctl_doc a	with(nolock)				     							--pda_comunicazione_gara
								inner join ctl_doc b with(nolock)    ON b.id = a.linkeddoc			--PDA_COMUNICAZIONE_GENERICA 
								inner join ctl_doc bando with(nolock) ON bando.id = b.linkeddoc		--GARA
						where a.id = @idDoc



					IF @tipoDocCollegato = 'BANDO_SEMPLIFICATO'
					BEGIN
						set @contesto = 'SEMPLIFICATO'
					END
					ELSE IF @tipoDocCollegato = 'BANDO_ASTA'
					BEGIN
						set @contesto = 'ASTE'
					END
					ELSE
					BEGIN

						IF EXISTS( select idRow from document_bando with(nolock) where tipoProceduraCaratteristica = 'RDO' AND idheader = @idDocPrincipale )
						BEGIN
							set @contesto = 'me-rdo'
						END
						ELSE IF EXISTS( select idRow from document_bando with(nolock) where isnull(tipoProceduraCaratteristica,'') = '' AND idheader = @idDocPrincipale )
						BEGIN
							set @contesto = 'GARE'
						END
						ELSE
						BEGIN
							set @contesto = 'altro-contesto'
						END

					END


				END
				ELSE IF EXISTS ( Select id from ctl_doc with(nolock) where id = @idDoc and jumpcheck like '%-ESCLUSIONE' )
				BEGIN

					set @jumpCheck = 'ESCLUSIONE'
					set @sottoTipo = ''
					set @oggetto = @oggetto + ' - Comunicazione esclusione'

					select @idDocPrincipale = gara.id ,
						   @azienda = gara.azienda,
						   @tipoDocCollegato = gara.TipoDoc
						from ctl_doc a	with(nolock)				     						 --pda_comunicazione_gara
								inner join ctl_doc b with(nolock)    ON b.id = a.linkeddoc		 --PDA_COMUNICAZIONE_GENERICA (oppure il documento che ha generato la comunicazione)
								inner join ctl_doc pda with(nolock)  ON pda.id = b.linkeddoc	 --PDA_MICROLOTTI
								inner join ctl_doc gara with(nolock) ON gara.id = pda.linkeddoc  --GARA
						where a.id = @idDoc

					IF @tipoDocCollegato = 'BANDO_SEMPLIFICATO'
					BEGIN
						set @contesto = 'SEMPLIFICATO'
					END
					ELSE IF @tipoDocCollegato = 'BANDO_ASTA'
					BEGIN
						set @contesto = 'ASTE'
					END
					ELSE
					BEGIN

						--select * from Document_protocollo_docER where jumpcheck = 'ESCLUSIONE'

						-- se il bando collegato è un RDO
						IF EXISTS( select idRow from document_bando with(nolock) where tipoProceduraCaratteristica = 'RDO' AND idheader = @idDocPrincipale )
						BEGIN

							set @contesto = 'me-rdo'

						END
						ELSE IF EXISTS( select idRow from document_bando with(nolock) where isnull(tipoProceduraCaratteristica,'') = '' AND idheader = @idDocPrincipale )
						BEGIN

							set @contesto = 'GARE'

						END
						ELSE
						BEGIN
							-- DA AGGIUNGERE IN QUEST'ELSE GLI ALTRI CONTESTI, QUANDO VERRANNO IMPLEMENTATI
							set @contesto = 'altro-contesto'
						END

					END

				END
				ELSE IF EXISTS ( Select id from ctl_doc with(nolock) where id = @idDoc and jumpcheck like '%-ESCLUSIONE_MANIFESTAZIONE' )
				BEGIN

					set @jumpCheck = 'ESCLUSIONE_MANIFESTAZIONE'
					set @sottoTipo = ''
					set @oggetto = @oggetto + ' - Comunicazione esclusione'

					select @idDocPrincipale = gara.id ,
						   @azienda = gara.azienda,
						   @tipoDocCollegato = gara.TipoDoc
						from ctl_doc a	with(nolock)				     						--pda_comunicazione_gara
								inner join ctl_doc b with(nolock)    ON b.id = a.linkeddoc		--PDA_COMUNICAZIONE_GENERICA (oppure il documento che ha generato la comunicazione)
								inner join ctl_doc gara with(nolock) ON gara.id = b.linkeddoc  --GARA
						where a.id = @idDoc

					IF @tipoDocCollegato = 'BANDO_SEMPLIFICATO'
					BEGIN
						set @contesto = 'SEMPLIFICATO'
					END
					ELSE IF @tipoDocCollegato = 'BANDO_ASTA'
					BEGIN
						set @contesto = 'ASTE'
					END
					ELSE
					BEGIN

						--select * from Document_protocollo_docER where jumpcheck = 'ESCLUSIONE'

						-- se il bando collegato è un RDO
						IF EXISTS( select idRow from document_bando with(nolock) where tipoProceduraCaratteristica = 'RDO' AND idheader = @idDocPrincipale )
						BEGIN

							set @contesto = 'me-rdo'

						END
						ELSE IF EXISTS( select idRow from document_bando with(nolock) where isnull(tipoProceduraCaratteristica,'') = '' AND idheader = @idDocPrincipale )
						BEGIN

							set @contesto = 'GARE'

						END
						ELSE
						BEGIN
							-- DA AGGIUNGERE IN QUEST'ELSE GLI ALTRI CONTESTI, QUANDO VERRANNO IMPLEMENTATI
							set @contesto = 'altro-contesto'
						END

					END
					
				END
				ELSE IF EXISTS ( Select id from ctl_doc with(nolock) where id = @idDoc and jumpcheck like '%-VERIFICA_INTEGRATIVA' )
				BEGIN

					set @jumpCheck = 'VERIFICA_INTEGRATIVA'
					set @sottoTipo = ''
					set @oggetto = @oggetto + ' - Comunicazione Integrativa'


					select @idDocPrincipale = gara.id ,
						   @azienda = gara.azienda,
						   @tipoDocCollegato = gara.TipoDoc
						from ctl_doc a	with(nolock)				     						--pda_comunicazione_gara
								inner join ctl_doc b with(nolock)    ON b.id = a.linkeddoc		--PDA_COMUNICAZIONE_GENERICA (oppure il documento che ha generato la comunicazione)
								inner join ctl_doc pda with(nolock)  ON pda.id = b.linkeddoc	    --PDA_MICROLOTTI
								inner join ctl_doc gara with(nolock) ON gara.id = pda.linkeddoc  --GARA
						where a.id = @idDoc

					IF @tipoDocCollegato = 'BANDO_SEMPLIFICATO'
					BEGIN
						set @contesto = 'SEMPLIFICATO'
					END
					ELSE IF @tipoDocCollegato = 'BANDO_ASTA'
					BEGIN
						set @contesto = 'ASTE'
					END
					ELSE
					BEGIN

						-- se il bando collegato è un RDO
						IF EXISTS( select idRow from document_bando with(nolock) where tipoProceduraCaratteristica = 'RDO' AND idheader = @idDocPrincipale )
						BEGIN

							set @contesto = 'me-rdo'

						END
						ELSE IF EXISTS( select idRow from document_bando with(nolock) where isnull(tipoProceduraCaratteristica,'') = '' AND idheader = @idDocPrincipale )
						BEGIN

							set @contesto = 'GARE'

						END
						ELSE
						BEGIN
							-- DA AGGIUNGERE IN QUEST'ELSE GLI ALTRI CONTESTI, QUANDO VERRANNO IMPLEMENTATI
							set @contesto = 'altro-contesto'
						END

					END


				END
				ELSE IF EXISTS ( Select id from ctl_doc with(nolock) where id = @idDoc and jumpcheck like '%-LOTTI_ESCLUSIONE' )
				BEGIN
					set @jumpCheck = 'LOTTI_ESCLUSIONE'
					set @sottoTipo = ''
					set @oggetto = @oggetto + ' - Comunicazione di Esclusione'


					select @idDocPrincipale = gara.id ,
						   @azienda = gara.azienda,
						   @tipoDocCollegato = gara.TipoDoc
						from ctl_doc a	with(nolock)				     						--pda_comunicazione_gara
								inner join ctl_doc b with(nolock)    ON b.id = a.linkeddoc		--PDA_COMUNICAZIONE_GENERICA (oppure il documento che ha generato la comunicazione)
								inner join ctl_doc pda with(nolock)  ON pda.id = b.linkeddoc	--PDA_MICROLOTTI
								inner join ctl_doc gara with(nolock) ON gara.id = pda.linkeddoc --GARA
						where a.id = @idDoc

					IF @tipoDocCollegato = 'BANDO_SEMPLIFICATO'
					BEGIN
						set @contesto = 'SEMPLIFICATO'
					END
					ELSE IF @tipoDocCollegato = 'BANDO_ASTA'
					BEGIN
						set @contesto = 'ASTE'
					END
					ELSE
					BEGIN

						-- se il bando collegato è un RDO
						IF EXISTS( select idRow from document_bando with(nolock) where tipoProceduraCaratteristica = 'RDO' AND idheader = @idDocPrincipale )
						BEGIN

							set @contesto = 'me-rdo'

						END
						ELSE IF EXISTS( select idRow from document_bando with(nolock) where isnull(tipoProceduraCaratteristica,'') = '' AND idheader = @idDocPrincipale )
						BEGIN

							set @contesto = 'GARE'

						END
						ELSE
						BEGIN
							-- DA AGGIUNGERE IN QUEST'ELSE GLI ALTRI CONTESTI, QUANDO VERRANNO IMPLEMENTATI
							set @contesto = 'altro-contesto'
						END

					END


				END
				ELSE IF EXISTS ( Select id from ctl_doc with(nolock) where id = @idDoc and jumpcheck like '%-RICHIESTA_STIPULA_CONTRATTO' )
				BEGIN

					set @jumpCheck = 'RICHIESTA_STIPULA_CONTRATTO'
					set @sottoTipo = ''
					set @oggetto = 'Comunicazione di Richiesta Stipula Contratto - ' + isnull(@oggetto,'')

					select @idDocPrincipale = gara.id,
						   @azienda = gara.azienda,
						   @tipoDocCollegato = gara.TipoDoc
						from ctl_doc a	with(nolock)				     						--pda_comunicazione_gara
								inner join ctl_doc b with(nolock)    ON b.id = a.linkeddoc		--PDA_COMUNICAZIONE_GENERICA (oppure il documento che ha generato la comunicazione)
								inner join ctl_doc pda with(nolock)  ON pda.id = b.linkeddoc	--PDA_MICROLOTTI
								inner join ctl_doc gara with(nolock) ON gara.id = pda.linkeddoc --GARA
						where a.id = @idDoc

					IF @tipoDocCollegato = 'BANDO_SEMPLIFICATO'
					BEGIN
						set @contesto = 'SEMPLIFICATO'
					END
					ELSE IF @tipoDocCollegato = 'BANDO_ASTA'
					BEGIN
						set @contesto = 'ASTE'
					END
					ELSE
					BEGIN

						-- se il bando collegato è un RDO
						IF EXISTS( select idRow from document_bando with(nolock) where tipoProceduraCaratteristica = 'RDO' AND idheader = @idDocPrincipale )
						BEGIN

							set @contesto = 'me-rdo'

						END
						ELSE IF EXISTS( select idRow from document_bando with(nolock) where isnull(tipoProceduraCaratteristica,'') = '' AND idheader = @idDocPrincipale )
						BEGIN

							set @contesto = 'GARE'

						END
						ELSE
						BEGIN
							-- DA AGGIUNGERE IN QUEST'ELSE GLI ALTRI CONTESTI, QUANDO VERRANNO IMPLEMENTATI
							set @contesto = 'altro-contesto'
						END

					END

				END
				ELSE IF EXISTS ( Select id from ctl_doc with(nolock) where id = @idDoc and jumpcheck like '%-PROSSIMA_SEDUTA' )
				BEGIN

					set @jumpCheck = 'PROSSIMA_SEDUTA'
					set @sottoTipo = ''
					set @oggetto = @oggetto + ' - Comunicazione Prossima Seduta'

					select @idDocPrincipale = gara.id ,
						   @azienda = gara.azienda,
						   @tipoDocCollegato = gara.TipoDoc
						from ctl_doc a	with(nolock)				     						--pda_comunicazione_gara
								inner join ctl_doc b with(nolock)    ON b.id = a.linkeddoc		--PDA_COMUNICAZIONE_GENERICA (oppure il documento che ha generato la comunicazione)
								inner join ctl_doc pda with(nolock)  ON pda.id = b.linkeddoc	--PDA_MICROLOTTI
								inner join ctl_doc gara with(nolock) ON gara.id = pda.linkeddoc --GARA
						where a.id = @idDoc

					IF @tipoDocCollegato = 'BANDO_SEMPLIFICATO'
					BEGIN
						set @contesto = 'SEMPLIFICATO'
					END
					ELSE IF @tipoDocCollegato = 'BANDO_ASTA'
					BEGIN
						set @contesto = 'ASTE'
					END
					ELSE
					BEGIN

						-- se il bando collegato è un RDO
						IF EXISTS( select idRow from document_bando with(nolock) where tipoProceduraCaratteristica = 'RDO' AND idheader = @idDocPrincipale )
						BEGIN

							set @contesto = 'me-rdo'

						END
						ELSE IF EXISTS( select idRow from document_bando with(nolock) where isnull(tipoProceduraCaratteristica,'') = '' AND idheader = @idDocPrincipale )
						BEGIN

							set @contesto = 'GARE'

						END
						ELSE
						BEGIN
							-- DA AGGIUNGERE IN QUEST'ELSE GLI ALTRI CONTESTI, QUANDO VERRANNO IMPLEMENTATI
							set @contesto = 'altro-contesto'
						END

					END

				END
				ELSE IF EXISTS ( Select id from ctl_doc with(nolock) where id = @idDoc and ( jumpcheck like '%-ESITO' or jumpcheck like '%-ESITO_MICROLOTTI' )  )
				BEGIN

					set @jumpCheck = 'ESITO'
					set @sottoTipo = ''
					set @oggetto = @oggetto + ' - Comunicazione di esito provvisorio'

					select @idDocPrincipale = gara.id ,
						   @azienda = gara.azienda,
						   @tipoDocCollegato = gara.tipodoc
						from ctl_doc a	with(nolock)				     						--pda_comunicazione_gara
								inner join ctl_doc b with(nolock)    ON b.id = a.linkeddoc		--PDA_COMUNICAZIONE_GENERICA (oppure il documento che ha generato la comunicazione)
								inner join ctl_doc pda with(nolock)  ON pda.id = b.linkeddoc	    --PDA_MICROLOTTI
								inner join ctl_doc gara with(nolock) ON gara.id = pda.linkeddoc  --GARA
						where a.id = @idDoc

					IF @tipoDocCollegato = 'BANDO_SEMPLIFICATO'
					BEGIN
						set @contesto = 'SEMPLIFICATO'
					END
					ELSE IF @tipoDocCollegato = 'BANDO_ASTA'
					BEGIN
						set @contesto = 'ASTE'
					END
					ELSE
					BEGIN

						-- se il bando collegato è un RDO
						IF EXISTS( select idRow from document_bando with(nolock) where tipoProceduraCaratteristica = 'RDO' AND idheader = @idDocPrincipale )
						BEGIN

							set @contesto = 'me-rdo'

						END
						ELSE IF EXISTS( select idRow from document_bando with(nolock) where isnull(tipoProceduraCaratteristica,'') = '' AND idheader = @idDocPrincipale )
						BEGIN

							set @contesto = 'GARE'

						END
						ELSE
						BEGIN
							-- DA AGGIUNGERE IN QUEST'ELSE GLI ALTRI CONTESTI, QUANDO VERRANNO IMPLEMENTATI
							set @contesto = 'altro-contesto'
						END

					END

				END
				ELSE IF EXISTS ( Select id from ctl_doc with(nolock) where id = @idDoc and jumpcheck like '%-VERIFICA_AMMINISTRATIVA' )
				BEGIN

					set @jumpCheck = 'VERIFICA_AMMINISTRATIVA'
					set @sottoTipo = ''
					set @oggetto = @oggetto + ' - Comunicazione Verifica Amministrativa'

					select @idDocPrincipale = gara.id ,
						   @azienda = gara.azienda,
						   @tipoDocCollegato = gara.TipoDoc
						from ctl_doc a	with(nolock)				     						--pda_comunicazione_gara
								inner join ctl_doc b with(nolock)    ON b.id = a.linkeddoc		--PDA_COMUNICAZIONE_GENERICA (oppure il documento che ha generato la comunicazione)
								inner join ctl_doc pda with(nolock)  ON pda.id = b.linkeddoc	 --PDA_MICROLOTTI
								inner join ctl_doc gara with(nolock) ON gara.id = pda.linkeddoc  --GARA
						where a.id = @idDoc

					IF @tipoDocCollegato = 'BANDO_SEMPLIFICATO'
					BEGIN
						set @contesto = 'SEMPLIFICATO'
					END
					ELSE IF @tipoDocCollegato = 'BANDO_ASTA'
					BEGIN
						set @contesto = 'ASTE'
					END
					ELSE
					BEGIN

						-- se il bando collegato è un RDO
						IF EXISTS( select idRow from document_bando with(nolock) where tipoProceduraCaratteristica = 'RDO' AND idheader = @idDocPrincipale )
						BEGIN

							set @contesto = 'me-rdo'

						END
						ELSE IF EXISTS( select idRow from document_bando with(nolock) where isnull(tipoProceduraCaratteristica,'') = '' AND idheader = @idDocPrincipale )
						BEGIN

							set @contesto = 'GARE'

						END
						ELSE
						BEGIN
							-- DA AGGIUNGERE IN QUEST'ELSE GLI ALTRI CONTESTI, QUANDO VERRANNO IMPLEMENTATI
							set @contesto = 'altro-contesto'
						END

					END

				END
				ELSE IF EXISTS ( Select id from ctl_doc with(nolock) where id = @idDoc and ( jumpcheck like '%-ESITO_DEFINITIVO' or jumpcheck like '%-ESITO_DEFINITIVO_MICROLOTTI' )  )
				BEGIN

					set @jumpCheck = 'ESITO_DEFINITIVO'
					set @sottoTipo = ''
					set @oggetto = @oggetto + ' - Comunicazione di aggiudicazione definitiva'

					select @idDocPrincipale = gara.id ,
						   @azienda = gara.azienda,
						   @tipoDocCollegato = gara.TipoDoc
						from ctl_doc a	with(nolock)				     						--pda_comunicazione_gara
								inner join ctl_doc b with(nolock)    ON b.id = a.linkeddoc		--PDA_COMUNICAZIONE_GENERICA (oppure il documento che ha generato la comunicazione)
								inner join ctl_doc pda with(nolock) ON pda.id = b.linkeddoc	    --PDA_MICROLOTTI
								inner join ctl_doc gara with(nolock) ON gara.id = pda.linkeddoc  --GARA
						where a.id = @idDoc

					IF @tipoDocCollegato = 'BANDO_SEMPLIFICATO'
					BEGIN
						set @contesto = 'SEMPLIFICATO'
					END
					ELSE IF @tipoDocCollegato = 'BANDO_ASTA'
					BEGIN
						set @contesto = 'ASTE'
					END
					ELSE
					BEGIN

						-- se il bando collegato è un RDO
						IF EXISTS( select idRow from document_bando with(nolock) where tipoProceduraCaratteristica = 'RDO' AND idheader = @idDocPrincipale )
						BEGIN

							set @contesto = 'me-rdo'

						END
						ELSE IF EXISTS( select idRow from document_bando with(nolock) where isnull(tipoProceduraCaratteristica,'') = '' AND idheader = @idDocPrincipale )
						BEGIN

							set @contesto = 'GARE'

						END
						ELSE
						BEGIN
							-- DA AGGIUNGERE IN QUEST'ELSE GLI ALTRI CONTESTI, QUANDO VERRANNO IMPLEMENTATI
							set @contesto = 'altro-contesto'
						END

					END

				END
				ELSE IF EXISTS ( Select id from ctl_doc with(nolock) where id = @idDoc and ( jumpcheck like '%-VERIFICA_REQUISITI' ) )
				BEGIN

					set @jumpCheck = 'VERIFICA_REQUISITI'
					set @sottoTipo = ''
					set @oggetto = @oggetto + ' - Verifica Requisiti Amministrativi'

					select @idDocPrincipale = gara.id ,
						   @azienda = gara.azienda,
						   @tipoDocCollegato = gara.TipoDoc
						from ctl_doc a	with(nolock)				     						 --pda_comunicazione_gara
								inner join ctl_doc b with(nolock)    ON b.id = a.linkeddoc		 --PDA_COMUNICAZIONE_GENERICA (oppure il documento che ha generato la comunicazione)
								inner join ctl_doc pda with(nolock) ON pda.id = b.linkeddoc	     --PDA_MICROLOTTI
								inner join ctl_doc gara with(nolock) ON gara.id = pda.linkeddoc  --GARA
						where a.id = @idDoc

					IF @tipoDocCollegato = 'BANDO_SEMPLIFICATO'
					BEGIN
						set @contesto = 'SEMPLIFICATO'
					END
					ELSE IF @tipoDocCollegato = 'BANDO_ASTA'
					BEGIN
						set @contesto = 'ASTE'
					END
					ELSE
					BEGIN

						-- se il bando collegato è un RDO
						IF EXISTS( select idRow from document_bando with(nolock) where tipoProceduraCaratteristica = 'RDO' AND idheader = @idDocPrincipale )
						BEGIN

							set @contesto = 'me-rdo'

						END
						ELSE IF EXISTS( select idRow from document_bando with(nolock) where isnull(tipoProceduraCaratteristica,'') = '' AND idheader = @idDocPrincipale )
						BEGIN

							set @contesto = 'GARE'

						END
						ELSE
						BEGIN
							-- DA AGGIUNGERE IN QUEST'ELSE GLI ALTRI CONTESTI, QUANDO VERRANNO IMPLEMENTATI
							set @contesto = 'altro-contesto'
						END

					END

				END
				ELSE IF EXISTS ( Select id from ctl_doc with(nolock) where id = @idDoc and jumpcheck like '%-PROROGA_BANDO_GARA')
				BEGIN

					set @jumpCheck = 'PROROGA_BANDO_GARA'
					set @sottoTipo = ''

					set @oggetto = isnull(@oggetto,'') + ' ' + isnull(@note,'')

					-- SE chi ha indetto l'rdo fa parte della relazione aoo_ente (è quindi IC o la regione) allora siamo nel caso
					-- Mercato Elettronico - RdO ( RER - IC )
					IF EXISTS ( select * from CTL_Relations with(nolock) where rel_type = 'AOO_ENTE' and REL_ValueOutput = 'AOO_AI' and rel_valueinput = @azienda ) 
					BEGIN
						set @oggetto = @oggetto + ' - Proroga'
					END
					ELSE
					BEGIN
						set @bloccaProtocollo = 1
					END

					IF @tipoDocCollegato = 'BANDO_SEMPLIFICATO'
					BEGIN
						set @contesto = 'SEMPLIFICATO'
					END
					ELSE IF @tipoDocCollegato = 'BANDO_ASTA'
					BEGIN
						set @contesto = 'ASTE'
					END
					ELSE
					BEGIN

						-- se il bando collegato è un RDO
						IF EXISTS( select idRow from document_bando with(nolock) where tipoProceduraCaratteristica = 'RDO' AND idheader = @idDocPrincipale )
						BEGIN

							set @contesto = 'me-rdo'

						END
						ELSE IF EXISTS( select idRow from document_bando with(nolock) where isnull(tipoProceduraCaratteristica,'') = '' AND idheader = @idDocPrincipale )
						BEGIN

							set @contesto = 'GARE'

						END
						ELSE
						BEGIN
							-- DA AGGIUNGERE IN QUEST'ELSE GLI ALTRI CONTESTI, QUANDO VERRANNO IMPLEMENTATI
							set @contesto = 'altro-contesto'
						END

					END

				END
				ELSE IF EXISTS ( Select id from ctl_doc with(nolock) where id = @idDoc and jumpcheck like '%-SOSPENSIONE_ALBO') 
				BEGIN

					-- Sospensione Abilitazione per il giro dello SDA e per il giro dell'Abilitazione Mercato Elettronico

					set @jumpCheck = 'SOSPENSIONE_ALBO'
					set @sottoTipo = ''
					set @contesto = ''

					--- Nell'oggetto della sospensione ER vuole la sola descrizione, priva del testo della comunicazione
					set @oggetto = replace( @oggetto, isnull(@note,''), '')

					set @testAssenzaFascicoloBase=1

					select 	@idDocPrincipale = bando.id ,
								@azienda = a.Azienda ,
								@tipoDocCollegato = bando.TipoDoc,
								@linkeddoc=bando.id
							from ctl_doc a	with(nolock)				     							--pda_comunicazione_gara
									inner join ctl_doc_destinatari b with(nolock)    ON b.idrow = a.linkeddoc			--RIGA PARTECIPAZIONE
									inner join ctl_doc bando with(nolock) on bando.id=b.idheader
							where a.id = @idDoc			

										  
							  
										  
						   
																		  
																										  
																	 
						  

				END
				ELSE IF EXISTS ( Select id from ctl_doc with(nolock) where id = @idDoc and jumpcheck like '%-RETTIFICA_BANDO_GARA')
				BEGIN

					set @jumpCheck = 'RETTIFICA_BANDO_GARA'
					set @sottoTipo = ''

					set @oggetto = isnull(@oggetto,'') + isnull(@note,'')

					IF @tipoDocCollegato = 'BANDO_SEMPLIFICATO'
					BEGIN
						set @contesto = 'SEMPLIFICATO'
					END
					ELSE IF @tipoDocCollegato = 'BANDO_ASTA'
					BEGIN
						set @contesto = 'ASTE'
					END
					ELSE
					BEGIN

						-- se il bando collegato è un RDO
						IF EXISTS( select idRow from document_bando with(nolock) where tipoProceduraCaratteristica = 'RDO' AND idheader = @idDocPrincipale )
						BEGIN

							set @contesto = 'me-rdo'

						END
						ELSE IF EXISTS( select idRow from document_bando with(nolock) where isnull(tipoProceduraCaratteristica,'') = '' AND idheader = @idDocPrincipale )
						BEGIN

							set @contesto = 'GARE'

						END
						ELSE
						BEGIN
							-- DA AGGIUNGERE IN QUEST'ELSE GLI ALTRI CONTESTI, QUANDO VERRANNO IMPLEMENTATI
							set @contesto = 'altro-contesto'
						END

					END
						

				END
				ELSE IF EXISTS ( Select id from ctl_doc with(nolock) where id = @idDoc and jumpcheck like '%-REVOCA_BANDO')
				BEGIN

					set @jumpCheck = 'REVOCA_BANDO'
					set @sottoTipo = ''
					set @oggetto = isnull(@oggetto,'')

					set @invito = 'no'
					set @rdo = ''

					IF @tipoDocCollegato = 'BANDO_SEMPLIFICATO'
					BEGIN
						set @contesto = 'SEMPLIFICATO'
					END
					ELSE IF @tipoDocCollegato = 'BANDO_ASTA'
					BEGIN
						set @contesto = 'ASTE'
					END
					ELSE
					BEGIN

						-- se il bando collegato è un RDO
						IF EXISTS( select idRow from document_bando with(nolock) where tipoProceduraCaratteristica = 'RDO' AND idheader = @idDocPrincipale )
						BEGIN

							set @contesto = 'me-rdo'

						END
						ELSE IF EXISTS( select idRow from document_bando with(nolock) where isnull(tipoProceduraCaratteristica,'') = '' AND idheader = @idDocPrincipale )
						BEGIN

							set @contesto = 'GARE'

						END
						ELSE
						BEGIN
							-- DA AGGIUNGERE IN QUEST'ELSE GLI ALTRI CONTESTI, QUANDO VERRANNO IMPLEMENTATI
							set @contesto = 'altro-contesto'
						END

					END
										
				END
				ELSE IF EXISTS ( Select id from ctl_doc with(nolock) where id = @idDoc and jumpcheck like '%-SOSPENSIONE_GARA')
				BEGIN

					set @jumpCheck = 'SOSPENSIONE_GARA'
					set @sottoTipo = ''
					set @oggetto = isnull(@oggetto,'')

					set @invito = 'no'
					set @rdo = ''

					IF @tipoDocCollegato = 'BANDO_SEMPLIFICATO'
					BEGIN
						set @contesto = 'SEMPLIFICATO'
					END
					ELSE IF @tipoDocCollegato = 'BANDO_ASTA'
					BEGIN
						set @contesto = 'ASTE'
					END
					ELSE
					BEGIN

						-- se il bando collegato è un RDO
						IF EXISTS( select idRow from document_bando with(nolock) where tipoProceduraCaratteristica = 'RDO' AND idheader = @idDocPrincipale )
						BEGIN

							set @contesto = 'me-rdo'

						END
						ELSE IF EXISTS( select idRow from document_bando with(nolock) where isnull(tipoProceduraCaratteristica,'') = '' AND idheader = @idDocPrincipale )
						BEGIN

							set @contesto = 'GARE'

						END
						ELSE
						BEGIN
							-- DA AGGIUNGERE IN QUEST'ELSE GLI ALTRI CONTESTI, QUANDO VERRANNO IMPLEMENTATI
							set @contesto = 'altro-contesto'
						END

					END
										
				END
				ELSE IF EXISTS ( Select id from ctl_doc with(nolock) where id = @idDoc and jumpcheck like '%-RIPRISTINO_GARA')
				BEGIN

					set @jumpCheck = 'RIPRISTINO_GARA'
					set @sottoTipo = ''

					set @oggetto = isnull(@oggetto,'') + ' ' + isnull(@note,'')

					-- SE chi ha indetto l'rdo fa parte della relazione aoo_ente (è quindi IC o la regione) allora siamo nel caso
					-- Mercato Elettronico - RdO ( RER - IC )
					IF EXISTS ( select * from CTL_Relations with(nolock) where rel_type = 'AOO_ENTE' and REL_ValueOutput = 'AOO_AI' and rel_valueinput = @azienda ) 
					BEGIN
						set @oggetto = @oggetto + ' - Ripristino'
					END
					ELSE
					BEGIN
						set @bloccaProtocollo = 1
					END

					IF @tipoDocCollegato = 'BANDO_SEMPLIFICATO'
					BEGIN
						set @contesto = 'SEMPLIFICATO'
					END
					ELSE IF @tipoDocCollegato = 'BANDO_ASTA'
					BEGIN
						set @contesto = 'ASTE'
					END
					ELSE
					BEGIN

						-- se il bando collegato è un RDO
						IF EXISTS( select idRow from document_bando with(nolock) where tipoProceduraCaratteristica = 'RDO' AND idheader = @idDocPrincipale )
						BEGIN

							set @contesto = 'me-rdo'

						END
						ELSE IF EXISTS( select idRow from document_bando with(nolock) where isnull(tipoProceduraCaratteristica,'') = '' AND idheader = @idDocPrincipale )
						BEGIN

							set @contesto = 'GARE'

						END
						ELSE
						BEGIN
							-- DA AGGIUNGERE IN QUEST'ELSE GLI ALTRI CONTESTI, QUANDO VERRANNO IMPLEMENTATI
							set @contesto = 'altro-contesto'
						END

					END

				END				
				ELSE IF EXISTS ( Select id from ctl_doc with(nolock) where id = @idDoc and jumpcheck like '%-IMPEGNATO') -- ??? da aggiungere ???
				BEGIN
					set @jumpCheck = 'IMPEGNATO'
					set @sottoTipo = ''
					set @oggetto = @oggetto + ' - ???'
				END
				ELSE IF EXISTS ( Select id from ctl_doc with(nolock) where id = @idDoc and jumpcheck like '%-GENERICA_RIDOTTA')
				BEGIN

					set @jumpCheck = 'GENERICA_RIDOTTA'
					set @sottoTipo = 'ANNULLA_ORDINATIVO'

					-- con linkedDoc GENERICA_RIDOTTA non c'è solo l'annulla ordinativo, quindi controlo anche il documento associato al linkedDoc
					IF EXISTS (  Select id from ctl_doc with(nolock) where id = @linkedDoc and tipodoc = 'ANNULLA_ORDINATIVO' )
					BEGIN

						Select top 1 @azienda = azienda 
							from ctl_doc with(nolock) 
							where tipodoc = 'ANNULLA_ORDINATIVO' and id = @linkedDoc

						set @oggetto = @oggetto + ' - Annullamento Ordinativo di fornitura'

					END 
					ELSE
					BEGIN
						set @bloccaProtocollo = 1
					END

				END
				ELSE IF EXISTS ( Select id from ctl_doc with(nolock) where id = @idDoc and jumpcheck like '%-COMUNICAZIONE_FORNITORE_CONVENZIONE' )						
				BEGIN

						set @jumpCheck = 'COMUNICAZIONE_FORNITORE_CONVENZIONE'
						set @sottoTipo = ''
						set @oggetto = 'Comunicazione al fornitore della convenzione - ' + @oggetto
						set @contesto = 'CONVENZIONE'

				END
				ELSE
				BEGIN

					set @bloccaProtocollo = 1

				END

				-- PROCESSO CHE VERRA' SCHEDULATO IMMEDIATAMENTE SE NON CI SARA' IL GIRO DI PROTOCOLLO GENERALE
				set @DPR_DOC_ID = 'PDA_COMUNICAZIONE_GARA'
				set @DPR_ID = 'FINALIZZA'


				-- SE C'È IL CONTROLLO DEL FASCICOLO
				IF EXISTS( select id from Document_protocollo_docER with(nolock) where tipodoc = @tipoDoc and isnull(jumpCheck,'') = @jumpCheck and isnull(contesto,'') = @contesto and aoo = dbo.getAOO( @idPfuAOO ) and isnull(verificaFascicolo,1) = 1 )
				BEGIN

					-------------------------------------------------------------------------------------------------
					-- SE IL FASCICOLO GENERALE NON E' PRESENTE SULLA GARA VUOL DIRE
					-- CHE LA GARA E' DI UN GIRO VECCHIO, PRECEDENTE ALL'ATTIVAZIONE DELLA PROTOCOLLAZIONE PER IL FLUSSO
					-- QUINDI NON PROTOCOLLO QUESTO DOCUMENTO 
					-------------------------------------------------------------------------------------------------

					set @fascicoloGenerale = ''

					-- recupero il fascicolo dalla gara 
					select  @fascicoloGenerale = isnull(fascicoloSecondario,'')
						from ctl_doc doc with(nolock) 
								inner join Document_dati_protocollo prot with(nolock) ON prot.idheader = doc.id 
						where doc.id = @idDocPrincipale

					IF @fascicoloGenerale = ''
					BEGIN
						select @fascicoloGenerale = isnull(FascicoloGenerale,'')
							from ctl_doc with(nolock) where id = @idDocPrincipale
					END

					IF @fascicoloGenerale = ''
					BEGIN
						set @bloccaProtocollo = 1
					END

				END

				


			END
			ELSE IF @tipoDoc = 'RETTIFICA_GARA'
			BEGIN

				SET @modalita = 'U'
				SET @descrizione = @titolo + ' - ' + @protocolloInterno
				SET @oggetto = @titolo

				set @idPfuAOO = @IdUser

				set @invito = 'no'
				set @rdo = ''

				-- Recupero i parametri del bando. Se è ad invito e se è un RDO
				select @invito = CASE WHEN TipoBandoGara =  '3' THEN 'si' 
									  ELSE 'no' 
								 END,
					   @rdo = upper( isnull(TipoProceduraCaratteristica,'')) 
					from document_bando with(nolock)
					where idheader = @linkedDoc

				-- INIZIO settaggio delle variabili chiave per entrare sulla tabella di configurazione 'Document_protocollo_docER' --
				SET @jumpCheck = ''
				SET @sottoTipo = ''

				IF @rdo = 'RDO'
					set @contesto = 'me-rdo'
				ELSE
					set @contesto = 'altro'

				-- FINE settaggio --

				--	Blocco se il bando NON è ad invito
				IF @invito = 'no' 
				BEGIN
					set @bloccaProtocollo = 1
				END

				-- PROCESSO CHE VERRA' SCHEDULATO IMMEDIATAMENTE SE NON CI SARA' IL GIRO DI PROTOCOLLO GENERALE
				set @DPR_DOC_ID = 'RETTIFICA_GARA'
				set @DPR_ID = 'SEND_FINALIZZA'

				set @testAssenzaFascicoloBase = 1

			END
			ELSE IF @tipoDoc = 'PROROGA_GARA'
			BEGIN

				SET @modalita = 'U'
				set @invito = 'no'
				set @rdo = ''
				set @idPfuAOO = @IdUser

				-- Recupero i parametri del bando. Se è ad invito e se è un RDO
				select @invito = CASE WHEN TipoBandoGara =  '3' THEN 'si' 
									  ELSE 'no' 
								 END,
					   @rdo = upper( isnull(TipoProceduraCaratteristica,'')) 
					from document_bando with(nolock)
					where idheader = @linkedDoc

				-- INIZIO settaggio delle variabili chiave per entrare sulla tabella di configurazione 'Document_protocollo_docER' --
				SET @jumpCheck = ''
				SET @sottoTipo = ''

				IF @rdo = 'RDO'
					set @contesto = 'me-rdo'
				ELSE
					set @contesto = 'altro'

				-- FINE SETTAGGIO --

				--	Blocco se il bando NON è ad invito
				IF @invito = 'no' 
				BEGIN
					set @bloccaProtocollo = 1
				END

				-- PROCESSO CHE VERRA' SCHEDULATO IMMEDIATAMENTE SE NON CI SARA' IL GIRO DI PROTOCOLLO GENERALE
				set @DPR_DOC_ID = 'PROROGA_GARA'
				set @DPR_ID = 'SEND_FINALIZZA'

				SET @descrizione = @titolo + @protocolloInterno
				SET @oggetto = @titolo

				set @testAssenzaFascicoloBase = 1

			END
			ELSE IF @tipoDoc = 'RIPRISTINO_GARA'
			BEGIN

				SET @modalita = 'U'
				set @invito = 'no'
				set @rdo = ''
				set @idPfuAOO = @IdUser

				-- Recupero i parametri del bando. Se è ad invito e se è un RDO
				select @invito = CASE WHEN TipoBandoGara =  '3' THEN 'si' 
									  ELSE 'no' 
								 END,
					   @rdo = upper( isnull(TipoProceduraCaratteristica,'')) 
					from document_bando with(nolock)
					where idheader = @linkedDoc

				-- INIZIO settaggio delle variabili chiave per entrare sulla tabella di configurazione 'Document_protocollo_docER' --
				SET @jumpCheck = ''
				SET @sottoTipo = ''

				IF @rdo = 'RDO'
					set @contesto = 'me-rdo'
				ELSE
					set @contesto = 'altro'

				-- FINE SETTAGGIO --

				--	Blocco se il bando NON è ad invito
				IF @invito = 'no' 
				BEGIN
					set @bloccaProtocollo = 1
				END

				-- PROCESSO CHE VERRA' SCHEDULATO IMMEDIATAMENTE SE NON CI SARA' IL GIRO DI PROTOCOLLO GENERALE
				set @DPR_DOC_ID = 'RIPRISTINO_GARA'
				set @DPR_ID = 'SEND_FINALIZZA'

				SET @descrizione = @titolo + @protocolloInterno
				SET @oggetto = @titolo

				set @testAssenzaFascicoloBase = 1

			END
			ELSE IF @tipoDoc = 'REVOCA_GARA' -- IL DOCUMENTO E' SOLO FITTIZIO. NON VIENE USATO NE GENERATO. VIENE PROTOCOLLATA LA COMUNICAZIONE DI REVOCA
			BEGIN

				set @invito = 'no'
				set @rdo = ''

				-- Recupero i parametri del bando. Se è ad invito e se è un RDO
				select @invito = CASE WHEN TipoBandoGara =  '3' THEN 'si' 
									  ELSE 'no' 
								 END,
					   @rdo = upper( isnull(TipoProceduraCaratteristica,'')) 
					from document_bando with(nolock)
					where idheader = @linkedDoc

				-- INIZIO settaggio delle variabili chiave per entrare sulla tabella di configurazione 'Document_protocollo_docER' --
				SET @jumpCheck = ''
				SET @sottoTipo = ''

				IF @rdo = 'RDO'
					set @contesto = 'me-rdo'
				ELSE
					set @contesto = 'altro'

				-- FINE SETTAGGIO --

				--	Blocco se il bando NON è ad invito
				IF @invito = 'no' 
				BEGIN
					set @bloccaProtocollo = 1
				END

				SET @modalita = 'U'
				SET @descrizione = @titolo + ' - ' + @protocolloInterno

				IF @oggetto is null
				BEGIN
					set @oggetto = 'Revoca' 
				END

				set @testAssenzaFascicoloBase = 1

			END
			ELSE IF @tipoDoc = 'PDA_COMUNICAZIONE_RISP'
			BEGIN

				declare @jumpcheckDocCollegati varchar(200)
				declare @oggettoGara varchar(max)
				declare @tipoDocCollegato2 varchar(500)
				declare @azienda2 INT
				declare @idDocPrincipale2 INT
				declare @oggettoGara2 varchar(1000)

				set @jumpcheckDocCollegati = ''

				SET @modalita = 'I'
				SET @descrizione = @titolo + ' - ' + @protocolloInterno

				set @idDocPrincipale = -1

				-- INIZIO settaggio delle variabili chiave per entrare sulla tabella di configurazione 'Document_protocollo_docER' --
				SET @jumpCheck = 'COMUNICAZIONE_RISPOSTA'
				SET @sottoTipo = ''

				select  @idDocPrincipale = isnull(bando.id, b.id) ,
						@azienda = bando.azienda,
						@tipoDocCollegato = bando.TipoDoc,
						@jumpcheckDocCollegati = isnull(aa.JumpCheck,''),
						@oggettoGara = isnull(bando.Body,''),
						@tipoDocCollegato2 = b.TipoDoc, --per la Comunicazione al Fornitore della Convenzione.
						@azienda2 = pb.pfuIdAzi,		--per la Comunicazione al Fornitore della Convenzione.
						@idDocPrincipale2 = b.id,		--per la Comunicazione al Fornitore della Convenzione.
						@oggettoGara2 = isnull(aa.Body,'')
						, @idPfuAOO = isnull( bando.idpfu, aa.IdPfu )
					from ctl_doc a	with(nolock)				     						 --PDA_COMUNICAZIONE_RISP
							inner join ctl_doc aa with(nolock)    ON aa.id = a.linkeddoc	 --PDA_COMUNICAZIONE_GARA
							inner join ctl_doc b with(nolock)    ON b.id = aa.linkeddoc		 --PDA_COMUNICAZIONE_GENERICA (oppure il documento che ha generato la comunicazione, come ad esempio la convenzione)
							left join profiliutente pb with(nolock) on pb.idpfu = b.IdPfu
							left join ctl_doc bb with(nolock)    ON bb.id = b.linkeddoc		 --PDA_MICROLOTTI
							left join ctl_doc bando with(nolock) ON bando.id = bb.linkeddoc  --bando_gara (o comunque il documento del bando)
					where a.id = @idDoc

				IF @jumpcheckDocCollegati like '%-GARA_COMUNICAZIONE_GENERICA'
				BEGIN
					select  @idDocPrincipale = bando.id ,
						@azienda = bando.azienda,
						@tipoDocCollegato = bando.TipoDoc,
						@jumpcheckDocCollegati = isnull(aa.JumpCheck,''),
						@oggettoGara = isnull(bando.Body,''),						
						@idPfuAOO = isnull( bando.idpfu, aa.IdPfu )
					from ctl_doc a	with(nolock)				     						 --PDA_COMUNICAZIONE_RISP
							inner join ctl_doc aa with(nolock)    ON aa.id = a.linkeddoc	 --PDA_COMUNICAZIONE_GARA
							inner join ctl_doc b with(nolock)    ON b.id = aa.linkeddoc		 --PDA_COMUNICAZIONE_GENERICA 
							left join profiliutente pb with(nolock) on pb.idpfu = b.IdPfu							
							left join ctl_doc bando with(nolock) ON bando.id = b.linkeddoc  --GARA
					where a.id = @idDoc
				END

				IF @jumpcheckDocCollegati like '%-RICHIESTA_STIPULA_CONTRATTO'
					set @oggetto = 'Risposta Stipula Contratto - ' + @oggettoGara
				ELSE IF @jumpcheckDocCollegati like '%-COMUNICAZIONE_FORNITORE_CONVENZIONE'
					set @oggetto = 'Risposta comunicazione al fornitore della convenzione - ' + @oggettoGara2
				ELSE
					set @oggetto = isnull(@oggetto,'') + ' - ' + isnull(@note,'')

				IF @tipoDocCollegato = 'BANDO_SEMPLIFICATO'
				BEGIN
					set @contesto = 'SEMPLIFICATO'
				END
				ELSE IF @tipoDocCollegato = 'BANDO_ASTA'
				BEGIN
					set @contesto = 'ASTE'
				END
				ELSE IF @tipoDocCollegato2 = 'CONVENZIONE'
				BEGIN
					set @contesto = 'CONVENZIONE'	--per la Comunicazione al Fornitore della Convenzione.
					set @azienda = @azienda2
					set @idDocPrincipale = @idDocPrincipale2
				END
				ELSE
				BEGIN

					-- se il bando collegato è un RDO
					IF EXISTS( select idRow from document_bando with(nolock) where tipoProceduraCaratteristica = 'RDO' AND idheader = @idDocPrincipale )
					BEGIN
						set @contesto = 'me-rdo'
					END
					ELSE IF EXISTS( select idRow from document_bando with(nolock) where isnull(tipoProceduraCaratteristica,'') = '' AND idheader = @idDocPrincipale )
					BEGIN
						set @contesto = 'GARE'
					END
					ELSE
					BEGIN
						-- DA AGGIUNGERE IN QUEST'ELSE GLI ALTRI CONTESTI, QUANDO VERRANNO IMPLEMENTATI
						set @contesto = 'altro-contesto'
					END

				END

				------------------------------------------------------------------------------------------------------------------------
				-- SE IL FLUSSO È ATTIVO VADO A VEDERIFICARE SE È ATTIVO ANCHE IL FLUSSO RELATIVO ALLA COMUNICAZIONE IN PARTENZA -------
				------------------------------------------------------------------------------------------------------------------------

				set @jumpcheckDocCollegati = replace( @jumpcheckDocCollegati, '0-', '')
				set @jumpcheckDocCollegati = replace( @jumpcheckDocCollegati, '1-', '')

				IF NOT EXISTS( select id from Document_protocollo_docER with(nolock) where tipodoc = 'PDA_COMUNICAZIONE_GARA' and isnull(jumpcheck,'') = @jumpcheckDocCollegati and attivo = 1 and isnull(contesto,'') = @contesto and aoo = dbo.getAOO( @idPfuAOO ) )
				BEGIN
					set @bloccaProtocollo = 1
				END
				ELSE
				BEGIN


					SET @descrizione = 'Risposta a Comunicazione - '  + @protocolloInterno

					IF @oggetto is null
					BEGIN
						set @oggetto = 'Risposta a Comunicazione' 
					END

				END

				-- se c'è il controllo del fascicolo
				IF @bloccaProtocollo <> 1
						and
					EXISTS( select id from Document_protocollo_docER with(nolock) where tipodoc = @tipoDoc and isnull(contesto,'') = @contesto and isnull(verificaFascicolo,1) = 1 and aoo = dbo.getAOO(@idPfuAOO) )
				BEGIN

					-------------------------------------------------------------------------------------------------
					-- SE IL FASCICOLO GENERALE NON E' PRESENTE SULLA GARA VUOL DIRE
					-- CHE LA GARA E' DI UN GIRO VECCHIO, PRECEDENTE ALL'ATTIVAZIONE DELLA PROTOCOLLAZIONE PER IL FLUSSO
					-- QUINDI NON PROTOCOLLO QUESTO DOCUMENTO 
					-------------------------------------------------------------------------------------------------

					set @fascicoloGenerale = ''

					-- recupero il fascicolo dalla gara 
					select  @fascicoloGenerale = isnull(fascicoloSecondario,'')
						from ctl_doc doc with(nolock) 
								inner join Document_dati_protocollo prot with(nolock) ON prot.idheader = doc.id 
						where doc.id = @idDocPrincipale

					IF @fascicoloGenerale = ''
					BEGIN
						select @fascicoloGenerale = isnull(FascicoloGenerale,'')
							from ctl_doc with(nolock) where id = @idDocPrincipale
					END

					IF @fascicoloGenerale = ''
					BEGIN
						set @bloccaProtocollo = 1
					END

				END


			END
			--ELSE IF @tipoDoc = 'BANDO_GARA'
			ELSE IF @tipoDoc in ( 'BANDO_GARA' , 'BANDO_CONCORSO')
			BEGIN

				-- PER LE RDO E PER GLI INVITI

				SET @modalita = 'U'
				SET @descrizione = @titolo + ' - ' + @protocolloInterno

				set @oggetto = isnull(@oggetto,'') --+ ' - Richiesta di Offerta'

				set @idPfuAOO = @idUtente

				-- INIZIO settaggio delle variabili chiave per entrare sulla tabella di configurazione 'Document_protocollo_docER' --
				SET @jumpCheck = ''
				SET @sottoTipo = ''

				-- PROCESSO CHE VERRA' SCHEDULATO IMMEDIATAMENTE SE NON CI SARA' IL GIRO DI PROTOCOLLO GENERALE
				set @DPR_DOC_ID = 'BANDO_SEMPLIFICATO'
				set @DPR_ID = 'APPROVE_FINALIZZA'

				-- SE NON È UN CASO DA PROTOCOLLARE BLOCCO A PRESCINDERE
				SET @sottoTipo = 'GARE'
				set @contesto = 'GARE'				
				set @bloccaProtocollo = 1

				-- se è un RDO
				IF EXISTS( select idRow from document_bando with(nolock) where tipoProceduraCaratteristica = 'RDO' AND idheader = @idDoc )
				BEGIN
					SET @sottoTipo = 'RDO'
					set @contesto = 'ME-RDO'
					set @bloccaProtocollo = 0
				END 
				
				--se è un invito su una ristretta
				--generalizzato il meccanismo tramite un parametro per prevedere più gare
				IF EXISTS ( 
							--select idheader from Document_Bando WITH(NOLOCK) 
							--where idheader = @IdDoc
							--	 and  (  tipobandogara = '3' /*Invito*/ and ProceduraGara = '15477' /* Ristretta*/  ) 

							select idheader,ProceduraGara,tipobandogara from Document_Bando WITH(NOLOCK) 
								inner join ( select items from 
								dbo.split(dbo.PARAMETRI ('ProtGenInsert', 'BANDO_GARA','ProceduraGara','15477',0),'###') ) a on ProceduraGara=a.items
									where idheader = @IdDoc
										and    tipobandogara = '3' /*Invito*/ 

							)
				BEGIN
					SET @sottoTipo = 'INVITO'
					set @contesto = 'RISTRETTA'
					set @bloccaProtocollo = 0
					
				END 
				
				-- se è un AffidamentoSemplificato
				IF EXISTS( select idRow from document_bando with(nolock) where tipoProceduraCaratteristica = 'AffidamentoSemplificato' AND idheader = @idDoc )
				BEGIN
					SET @sottoTipo = 'GARE'
					set @contesto = 'AFF_SEMPLIFICATO'
					set @bloccaProtocollo = 0
				END 


			END
			ELSE IF @tipoDoc = 'BANDO_SEMPLIFICATO'
			BEGIN
				-- PROCESSO CHE VERRA' SCHEDULATO IMMEDIATAMENTE SE NON CI SARA' IL GIRO DI PROTOCOLLO GENERALE
				set @DPR_DOC_ID = 'BANDO_SEMPLIFICATO'
				set @DPR_ID = 'APPROVE_FINALIZZA'
				--SETTO CONTESTO SEMPLIFICATO PER ESSERE CERTO CHE NON FA NULLA NELLE VERIFICHE
				--Document_protocollo_docER 
				set @contesto = 'SEMPLIFICATO'
			END
			ELSE IF @tipoDoc = 'VARIAZIONE_ANAGRAFICA'
			BEGIN

				---- DOCUMENTO DI RICHIESTA VARIAZIONE DATI ANAGRAFICI

				SET @modalita = 'I'

				-- INIZIO settaggio delle variabili chiave per entrare sulla tabella di configurazione 'Document_protocollo_docER' --
				SET @jumpCheck = ''
				SET @sottoTipo = ''
				SET @contesto = ''
				-- FINE settaggio --

				set @idPfuAOO = -1

				SET @descrizione = @titolo + ' ' + @protocolloInterno

				IF isnull(@oggetto,'') = ''
				BEGIN
					set @oggetto = 'Variazione Dati sensibili OE' 
				END

	

			END
			ELSE IF @tipoDoc = 'PREGARA'
			BEGIN
				--SET @modalita = 'I'
				declare @azienda_utente int
				select @azienda_utente=pfuidazi from ProfiliUtente with(nolock) where IdPfu=@IdUser

				-- DOCUMENTO DI PREGARA 
				--@modalita = 'L' SE ENTE APP E ENTE PROP SONO UGUALI ---la L sta per LOCALE
				--@modalita = 'I' SE USER fa parte di proponente				 
				--@modalita = 'U' se USER fa parte ente appaltante
				--SUL DOCUMENTO NEL CAMPO AZIENDA Ente appaltante mentre EnteProponente su document bando
				select @modalita=
							case 
								when cast(Azienda as varchar(50)) + '#\0000\0000'= EnteProponente then 'L'
								when cast(@azienda_utente as varchar(50)) + '#\0000\0000' = EnteProponente then 'I'
								when @azienda_utente = Azienda  then 'U'
							end
					from CTL_DOC with(nolock) 
						inner join Document_Bando with(nolock) on idHeader=id
					where Id=@idDoc
				
				
				

				-- INIZIO settaggio delle variabili chiave per entrare sulla tabella di configurazione 'Document_protocollo_docER' --
				SET @jumpCheck = ''
				SET @sottoTipo = ''
				SET @contesto = ''
				-- FINE settaggio --

				set @idPfuAOO = -1

				SET @descrizione = @titolo + ' ' + @protocolloInterno

				IF isnull(@oggetto,'') = ''
				BEGIN
					set @oggetto = 'Indizione Procedura di Gara' 
				END


				--E.P. att.416087 prendiamo il campo dirigente e lo settiamo in @idUtente
				--E.P. KPF 443116 solo se valorizzato ricopro @idUtente per i documenti vecchi per non farli andare in eccezione
				if exists (select idrow from ctl_doc_Value with (nolock) 
								where idheader= @idDoc and dse_id='CRITERI_ECO' and dzt_name='UserDirigente' and value<>'')
				begin
					select  @idUtente = value from CTL_DOC_Value with (nolock) where idheader= @idDoc and dse_id='CRITERI_ECO' and dzt_name='UserDirigente'
				end

			END
			ELSE IF @tipoDoc = 'VARIAZIONE_ANAGRAFICA_ACCETTA'
			BEGIN

				---- ACCETTAZIONE VARIAZIONE ANAGRAFICA. stesso record di VARIAZIONE_ANAGRAFICA, ma cambiato il tipo nella chiamata a questa stored

				SET @modalita = 'U'

				-- INIZIO settaggio delle variabili chiave per entrare sulla tabella di configurazione 'Document_protocollo_docER' --
				SET @jumpCheck = ''
				SET @sottoTipo = ''
				SET @contesto = ''
				-- FINE settaggio --

				-- PROCESSO CHE VERRA' SCHEDULATO IMMEDIATAMENTE SE NON CI SARA' IL GIRO DI PROTOCOLLO GENERALE
				set @DPR_DOC_ID = 'VARIAZIONE_ANAGRAFICA'
				set @DPR_ID = 'ACCETTA_FINALIZZA'

				SET @descrizione = @titolo + ' ' + @protocolloInterno

				IF isnull(@oggetto,'') = ''
				BEGIN
					set @oggetto = 'Conferma Variazione Dati sensibili OE' 
				END

			END
			ELSE IF @tipoDoc = 'INVIO_ATTI_GARA'
			BEGIN

					-----------------------------------------------------------------------------------
				-- QUESTO TIPO DOC UTILIZZA COME PROCESSO DI SEND IL PDA_COMUNICAZIONE_GARA-SEND --
				-----------------------------------------------------------------------------------

				SET @modalita = 'U'

				SET @jumpCheck = ''
				SET @sottoTipo = ''

				set @idPfuAOO = @IdUser

				-- PROCESSO CHE VERRA' SCHEDULATO IMMEDIATAMENTE SE NON CI SARA' IL GIRO DI PROTOCOLLO GENERALE
				set @DPR_DOC_ID = 'INVIO_ATTI_GARA'
				set @DPR_ID = 'SEND_FINALIZZA'

				SET @descrizione = @titolo + @protocolloInterno

				IF isnull(@oggetto,'') = ''
				BEGIN
					set @oggetto = 'Riscontro richiesta di accesso agli atti' 
				END

				set @idDocPrincipale = -1
			
				select 	@idDocPrincipale = bando.id,
						@azienda = bando.azienda,
						@tipoDocCollegato = bando.TipoDoc
					from ctl_doc a	with(nolock)				     							-- INVIO_ATTI
							inner join ctl_doc b with(nolock)    ON b.id = a.linkeddoc			-- RICHIESTA_ATTI							
							inner join ctl_doc bando with(nolock) ON bando.id = b.linkeddoc	-- BANDO 
					where a.id = @idDoc				

				IF @tipoDocCollegato = 'BANDO_SEMPLIFICATO'
				BEGIN
					set @contesto = 'SEMPLIFICATO'
				END
				ELSE IF @tipoDocCollegato = 'BANDO_ASTA'
				BEGIN
					set @contesto = 'ASTE'
				END
				ELSE
				BEGIN

					IF EXISTS( select idRow from document_bando with(nolock) where tipoProceduraCaratteristica = 'RDO' AND idheader = @idDocPrincipale )
					BEGIN
						set @contesto = 'me-rdo'
					END
					ELSE IF EXISTS( select idRow from document_bando with(nolock) where isnull(tipoProceduraCaratteristica,'') = '' AND idheader = @idDocPrincipale )
					BEGIN
						set @contesto = 'GARE'
					END
					ELSE
					BEGIN
						set @contesto = 'altro-contesto'
					END

				END
			
			END
			ELSE IF @tipoDoc = 'CAMBIO_RUOLO_UTENTE'
			BEGIN

				SET @modalita = 'I' -- I = Ingresso  U = Uscita
				
				-- INIZIO settaggio delle variabili chiave per entrare sulla tabella di configurazione 'Document_protocollo_docER' --
				SET @jumpCheck = ''
				SET @sottoTipo = ''
				SET @contesto = ''
				-- FINE settaggio --

				set @idPfuAOO = -1

				-- Utilizzo come azienda destinatario l'azimaster
				select top 1 @azienda = mpIdAziMaster 
					from MarketPlace where mpDeleted = 0 order by idmp asc

				SET @descrizione = @titolo + ' ' + @protocolloInterno
				set @oggetto = 'Modifica Ruolo'

			END
			ELSE IF @tipoDoc = 'OFFERTA'
			BEGIN
				
				SET @modalita = 'I'

				-- INIZIO settaggio delle variabili chiave per entrare sulla tabella di configurazione 'Document_protocollo_docER' --
				SET @jumpCheck = ''
				SET @sottoTipo = ''

				-- PRENDO L'IDPFU DESTINATARIO DALLA GARA
				select @idPfuAOO = idpfu
					from ctl_doc with(nolock)
					where id = @linkedDoc
				
				select @tipoDocCollegato = TipoDoc FROM ctl_doc with(nolock) where id = @linkedDoc
				
				IF @tipoDocCollegato = 'BANDO_SEMPLIFICATO'
				BEGIN
					set @contesto = 'SEMPLIFICATO'
				END
				ELSE IF @tipoDocCollegato = 'BANDO_ASTA'
				BEGIN
					set @contesto = 'ASTE'
				END
				ELSE
				BEGIN

					-- se il bando collegato è un RDO
					IF EXISTS( select idRow from document_bando with(nolock) where tipoProceduraCaratteristica = 'RDO' AND idheader = @linkedDoc )
					BEGIN
						set @contesto = 'me-rdo'
					END
					ELSE IF EXISTS( select idRow from document_bando with(nolock) where isnull(tipoProceduraCaratteristica,'') = '' AND idheader = @linkedDoc )
					BEGIN
						set @contesto = 'GARE'
					END
					ELSE
					BEGIN
						-- DA AGGIUNGERE IN QUEST'ELSE GLI ALTRI CONTESTI, QUANDO VERRANNO IMPLEMENTATI
						set @contesto = 'altro-contesto'
					END

				END

				-- FINE settaggio --
				

				SET @descrizione = 'Offerta '  + isnull(@protocolloInterno,'')

				IF isnull(@oggetto,'') = ''
				BEGIN
					set @oggetto = 'Offerta' 
				END

				set @testAssenzaFascicoloBase = 1

			END
			ELSE IF @tipoDoc = 'OFFERTA_BA'
			BEGIN
				
				SET @modalita = 'I'

				-- INIZIO settaggio delle variabili chiave per entrare sulla tabella di configurazione 'Document_protocollo_docER' --
				SET @jumpCheck = ''
				SET @sottoTipo = ''

				-- PRENDO L'IDPFU DESTINATARIO DALLA GARA
				select @idPfuAOO = idpfu
					from ctl_doc with(nolock)
					where id = @linkedDoc
				
				select @tipoDocCollegato = TipoDoc FROM ctl_doc with(nolock) where id = @linkedDoc
				
				IF @tipoDocCollegato = 'BANDO_SEMPLIFICATO'
				BEGIN
					set @contesto = 'SEMPLIFICATO'
				END
				ELSE IF @tipoDocCollegato = 'BANDO_ASTA'
				BEGIN
					set @contesto = 'ASTE'
				END
				ELSE
				BEGIN

					-- se il bando collegato è un RDO
					IF EXISTS( select idRow from document_bando with(nolock) where tipoProceduraCaratteristica = 'RDO' AND idheader = @linkedDoc )
					BEGIN
						set @contesto = 'me-rdo'
					END
					ELSE IF EXISTS( select idRow from document_bando with(nolock) where isnull(tipoProceduraCaratteristica,'') = '' AND idheader = @linkedDoc )
					BEGIN
						set @contesto = 'GARE'
					END
					ELSE
					BEGIN
						-- DA AGGIUNGERE IN QUEST'ELSE GLI ALTRI CONTESTI, QUANDO VERRANNO IMPLEMENTATI
						set @contesto = 'altro-contesto'
					END

				END
				-- FINE settaggio --

				select @cf_mittente = pfuCodiceFiscale from ProfiliUtente with(nolock) where IdPfu = @idUtente

				--PIxxxxxx-yy_BA_CODFISC 
				set @descrizione = @protocolloInterno + '_BA_' + ISNULL(@cf_mittente,'')

				set @oggetto = @descrizione

				set @testAssenzaFascicoloBase = 1

			END
			ELSE IF @tipoDoc IN ('COM_DPE_FORNITORE' )
			BEGIN

				-- L'IDDOC CHE ARRIVA QUI è L'ID DELLA Document_Com_DPE_Fornitori

				SET @modalita = 'U'

				-- INIZIO settaggio delle variabili chiave per entrare sulla tabella di configurazione 'Document_protocollo_docER' --
				SET @jumpCheck = ''
				SET @sottoTipo = ''	
				
				SET @descrizione = @titolo + ' ' + @protocolloInterno		
				
				-- PROCESSO CHE VERRA' SCHEDULATO IMMEDIATAMENTE SE NON CI SARA' IL GIRO DI PROTOCOLLO GENERALE
				--set @DPR_DOC_ID = 'COM_DPE'
				--set @DPR_ID = 'SEND_FINALIZZA'

					
			END		
			ELSE IF @tipoDoc IN ('COM_DPE_ENTE' )
			BEGIN

				-- L'IDDOC CHE ARRIVA QUI è L'ID DELLA Document_Com_DPE_Enti

				SET @modalita = 'U'

				-- INIZIO settaggio delle variabili chiave per entrare sulla tabella di configurazione 'Document_protocollo_docER' --
				SET @jumpCheck = ''
				SET @sottoTipo = ''	
				
				SET @descrizione = @titolo + ' ' + @protocolloInterno		
				
				-- PROCESSO CHE VERRA' SCHEDULATO IMMEDIATAMENTE SE NON CI SARA' IL GIRO DI PROTOCOLLO GENERALE
				--set @DPR_DOC_ID = 'COM_DPE'
				--set @DPR_ID = 'SEND_FINALIZZA'

				--INSERT INTO CTL_Schedule_Process ( IdDoc, IdUser, DPR_DOC_ID, DPR_ID  ) 
				--	select  IdCom, @IdUser , 'COM_DPE','SEND_FINALIZZA'
				--		from Document_Com_DPE_Enti with (nolock) where idcomEnte = @idDoc
					
			END			
			ELSE IF @tipoDoc IN ('OFFERTA_BT', 'OFFERTA_BE' )
			BEGIN

				-- L'IDDOC CHE ARRIVA QUI è L'ID RIGA DELLA MICROLOTTI DETTAGLI RELATIVO ALLA BUSTA TECNICA/ECONOMICA DEL RELATIVO LOTTO ( o anche monolotto )

				SET @modalita = 'I'

				-- INIZIO settaggio delle variabili chiave per entrare sulla tabella di configurazione 'Document_protocollo_docER' --
				SET @jumpCheck = ''
				SET @sottoTipo = ''

				-- PRENDO L'IDPFU DESTINATARIO DALLA GARA
				select @idPfuAOO = idpfu
					from ctl_doc with(nolock)
					where id = @linkedDoc
				
				select @tipoDocCollegato = TipoDoc FROM ctl_doc with(nolock) where id = @linkedDoc
				
				IF @tipoDocCollegato = 'BANDO_SEMPLIFICATO'
				BEGIN
					set @contesto = 'SEMPLIFICATO'
				END
				ELSE IF @tipoDocCollegato = 'BANDO_ASTA'
				BEGIN
					set @contesto = 'ASTE'
				END
				ELSE
				BEGIN

					-- se il bando collegato è un RDO
					IF EXISTS( select idRow from document_bando with(nolock) where tipoProceduraCaratteristica = 'RDO' AND idheader = @linkedDoc )
					BEGIN
						set @contesto = 'me-rdo'
					END
					ELSE IF EXISTS( select idRow from document_bando with(nolock) where isnull(tipoProceduraCaratteristica,'') = '' AND idheader = @linkedDoc )
					BEGIN
						set @contesto = 'GARE'
					END
					ELSE
					BEGIN
						-- DA AGGIUNGERE IN QUEST'ELSE GLI ALTRI CONTESTI, QUANDO VERRANNO IMPLEMENTATI
						set @contesto = 'altro-contesto'
					END

				END
				-- FINE settaggio --



				select @cf_mittente = pfuCodiceFiscale from ProfiliUtente with(nolock) where IdPfu = @idUtente

				IF EXISTS ( select idheader from Document_Bando with(nolock) where idHeader = @linkedDoc and Divisione_lotti <> '0' ) --SE MULTILOTTO
				BEGIN
					select @cf_mittente = 'Lotto-' + ISNULL(NumeroLotto,'') + '_' + @cf_mittente from Document_MicroLotti_Dettagli with(nolock) where Id = @iddoc
				END

				--PIxxxxxx-yy_BT_CODFISC 
				--PIxxxxxx-yy_BE_CODFISC 
				set @descrizione = @protocolloInterno + case when @tipoDoc = 'OFFERTA_BT' then  '_BT_' else '_BE' end + ISNULL(@cf_mittente,'')

				--IF isnull(@oggetto,'') = ''
				--BEGIN
					set @oggetto = @descrizione
				--END

				set @testAssenzaFascicoloBase = 1

			END
			ELSE IF @tipoDoc = 'MANIFESTAZIONE_INTERESSE'
			BEGIN
				
				SET @modalita = 'I'

				-- INIZIO settaggio delle variabili chiave per entrare sulla tabella di configurazione 'Document_protocollo_docER' --
				SET @jumpCheck = ''
				SET @sottoTipo = ''

				-- PRENDO L'IDPFU DESTINATARIO DALLA GARA
				select @idPfuAOO = idpfu
					from ctl_doc with(nolock)
					where id = @linkedDoc
				
				select @tipoDocCollegato = TipoDoc FROM ctl_doc with(nolock) where id = @linkedDoc
				
				IF @tipoDocCollegato = 'BANDO_SEMPLIFICATO'
				BEGIN
					set @contesto = 'SEMPLIFICATO'
				END
				ELSE IF @tipoDocCollegato = 'BANDO_ASTA'
				BEGIN
					set @contesto = 'ASTE'
				END
				ELSE
				BEGIN

					-- se il bando collegato è un RDO
					IF EXISTS( select idRow from document_bando with(nolock) where tipoProceduraCaratteristica = 'RDO' AND idheader = @linkedDoc )
					BEGIN
						set @contesto = 'me-rdo'
					END
					ELSE IF EXISTS( select idRow from document_bando with(nolock) where isnull(tipoProceduraCaratteristica,'') = '' AND idheader = @linkedDoc )
					BEGIN
						set @contesto = 'GARE'
					END
					ELSE
					BEGIN
						-- DA AGGIUNGERE IN QUEST'ELSE GLI ALTRI CONTESTI, QUANDO VERRANNO IMPLEMENTATI
						set @contesto = 'altro-contesto'
					END

				END

				-- FINE settaggio --
				

				SET @descrizione = 'Manifestazione di Interesse '  + isnull(@protocolloInterno,'')

				IF isnull(@oggetto,'') = ''
				BEGIN
					set @oggetto = 'Manifestazione di Interesse' 
				END

				set @testAssenzaFascicoloBase = 1

			END

			ELSE IF @tipoDoc = 'DOMANDA_PARTECIPAZIONE'
			BEGIN
				
				SET @modalita = 'I'

				-- INIZIO settaggio delle variabili chiave per entrare sulla tabella di configurazione 'Document_protocollo_docER' --
				SET @jumpCheck = ''
				SET @sottoTipo = ''

				-- PRENDO L'IDPFU DESTINATARIO DALLA GARA
				select @idPfuAOO = idpfu
					from ctl_doc with(nolock)
					where id = @linkedDoc
				
				select @tipoDocCollegato = TipoDoc FROM ctl_doc with(nolock) where id = @linkedDoc
				
				IF @tipoDocCollegato = 'BANDO_SEMPLIFICATO'
				BEGIN
					set @contesto = 'SEMPLIFICATO'
				END
				ELSE IF @tipoDocCollegato = 'BANDO_ASTA'
				BEGIN
					set @contesto = 'ASTE'
				END
				ELSE
				BEGIN

					-- se il bando collegato è un RDO
					IF EXISTS( select idRow from document_bando with(nolock) where tipoProceduraCaratteristica = 'RDO' AND idheader = @linkedDoc )
					BEGIN
						set @contesto = 'me-rdo'
					END
					ELSE IF EXISTS( select idRow from document_bando with(nolock) where isnull(tipoProceduraCaratteristica,'') = '' AND idheader = @linkedDoc )
					BEGIN
						set @contesto = 'GARE'
					END
					ELSE
					BEGIN
						-- DA AGGIUNGERE IN QUEST'ELSE GLI ALTRI CONTESTI, QUANDO VERRANNO IMPLEMENTATI
						set @contesto = 'altro-contesto'
					END

				END

				-- FINE settaggio --
				

				SET @descrizione = 'Domanda di Partecipazione '  + isnull(@protocolloInterno,'')

				IF isnull(@oggetto,'') = ''
				BEGIN
					set @oggetto = 'Domanda di Partecipazione' 
				END

				set @testAssenzaFascicoloBase = 1

			END

			ELSE IF @tipoDoc = 'RITIRA_OFFERTA'
			BEGIN
				
				declare @newLinkedDoc int

				SET @modalita = 'I'

				-- INIZIO settaggio delle variabili chiave per entrare sulla tabella di configurazione 'Document_protocollo_docER' --
				SET @jumpCheck = ''
				SET @sottoTipo = ''			

				select    @tipoDocCollegato = b.TipoDoc
						,  @oggetto = 'Ritiro offerta - ' + cast( isnull(B.Body,'') as nvarchar(max)) --descrizione estesa
						,  @idPfuAOO = b.IdPfu
						,  @newLinkedDoc = b.Id	-- al momento il linked doc è l'offerta. lo trasformo nell'id della gara
					FROM ctl_doc O with(nolock)
						inner join ctl_doc B on o.LinkedDoc=b.id 
				where o.id = @linkedDoc
				
				IF @tipoDocCollegato = 'BANDO_SEMPLIFICATO'
				BEGIN
					set @contesto = 'SEMPLIFICATO'
				END
				ELSE IF @tipoDocCollegato = 'BANDO_ASTA'
				BEGIN
					set @contesto = 'ASTE'
				END
				ELSE
				BEGIN

					-- se il bando collegato è un RDO
					IF EXISTS( select idRow from ctl_doc  with(nolock) inner join document_bando with(nolock) on idHeader=LinkedDoc where tipoProceduraCaratteristica = 'RDO' AND id = @linkedDoc )
					BEGIN
						set @contesto = 'me-rdo'
					END
					ELSE IF EXISTS( select idRow from ctl_doc  with(nolock) inner join document_bando with(nolock) on idHeader=LinkedDoc  where isnull(tipoProceduraCaratteristica,'') = '' AND id = @linkedDoc )
					BEGIN
						set @contesto = 'GARE'
					END
					ELSE
					BEGIN
						-- DA AGGIUNGERE IN QUEST'ELSE GLI ALTRI CONTESTI, QUANDO VERRANNO IMPLEMENTATI
						set @contesto = 'altro-contesto'
					END

				END
				-- FINE settaggio --

				SET @descrizione = 'Ritira Offerta '  + isnull(@protocolloInterno,'')

				IF isnull(@oggetto,'') = ''
				BEGIN
					set @oggetto = 'Ritira Offerta' 
				END

				set @testAssenzaFascicoloBase = 1

				set @linkedDoc = @newLinkedDoc

			END  
			ELSE IF @tipoDoc = 'RICHIESTA_ATTI_GARA'
			BEGIN
				
				declare @newLinkedDoc1 int

				SET @modalita = 'I'

				-- INIZIO settaggio delle variabili chiave per entrare sulla tabella di configurazione 'Document_protocollo_docER' --
				SET @jumpCheck = ''
				SET @sottoTipo = ''							
				select 
					    @tipoDocCollegato = TipoDoc,
						@idPfuAOO = idpfu,
						@oggetto = 'Richiesta accesso atti di gara - ' + cast( isnull(Body,'') as nvarchar(max)) --descrizione estesa
					from ctl_doc with(nolock)
					where id = @linkedDoc				
				
				IF @tipoDocCollegato = 'BANDO_SEMPLIFICATO'
				BEGIN
					set @contesto = 'SEMPLIFICATO'
				END
				ELSE IF @tipoDocCollegato = 'BANDO_ASTA'
				BEGIN
					set @contesto = 'ASTE'
				END
				ELSE
				BEGIN

					-- se il bando collegato è un RDO
					IF EXISTS( select idRow from document_bando with(nolock) where tipoProceduraCaratteristica = 'RDO' AND idheader = @linkedDoc )
					BEGIN
						set @contesto = 'me-rdo'
					END
					ELSE IF EXISTS( select idRow from document_bando with(nolock) where isnull(tipoProceduraCaratteristica,'') = '' AND idheader = @linkedDoc )
					BEGIN
						set @contesto = 'GARE'
					END
					ELSE
					BEGIN
						-- DA AGGIUNGERE IN QUEST'ELSE GLI ALTRI CONTESTI, QUANDO VERRANNO IMPLEMENTATI
						set @contesto = 'altro-contesto'
					END

				END
				-- FINE settaggio --

				SET @descrizione = 'Richiesta accesso atti di gara '  + isnull(@protocolloInterno,'')

				IF isnull(@oggetto,'') = ''
				BEGIN
					set @oggetto = 'Richiesta accesso atti di gara' 
				END

				set @testAssenzaFascicoloBase = 1				

			END

			ELSE IF @tipoDoc = 'BANDO_ASTA'
			BEGIN
				
				set @bloccaProtocollo = 1

				-- PROCESSO CHE VERRA' SCHEDULATO IMMEDIATAMENTE SE NON CI SARA' IL GIRO DI PROTOCOLLO GENERALE
				set @DPR_DOC_ID = 'BANDO_SEMPLIFICATO'
				set @DPR_ID = 'APPROVE_FINALIZZA'

			END
			ELSE IF @tipoDoc in ('NOTIER_ISCRIZ', 'NOTIER_ISCRIZ_PA')
			BEGIN

				--- Documento di iscrizione/registrazione a NoTI-ER

				SET @modalita = 'I'

				-- INIZIO settaggio delle variabili chiave per entrare sulla tabella di configurazione 'Document_protocollo_docER' --
				SET @jumpCheck = ''
				SET @sottoTipo = ''
				SET @contesto = ''
				-- FINE settaggio --

				set @idPfuAOO = -1

				SET @oggetto = 'Iscrizione Peppol'

				SET @descrizione = @titolo + ' ' + @protocolloInterno

				IF @oggetto is null
				BEGIN
					set @oggetto = 'Iscrizione a NoTI-ER'
				END


			END
			ELSE IF @tipoDoc in ('RIAMMISSIONE_OFFERTA')
			BEGIN

				-- PROCESSO CHE VERRA' SCHEDULATO IMMEDIATAMENTE SE NON CI SARA' IL GIRO DI PROTOCOLLO GENERALE
				set @DPR_DOC_ID = 'RIAMMISSIONE_OFFERTA'
				set @DPR_ID = 'SEND_FINALIZZA'


			END
			ELSE IF @tipoDoc = 'PDA_COMUNICAZIONE_OFFERTA'
			BEGIN

				-----------------------------------------------------------------------------------
				-- QUESTO TIPO DOC UTILIZZA COME PROCESSO DI SEND IL PDA_COMUNICAZIONE_GARA-SEND --
				-----------------------------------------------------------------------------------

				SET @modalita = 'U'

				SET @jumpCheck = ''
				SET @sottoTipo = ''

				set @idPfuAOO = @IdUser

				-- PROCESSO CHE VERRA' SCHEDULATO IMMEDIATAMENTE SE NON CI SARA' IL GIRO DI PROTOCOLLO GENERALE
				set @DPR_DOC_ID = 'PDA_COMUNICAZIONE_GARA'
				set @DPR_ID = 'FINALIZZA'

				SET @descrizione = @titolo + @protocolloInterno

				set @oggetto = isnull(@oggetto,'') + isnull(@note,'')

				set @idDocPrincipale = -1
			
				select 	@idDocPrincipale = bando.id,
						@azienda = bando.azienda,
						@tipoDocCollegato = bando.TipoDoc
					from ctl_doc a	with(nolock)				     							-- PDA_COMUNICAZIONE_OFFERTA
							inner join ctl_doc b with(nolock)    ON b.id = a.linkeddoc			-- PDA_COMUNICAZIONE
							inner join ctl_doc b2 with(nolock)   ON b2.id = b.LinkedDoc			-- PDA_MICROLOTTI
							inner join ctl_doc bando with(nolock) ON bando.id = b2.linkeddoc	-- BANDO 
					where a.id = @idDoc

				set @oggetto = @oggetto + ' - Richiesta Offerta Migliorativa'

				IF @tipoDocCollegato = 'BANDO_SEMPLIFICATO'
				BEGIN
					set @contesto = 'SEMPLIFICATO'
				END
				ELSE IF @tipoDocCollegato = 'BANDO_ASTA'
				BEGIN
					set @contesto = 'ASTE'
				END
				ELSE
				BEGIN

					IF EXISTS( select idRow from document_bando with(nolock) where tipoProceduraCaratteristica = 'RDO' AND idheader = @idDocPrincipale )
					BEGIN
						set @contesto = 'me-rdo'
					END
					ELSE IF EXISTS( select idRow from document_bando with(nolock) where isnull(tipoProceduraCaratteristica,'') = '' AND idheader = @idDocPrincipale )
					BEGIN
						set @contesto = 'GARE'
					END
					ELSE
					BEGIN
						set @contesto = 'altro-contesto'
					END

				END

				
				IF EXISTS( select id from Document_protocollo_docER with(nolock) where tipodoc = @tipoDoc and isnull(contesto,'') = @contesto and isnull(verificaFascicolo,1) = 1 and aoo = dbo.getAOO( @idPfuAOO ) )
				BEGIN

					-------------------------------------------------------------------------------------------------
					-- SE IL FASCICOLO GENERALE NON E' PRESENTE SULLA GARA VUOL DIRE
					-- CHE LA GARA E' DI UN GIRO VECCHIO, PRECEDENTE ALL'ATTIVAZIONE DELLA PROTOCOLLAZIONE PER IL FLUSSO
					-- QUINDI NON PROTOCOLLO QUESTO DOCUMENTO 
					-------------------------------------------------------------------------------------------------

					set @fascicoloGenerale = ''

					-- recupero il fascicolo dalla gara 
					select  @fascicoloGenerale = isnull(fascicoloSecondario,'')
						from ctl_doc doc with(nolock) 
								inner join Document_dati_protocollo prot with(nolock) ON prot.idheader = doc.id 
						where doc.id = @idDocPrincipale

					IF @fascicoloGenerale = ''
					BEGIN
						select @fascicoloGenerale = isnull(FascicoloGenerale,'')
							from ctl_doc with(nolock) where id = @idDocPrincipale
					END

					IF @fascicoloGenerale = ''
					BEGIN
						set @bloccaProtocollo = 1
					END

				END


			END
			ELSE IF @tipoDoc = 'PDA_COMUNICAZIONE_OFFERTA_RISP'
			BEGIN
				
				SET @modalita = 'I'
				set @jumpCheck = ''
				set @sottoTipo = ''
				set @oggetto = isnull(@oggetto,'') + ' - Risposta a richiesta Offerta Migliorativa'

				if isnull(@descrizione,'') = ''
					set @descrizione = @oggetto

				select 	@idDocPrincipale = bando.id,
						@azienda = bando.azienda,
						@tipoDocCollegato = bando.TipoDoc,
						@idPfuAOO = bando.IdPfu
					from ctl_doc a	with(nolock)				     							
							inner join ctl_doc b with(nolock)    ON b.id = a.linkeddoc	
							inner join ctl_doc b2 with(nolock)   ON b2.id = b.LinkedDoc			
							inner join ctl_doc pda with(nolock) ON pda.id = b2.linkeddoc		
							inner join ctl_doc bando with(nolock) ON bando.id = pda.linkeddoc	
					where a.id = @idDoc
				
				IF @tipoDocCollegato = 'BANDO_SEMPLIFICATO'
				BEGIN
					set @contesto = 'SEMPLIFICATO'
				END
				ELSE IF @tipoDocCollegato = 'BANDO_ASTA'
				BEGIN
					set @contesto = 'ASTE'
				END
				ELSE
				BEGIN

					-- se il bando collegato è un RDO
					IF EXISTS( select idRow from document_bando with(nolock) where tipoProceduraCaratteristica = 'RDO' AND idheader = @idDocPrincipale )
					BEGIN

						set @contesto = 'me-rdo'

					END
					ELSE IF EXISTS( select idRow from document_bando with(nolock) where isnull(tipoProceduraCaratteristica,'') = '' AND idheader = @idDocPrincipale )
					BEGIN

						set @contesto = 'GARE'

					END
					ELSE
					BEGIN

						-- DA AGGIUNGERE IN QUEST'ELSE GLI ALTRI CONTESTI, QUANDO VERRANNO IMPLEMENTATI
						set @contesto = 'altro-contesto'

					END

				END

				IF EXISTS( select id from Document_protocollo_docER with(nolock) where tipodoc = @tipoDoc and isnull(contesto,'') = @contesto and isnull(verificaFascicolo,1) = 1 and aoo = dbo.getAOO ( @idPfuAOO ) )
				BEGIN

					-------------------------------------------------------------------------------------------------
					-- SE IL FASCICOLO GENERALE NON E' PRESENTE SULLA GARA VUOL DIRE
					-- CHE LA GARA E' DI UN GIRO VECCHIO, PRECEDENTE ALL'ATTIVAZIONE DELLA PROTOCOLLAZIONE PER IL FLUSSO
					-- QUINDI NON PROTOCOLLO QUESTO DOCUMENTO 
					-------------------------------------------------------------------------------------------------

					set @fascicoloGenerale = ''

					-- recupero il fascicolo dalla gara 
					select  @fascicoloGenerale = isnull(fascicoloSecondario,'')
						from ctl_doc doc with(nolock) 
								inner join Document_dati_protocollo prot with(nolock) ON prot.idheader = doc.id 
						where doc.id = @idDocPrincipale

					IF @fascicoloGenerale = ''
					BEGIN
						select @fascicoloGenerale = isnull(FascicoloGenerale,'')
							from ctl_doc with(nolock) where id = @idDocPrincipale
					END

					IF @fascicoloGenerale = ''
					BEGIN
						set @bloccaProtocollo = 1
					END

				END

			END
			ELSE IF @tipoDoc = 'CONTRATTO_GARA_FORN'
			BEGIN

				SET @modalita = 'I' -- I = Ingresso  U = Uscita

				SET @jumpCheck = ''
				SET @sottoTipo = ''
				SET @contesto  = ''

				SET @descrizione = @titolo + @protocolloInterno

				-- recupero l'utente per l'AOO dalla gara
				select @idPfuAOO = gara.IdPfu
					from ctl_doc contr with(nolock)
							inner join ctl_doc com with(nolock) on com.id = contr.LinkedDoc
							inner join ctl_doc pda with(nolock) on pda.id = com.LinkedDoc
							inner join ctl_doc gara with(nolock) on gara.id = pda.LinkedDoc
					where contr.id = @linkedDoc

				SELECT  @oggetto = ISNULL(value,'')	FROM CTL_DOC_Value with(nolock) where IdHeader = @idDoc and DSE_ID='CONTRATTO' and DZT_Name='BodyContratto'

				SET @oggetto = 'Contratto - ' + @oggetto

			END
			ELSE IF @tipoDoc = 'ODA' -- Ordine di acquisto ( SEND_FORNITORE )
			BEGIN


				 SET @modalita = 'U'

				-- INIZIO settaggio delle variabili chiave per entrare sulla tabella di configurazione 'Document_protocollo_docER' --
				SET @jumpCheck = ''
				SET @sottoTipo = ''
				SET @contesto = ''
				-- FINE settaggio --

				-- PROCESSO CHE VERRA' SCHEDULATO IMMEDIATAMENTE SE NON CI SARA' IL GIRO DI PROTOCOLLO GENERALE
				set @DPR_DOC_ID = 'ODA'
				set @DPR_ID = 'SEND_FORNITORE_FINALIZZA'

				SET @descrizione = @titolo + @protocolloInterno

				set @oggetto = 'Ordine di acquisto' 

				set @oggetto = @oggetto + ' - ' + @oggetto


			END			
			ELSE
			BEGIN

				set @bloccaProtocollo = 1

				--raiserror ('Documento non gestito', 16, 1)  --, CAST(@@ERROR AS NVARCHAR(4000)))
				--return 99

			END

			declare @AOO VARCHAR(100)

			-- SE IL DOCUMENTO E' IN USCITA, COME IDPFU DELL'ENTE USIAMO L'UTENTE COLLEGATO
			IF @modalita = 'U' and @stopIdPfuAOO = 0
			BEGIN
				SET @idPfuAOO = @IdUser
			END

			SET @AOO = dbo.getAOO(@idPfuAOO)

			-- SE NON HO GIÀ BLOCCATO IL PROTOCOLLO, ED IL FLAG DI TEST DEL FASCICOLO BASE E' ALZATO ED È RICHIESTA LA GESTIONE CON FASCICOLO ED ATTIVO IL FLUSSO PER LA SPECIFICA AOO
			IF @bloccaProtocollo <> 1
					and
				@testAssenzaFascicoloBase = 1
					and
				EXISTS( select id from Document_protocollo_docER with(nolock) where tipodoc = @tipoDoc and isnull(contesto,'') = @contesto and isnull(verificaFascicolo,1) = 1 and aoo = @AOO )
			BEGIN

				-------------------------------------------------------------------------------------------------
				-- SE IL FASCICOLO GENERALE NON E' PRESENTE SULLA GARA VUOL DIRE
				-- CHE LA GARA E' DI UN GIRO VECCHIO, PRECEDENTE ALL'ATTIVAZIONE DELLA PROTOCOLLAZIONE PER IL FLUSSO
				-- QUINDI NON PROTOCOLLO QUESTO DOCUMENTO 
				-------------------------------------------------------------------------------------------------

				set @fascicoloGenerale = ''

				IF @tipoDoc in ( 'COM_DPE_FORNITORE', 'COM_DPE_RISPOSTA','COM_DPE_ENTE','COM_DPE_RISPOSTA_ENTE')
				BEGIN
					select @fascicoloGenerale = isnull(fascicoloSecondario,'')
						from Document_Com_DPE with(nolock) where IdCom=@linkedDoc
				END
				ELSE
				BEGIN
					-- recupero il fascicolo dalla gara 
					select  @fascicoloGenerale = isnull(fascicoloSecondario,'')
						from ctl_doc doc with(nolock) 
								inner join Document_dati_protocollo prot with(nolock) ON prot.idheader = doc.id 
						where doc.id = @linkedDoc
				END
				IF @fascicoloGenerale = '' and  @tipoDoc not in ( 'COM_DPE_FORNITORE', 'COM_DPE_RISPOSTA','COM_DPE_ENTE','COM_DPE_RISPOSTA_ENTE')
				BEGIN
					select @fascicoloGenerale = isnull(FascicoloGenerale,'') from ctl_doc with(nolock) where id = @linkedDoc
				END

				IF @fascicoloGenerale = ''
				BEGIN
					set @bloccaProtocollo = 1
				END

			END


			-- SE NON E' GIA STATO RICHIESTO UN BLOCCO DELLA PROTOCOLLAZIONE ED ESISTE IL RECORD DI CONFIGURAZIONE PER IL FLUSSO IN ESAME ( CHIAVE TIPODOC+JUMPCHECK+SOTTOTIPO+CONTESTO+AOO )
			IF @bloccaProtocollo = 0 AND EXISTS( select id from Document_protocollo_docER with(nolock) where tipodoc = @tipoDoc and isnull(jumpCheck,'') = @jumpCheck and isnull(sottoTipo,'') = @sottoTipo and isnull(contesto,'') = @contesto and aoo = @AOO and attivo = 1 )
			BEGIN

				IF isnull(@oggetto,'') = ''
				BEGIN
					set @oggetto = 'Senza Titolo'
				END

				INSERT INTO v_protgen ( Modalita, Data_Documento, Oggetto, Tipo, Descrizione, Appl_Id_Evento, Flag_Annullato, Prot_Acquisito, Appl_Sigla, Mime_Type, idPfu, jumpCheck, sottoTipo )
							   VALUES ( @modalita, @dataDocumento, @oggetto, @tipo, @descrizione, @idDoc, 0, @avanzamentoProtocollo, @tipodoc, 'PDF', @IdUser, @jumpCheck, @sottoTipo  )

				IF @@ERROR <> 0 
				BEGIN
					raiserror ('Errore creazione inserimento record nella v_protgen.', 16, 1)  --, CAST(@@ERROR AS NVARCHAR(4000)))
					return 99
				END 

				set @idProtGen = SCOPE_IDENTITY()

				INSERT INTO V_protgen_dati ( IdHeader, DZT_Name, Value, data )
					VALUES ( @idProtGen, 'appl_id_evento', @idDoc , getDate() )

				INSERT INTO V_protgen_dati ( IdHeader, DZT_Name, Value, data )
					VALUES ( @idProtGen, 'modalita', @modalita , getDate() )

				INSERT INTO V_protgen_dati ( IdHeader, DZT_Name, Value, data )
					VALUES ( @idProtGen, 'Oggetto', dbo.striphtml(@oggetto) , getDate() )

				-- INSERISCO I VALORI CHIAVE UTILIZZATI PER ENTRARE SULLA 'DOCUMENT_PROTOCOLLO_DOCER', VERRANNO RECUPERATI E RIUSATI NELLA STORED SUCCESSIVA ( ProtGenCompletaInformazioni )
				INSERT INTO V_protgen_dati ( IdHeader, DZT_Name, Value, data )
					VALUES ( @idProtGen, 'TipoDoc', @tipodoc , getDate() )

				INSERT INTO V_protgen_dati ( IdHeader, DZT_Name, Value, data )
					VALUES ( @idProtGen, 'jumpCheck', @jumpCheck , getDate() )

				INSERT INTO V_protgen_dati ( IdHeader, DZT_Name, Value, data )
					VALUES ( @idProtGen, 'sottoTipo', @sottoTipo , getDate() )

				INSERT INTO V_protgen_dati ( IdHeader, DZT_Name, Value, data )
					VALUES ( @idProtGen, 'contesto', @contesto , getDate() )

				INSERT INTO v_protgen_dati( IdHeader, DZT_Name, Value, data )
					VALUES (@idProtGen, 'aoo', @AOO , getdate() )

				INSERT INTO v_protgen_dati( IdHeader, DZT_Name, Value, data )
					VALUES (@idProtGen, 'idPfuCompilatore', @idUtente , getdate() )

			END
			ELSE
			BEGIN

				-- SE E' RICHIESTA LA SCHEDULAZIONE DI UN PROCESSO DI FINALIZZA
				IF ISNULL(@DPR_DOC_ID,'') <> ''
				BEGIN
						INSERT INTO CTL_Schedule_Process ( IdDoc, IdUser, DPR_DOC_ID, DPR_ID  ) 
							VALUES ( @idDoc, @IdUser, @DPR_DOC_ID, @DPR_ID)					
				END

			END

		END

		IF @@ERROR <> 0 
		BEGIN
			raiserror ('Errore', 16, 1)  --, CAST(@@ERROR AS NVARCHAR(4000)))
			return 99
		END
		--ELSE
		--BEGIN
		--	select 'OK'
		--END

	END
	ELSE
	BEGIN
		SELECT 'SYS_ATTIVA_PROTOCOLLO_GENERALE non attiva'
	END

		
END			




GO
