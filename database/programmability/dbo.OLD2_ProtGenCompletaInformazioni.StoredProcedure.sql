USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_ProtGenCompletaInformazioni]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO












CREATE PROCEDURE [dbo].[OLD2_ProtGenCompletaInformazioni] ( @idVProtGen varchar(50) , @IdUser int , @tipoDoc varchar(500) )
AS
BEGIN

	-- l'avanzamento degli stati del record della v_protgen avviene nel processo che chiama questa stored

	-----------------------------------------------------------------------------------
	-- Stored di completamento informazioni prima della protocollazione finale	-------
	-----------------------------------------------------------------------------------

	SET NOCOUNT ON

	declare @idDoc int
	declare @idPfuDoc int
	declare @statoFunzionale varchar(500)
	declare @statoDoc varchar(1000)
	declare @linkedDoc INT

	declare @jumpCheck varchar(500)
	declare @sottoTipo varchar(500)
	declare @contesto varchar(200)

	declare @userIdAzi INT
	declare @contratto nvarchar(4000)
	declare @clausoleVessatorie nvarchar(4000)
	declare @allegatoFirmato nvarchar(4000)

	-- METADATI di DocER
	declare @AOO varchar(200)
	declare @DenomAOO varchar(1000)
	declare @repertorio varchar(500)
	declare @UO varchar(500)
	declare @DenomUO varchar(1000)
	declare @titolario varchar(500)			-- titolario recuperato dalla configurazione
	declare @fascicolo varchar(500)			-- fascicolo recuperato dalla configurazione.
	declare @fascicoloGenerale varchar(500) -- fascicolo generato o recuperato su un documento principale ( come il bando ) e che devono ereditare i documenti ad esso associato (come le istanze), o imputato dall'utente
	declare @titolarioGenerale varchar(500) -- titolario principale associato al fascicolo 
	declare @fascicoloSecondario varchar(500)
	declare @titolarioSecondario varchar(500)
	declare @algoritmo varchar(50)

	declare @documentAOO varchar(200)
	declare @documentDenomAOO varchar(1000)
	declare @documentRepertorio varchar(500)
	declare @documentUO varchar(500)
	declare @documentDenomUO varchar(1000)

	declare @idDocPrincipale int
	declare @ID_ALBO INT

	declare @idAziEnte int
	declare @idPfuUtenteEnte int
	declare @idPfuInCarico int

	declare @annoFascicolo varchar(100)

	declare @newid INT

	declare @esitoRichiestaFascicolo INT
	DECLARE @tipoDocCollegato varchar(500)

	declare @destUser INT
	declare @jumpcheckDocCollegati  varchar(500)

	SET @tipoDocCollegato = ''

	set @esitoRichiestaFascicolo = 0
	set @newid = -1
	set @statoFunzionale = ''
	set @statoDoc = ''

	set @jumpCheck = ''
	set @sottoTipo = ''
	set @contesto = ''

	set @idDoc = -1
	set @idPfuDoc = -1
	set @linkedDoc = -1
	set @idAziEnte = 0
	set @idPfuUtenteEnte = -1
	set @destUser = -1
	set @idPfuInCarico = -1

	set @fascicoloGenerale = NULL
	set @titolarioGenerale = NULL
	set @userIdAzi = 0
	set @aoo = null
	set @jumpcheckDocCollegati=''

	-- se è attivo il protocollo generale
	IF EXISTS( select id from lib_dictionary with(nolock) where dzt_name = 'SYS_ATTIVA_PROTOCOLLO_GENERALE' and dzt_valuedef = 'YES')
	BEGIN

		select @idDoc = Appl_id_evento
			from v_protgen with(nolock) where id = @idVProtGen

		--------------------------------------------------------------------------------------------------
		-- SETTO L'AOO PRENDENDOLA DALLA V_PROTGEN_DATI, INSERITA NELLA STORED [PROTGENINSERT] tramite dbo.getAOO( @idPfuAOO ) 
		--------------------------------------------------------------------------------------------------
		select @AOO = a.[Value] from v_protgen_dati a with(nolock) where a.IdHeader = @idVProtGen and a.DZT_Name = 'aoo'

		-- RECUPERO LE VARIABILI INSERITE NELLA STORED '[ProtGenInsert]' PER UTILIZZARLE COME CHIAVE DI ACCESSO ALLA CONFIGURAZIONE DEL PROTOCOLLO
		select @jumpCheck = a.[Value] from v_protgen_dati a with(nolock) where a.IdHeader = @idVProtGen and a.DZT_Name = 'jumpCheck'
		select @sottoTipo = a.[Value] from v_protgen_dati a with(nolock) where a.IdHeader = @idVProtGen and a.DZT_Name = 'sottoTipo'
		select @contesto = a.[Value] from v_protgen_dati a with(nolock) where a.IdHeader = @idVProtGen and a.DZT_Name = 'contesto'

		-- se stiamo su un chiarimento ( o una risp al chiarimento ) il documento non è imperniato sulla ctl_doc ma sulla document_chiarimenti
		IF  @tipoDoc <> 'COM_DPE_FORNITORE' and @tipoDoc <> 'COM_DPE_ENTE' and @tipoDoc <> 'CHIARIMENTI_PORTALE' and @tipoDoc <> 'DETAIL_CHIARIMENTI_BANDO'  and @tipoDoc not in ( 'OFFERTA_BT', 'OFFERTA_BE' )
		BEGIN

			select top 1 @idPfuDoc = idpfu,
					@allegatoFirmato = isnull(sign_attach,'')
				   ,@statoFunzionale = StatoFunzionale
				   ,@statoDoc = StatoDoc
				   ,@userIdAzi = Destinatario_azi
				   ,@destUser = Destinatario_User
				   ,@linkedDoc = LinkedDoc 
				   ,@idAziEnte = isnull(azienda,0)
				   ,@idPfuUtenteEnte = idpfu
				   ,@idPfuInCarico = idPfuInCharge
				from ctl_doc with(nolock) 
				where id = @idDoc

			-- Se l'azienda non è stata avvalorata perchè il documento configurato non lo prevedeva, la vado a recuperare a partire dall'idpfu
			IF @idAziEnte = 0
			BEGIN

				select @idAziEnte = pfu.pfuIdAzi 
					from profiliutente pfu with(nolock) 
					where pfu.idpfu = @idPfuUtenteEnte
				
			END

		END
		ELSE
		BEGIN

			IF @tipoDoc in ( 'OFFERTA_BT', 'OFFERTA_BE' )
			BEGIN

				SELECT  @idPfuDoc = idpfu,
						@allegatoFirmato = ''
					   ,@statoFunzionale = StatoFunzionale
					   ,@statoDoc = StatoDoc
					   ,@userIdAzi = Azienda
					   ,@destUser = Destinatario_User
					   ,@linkedDoc = LinkedDoc 
					   ,@idAziEnte = isnull(azienda,0)
					   ,@idPfuUtenteEnte = idpfu
					   ,@idPfuInCarico = idPfuInCharge
					   ,@idDocPrincipale = c.id
				FROM Document_MicroLotti_Dettagli d with(nolock)
						inner join ctl_doc c with(nolock) ON c.Id = d.IdHeader and c.TipoDoc = 'OFFERTA'
				where d.id = @idDoc


			END

			IF @tipoDoc in ('COM_DPE_FORNITORE')
			BEGIN
				
				SELECT  @idPfuDoc = idpfu,
						@allegatoFirmato = ''
					   ,@statoFunzionale = StatoComFor
					   ,@statoDoc = StatoComFor
					   ,@userIdAzi = d.IdAzi
					   ,@destUser = 0
					   ,@linkedDoc = d.IdCom 
					   ,@idAziEnte = isnull(P.pfuIdAzi,0)
					   ,@idPfuUtenteEnte = idpfu
					   ,@idPfuInCarico = idpfu
					   ,@idDocPrincipale = d.IdCom					   
				FROM Document_Com_DPE_Fornitori d with(nolock)
						inner join Document_Com_DPE  c with(nolock) ON c.IdCom  = d.IdCom 
						inner join ProfiliUtente P with(nolock) on P.IdPfu=c.Owner
				where d.IdComFor  = @idDoc
			END

			IF @tipoDoc in ('COM_DPE_ENTE')
			BEGIN
				
				SELECT  @idPfuDoc = idpfu,
						@allegatoFirmato = ''
					   ,@statoFunzionale = StatoComFor
					   ,@statoDoc = StatoComFor
					   ,@userIdAzi = d.IdAzi
					   ,@destUser = 0
					   ,@linkedDoc = d.IdCom 
					   ,@idAziEnte = isnull(P.pfuIdAzi,0)
					   ,@idPfuUtenteEnte = idpfu
					   ,@idPfuInCarico = idpfu
					   ,@idDocPrincipale = d.IdCom					   
				FROM Document_Com_DPE_Enti d with(nolock)
						inner join Document_Com_DPE  c with(nolock) ON c.IdCom  = d.IdCom 
						inner join ProfiliUtente P with(nolock) on P.IdPfu=c.Owner
				where d.IdComEnte  = @idDoc
			END

		END
		
		IF @tipoDoc = 'CONTRATTO_CONVENZIONE'
		BEGIN

			declare @f23 nvarchar(4000)
			DECLARE @idContrattoOriginale INT
			DECLARE @idTmpVprotgen INT
			DECLARE @idUnitaDoc varchar(100)


			--PER IL GIRO DI STIPULA FORMA PUBB= SI arrivo con l'id delle conveznione non id del contratto_convenzione visto che non esiste
			if exists ( select ID from CTL_DOC with(nolock) where Id=@idDoc AND TipoDoc='CONVENZIONE' )
			BEGIN
				set @idAziEnte = -1
				select
					@userIdAzi=AZI_Dest,
					@destUser=ReferenteFornitore
				from Document_Convenzione with(nolock) where Id=@idDoc

				delete from ctl_doc_value where dse_id = 'ALLEGATI_PROTOCOLLO' and idHeader = @idDoc

					-- Recupero gli allegati da passare per la convenzione
				select top 1 
						@contratto = isnull(F2_SIGN_ATTACH,'') ,		--contratto allegato su convenzione
						@clausoleVessatorie = isnull(F1_SIGN_ATTACH,'')	--clausola  allegato su convenzione
					from CTL_DOC_SIGN with(nolock) where idHeader = @idDoc

				select top 1 @f23 = isnull(F3_SIGN_ATTACH, '')
					from CTL_DOC_SIGN with(nolock) where idHeader = @idDoc

				--documento principale
				insert ctl_doc_value ( idHeader, dse_id,[row],[dzt_name],Value )
					VALUES (@idDoc, 'ALLEGATI_PROTOCOLLO',0, 'Allegato', @contratto)
				
				--documento allegato
				insert ctl_doc_value ( idHeader, dse_id,[row],[dzt_name],Value )
					VALUES (@idDoc, 'ALLEGATI_PROTOCOLLO',1, 'Allegato', @clausoleVessatorie)

				--secondo documento allegato, l'f23 (opzionale)
				IF @f23 <> ''
				BEGIN

					INSERT ctl_doc_value ( idHeader, dse_id,[row],[dzt_name],Value )
						VALUES (@idDoc, 'ALLEGATI_PROTOCOLLO',2, 'Allegato', @f23)

				END

				-- AGGIUNGO IL LISTINO COME ALLEGATO DEL CONTRATTO
				insert ctl_doc_value ( idHeader, dse_id,[row],[dzt_name],Value )
					select @idDoc, 'ALLEGATI_PROTOCOLLO',3, 'Allegato', lst.SIGN_ATTACH
						from CTL_DOC lst with(nolock)								
						where lst.LinkedDoc = @idDoc AND lst.TipoDoc = 'LISTINO_CONVENZIONE'
				
				-- AGGIUNGO SE ESISTE IL LISTINO ORDINI ASSOCIATO ALLA CONVENZIONE
				insert ctl_doc_value ( idHeader, dse_id,[row],[dzt_name],Value )
					select @idDoc, 'ALLEGATI_PROTOCOLLO',4, 'Allegato', lst_o.SIGN_ATTACH
						from CTL_DOC lst_o with(nolock)	
								inner join document_convenzione DC with (nolock) on DC.id = @idDoc and isnull(DC.PresenzaListinoOrdini,'') ='si'
						where lst_o.LinkedDoc = @idDoc AND lst_o.TipoDoc = 'LISTINO_ORDINI_OE' and lst_o.Deleted = 0 and lst_o.StatoFunzionale = 'Confermato'


				-- IL FASCICOLO SECONDARIO E' IMPUTATO DALL'UTENTE SULLA CONVENZIONE MENTRE IL PRINCIPALE è GENERATO IN AUTOMATICO annualmente ED ASSOCIATO
				-- la gestione del fascicolo annuo è implicita nell'algoritmo F005

				-- recupero il fascicolo di iniziativa. imputato sulla convenzione per agganciare tutto il flusso della convenzione 
				-- con questo fascicolo ( che dovrebbe corrispondere ad una gara fatta extrapiattaforma che è sfociata in una convenzione)
				select @fascicoloSecondario = a.fascicoloSecondario 
					from Document_dati_protocollo a with(nolock) where idheader = @idDoc


				---------------------------------------------------------------------------------------------------------------------------
				---- AGGIUNGO I NUOVI METADATI DA PASSARE ALLA CREATEDOCUMENT PER PERMETTERE IL SUCCESSIVO PASSAGGIO ALLA CONSERVAZIONE ---
				---		(METADATI CUSTOM DELL'RSPIC) 
				---------------------------------------------------------------------------------------------------------------------------

					-- Ragione Sociale (MS_C_FISC) e Codice Fiscale (MS_CF_PIVA_BENEF) del Contraente verranno recuperato dalla dll al momento dell'invio a docer tramite
					--	il campo idazi già presente nella v_protgen_dati

				-- Oggetto del Contratto
				INSERT INTO v_protgen_dati ( IdHeader, DZT_Name, Value, data )
					select top 1 @idVProtGen, 'MS_DESC_FORNITORE', isnull(DescrizioneEstesa,'Senza Descrizione'), getdate() 
						from Document_Convenzione with(nolock)
					where id = @idDoc

				-- Valore del Contratto
				INSERT INTO v_protgen_dati ( IdHeader, DZT_Name, Value, data )
					select top 1 @idVProtGen, 'NUMERO_BU', dbo.FormatMoney( isnull(total,0)), getdate() 
						from Document_Convenzione with(nolock)
					where id = @idDoc

				-- SE CI TROVIAMO SU ' Integrazione Convenzione'. 
				-- cioè se la convenzione collegata ha jumpcheck INTEGRAZIONE
				IF EXISTS ( select id from ctl_doc with(nolock) where id = @idDoc and JumpCheck = 'INTEGRAZIONE' )
				BEGIN

					
					SET @idContrattoOriginale = -1

					-- RECUPERO L'IDDOC DEL DOCUMENTO CONTRATTO 'ORIGINALE'
					select top 1 @idContrattoOriginale = ISNULL(contratto.id,conv.id)
							from ctl_doc integr with(nolock)								
								INNER JOIN ctl_doc conv with(nolock) ON Integr.LinkedDoc = conv.id
								LEFT JOIN ctl_doc contratto with(nolock) ON contratto.linkeddoc = conv.id and contratto.tipoDoc = 'CONTRATTO_CONVENZIONE' and contratto.deleted = 0 and contratto.JumpCheck <> 'INTEGRAZIONE' and contratto.statofunzionale = 'Confermato'
					where integr.id = @idDoc

					IF @idContrattoOriginale <> -1
					BEGIN

						

						SET @idTmpVprotgen = -1

						select @idTmpVprotgen = id from v_protgen with(nolock) where Appl_Id_Evento = @idContrattoOriginale and Flag_Annullato = 0 and Prot_Acquisito = 6

						IF @idTmpVprotgen <> -1
						BEGIN

							
							set @idUnitaDoc = ''

							select top 1 @idUnitaDoc = Value from v_protgen_dati with(nolock) where idheader = @idTmpVprotgen and DZT_Name = 'LOG_ID_UNITA_DOCUMENT' order by data desc

							INSERT INTO v_protgen_dati ( IdHeader, DZT_Name, Value, data )
											VALUES ( @idVProtGen, 'idDocLink', @idUnitaDoc, getdate() )

						END

					END

				END	-- chiusura if per integrazione contratto

			END
			ELSE
			BEGIN
				set @idAziEnte = -1				

				delete from ctl_doc_value where dse_id = 'ALLEGATI_PROTOCOLLO' and idHeader = @idDoc

				-- Recupero gli allegati da passare per la convenzione
				select top 1 @contratto = isnull(F3_SIGN_ATTACH,'') ,			--contratto controfirmato dal fornitore
							 @clausoleVessatorie = isnull(F4_SIGN_ATTACH,'')	--clausola  controfirmata dal fornitore
					  from CTL_DOC_SIGN with(nolock) where idHeader = @idDoc
				  
				-- NON E' CORRETTO BLOCCARE IN QUESTO PUNTO DEL FLUSSO DI PROTOCOLLAZIONE. IL BLOCCO E' GIA PRESENTE NEL PROCESSO 
				--IF @contratto = '' or @clausoleVessatorie = ''
				--BEGIN
				--	raiserror ('Errore completamento dati per tipoDoc ''contratto_convenzione'' %s - Contratto e/o clausola vessatoria mancante', 16, 1 , @idDoc )
				--	return 99
				--END

				select top 1 @f23 = isnull(F3_SIGN_ATTACH, '')
					from CTL_DOC_SIGN with(nolock) where idHeader = @linkedDoc

				--documento principale
				insert ctl_doc_value ( idHeader, dse_id,[row],[dzt_name],Value )
					VALUES (@idDoc, 'ALLEGATI_PROTOCOLLO',0, 'Allegato', @contratto)
			
				--documento allegato
				insert ctl_doc_value ( idHeader, dse_id,[row],[dzt_name],Value )
					VALUES (@idDoc, 'ALLEGATI_PROTOCOLLO',1, 'Allegato', @clausoleVessatorie)

				--secondo documento allegato, l'f23 (opzionale)
				IF @f23 <> ''
				BEGIN

					INSERT ctl_doc_value ( idHeader, dse_id,[row],[dzt_name],Value )
						VALUES (@idDoc, 'ALLEGATI_PROTOCOLLO',2, 'Allegato', @f23)

				END

				-- AGGIUNGO IL LISTINO COME ALLEGATO DEL CONTRATTO
				insert ctl_doc_value ( idHeader, dse_id,[row],[dzt_name],Value )
					select @idDoc, 'ALLEGATI_PROTOCOLLO',3, 'Allegato', lst.SIGN_ATTACH
						from CTL_DOC cont with(nolock)
								inner join CTL_DOC lst with(nolock) on lst.LinkedDoc = cont.LinkedDoc and lst.TipoDoc = 'LISTINO_CONVENZIONE'
						where cont.Id = @idDoc and cont.TipoDoc = 'CONTRATTO_CONVENZIONE'


				-- inserisce l'ulteriore allegato se eventualmente inserito dall'OE
				insert ctl_doc_value ( idHeader, dse_id,[row],[dzt_name], [Value] )
					select @idDoc, 'ALLEGATI_PROTOCOLLO',4, 'Allegato', a.[Value]
						from ctl_doc_value a with(nolock)
						where a.IdHeader = @idDoc and a.DSE_ID = 'NOTE' and a.DZT_Name = 'Allegato'
				
				-- AGGIUNGO SE ESISTE IL LISTINO ORDINI ASSOCIATO ALLA CONVENZIONE
				insert ctl_doc_value ( idHeader, dse_id,[row],[dzt_name],Value )
					select @idDoc, 'ALLEGATI_PROTOCOLLO',5, 'Allegato', lst_o.SIGN_ATTACH
						from CTL_DOC cont with(nolock)
							inner join document_convenzione DC with (nolock) on DC.id = cont.LinkedDoc and isnull(DC.PresenzaListinoOrdini,'') ='si'
							inner join CTL_DOC lst_o with(nolock) on lst_o.LinkedDoc = cont.LinkedDoc and lst_o.TipoDoc = 'LISTINO_ORDINI_OE' and lst_o.Deleted = 0 and lst_o.StatoFunzionale = 'Confermato'
						where cont.Id = @idDoc and cont.TipoDoc = 'CONTRATTO_CONVENZIONE'
				-- IL FASCICOLO SECONDARIO E' IMPUTATO DALL'UTENTE SULLA CONVENZIONE MENTRE IL PRINCIPALE è GENERATO IN AUTOMATICO annualmente ED ASSOCIATO
				-- la gestione del fascicolo annuo è implicita nell'algoritmo F005

				-- recupero il fascicolo di iniziativa. imputato sulla convenzione per agganciare tutto il flusso della convenzione 
				-- con questo fascicolo ( che dovrebbe corrispondere ad una gara fatta extrapiattaforma che è sfociata in una convenzione)
				select @fascicoloSecondario = a.fascicoloSecondario 
					from Document_dati_protocollo a with(nolock) where idheader = @linkedDoc


				---------------------------------------------------------------------------------------------------------------------------
				---- AGGIUNGO I NUOVI METADATI DA PASSARE ALLA CREATEDOCUMENT PER PERMETTERE IL SUCCESSIVO PASSAGGIO ALLA CONSERVAZIONE ---
				---		(METADATI CUSTOM DELL'RSPIC) 
				---------------------------------------------------------------------------------------------------------------------------

					-- Ragione Sociale (MS_C_FISC) e Codice Fiscale (MS_CF_PIVA_BENEF) del Contraente verranno recuperato dalla dll al momento dell'invio a docer tramite
					--	il campo idazi già presente nella v_protgen_dati

				-- Oggetto del Contratto
				INSERT INTO v_protgen_dati ( IdHeader, DZT_Name, Value, data )
						select top 1 @idVProtGen, 'MS_DESC_FORNITORE', isnull(DescrizioneEstesa,'Senza Descrizione'), getdate() 
						from Document_Convenzione with(nolock)
						where id = @idDoc

				-- Valore del Contratto
				INSERT INTO v_protgen_dati ( IdHeader, DZT_Name, Value, data )
						select top 1 @idVProtGen, 'NUMERO_BU', dbo.FormatMoney( isnull(total,0)), getdate() 
						from Document_Convenzione with(nolock)
						where id = @idDoc

				-- SE CI TROVIAMO SU 'Contratto Integrazione Convenzione'. cioè un contratto effettuato su un Integrazione Convenzione
				-- cioè se la convenzione collegata ha jumpcheck INTEGRAZIONE
				IF EXISTS ( select id from ctl_doc with(nolock) where id = @linkedDoc and JumpCheck = 'INTEGRAZIONE' )
				BEGIN

					
					SET @idContrattoOriginale = -1

					-- RECUPERO L'IDDOC DEL DOCUMENTO CONTRATTO 'ORIGINALE'
					select top 1 @idContrattoOriginale = contratto.id
							from ctl_doc integr with(nolock)
								INNER JOIN ctl_doc convIntegr with(nolock) ON integr.linkeddoc = convIntegr.id
								INNER JOIN ctl_doc conv with(nolock) ON convIntegr.LinkedDoc = conv.id
								INNER JOIN ctl_doc contratto with(nolock) ON contratto.linkeddoc = conv.id and contratto.tipoDoc = 'CONTRATTO_CONVENZIONE' and contratto.deleted = 0 and contratto.JumpCheck <> 'INTEGRAZIONE' and contratto.statofunzionale = 'Confermato'
					where integr.id = @idDoc

					IF @idContrattoOriginale <> -1
					BEGIN

						

						SET @idTmpVprotgen = -1

						select @idTmpVprotgen = id from v_protgen with(nolock) where Appl_Id_Evento = @idContrattoOriginale and Flag_Annullato = 0 and Prot_Acquisito = 6

						IF @idTmpVprotgen <> -1
						BEGIN

							
							set @idUnitaDoc = ''

							select top 1 @idUnitaDoc = Value from v_protgen_dati with(nolock) where idheader = @idTmpVprotgen and DZT_Name = 'LOG_ID_UNITA_DOCUMENT' order by data desc

							INSERT INTO v_protgen_dati ( IdHeader, DZT_Name, Value, data )
											VALUES ( @idVProtGen, 'idDocLink', @idUnitaDoc, getdate() )

						END

					END

				END	-- chiusura if per integrazione contratto

			END -- chiusura if per verifica se stipula forma pub=SI
		END
		ELSE IF @tipoDoc = 'LISTINO_CONVENZIONE'
		BEGIN

			set @idAziEnte = -1

			insert ctl_doc_value ( idHeader, dse_id,[row],[dzt_name],Value )
				VALUES (@idDoc, 'ALLEGATI_PROTOCOLLO',0, 'Allegato', @allegatoFirmato)

			--- Recupero il fascicolo da utilizzare dalla CONVENZIONE
			select @fascicoloGenerale = a.fascicoloSecondario,
				    @titolarioGenerale = titolarioPrimario 
				from Document_dati_protocollo a with(nolock) where idheader = @linkedDoc

		END
		ELSE IF @tipoDoc = 'ESITO_CONTROLLI_OE'
		BEGIN

			set @idAziEnte = -1

			insert ctl_doc_value ( idHeader, dse_id,[row],[dzt_name],Value )
				VALUES (@idDoc, 'ALLEGATI_PROTOCOLLO',0, 'Allegato', @allegatoFirmato)

			--------------------------
			-- RECUPERO IL MITTENTE --
			--------------------------
			SELECT top 1 @userIdAzi = azi.idAzi
				FROM ctl_doc doc with(nolock)
						INNER JOIN profiliutente pfu with(nolock) ON doc.idpfu = pfu.idpfu
						INNER JOIN aziende azi with(nolock) ON pfu.pfuIdAzi = azi.IdAzi 
				WHERE doc.id = @idDoc 


			select  @fascicoloGenerale=fascicolosecondario
					from CTL_DOC C with(nolock)  --ESITO_CONTROLLI
						inner join CTL_DOC D with(nolock) on D.Id=C.LinkedDoc  --CONTROLLI_OE
						inner join CTL_DOC F with(nolock) on F.Id=D.LinkedDoc  --CONTROLLI_OE CAPPELLO
						inner join Document_dati_protocollo prot with(nolock) ON prot.idheader = F.LinkedDoc
					where C.Id=@idDoc

		END
		ELSE IF @tipoDoc IN ( 'ODC-ACCETTATO' , 'ODC-RIFIUTATO' ) -- Conferma Ordinativo di fornitura ( ACCETTA ) e  Conferma Ordinativo di fornitura ( ACCETTA )
		BEGIN

			set @idAziEnte = -1

			-- nel linkeddoc degli ODC c'è la CONVENZIONE

			------------------------------------------------------------------------------------------
			-- IL FASCICOLO DA UTILIZZARE E' QUELLO IMPUTATO SULL'ODC. non + quello dell'ordinativo --
			------------------------------------------------------------------------------------------
			--select @fascicoloGenerale = a.fascicoloSecondario 
			--	from Document_dati_protocollo a with(nolock) where idheader = @idDoc

			select @fascicoloGenerale = a.FascicoloGenerale from ctl_doc a with(nolock) where a.id = @idDoc

			-- L'allegato principale è il pdf della custom con la filigrana 'accettato' o 'rifiutato' e viene generato prima di arrivare nella stored
			set @allegatoFirmato = null

			--------------------------
			-- RECUPERO IL MITTENTE --
			--------------------------
			SELECT top 1 @userIdAzi = doc.Destinatario_Azi
				FROM ctl_doc doc with(nolock)
						--INNER JOIN profiliutente pfu with(nolock) ON doc.idpfu = pfu.idpfu
						--INNER JOIN aziende azi with(nolock) ON pfu.pfuIdAzi = azi.IdAzi 
				WHERE doc.id = @idDoc 


			---------------------
			-- Avendo un conflitto di ID tra ODC, per non prendere gli stessi allegati dell'ODC inviato al fornitore.
			-- Inserisco un discriminante 
			----------------------
			INSERT INTO v_protgen_dati( IdHeader, DZT_Name, Value, data )
							VALUES (@idVProtGen, 'allegatoProtocollo', 'Allegato_ODC' , getdate() )

		END
		ELSE IF @tipoDoc = 'ODC'  -- Ordinativo di fornitura ( SEND_FORNITORE )
		BEGIN

			set @idAziEnte = -1

			-- nel linkeddoc degli ODC c'è la CONVENZIONE

			-- il fascicolo secondario è quello imputato sull'odc ( NON E' QUELLO DELLA CONVENZIONE! )
			select @fascicoloSecondario = a.fascicoloSecondario 
				from Document_dati_protocollo a with(nolock) where idheader = @idDoc

			IF @fascicoloGenerale = ''
			BEGIN
				raiserror ('Errore completamento dati per tipoDoc ''ODC'' ID %s - Fascicolo generale mancante', 16, 1 , @idDoc )
				return 99
			END

			DECLARE @oggettoDelContratto nvarchar(4000)
			DECLARE @ValoreDelContratto nvarchar(500)
			
			DECLARE @AOO_FascicoloSecondario varchar(100)

			-----------------------------------------
			-- RECUPERO IL DESTINATARIO DELL'ODC ----
			-----------------------------------------

			SELECT top 1 @userIdAzi = c.AZI_Dest,
						 @oggettoDelContratto = ct.Note,
						 @ValoreDelContratto = dbo.FormatMoney(o.RDA_Total)
						 --,@AOO_FascicoloSecondario = dbo.getAOO(c.Compilatore )
				FROM ctl_doc CT with(nolock)
						inner join Document_ODC o with(nolock) on CT.ID=O.RDA_ID
						inner join Document_convenzione c with(nolock) on c.id = o.id_convenzione
				WHERE CT.id = @idDoc 

			insert ctl_doc_value ( idHeader, dse_id,[row],[dzt_name],Value )
				VALUES (@idDoc, 'ALLEGATI_PROTOCOLLO',0, 'Allegato', @allegatoFirmato)

			insert ctl_doc_value ( idHeader, dse_id,[row],[dzt_name],Value )
					select @idDoc,'ALLEGATI_PROTOCOLLO',0, 'Allegato', Allegato
					from CTL_DOC_ALLEGATI with(nolock) where idHeader = @idDoc and isnull(Allegato,'') <> ''

			--------> E' STATO COMMENTATO IL RECUPERO DELL'AOO FASCICOLO SECONDARIO DALLA CONVENZIONE QUINDI QUESTO PEZZO DI SQL NON VERRA' FATTO
			-------			. E' STATO FATTO COSì PERCHE IL FASCICOLO SECONDARIO NON VIENE RECUPERATO DALLA CONVENZIONE, DALL'ODC CORRENTE

			-- SE PRESENTE AOO E FASCICOLO SECONDATIO INSERISCO NELLA V_PROTGEN_DATI L'AOO DELL'UTENTE CHE HA CREATO LA CONVENZIONE
			-- PER PERMETTERE ALL'INTEGRAZIONE DI "NON" FARE LA DOPPIA FASCICOLAZIONE NEL CASO IN CUI L'AOO DELL'ODC E L'AOO DELLA CONVENZIONE SONO DIVERSE
			IF isnull(@AOO_FascicoloSecondario,'') <> '' and isnull( @fascicoloSecondario,'' ) <> ''
			BEGIN

				INSERT INTO v_protgen_dati ( IdHeader, DZT_Name, Value, data )
								values ( @idVProtGen, 'AOO_FASCICOLO_SECONDARIO',  @AOO_FascicoloSecondario, getdate() )

			END

			---------------------------------------------------------------------------------------------------------------------------
			---- AGGIUNGO I NUOVI METADATI DA PASSARE ALLA CREATEDOCUMENT PER PERMETTERE IL SUCCESSIVO PASSAGGIO ALLA CONSERVAZIONE ---
			---		(METADATI CUSTOM DELL'RSPIC) 
			---------------------------------------------------------------------------------------------------------------------------

				-- Ragione Sociale (MS_C_FISC) e Codice Fiscale (MS_CF_PIVA_BENEF) del Contraente verranno recuperato dalla dll al momento dell'invio a docer tramite
				--	il campo idazi già presente nella v_protgen_dati

			-- Oggetto del Contratto
			INSERT INTO v_protgen_dati ( IdHeader, DZT_Name, Value, data )
								values ( @idVProtGen, 'MS_DESC_FORNITORE',  isnull(@oggettoDelContratto,'Senza Descrizione'), getdate() )

			-- Valore del Contratto
			INSERT INTO v_protgen_dati ( IdHeader, DZT_Name, Value, data )
							    values ( @idVProtGen, 'NUMERO_BU', @ValoreDelContratto, getdate() )
								


		END
		ELSE IF @tipoDoc = 'ANNULLA_ORDINATIVO'
		BEGIN

			-------------------------------
			--- ANNULLAMENTO ODF ----------
			-------------------------------

			set @idAziEnte = -1

			-- nel linkeddoc degli dell'annullamento odf c'è l'odc

			--- Recupero il fascicolo da utilizzare dall'ODC

			select @fascicoloGenerale = a.fascicoloSecondario 
				from Document_dati_protocollo a with(nolock) where idheader = @linkedDoc


			IF @fascicoloGenerale = ''
			BEGIN
				raiserror ('Errore completamento dati per tipoDoc ''ANNULLA_ORDINATIVO'' ID %s - Fascicolo generale mancante', 16, 1 , @idDoc )
				return 99
			END

			--------------------------------------------------------
			-- RECUPERO IL DESTINATARIO DELL'ANNULLA_ORDINATIVO ----
			--------------------------------------------------------
			SELECT top 1 @userIdAzi = c.AZI_Dest 
				FROM ctl_doc a with(nolock)
						inner join ctl_doc CT with(nolock) ON A.linkeddoc = ct.id
						inner join Document_ODC o with(nolock) on CT.ID=O.RDA_ID
						inner join Document_convenzione c with(nolock) on c.id = o.id_convenzione
				WHERE a.id = @idDoc 

			insert ctl_doc_value ( idHeader, dse_id,[row],[dzt_name],Value )
				VALUES (@idDoc, 'ALLEGATI_PROTOCOLLO',0, 'Allegato', @allegatoFirmato)

		END
		ELSE IF @tipoDoc in ('VERIFICA_REGISTRAZIONE_FORN','VERIFICA_REGISTRAZIONE', 'VERIFICA_REGISTRAZIONE_ACCETTA')
		BEGIN

			IF @tipoDoc in ('VERIFICA_REGISTRAZIONE_FORN','VERIFICA_REGISTRAZIONE' )
			BEGIN
				-- il mittente diventa la colonna azienda
				SET @userIdAzi = @idAziEnte
				set @idAziEnte = -1
			END
			ELSE
			BEGIN

				--VERIFICA_REGISTRAZIONE_ACCETTA
				select @userIdAzi =  pfuIdAzi
					from profiliutente with(nolock) where idpfu = @idPfuInCarico

			END

			insert ctl_doc_value ( idHeader, dse_id,[row],[dzt_name],Value )
				VALUES (@idDoc, 'ALLEGATI_PROTOCOLLO',0, 'Allegato', @allegatoFirmato)
				
			insert ctl_doc_value ( idHeader, dse_id,[row],[dzt_name],Value )
				select @idDoc,'ALLEGATI_PROTOCOLLO',idRow, 'Allegato', Allegato
				from CTL_DOC_ALLEGATI with(nolock) where idHeader = @idDoc and isnull(Allegato,'') <> ''

			------------------------------------------------------------------------------------------------------------
			-- RECUPERO IL FASCICOLO UTILIZZATO PER LE REGISTRAZIONI PER L'ANNO CORRENTE DALLA TABELLA DEI FASCICOLI ---
			------------------------------------------------------------------------------------------------------------

			set @fascicoloGenerale = ''
			select top 1 @fascicoloGenerale = isnull(fascicoloNuovo,'')
				from v_protgen_fascicoli with(nolock) 
				where deleted = 0 and tipoDoc = 'REGISTRAZIONI' and dbo.GetColumnValue ( isnull(fascicoloNuovo,''), '.', 1 ) = year(getdate()) and isnull(aoo,'') = isnull(@AOO,'')
				order by id desc

			-- Verifo se per questo documento è richiesta la gestione del fascicolo annuale
			exec ProtGenRichiediFascicoloAnnuo @idVProtGen , @IdUser , @tipoDoc , @linkedDoc , @fascicoloGenerale , 'REGISTRAZIONI' , '', '', @AOO, @esitoRichiestaFascicolo output

			IF @esitoRichiestaFascicolo = 1
			BEGIN
				return 0
			END


		END
		ELSE IF @tipoDoc = 'PDA_COMUNICAZIONE_GARA'
		BEGIN
			
			declare @idComunicazioneGenerica INT

			-- Il file allegato della comunicazione
			-- è stato inserito prima dell'invocazione di questa stored dalla clsDownloader
			-- ( è una stampa base pdf )

			set @idDocPrincipale = -1

			IF EXISTS ( Select id from ctl_doc with(nolock) where id = @idDoc and jumpcheck like '%-COMUNICAZIONE_FORNITORE_CONVENZIONE' )				
			begin
					
				select 	@idDocPrincipale = b.id ,
						@idAziEnte = a.Azienda ,
						@tipoDocCollegato = b.TipoDoc
						from ctl_doc a	with(nolock)				     							--pda_comunicazione_gara
								inner join ctl_doc b with(nolock)    ON b.id = a.linkeddoc			--CONVENZIONE							
						where a.id = @idDoc

				select @fascicoloSecondario = a.fascicoloSecondario 
					from Document_dati_protocollo a with(nolock) 
					where idheader = @idDocPrincipale


			end
			else
			begin

				select 	@idDocPrincipale = case when bando.TipoDoc = 'PDA_MICROLOTTI' then bando2.id
													 else bando.id
												end 

						,@idAziEnte = case when bando.TipoDoc = 'PDA_MICROLOTTI' then isnull(bando2.azienda,-1)
													 else isnull(bando.azienda,-1)
												end 

						,@idPfuUtenteEnte = case when bando.TipoDoc = 'PDA_MICROLOTTI' then bando2.idpfu
													 else bando.idpfu
												end 

						,@idComunicazioneGenerica = b.Id

						,@tipoDocCollegato = case when bando.TipoDoc = 'PDA_MICROLOTTI' then bando2.TipoDoc 
													 else bando.TipoDoc
												 end 

					from ctl_doc a with(nolock)		     											-- pda_comunicazione_gara
							inner join ctl_doc b with(nolock)    ON b.id = a.linkeddoc				-- PDA_COMUNICAZIONE_GENERICA (oppure il documento che ha generato la comunicazione)
							inner join ctl_doc bando with(nolock) ON bando.id = b.linkeddoc			-- BANDO o PDA
							left join  ctl_doc bando2 with(nolock) ON bando2.id = bando.linkeddoc   -- livello 2 se l'alias bando corrisponde con una PDA e non con un bando
					where a.id = @idDoc
			end

			-- recupero il fascicolo dal bando_gara
			select   @fascicoloGenerale = isnull(fascicoloSecondario,'')
				from Document_dati_protocollo with(nolock) where idHeader = @idDocPrincipale

			IF @fascicoloGenerale = ''
			BEGIN

				select @fascicoloGenerale = isnull(FascicoloGenerale,'')
					from ctl_doc with(nolock) where id = @idDocPrincipale

			END

			------------------------------------------------------------------------
			-- AGGIUNGO SOLO GLI ALLEGATI PRESENTI SULLA SINGOLA COMUNICAZIONE  ----
			-- PERCHÈ È IL DOCUMENTO DI SINGOLA COMUNICAZIONE AD ESSERE INVIATO ----
			-- AL FORNITORE. E QUELLO, COSÌ COM'È DEVE ESSERE PROTOCOLLATO.     ----
			-- SE CI SONO ALLEGATI SUL PADRE CHE NON VENGONO RIPORTATI PER ERRORE --
			-- SUL FIGLIO BISOGNA CORREGGERE LA CONFIGURAZIONE E NON RECUPERARLI  --
			-- DA QUI PER ESSERE MANDATI AL PROTOCOLLO. NON È 'LEGALMENTE'        --
			-- CORRETTO															  --
			------------------------------------------------------------------------
			--PER LE COMUNICAZIONi PDA_COMUNICAZIONE_GARA con jumpcheck RICHIESTA_STIPULA_CONTRATTO
			--se il parametro lo richiede allegato principale  diventa quello allegato sul documento
			IF EXISTS ( Select id from ctl_doc with(nolock) where id = @idDoc and jumpcheck like '%-RICHIESTA_STIPULA_CONTRATTO' 
						and dbo.PARAMETRI('COMUNICAZIONE_RICHIESTA_STIPULA_CONTRATTO','AREA_FIRMA','ATTIVA','NO',-1) = 'YES' )
			BEGIN
				insert ctl_doc_value ( idHeader, dse_id,[row],[dzt_name],Value )
					select @idDoc,'ALLEGATI_PROTOCOLLO',0, 'Allegato', SIGN_ATTACH
					from CTL_DOC with(nolock) where id = @idDoc and isnull(SIGN_ATTACH,'')<>''
			END

			insert ctl_doc_value ( idHeader, dse_id,[row],[dzt_name],Value )
					select @idDoc,'ALLEGATI_PROTOCOLLO',0, 'Allegato', Allegato
					from CTL_DOC_ALLEGATI with(nolock) where idHeader = @idDoc and isnull(Allegato,'') <> ''

			IF EXISTS ( Select id from ctl_doc with(nolock) where id = @idDoc and jumpcheck like '%-ESCLUSIONE' )
			BEGIN

				select @idDocPrincipale = gara.id
					   ,@idAziEnte = isnull(gara.azienda,-1)
					   ,@idPfuUtenteEnte = gara.idpfu
					   ,@idComunicazioneGenerica = b.Id 
					from ctl_doc a with(nolock)					     						--pda_comunicazione_gara
							inner join ctl_doc b with(nolock)     ON b.id = a.linkeddoc		--PDA_COMUNICAZIONE_GENERICA (oppure il documento che ha generato la comunicazione)
							inner join ctl_doc pda with(nolock) ON pda.id = b.linkeddoc	    --PDA_MICROLOTTI
							inner join ctl_doc gara with(nolock) ON gara.id = pda.linkeddoc  --GARA
					where a.id = @idDoc

				-- recupero il fascicolo 
				select   @fascicoloGenerale = isnull(fascicoloSecondario,'')
					from Document_dati_protocollo with(nolock) where idHeader = @idDocPrincipale

				IF @fascicoloGenerale = ''
				BEGIN

					select @fascicoloGenerale = isnull(FascicoloGenerale,'')
						from ctl_doc with(nolock) where id = @idDocPrincipale

				END

			END
			ELSE IF EXISTS ( Select id from ctl_doc with(nolock) where id = @idDoc and jumpcheck like '%-ESCLUSIONE_MANIFESTAZIONE' )
			BEGIN

				select @idDocPrincipale = gara.id
					   ,@idAziEnte = isnull(gara.azienda,-1)
					   ,@idPfuUtenteEnte = gara.idpfu
					   ,@idComunicazioneGenerica = b.Id 
					from ctl_doc a with(nolock)					     						--pda_comunicazione_gara
							inner join ctl_doc b with(nolock)     ON b.id = a.linkeddoc		--PDA_COMUNICAZIONE_GENERICA (oppure il documento che ha generato la comunicazione)
							inner join ctl_doc gara with(nolock) ON gara.id = b.linkeddoc  --GARA
					where a.id = @idDoc

				-- recupero il fascicolo 
				select   @fascicoloGenerale = isnull(fascicoloSecondario,'')
					from Document_dati_protocollo with(nolock) where idHeader = @idDocPrincipale

				IF @fascicoloGenerale = ''
				BEGIN

					select @fascicoloGenerale = isnull(FascicoloGenerale,'')
						from ctl_doc with(nolock) where id = @idDocPrincipale

				END


			END
			ELSE IF EXISTS ( Select id from ctl_doc with(nolock) where id = @idDoc and jumpcheck like '%-VERIFICA_REQUISITI' )
			BEGIN

				select @idDocPrincipale = gara.id
					   ,@idAziEnte = isnull(gara.azienda,-1)
					   ,@idPfuUtenteEnte = gara.idpfu
					   ,@idComunicazioneGenerica = b.Id 
					from ctl_doc a with(nolock)					     						--pda_comunicazione_gara
							inner join ctl_doc b with(nolock)     ON b.id = a.linkeddoc		--PDA_COMUNICAZIONE_GENERICA (oppure il documento che ha generato la comunicazione)
							inner join ctl_doc pda with(nolock) ON pda.id = b.linkeddoc	    --PDA_MICROLOTTI
							inner join ctl_doc gara with(nolock) ON gara.id = pda.linkeddoc  --GARA
					where a.id = @idDoc

				-- recupero il fascicolo 
				select   @fascicoloGenerale = isnull(fascicoloSecondario,'')
					from Document_dati_protocollo with(nolock) where idHeader = @idDocPrincipale

				IF @fascicoloGenerale = ''
				BEGIN

					select @fascicoloGenerale = isnull(FascicoloGenerale,'')
						from ctl_doc with(nolock) where id = @idDocPrincipale

				END

			END
			ELSE IF EXISTS ( Select id from ctl_doc with(nolock) where id = @idDoc and ( jumpcheck like '%-ESITO' or jumpcheck like '%-ESITO_MICROLOTTI' )  )
			BEGIN

				select @idDocPrincipale = gara.id
					   ,@idAziEnte = isnull(gara.azienda,-1)
					   ,@idPfuUtenteEnte = gara.idpfu
					   ,@idComunicazioneGenerica = b.id
					from ctl_doc a with(nolock)					     						--pda_comunicazione_gara
							inner join ctl_doc b with(nolock)     ON b.id = a.linkeddoc		--PDA_COMUNICAZIONE_GENERICA (oppure il documento che ha generato la comunicazione)
							inner join ctl_doc pda with(nolock) ON pda.id = b.linkeddoc	    --PDA_MICROLOTTI
							inner join ctl_doc gara with(nolock) ON gara.id = pda.linkeddoc  --GARA
					where a.id = @idDoc

				-- recupero il fascicolo 
				select   @fascicoloGenerale = isnull(fascicoloSecondario,'')
					from Document_dati_protocollo with(nolock) where idHeader = @idDocPrincipale

				IF @fascicoloGenerale = ''
				BEGIN

					select @fascicoloGenerale = isnull(FascicoloGenerale,'')
						from ctl_doc with(nolock) where id = @idDocPrincipale

				END

			END
			ELSE IF EXISTS ( Select id from ctl_doc with(nolock) where id = @idDoc and jumpcheck like '%-LOTTI_ESCLUSIONE' )
			BEGIN

				select @idDocPrincipale = gara.id ,
						@tipoDocCollegato = gara.TipoDoc
					from ctl_doc a	with(nolock)				     						--pda_comunicazione_gara
							inner join ctl_doc b with(nolock)    ON b.id = a.linkeddoc		--PDA_COMUNICAZIONE_GENERICA (oppure il documento che ha generato la comunicazione)
							inner join ctl_doc pda with(nolock)  ON pda.id = b.linkeddoc	--PDA_MICROLOTTI
							inner join ctl_doc gara with(nolock) ON gara.id = pda.linkeddoc --GARA
					where a.id = @idDoc

				-- recupero il fascicolo 
				select   @fascicoloGenerale = isnull(fascicoloSecondario,'')
					from Document_dati_protocollo with(nolock) where idHeader = @idDocPrincipale

				IF @fascicoloGenerale = ''
				BEGIN

					select @fascicoloGenerale = isnull(FascicoloGenerale,'')
						from ctl_doc with(nolock) where id = @idDocPrincipale

				END

			END
			ELSE IF EXISTS ( Select id from ctl_doc with(nolock) where id = @idDoc and jumpcheck like '%-RICHIESTA_STIPULA_CONTRATTO' )
			BEGIN

				select @idDocPrincipale = gara.id ,
						@tipoDocCollegato = gara.TipoDoc
					from ctl_doc a	with(nolock)				     						--pda_comunicazione_gara
							inner join ctl_doc b with(nolock)    ON b.id = a.linkeddoc		--PDA_COMUNICAZIONE_GENERICA (oppure il documento che ha generato la comunicazione)
							inner join ctl_doc pda with(nolock)  ON pda.id = b.linkeddoc	--PDA_MICROLOTTI
							inner join ctl_doc gara with(nolock) ON gara.id = pda.linkeddoc --GARA
					where a.id = @idDoc

				-- recupero il fascicolo 
				select   @fascicoloGenerale = isnull(fascicoloSecondario,'')
					from Document_dati_protocollo with(nolock) 
					where idHeader = @idDocPrincipale

				IF @fascicoloGenerale = ''
				BEGIN

					select @fascicoloGenerale = isnull(FascicoloGenerale,'')
						from ctl_doc with(nolock) where id = @idDocPrincipale

				END

			END
			ELSE IF EXISTS ( Select id from ctl_doc with(nolock) where id = @idDoc and jumpcheck like '%-PROSSIMA_SEDUTA' )
			BEGIN

				select @idDocPrincipale = gara.id ,
						@tipoDocCollegato = gara.TipoDoc
					from ctl_doc a	with(nolock)				     						--pda_comunicazione_gara
							inner join ctl_doc b with(nolock)    ON b.id = a.linkeddoc		--PDA_COMUNICAZIONE_GENERICA (oppure il documento che ha generato la comunicazione)
							inner join ctl_doc pda with(nolock)  ON pda.id = b.linkeddoc	--PDA_MICROLOTTI
							inner join ctl_doc gara with(nolock) ON gara.id = pda.linkeddoc --GARA
					where a.id = @idDoc

				-- recupero il fascicolo 
				select   @fascicoloGenerale = isnull(fascicoloSecondario,'')
					from Document_dati_protocollo with(nolock) where idHeader = @idDocPrincipale

				IF @fascicoloGenerale = ''
				BEGIN

					select @fascicoloGenerale = isnull(FascicoloGenerale,'')
						from ctl_doc with(nolock) where id = @idDocPrincipale

				END


			END
			ELSE IF EXISTS ( Select id from ctl_doc with(nolock) where id = @idDoc and jumpcheck like '%-VERIFICA_INTEGRATIVA' )
			BEGIN

				select @idDocPrincipale = gara.id
					   ,@idAziEnte = isnull(gara.azienda,-1)
					   ,@idPfuUtenteEnte = gara.idpfu
					   ,@idComunicazioneGenerica = b.id
					from ctl_doc a with(nolock)					     						--pda_comunicazione_gara
							inner join ctl_doc b with(nolock)     ON b.id = a.linkeddoc		--PDA_COMUNICAZIONE_GENERICA (oppure il documento che ha generato la comunicazione)
							inner join ctl_doc pda with(nolock) ON pda.id = b.linkeddoc	    --PDA_MICROLOTTI
							inner join ctl_doc gara with(nolock) ON gara.id = pda.linkeddoc  --GARA
					where a.id = @idDoc

				-- recupero il fascicolo 
				select   @fascicoloGenerale = isnull(fascicoloSecondario,'')
					from Document_dati_protocollo with(nolock) where idHeader = @idDocPrincipale

				IF @fascicoloGenerale = ''
				BEGIN

					select @fascicoloGenerale = isnull(FascicoloGenerale,'')
						from ctl_doc with(nolock) where id = @idDocPrincipale

				END


			END
			ELSE IF EXISTS ( Select id from ctl_doc with(nolock) where id = @idDoc and jumpcheck like '%-VERIFICA_AMMINISTRATIVA' )
			BEGIN

				select @idDocPrincipale = gara.id
					   ,@idAziEnte = isnull(gara.azienda,-1)
					   ,@idPfuUtenteEnte = gara.idpfu
					   ,@idComunicazioneGenerica = b.id
					from ctl_doc a with(nolock)					     						--pda_comunicazione_gara
							inner join ctl_doc b with(nolock)     ON b.id = a.linkeddoc		--PDA_COMUNICAZIONE_GENERICA (oppure il documento che ha generato la comunicazione)
							inner join ctl_doc pda with(nolock) ON pda.id = b.linkeddoc	    --PDA_MICROLOTTI
							inner join ctl_doc gara with(nolock) ON gara.id = pda.linkeddoc  --GARA
					where a.id = @idDoc

				-- recupero il fascicolo 
				select   @fascicoloGenerale = isnull(fascicoloSecondario,'')
					from Document_dati_protocollo with(nolock) where idHeader = @idDocPrincipale

				IF @fascicoloGenerale = ''
				BEGIN

					select @fascicoloGenerale = isnull(FascicoloGenerale,'')
						from ctl_doc with(nolock) where id = @idDocPrincipale

				END


			END
			ELSE IF EXISTS ( Select id from ctl_doc with(nolock) where id = @idDoc and ( jumpcheck like '%-ESITO_DEFINITIVO' or jumpcheck like '%-ESITO_DEFINITIVO_MICROLOTTI' )  )
			BEGIN

				select @idDocPrincipale = gara.id, 
					   @idAziEnte = isnull(gara.azienda,-1)
					   ,@idPfuUtenteEnte = gara.idpfu
					    ,@idComunicazioneGenerica = b.id
					from ctl_doc a with(nolock)					     						--pda_comunicazione_gara
							inner join ctl_doc b with(nolock)    ON b.id = a.linkeddoc		--PDA_COMUNICAZIONE_GENERICA (oppure il documento che ha generato la comunicazione)
							inner join ctl_doc pda with(nolock) ON pda.id = b.linkeddoc	    --PDA_MICROLOTTI
							inner join ctl_doc gara with(nolock) ON gara.id = pda.linkeddoc  --GARA
					where a.id = @idDoc

				-- recupero il fascicolo 
				select   @fascicoloGenerale = isnull(fascicoloSecondario,'')
					from Document_dati_protocollo with(nolock) where idHeader = @idDocPrincipale

				IF @fascicoloGenerale = ''
				BEGIN

					select @fascicoloGenerale = isnull(FascicoloGenerale,'')
						from ctl_doc with(nolock) where id = @idDocPrincipale

				END


			END
			ELSE IF EXISTS ( Select id from ctl_doc with(nolock) where id = @idDoc and jumpcheck like '%-REVOCA_BANDO')
			BEGIN

				set @idAziEnte = -1
				--RIMOSSO VISTO CHE VENGONO PROTOCOLLATE LE SINGOLE COMUNICAZIONI E  NON HA SENSO METTERE TUTTI I DESTINATARI IN QUESTI CASI
				-- SE la procedura rettificata è ad invito
				--IF EXISTS (select idRow from document_bando with(nolock) where TipoBandoGara = '3' AND idheader = @idDocPrincipale)
				--BEGIN

				--	set @userIdAzi = 0 --setto la variabile a 0 per non far fare la insert del singolo destinatario alla fine della stored
					
				--	----------------------------------------
				--	-------- AGGIUNGO GLI N DESTINATARI ----
				--	----------------------------------------
				--	INSERT INTO v_protgen_dati( IdHeader, DZT_Name, Value, data )
				--		select @idVProtGen as IdHeader,'IdAzi' as DZT_Name, cast( IdAzi as varchar(100)) as Value, getdate() as data
				--				from CTL_DOC_Destinatari with(nolock) where idHeader = @idDocPrincipale and seleziona='includi'

				--END
	

			END
			ELSE IF EXISTS ( Select id from ctl_doc with(nolock) where id = @idDoc and jumpcheck like '%-SOSPENSIONE_GARA')
			BEGIN

				set @idAziEnte = -1

				--RIMOSSO VISTO CHE VENGONO PROTOCOLLATE LE SINGOLE COMUNICAZIONI E  NON HA SENSO METTERE TUTTI I DESTINATARI IN QUESTI CASI
				---- SE la procedura rettificata è ad invito
				--IF EXISTS (select idRow from document_bando with(nolock) where TipoBandoGara = '3' AND idheader = @idDocPrincipale)
				--BEGIN

				--	set @userIdAzi = 0 --setto la variabile a 0 per non far fare la insert del singolo destinatario alla fine della stored
					
				--	----------------------------------------
				--	-------- AGGIUNGO GLI N DESTINATARI ----
				--	----------------------------------------
				--	INSERT INTO v_protgen_dati( IdHeader, DZT_Name, Value, data )
				--		select @idVProtGen as IdHeader,'IdAzi' as DZT_Name, cast( IdAzi as varchar(100)) as Value, getdate() as data
				--				from CTL_DOC_Destinatari with(nolock) where idHeader = @idDocPrincipale and seleziona='includi'

				--END
	

			END			
			ELSE IF EXISTS ( Select id from ctl_doc with(nolock) where id = @idDoc and jumpcheck like '%-SOSPENSIONE_ALBO') 
			BEGIN

				declare @tipoDocAlbo varchar(200)
				set @tipoDocAlbo = ''

				-- Sospensione Abilitazione per il giro dello SDA e per il giro dell'Abilitazione Mercato Elettronico

				set @idAziEnte = -1

				select @idDocPrincipale = bando.id,
				       @idAziEnte = isnull(bando.azienda,-1),
					   @idPfuUtenteEnte = bando.idpfu,
					   @tipoDocAlbo = bando.TipoDoc 
					from ctl_doc com with(nolock)	-- comunicazione
							INNER JOIN ctl_doc_destinatari dest with(nolock) ON com.linkedDoc = dest.idrow -- fornitore a cui è stata sospesa l'iscrizione
							INNER JOIN ctl_doc bando with(nolock) on BANDO.ID = dest.idheader			  -- albo o sda
					where com.id = @idDoc

				-- recupero il fascicolo dal bando_gara
				select   @fascicoloGenerale = isnull(fascicoloSecondario,'')
					from Document_dati_protocollo with(nolock) where idHeader = @idDocPrincipale

				IF @fascicoloGenerale = ''
				BEGIN

					select @fascicoloGenerale = isnull(FascicoloGenerale,'')
						from ctl_doc with(nolock) where id = @idDocPrincipale

				END

				IF @tipoDocAlbo = 'BANDO'
				BEGIN

					exec ProtGenRichiediFascicoloAnnuo @idVProtGen , @IdUser , @tipoDoc , @idDocPrincipale , @fascicoloGenerale , @tipoDocAlbo , 'SOSPENSIONE_ALBO', '',@AOO, @esitoRichiestaFascicolo output

					IF @esitoRichiestaFascicolo = 1
					BEGIN
						return 0
					END

				END


			END
			ELSE IF EXISTS ( Select id from ctl_doc with(nolock) where id = @idDoc and jumpcheck like '%-PROROGA_BANDO_GARA')
			BEGIN

				set @idAziEnte = -1

				-- Aggiungo gli allegati di proroga

				insert ctl_doc_value ( idHeader, dse_id,[row],[dzt_name],Value )
					select @idDoc,'ALLEGATI_PROTOCOLLO',idRow, 'Allegato', Allegato
					from CTL_DOC_ALLEGATI with(nolock) where idHeader = @idDocPrincipale and isnull(Allegato,'') <> ''

			END
			ELSE IF EXISTS ( Select id from ctl_doc with(nolock) where id = @idDoc and jumpcheck like '%-RIPRISTINO_GARA')
			BEGIN

				set @idAziEnte = -1

				-- Aggiungo gli allegati di proroga

				insert ctl_doc_value ( idHeader, dse_id,[row],[dzt_name],Value )
					select @idDoc,'ALLEGATI_PROTOCOLLO',idRow, 'Allegato', Allegato
					from CTL_DOC_ALLEGATI with(nolock) where idHeader = @idDocPrincipale and isnull(Allegato,'') <> ''

			END
			ELSE IF EXISTS ( Select id from ctl_doc with(nolock) where id = @idDoc and jumpcheck like '%-RETTIFICA_BANDO_GARA')
			BEGIN

				set @idAziEnte = -1

				-- Aggiungo gli allegati di rettifica

				insert ctl_doc_value ( idHeader, dse_id,[row],[dzt_name],Value )
					select @idDoc,'ALLEGATI_PROTOCOLLO',idRow, 'Allegato', Allegato
					from Document_Atti_Rettifica with(nolock) where idHeader = @idDocPrincipale and isnull(Allegato,'') <> ''


			END
			ELSE IF EXISTS ( Select id from ctl_doc with(nolock) where id = @idDoc and jumpcheck like '%-VERIFICA_REGISTRAZIONE_FORN')
			BEGIN

				--  Verifica registrazione. Accettazione/Rifiuto
				set @idAziEnte = -1

			END
			ELSE IF EXISTS ( Select id from ctl_doc with(nolock) where id = @idDoc and jumpcheck like '%-GENERICA_RIDOTTA')
			BEGIN


				-- con linkedDoc GENERICA_RIDOTTA non c'è solo l'annulla ordinativo, quindi controlo anche il documento associato al linkedDoc
				IF EXISTS (  Select id from ctl_doc with(nolock) where id = @linkedDoc and tipodoc = 'ANNULLA_ORDINATIVO' )
				BEGIN

					select @idDocPrincipale = conv.id
						   --,@idAziEnte = isnull(conv.azienda,-1)
						from ctl_doc a with(nolock)					     						--pda_comunicazione_gara
								inner join ctl_doc b with(nolock)    ON b.id = a.linkeddoc		--ANNULLA_ORDINATIVO
								inner join ctl_doc odc with(nolock) ON odc.id = b.linkeddoc		--ODC
								inner join ctl_doc conv with(nolock) ON conv.id = odc.linkeddoc  --CONVENZIONE
						where a.id = @idDoc

					select   @fascicoloGenerale = fascicoloSecondario
						from Document_dati_protocollo with(nolock)
						where idHeader = @idDocPrincipale

				END 

			END

		END
		ELSE IF @tipoDoc = 'CAMBIO_RAPLEG' -- + CAMBIO_RAPLEG_INAPPROVE , ma il tipoDoc sulla ctl_doc resta comunque CAMBIO_RAPLEG
		BEGIN

			set @idAziEnte = -1

			IF @statoFunzionale = 'InValutazione'
			BEGIN

				INSERT ctl_doc_value ( idHeader, dse_id,[row],[dzt_name],Value )
					VALUES (@idDoc, 'ALLEGATI_PROTOCOLLO',0, 'Allegato', @allegatoFirmato)	

			END

		END
		ELSE IF @tipoDoc like 'ISTANZA_Albo%'
		BEGIN

			set @idAziEnte = -1

			delete from ctl_doc_value where idheader = @idDoc and dse_id = 'ALLEGATI_PROTOCOLLO' and dzt_name = 'Allegato'

			-- allegato firmato
			INSERT ctl_doc_value ( idHeader, dse_id,[row],[dzt_name],Value )
					VALUES (@idDoc, 'ALLEGATI_PROTOCOLLO',0, 'Allegato', @allegatoFirmato)	

			-- allegati della sezione documentazione
			insert ctl_doc_value ( idHeader, dse_id,[row],[dzt_name],Value )
				select idHeader,'ALLEGATI_PROTOCOLLO' as dse_id,0 as [row], 'Allegato' as dzt_name, Value
				from CTL_DOC_Value with(nolock) where dse_id = 'DOCUMENTAZIONE' and idHeader = @idDoc and dzt_name = 'Allegato' and isnull(value,'') <> ''

			insert ctl_doc_value ( idHeader, dse_id,[row],[dzt_name],Value )
				select @idDoc,'ALLEGATI_PROTOCOLLO' as dse_id , 0 as [row], 'Allegato' as dzt_name, F2_SIGN_ATTACH
				from CTL_DOC_SIGN  with(nolock) where idheader = @idDoc and isnull(F2_SIGN_ATTACH,'') <> ''

			---ALLEGO A DOCER il FILE FIRMATO DEL DGUE QUANDO LO TROVA
			insert ctl_doc_value ( idHeader, dse_id,[row],[dzt_name],Value )
				select @idDoc,'ALLEGATI_PROTOCOLLO' as dse_id , 0 as [row], 'Allegato' as dzt_name, C1.SIGN_ATTACH
				from CTL_DOC C with(nolock)
						inner join CTL_DOC C1 on C.id=C1.LinkedDoc and C1.TipoDoc='MODULO_TEMPLATE_REQUEST'	and C1.Deleted=0			 
				where C.id = @idDoc and isnull(C1.SIGN_ATTACH,'') <> '' 

			-- Aggiungo i file 'Curriculum vitae' dalla griglia aggiunta nell'istanza dei professionisti
			insert ctl_doc_value ( idHeader, dse_id,[row],[dzt_name],Value )
				select idHeader,'ALLEGATI_PROTOCOLLO' as dse_id,0 as [row], 'Allegato' as dzt_name, Value
				from CTL_DOC_Value with(nolock) where dse_id = 'POSIZIONI_ELENCO_PROF' and idHeader = @idDoc and dzt_name = 'Allegato' and isnull(value,'') <> ''

			--------------------------
			-- RECUPERO IL MITTENTE --
			--------------------------
			SELECT top 1 @userIdAzi = azi.idAzi
				FROM ctl_doc doc with(nolock)
						INNER JOIN profiliutente pfu with(nolock) ON doc.idpfu = pfu.idpfu
						INNER JOIN aziende azi with(nolock) ON pfu.pfuIdAzi = azi.IdAzi 
				WHERE doc.id = @idDoc 

			--------------------------------------------------------
			-- RECUPERO IL FASCICOLO E IL SUO TITOLARIO DALL'ALBO --
			--------------------------------------------------------

			select @fascicoloGenerale = fascicoloSecondario,
				   @titolarioGenerale = titolarioPrimario
				from Document_dati_protocollo with(nolock) where idHeader = @linkedDoc

			-- Verifo se per questo documento è richiesta la gestione del fascicolo annuale
			exec ProtGenRichiediFascicoloAnnuo @idVProtGen , @IdUser , @tipoDoc , @linkedDoc , @fascicoloGenerale , 'BANDO' , '', '', @AOO,@esitoRichiestaFascicolo output

			IF @esitoRichiestaFascicolo = 1
			BEGIN
				return 0
			END


		END
		ELSE IF @tipoDoc in ( 'COM_DPE_RISPOSTA','COM_DPE_RISPOSTA_ENTE')
		BEGIN
			set @idAziEnte = -1

			-- allegati della sezione documentazione
			insert ctl_doc_value ( idHeader, dse_id,[row],[dzt_name],Value )
				select @idDoc,'ALLEGATI_PROTOCOLLO',idRow, 'Allegato', Allegato
					from CTL_DOC_ALLEGATI with(nolock) where idHeader = @idDoc and isnull(Allegato,'') <> ''
			--------------------------
			-- RECUPERO IL MITTENTE --
			--------------------------
			SELECT top 1 @userIdAzi = Azienda
				FROM ctl_doc doc with(nolock)						
				WHERE doc.id = @idDoc 

			select @fascicoloGenerale = isnull(fascicoloSecondario,'')
				from Document_Com_DPE with(nolock) where IdCom=@linkedDoc

		END
		ELSE IF @tipoDoc = 'INTEGRA_ISCRIZIONE_RIS'
		BEGIN

			set @idAziEnte = -1

			-- IL DOCUMENTO PRINCIPALE ( cioè la stampa base del documento in pdf ) è stata inserita dal processo prima della chiamata a questa stored. qui aggiugo solo gli allegati 

			-- allegati della sezione documentazione
			insert ctl_doc_value ( idHeader, dse_id,[row],[dzt_name],Value )
					select @idDoc,'ALLEGATI_PROTOCOLLO',idRow, 'Allegato', Allegato
					from CTL_DOC_ALLEGATI with(nolock) where idHeader = @idDoc and isnull(Allegato,'') <> ''

			--------------------------
			-- RECUPERO IL MITTENTE --
			--------------------------

			SELECT top 1 @userIdAzi = azi.idAzi
				FROM ctl_doc doc with(nolock)
						INNER JOIN profiliutente pfu with(nolock) ON doc.idpfu = pfu.idpfu
						INNER JOIN aziende azi with(nolock) ON pfu.pfuIdAzi = azi.IdAzi 
				WHERE doc.id = @idDoc 

			--------------------------------------------------------
			-- RECUPERO IL FASCICOLO E IL SUO TITOLARIO DALL'ALBO --
			--------------------------------------------------------
			set @ID_ALBO = -1

			SELECT top 1 @ID_ALBO = d.id --, @fascicoloGenerale = d.fascicologenerale 
				FROM CTL_DOC a with(nolock)									-- INTEGRA_ISCRIZIONE_RIS
					INNER JOIN CTL_DOC b with(nolock) ON a.linkeddoc = b.id  -- INTEGRA_ISCRIZIONE
					INNER JOIN CTL_DOC c with(nolock) ON b.linkeddoc = c.id  -- ISTANZA_AlboOperaEco
					INNER JOIN CTL_DOC d with(nolock) ON c.linkeddoc = d.id  -- BANDO
				WHERE a.id = @idDoc
			
			select @fascicoloGenerale = fascicoloSecondario,
				   @titolarioGenerale = titolarioPrimario 
				from Document_dati_protocollo with(nolock) where idHeader = @ID_ALBO


			-- Verifo se per questo documento è richiesta la gestione del fascicolo annuale
			exec ProtGenRichiediFascicoloAnnuo @idVProtGen , @IdUser , @tipoDoc , @ID_ALBO , @fascicoloGenerale , 'BANDO' , '', '', @AOO,@esitoRichiestaFascicolo output

			IF @esitoRichiestaFascicolo = 1
			BEGIN
				return 0
			END

		END
		ELSE IF @tipoDoc = 'INTEGRA_ISCRIZIONE_RIS_SDA'
		BEGIN

			set @idAziEnte = -1

			-- IL DOCUMENTO PRINCIPALE ( cioè la stampa base del documento in pdf ) è stata inserita dal processo prima della chiamata a questa stored. qui aggiugo solo gli allegati 

			-- allegati della sezione documentazione
			insert ctl_doc_value ( idHeader, dse_id,[row],[dzt_name],Value )
					select @idDoc,'ALLEGATI_PROTOCOLLO',idRow, 'Allegato', Allegato
					from CTL_DOC_ALLEGATI with(nolock) where idHeader = @idDoc and isnull(Allegato,'') <> ''

			--------------------------
			-- RECUPERO IL MITTENTE --
			--------------------------

			SELECT top 1 @userIdAzi = azi.idAzi
				FROM ctl_doc doc with(nolock)
						INNER JOIN profiliutente pfu with(nolock) ON doc.idpfu = pfu.idpfu
						INNER JOIN aziende azi with(nolock) ON pfu.pfuIdAzi = azi.IdAzi 
				WHERE doc.id = @idDoc 

			--------------------------------------------------------
			-- RECUPERO IL FASCICOLO E IL SUO TITOLARIO DALLO SDA --
			--------------------------------------------------------
			set @ID_ALBO = -1

			SELECT top 1 @ID_ALBO = d.id --, @fascicoloGenerale = d.fascicologenerale 
				FROM CTL_DOC a	with(nolock)								-- INTEGRA_ISCRIZIONE_RIS_SDA
					INNER JOIN CTL_DOC b with(nolock) ON a.linkeddoc = b.id  -- INTEGRA_ISCRIZIONE_SDA
					INNER JOIN CTL_DOC c with(nolock) ON b.linkeddoc = c.id  -- ISTANZA_SDA_FARMACI
					INNER JOIN CTL_DOC d with(nolock) ON c.linkeddoc = d.id  -- BANDO_SDA
				WHERE a.id = @idDoc
			
			select @titolarioGenerale = titolarioPrimario,
				   @fascicoloGenerale = fascicoloSecondario 
				from Document_dati_protocollo with(nolock) where idHeader = @ID_ALBO

		END
		ELSE IF @tipoDoc like 'CONFERMA_ISCRIZIONE%'
		BEGIN

			set @idAziEnte = -1

			-- allegato firmato
			INSERT ctl_doc_value ( idHeader, dse_id,[row],[dzt_name],Value )
					VALUES (@idDoc, 'ALLEGATI_PROTOCOLLO',0, 'Allegato', @allegatoFirmato)	

			------------------------------
			-- RECUPERO IL DESTINATARIO --
			------------------------------

			SELECT top 1 @userIdAzi = azienda
				FROM ctl_doc with(nolock)
				WHERE id = @linkedDoc 

			--------------------------------------------------------
			-- RECUPERO IL FASCICOLO E IL SUO	TITOLARIO DALL'ALBO --
			--------------------------------------------------------
			set @ID_ALBO = -1

			SELECT top 1 @ID_ALBO = d.id --, @fascicoloGenerale = d.fascicologenerale 
				FROM CTL_DOC a	with(nolock)								-- CONFERMA_ISCRIZIONE / CONFERMA_ISCRIZIONE_LAVORI
					INNER JOIN CTL_DOC c with(nolock) ON a.linkeddoc = c.id  -- ISTANZA_AlboOperaEco
					INNER JOIN CTL_DOC d with(nolock) ON c.linkeddoc = d.id  -- BANDO
				WHERE a.id = @idDoc
			
			select @fascicoloGenerale = prot.fascicoloSecondario,
				   @titolarioGenerale = prot.titolarioPrimario,
				   @linkedDoc = d.id 
				from CTL_DOC a	with(nolock)								-- INTEGRA_ISCRIZIONE
					INNER JOIN CTL_DOC c with(nolock) ON a.linkeddoc = c.id  -- ISTANZA_AlboOperaEco
					INNER JOIN CTL_DOC d with(nolock) ON c.linkeddoc = d.id  -- BANDO
					INNER JOIN Document_dati_protocollo prot with(nolock) ON prot.idHeader = d.id
				WHERE a.id = @idDoc


			-- Verifo se per questo documento è richiesta la gestione del fascicolo annuale
			exec ProtGenRichiediFascicoloAnnuo @idVProtGen , @IdUser , @tipoDoc , @linkedDoc , @fascicoloGenerale , 'BANDO' , '', '', @AOO,@esitoRichiestaFascicolo output

			IF @esitoRichiestaFascicolo = 1
			BEGIN
				return 0
			END

		END
		ELSE IF @tipoDoc like 'SCARTO_ISCRIZIONE%'
		BEGIN

			set @idAziEnte = -1

			-- allegato firmato
			INSERT ctl_doc_value ( idHeader, dse_id,[row],[dzt_name],Value )
					VALUES (@idDoc, 'ALLEGATI_PROTOCOLLO',0, 'Allegato', @allegatoFirmato)	

			------------------------------
			-- RECUPERO IL DESTINATARIO --
			------------------------------

			SELECT top 1 @userIdAzi = azienda
				FROM ctl_doc with(nolock)
				WHERE id = @linkedDoc 

			--------------------------------------------------------
			-- RECUPERO IL FASCICOLO E IL SUO TITOLARIO DALL'ALBO --
			--------------------------------------------------------
			set @ID_ALBO = -1

			SELECT top 1 @ID_ALBO = d.id --, @fascicoloGenerale = d.fascicologenerale 
				FROM CTL_DOC a with(nolock)									-- SCARTO_ISCRIZIONE
					INNER JOIN CTL_DOC c with(nolock) ON a.linkeddoc = c.id  -- ISTANZA_AlboOperaEco
					INNER JOIN CTL_DOC d with(nolock) ON c.linkeddoc = d.id  -- BANDO
				WHERE a.id = @idDoc
			
			select @fascicoloGenerale = prot.fascicoloSecondario,
				   @titolarioGenerale = prot.titolarioPrimario 
				from CTL_DOC a									-- INTEGRA_ISCRIZIONE
					INNER JOIN CTL_DOC c with(nolock) ON a.linkeddoc = c.id  -- ISTANZA_AlboOperaEco
					INNER JOIN CTL_DOC d with(nolock) ON c.linkeddoc = d.id  -- BANDO
					INNER JOIN Document_dati_protocollo prot with(nolock) ON prot.idHeader = d.id
				WHERE a.id = @idDoc

			-- Verifo se per questo documento è richiesta la gestione del fascicolo annuale
			exec ProtGenRichiediFascicoloAnnuo @idVProtGen , @IdUser , @tipoDoc , @ID_ALBO , @fascicoloGenerale , 'BANDO' , '', '', @AOO,@esitoRichiestaFascicolo output

			IF @esitoRichiestaFascicolo = 1
			BEGIN
				return 0
			END

		END
		ELSE IF @tipoDoc = 'INTEGRA_ISCRIZIONE'
		BEGIN

			set @idAziEnte = -1

			-- allegato firmato
			INSERT ctl_doc_value ( idHeader, dse_id,[row],[dzt_name],Value )
					VALUES (@idDoc, 'ALLEGATI_PROTOCOLLO',0, 'Allegato', @allegatoFirmato)	

			------------------------------
			-- RECUPERO IL DESTINATARIO --
			------------------------------

			SELECT top 1 @userIdAzi = azienda
				FROM ctl_doc with(nolock)
				WHERE id = @linkedDoc 

			--------------------------------------------------------
			-- RECUPERO IL FASCICOLO E IL SUO TITOLARIO DALL'ALBO --
			--------------------------------------------------------
			set @ID_ALBO = -1

			SELECT top 1 @ID_ALBO = d.id --, @fascicoloGenerale = d.fascicologenerale 
				FROM CTL_DOC a	with(nolock)								-- INTEGRA_ISCRIZIONE
					INNER JOIN CTL_DOC c with(nolock) ON a.linkeddoc = c.id  -- ISTANZA_AlboOperaEco
					INNER JOIN CTL_DOC d with(nolock) ON c.linkeddoc = d.id  -- BANDO
				WHERE a.id = @idDoc
			
			select @fascicoloGenerale = prot.fascicoloSecondario,
				   @titolarioGenerale = prot.titolarioPrimario 
				from CTL_DOC a with(nolock)									-- INTEGRA_ISCRIZIONE
					INNER JOIN CTL_DOC c with(nolock) ON a.linkeddoc = c.id  -- ISTANZA_AlboOperaEco
					INNER JOIN CTL_DOC d with(nolock) ON c.linkeddoc = d.id  -- BANDO
					INNER JOIN Document_dati_protocollo prot with(nolock) ON prot.idHeader = d.id
				WHERE a.id = @idDoc


			-- Verifo se per questo documento è richiesta la gestione del fascicolo annuale
			exec ProtGenRichiediFascicoloAnnuo @idVProtGen , @IdUser , @tipoDoc , @ID_ALBO , @fascicoloGenerale , 'BANDO' , '', '', @AOO,@esitoRichiestaFascicolo output

			IF @esitoRichiestaFascicolo = 1
			BEGIN
				return 0
			END

		END
		ELSE IF @tipoDoc like 'ISTANZA_SDA%'
		BEGIN

			set @idAziEnte = -1

			delete from ctl_doc_value where idheader = @idDoc and dse_id = 'ALLEGATI_PROTOCOLLO' and dzt_name = 'Allegato'

			-- allegato firmato, documento principale
			INSERT ctl_doc_value ( idHeader, dse_id,[row],[dzt_name],Value )
					VALUES (@idDoc, 'ALLEGATI_PROTOCOLLO',0, 'Allegato', @allegatoFirmato)	

			-- allegati della sezione documentazione
			insert ctl_doc_value ( idHeader, dse_id,[row],[dzt_name],Value )
				select idHeader,'ALLEGATI_PROTOCOLLO' as dse_id,0 as [row], 'Allegato' as dzt_name, Value
				from CTL_DOC_Value with(nolock) where dse_id = 'DOCUMENTAZIONE' and idHeader = @idDoc and dzt_name = 'Allegato' and isnull(value,'') <> ''
			
			---ALLEGO A DOCER il FILE FIRMATO DEL DGUE QUANDO LO TROVA
			insert ctl_doc_value ( idHeader, dse_id,[row],[dzt_name],Value )
				select @idDoc,'ALLEGATI_PROTOCOLLO' as dse_id , 0 as [row], 'Allegato' as dzt_name, C1.SIGN_ATTACH
				from CTL_DOC C with(nolock)
						inner join CTL_DOC C1 on C.id=C1.LinkedDoc and C1.TipoDoc='MODULO_TEMPLATE_REQUEST'	and C1.Deleted=0			 
				where C.id = @idDoc and isnull(C1.SIGN_ATTACH,'') <> '' 
			
			--------------------------
			-- RECUPERO IL MITTENTE --
			--------------------------
			SELECT top 1 @userIdAzi = azi.idAzi
				FROM ctl_doc doc with(nolock)
						INNER JOIN profiliutente pfu with(nolock) ON doc.idpfu = pfu.idpfu
						INNER JOIN aziende azi with(nolock) ON pfu.pfuIdAzi = azi.IdAzi 
				WHERE doc.id = @idDoc 

			--------------------------------------------------------
			-- RECUPERO IL FASCICOLO E IL SUO TITOLARIO DAL BANDO_SDA --
			--------------------------------------------------------

			select @fascicoloGenerale = fascicoloSecondario,
				   @titolarioGenerale = titolarioPrimario 
				from Document_dati_protocollo with(nolock) where idHeader = @linkedDoc


		END
		ELSE IF @tipoDoc = 'CONFERMA_ISCRIZIONE_SDA'
		BEGIN
			
			set @idAziEnte = -1

			-- allegato firmato
			INSERT ctl_doc_value ( idHeader, dse_id,[row],[dzt_name],Value )
					VALUES (@idDoc, 'ALLEGATI_PROTOCOLLO',0, 'Allegato', @allegatoFirmato)	

			------------------------------
			-- RECUPERO IL DESTINATARIO --
			------------------------------
			SELECT top 1 @userIdAzi = azienda
				FROM ctl_doc with(nolock)
				WHERE id = @linkedDoc 

			--------------------------------------------------------
			-- RECUPERO IL FASCICOLO E IL SUO TITOLARIO DALL'ALBO --
			--------------------------------------------------------
			set @ID_ALBO = -1

			SELECT top 1 @ID_ALBO = d.id -- @fascicoloGenerale = d.fascicologenerale 
				FROM CTL_DOC a with(nolock)									-- CONFERMA_ISCRIZIONE_SDA
					INNER JOIN CTL_DOC c with(nolock) ON a.linkeddoc = c.id  -- ISTANZA_SDA_FARMACI
					INNER JOIN CTL_DOC d with(nolock) ON c.linkeddoc = d.id  -- BANDO_SDA
				WHERE a.id = @idDoc

			select   @fascicoloGenerale = fascicoloSecondario
					,@titolarioGenerale = titolarioPrimario 
				from Document_dati_protocollo with(nolock) where idHeader = @ID_ALBO

		END
		ELSE IF @tipoDoc = 'SCARTO_ISCRIZIONE_SDA'
		BEGIN

			set @idAziEnte = -1

			-- allegato firmato
			INSERT ctl_doc_value ( idHeader, dse_id,[row],[dzt_name],Value )
					VALUES (@idDoc, 'ALLEGATI_PROTOCOLLO',0, 'Allegato', @allegatoFirmato)	

			------------------------------
			-- RECUPERO IL DESTINATARIO --
			------------------------------

			SELECT top 1 @userIdAzi = azienda
				FROM ctl_doc with(nolock)
				WHERE id = @linkedDoc 

			------------------------------------------------------------
			-- RECUPERO IL FASCICOLO E IL SUO TITOLARIO DAL BANDO SDA --
			------------------------------------------------------------
			set @ID_ALBO = -1

			SELECT top 1 @ID_ALBO = d.id --, @fascicoloGenerale = d.fascicologenerale 
				FROM CTL_DOC a	with(nolock)								-- CONFERMA_ISCRIZIONE_SDA
					INNER JOIN CTL_DOC c with(nolock) ON a.linkeddoc = c.id  -- ISTANZA_SDA_FARMACI
					INNER JOIN CTL_DOC d with(nolock) ON c.linkeddoc = d.id  -- BANDO_SDA
				WHERE a.id = @idDoc
			
			select   @fascicoloGenerale = fascicoloSecondario
					,@titolarioGenerale = titolarioPrimario 
				from Document_dati_protocollo with(nolock) where idHeader = @ID_ALBO

		END
		ELSE IF @tipoDoc = 'INTEGRA_ISCRIZIONE_SDA'
		BEGIN
		
			set @idAziEnte = -1

			-- allegato firmato
			INSERT ctl_doc_value ( idHeader, dse_id,[row],[dzt_name],Value )
					VALUES (@idDoc, 'ALLEGATI_PROTOCOLLO',0, 'Allegato', @allegatoFirmato)	

			------------------------------
			-- RECUPERO IL DESTINATARIO --
			------------------------------

			SELECT top 1 @userIdAzi = azienda
				FROM ctl_doc with(nolock)
				WHERE id = @linkedDoc 

			------------------------------------------------------------
			-- RECUPERO IL FASCICOLO E IL SUO TITOLARIO DAL BANDO GARA -
			------------------------------------------------------------
			set @ID_ALBO = -1

			SELECT top 1 @ID_ALBO = d.id --, @fascicoloGenerale = d.fascicologenerale 
				FROM CTL_DOC a with(nolock)									-- CONFERMA_ISCRIZIONE_SDA
					INNER JOIN CTL_DOC c with(nolock) ON a.linkeddoc = c.id  -- ISTANZA_SDA_FARMACI
					INNER JOIN CTL_DOC d with(nolock) ON c.linkeddoc = d.id  -- BANDO_SDA
				WHERE a.id = @idDoc
			
			select   @fascicoloGenerale = fascicoloSecondario
					,@titolarioGenerale = titolarioPrimario 
				from Document_dati_protocollo with(nolock) where idHeader = @ID_ALBO

		END
		ELSE IF @tipoDoc = 'BANDO_GARA'
		BEGIN

			--------------------------------------------------------
			-- RECUPERO IL FASCICOLO E IL SUO TITOLARIO  -----------
			--------------------------------------------------------

			select @fascicoloGenerale = fascicoloSecondario,
				   @titolarioGenerale = titolarioPrimario 
				from Document_dati_protocollo with(nolock) where idHeader = @idDoc

			-- SE è una procedura ad invito 
			IF EXISTS (select idRow from document_bando with(nolock) where TipoBandoGara = '3' AND idheader = @idDoc)
			BEGIN

				set @userIdAzi = 0 --setto la variabile a 0 per non far fare la insert del singolo destinatario alla fine della stored

				----------------------------------------
				-------- AGGIUNGO GLI N DESTINATARI ----
				----------------------------------------
				-- se è un INVITO SU UNA RISTRETTA
				--OPPURE UN AFFIDAMENTO DIRETTO SEMPLIFICATO
				IF EXISTS ( select idheader from Document_Bando WITH(NOLOCK) 
							where idheader = @IdDoc
								 and  (  tipobandogara = '3' /*Invito*/ and ProceduraGara = '15477' /* Ristretta*/  ) 
						  ) or EXISTS ( select idRow from document_bando with(nolock) where tipoProceduraCaratteristica = 'AffidamentoSemplificato' AND idheader = @idDoc )
				BEGIN
					INSERT INTO v_protgen_dati( IdHeader, DZT_Name, Value, data )
						select @idVProtGen as IdHeader,'IdAzi' as DZT_Name, cast( IdAzi as varchar(100)) as Value, getdate() as data
							from CTL_DOC_Destinatari with(nolock) where idHeader = @idDoc and ISNULL(seleziona,'includi')='includi'
				END
				ELSE
				BEGIN
					INSERT INTO v_protgen_dati( IdHeader, DZT_Name, Value, data )
						select @idVProtGen as IdHeader,'IdAzi' as DZT_Name, cast( IdAzi as varchar(100)) as Value, getdate() as data
							from CTL_DOC_Destinatari with(nolock) where idHeader = @idDoc and seleziona='includi'
				END

			END

			-- se è un RDO
			IF EXISTS( select idRow from document_bando with(nolock) where tipoProceduraCaratteristica = 'RDO' AND idheader = @idDoc )
			BEGIN

				-- il Pdf custom di testata è già inserito prima della chiamata a questa stored

				-- Allegati dell'RDO. gli atti
				INSERT ctl_doc_value ( idHeader, dse_id,[row],[dzt_name],Value )
					SELECT @idDoc,'ALLEGATI_PROTOCOLLO',idRow, 'Allegato', Allegato
					FROM CTL_DOC_ALLEGATI with(nolock) 
					where idHeader = @idDoc and isnull(Allegato,'') <> ''

			END 

			-- se è un INVITO SU UNA RISTRETTA
			--OPPURE UN AFFIDAMENTO DIRETTO SEMPLIFICATO
			IF EXISTS( select idheader from Document_Bando WITH(NOLOCK) 
							where idheader = @IdDoc
								 and  (  tipobandogara = '3' /*Invito*/ and ProceduraGara = '15477' /* Ristretta*/  ) 
						)
			   or EXISTS ( select idRow from document_bando with(nolock) where tipoProceduraCaratteristica = 'AffidamentoSemplificato' AND idheader = @idDoc )
			BEGIN

				-- il Pdf custom di testata è già inserito prima della chiamata a questa stored
				-- se non esiste questo allegato, altrimenti il principale sarà questo
				INSERT ctl_doc_value ( idHeader, dse_id,[row],[dzt_name],Value )
					SELECT @idDoc,'ALLEGATI_PROTOCOLLO',0, 'Allegato', Allegato
						FROM CTL_DOC_ALLEGATI with(nolock) 
						where idHeader = @idDoc and isnull(Allegato,'') <> ''
							and AnagDoc = 'Lettera di Invito' 


				-- Allegati dell'invito gli atti tranne la lettera invito se esiste
				INSERT ctl_doc_value ( idHeader, dse_id,[row],[dzt_name],Value )
					SELECT @idDoc,'ALLEGATI_PROTOCOLLO',idRow, 'Allegato', Allegato
						FROM CTL_DOC_ALLEGATI with(nolock) 
						where idHeader = @idDoc and isnull(Allegato,'') <> ''
							and AnagDoc <> 'Lettera di Invito' 

			END 

		END
		ELSE IF @tipoDoc = 'RETTIFICA_GARA'
		BEGIN
			
			-- SE la procedura rettificata è ad invito
			IF EXISTS (select idRow from document_bando with(nolock) where TipoBandoGara = '3' AND idheader = @linkedDoc)
			BEGIN

				set @userIdAzi = 0 --setto la variabile a 0 per non far fare la insert del singolo destinatario alla fine della stored

				----------------------------------------
				-------- AGGIUNGO GLI N DESTINATARI ----
				----------------------------------------
				INSERT INTO v_protgen_dati( IdHeader, DZT_Name, Value, data )
					select @idVProtGen as IdHeader,'IdAzi' as DZT_Name, cast( IdAzi as varchar(100)) as Value, getdate() as data
							from CTL_DOC_Destinatari with(nolock) where idHeader = @linkedDoc and seleziona='includi'

			END

			-- il pdf della stampa base lo ritrovo gia inserito prima della chiamata a questa stored

			-- aggiungo gli allegati della rettifica
			INSERT ctl_doc_value ( idHeader, dse_id,[row],[dzt_name],Value )
				SELECT @idDoc,'ALLEGATI_PROTOCOLLO',idRow, 'Allegato', Allegato
				FROM CTL_DOC_ALLEGATI with(nolock) where idHeader = @idDoc and isnull(Allegato,'') <> ''

			-- aggiungo gli allegati dei nuovi atti di gara
			INSERT ctl_doc_value ( idHeader, dse_id,[row],[dzt_name],Value )
				SELECT @idDoc,'ALLEGATI_PROTOCOLLO',idRow, 'Allegato', Allegato
						 from Document_Atti_Rettifica where idheader = @idDoc and isnull(Allegato,'') <> ''

			-- recupero il fascicolo dal bando_gara
			select   @fascicoloGenerale = fascicoloSecondario
				from Document_dati_protocollo with(nolock) where idHeader = @linkedDoc

		END
		ELSE IF @tipoDoc = 'PROROGA_GARA'
		BEGIN
			
			-- SE la procedura prorogata è ad invito
			IF EXISTS (select idRow from document_bando with(nolock) where TipoBandoGara = '3' AND idheader = @linkedDoc)
			BEGIN

				set @userIdAzi = 0 --setto la variabile a 0 per non far fare la insert del singolo destinatario alla fine della stored

				----------------------------------------
				-------- AGGIUNGO GLI N DESTINATARI ----
				----------------------------------------
				INSERT INTO v_protgen_dati( IdHeader, DZT_Name, Value, data )
					select @idVProtGen as IdHeader,'IdAzi' as DZT_Name, cast( IdAzi as varchar(100)) as Value, getdate() as data
							from CTL_DOC_Destinatari with(nolock) where idHeader = @linkedDoc and seleziona='includi'

			END

			-- il pdf della stampa base lo ritrovo gia inserito prima della chiamata a questa stored

			-- aggiungo gli allegati della rettifica
			INSERT ctl_doc_value ( idHeader, dse_id,[row],[dzt_name],Value )
				SELECT @idDoc,'ALLEGATI_PROTOCOLLO',idRow, 'Allegato', Allegato
				FROM CTL_DOC_ALLEGATI with(nolock) where idHeader = @idDoc and isnull(Allegato,'') <> ''

			-- recupero il fascicolo dal bando_gara
			select   @fascicoloGenerale = fascicoloSecondario
				from Document_dati_protocollo with(nolock) where idHeader = @linkedDoc

		END
		ELSE IF @tipoDoc = 'RIPRISTINO_GARA'
		BEGIN
			
			-- SE la procedura prorogata è ad invito
			IF EXISTS (select idRow from document_bando with(nolock) where TipoBandoGara = '3' AND idheader = @linkedDoc)
			BEGIN

				set @userIdAzi = 0 --setto la variabile a 0 per non far fare la insert del singolo destinatario alla fine della stored

				----------------------------------------
				-------- AGGIUNGO GLI N DESTINATARI ----
				----------------------------------------
				INSERT INTO v_protgen_dati( IdHeader, DZT_Name, Value, data )
					select @idVProtGen as IdHeader,'IdAzi' as DZT_Name, cast( IdAzi as varchar(100)) as Value, getdate() as data
							from CTL_DOC_Destinatari with(nolock) where idHeader = @linkedDoc and seleziona='includi'

			END

			-- il pdf della stampa base lo ritrovo gia inserito prima della chiamata a questa stored

			-- aggiungo gli allegati della rettifica
			INSERT ctl_doc_value ( idHeader, dse_id,[row],[dzt_name],Value )
				SELECT @idDoc,'ALLEGATI_PROTOCOLLO',idRow, 'Allegato', Allegato
				FROM CTL_DOC_ALLEGATI with(nolock) where idHeader = @idDoc and isnull(Allegato,'') <> ''

			-- recupero il fascicolo dal bando_gara
			select   @fascicoloGenerale = fascicoloSecondario
				from Document_dati_protocollo with(nolock) where idHeader = @linkedDoc

		END
		ELSE IF @tipoDoc = 'REVOCA_GARA'
		BEGIN
			-- SE la procedura prorogata è ad invito
			IF EXISTS (select idRow from document_bando with(nolock) where TipoBandoGara = '3' AND idheader = @linkedDoc)
			BEGIN

				set @userIdAzi = 0 --setto la variabile a 0 per non far fare la insert del singolo destinatario alla fine della stored

				----------------------------------------
				-------- AGGIUNGO GLI N DESTINATARI ----
				----------------------------------------
				INSERT INTO v_protgen_dati( IdHeader, DZT_Name, Value, data )
					select @idVProtGen as IdHeader,'IdAzi' as DZT_Name, cast( IdAzi as varchar(100)) as Value, getdate() as data
							from CTL_DOC_Destinatari with(nolock) where idHeader = @linkedDoc and seleziona='includi'

			END

			-- il pdf della stampa base lo ritrovo gia inserito prima della chiamata a questa stored

			-- aggiungo gli allegati della rettifica
			INSERT ctl_doc_value ( idHeader, dse_id,[row],[dzt_name],Value )
				SELECT @idDoc,'ALLEGATI_PROTOCOLLO',idRow, 'Allegato', Allegato
				FROM CTL_DOC_ALLEGATI with(nolock) where idHeader = @idDoc and isnull(Allegato,'') <> ''

			-- recupero il fascicolo dal bando_gara
			select   @fascicoloGenerale = fascicoloSecondario
				from Document_dati_protocollo with(nolock) where idHeader = @linkedDoc

		END
		ELSE IF @tipoDoc = 'CHIARIMENTI_PORTALE'
		BEGIN

			-- il pdf della stampa custom del quesito lo ritrovo gia inserito prima della chiamata a questa stored

			declare @jumpCheckCollegato varchar(500)

			SELECT  @userIdAzi = isnull(p.pfuIdAzi,-1)
                   ,@linkedDoc = ID_ORIGIN
				   ,@tipoDocCollegato = DOCUMENT
				FROM document_chiarimenti c with(nolock)
						INNER JOIN profiliutente p with(nolock) ON c.UtenteDomanda = p.idpfu
				WHERE id = @idDoc

			-- recupero il fascicolo dalla gara e l'ente che ha indetto la gara
			select  @fascicoloGenerale = fascicoloSecondario
					, @idAziEnte = isnull(doc.azienda,-1)
					, @idPfuUtenteEnte = doc.idpfu
					, @jumpCheckCollegato = isnull(doc.jumpcheck,'')
				from ctl_doc doc with(nolock) 
						inner join Document_dati_protocollo prot with(nolock) ON prot.idheader = doc.id 
				where doc.id = @linkedDoc

			IF @fascicoloGenerale = ''
			BEGIN

				select @fascicoloGenerale = isnull(FascicoloGenerale,'')
					from ctl_doc with(nolock) where id = @linkedDoc

			END

			-- Verifo se per questo documento è richiesta la gestione del fascicolo annuale
			exec ProtGenRichiediFascicoloAnnuo @idVProtGen , @IdUser , @tipoDoc , @linkedDoc , @fascicoloGenerale , @tipoDocCollegato , '', @contesto,@AOO, @esitoRichiestaFascicolo output

			IF @esitoRichiestaFascicolo = 1
			BEGIN
				return 0
			END


		END
		ELSE IF @tipoDoc = 'DETAIL_CHIARIMENTI_BANDO'
		BEGIN

			declare @allegatoRisposta nvarchar(4000)

			-- il pdf della stampa custom del quesito lo ritrovo gia inserito prima della chiamata a questa stored

			SELECT 	 @userIdAzi = isnull(p.pfuidazi,-1)
					,@linkedDoc = ID_ORIGIN
					,@allegatoRisposta = isnull(c.Allegato, '')
					,@tipoDocCollegato = c.Document
				FROM document_chiarimenti c with(nolock)
						INNER JOIN profiliutente p with(nolock) ON c.UtenteDomanda = p.idpfu
				WHERE id = @idDoc

			-- recupero il fascicolo dalla gara e l'ente che ha indetto la gara
			select  @fascicoloGenerale = fascicoloSecondario
					, @idAziEnte = isnull(doc.azienda,-1)
					, @idPfuUtenteEnte = doc.idpfu
				from ctl_doc doc with(nolock) inner join Document_dati_protocollo prot with(nolock) ON prot.idheader = doc.id where doc.id = @linkedDoc


			IF @allegatoRisposta <> '' 
			BEGIN

				-- Aggiungo l'eventuale allegato messo nella risposta
				insert Document_Chiarimenti_Protocollo ( idHeader, [dzt_name],Value )
					VALUES (@idDoc, 'Allegato_risp_quesito', @allegatoRisposta)

			END

			IF @fascicoloGenerale = ''
			BEGIN

				select @fascicoloGenerale = isnull(FascicoloGenerale,'')
					from ctl_doc with(nolock) where id = @linkedDoc

			END

			---------------------
			-- Avendo un conflitto di ID tra quesito e risposta a quesito, per non prendere gli stessi allegati del quesito inviato dal fornitore.
			-- Inserisco un discriminante 
			----------------------
			INSERT INTO v_protgen_dati( IdHeader, DZT_Name, Value, data )
							VALUES (@idVProtGen, 'allegatoProtocollo', 'Allegato_risp_quesito' , getdate() )

			-- Verifo se per questo documento è richiesta la gestione del fascicolo annuale
			exec ProtGenRichiediFascicoloAnnuo @idVProtGen , @IdUser , @tipoDoc , @linkedDoc , @fascicoloGenerale , @tipoDocCollegato , '', @contesto, @AOO,@esitoRichiestaFascicolo output

			IF @esitoRichiestaFascicolo = 1
			BEGIN
				return 0
			END

		END
		ELSE IF @tipoDoc = 'OFFERTA'
		BEGIN
				
			-- l'allegato è già stato inserito prima della chiamata a questa stored, /report/busta_offerta.asp

			--------------------------
			-- RECUPERO IL MITTENTE --
			--------------------------
			SELECT top 1 @userIdAzi = azi.idAzi
				FROM ctl_doc doc with(nolock)
						INNER JOIN profiliutente pfu with(nolock) ON doc.idpfu = pfu.idpfu
						INNER JOIN aziende azi with(nolock) ON pfu.pfuIdAzi = azi.IdAzi 
				WHERE doc.id = @idDoc 

			--------------------------------------------------------
			-- RECUPERO IL FASCICOLO E IL SUO TITOLARIO DAL BANDO --
			--------------------------------------------------------
			select @fascicoloGenerale = fascicoloSecondario,
				   @titolarioGenerale = titolarioPrimario,
				   @idAziEnte = isnull(doc.azienda,-1),
				   @idPfuUtenteEnte = doc.idpfu
				from ctl_doc doc with(nolock) 
					inner join Document_dati_protocollo prot with(nolock) ON doc.id = prot.idheader 
				where doc.id = @linkedDoc

			IF @fascicoloGenerale = ''
			BEGIN

				select @fascicoloGenerale = isnull(FascicoloGenerale,'')
					from ctl_doc with(nolock) where id = @linkedDoc

			END

			-- AGGIUNTO LA CIVETTA CHE ELIMINA IL PASSAGGIO DEL DOCUMENTO AL PARER NELLA BLIND PHASE
			INSERT INTO v_protgen_dati ( IdHeader, DZT_Name, Value, data )
					VALUES ( @idVProtGen, 'noPARER', 'YES', getdate() )

		END
		ELSE IF @tipoDoc = 'OFFERTA_BA'
		BEGIN
				
			-- l'allegato principale è già stato inserito prima della chiamata a questa stored, /report/busta_offerta.asp

			--------------------------
			-- RECUPERO IL MITTENTE --
			--------------------------
			SELECT top 1 @userIdAzi = pfu.pfuIdAzi
				FROM ctl_doc doc with(nolock)
						INNER JOIN profiliutente pfu with(nolock) ON doc.idpfu = pfu.idpfu
				WHERE doc.id = @idDoc 

			--------------------------------------------------------
			-- RECUPERO IL FASCICOLO E IL SUO TITOLARIO DAL BANDO --
			--------------------------------------------------------
			select @fascicoloGenerale = fascicoloSecondario,
				   @titolarioGenerale = titolarioPrimario,
				   @idAziEnte = isnull(doc.azienda,-1),
				   @idPfuUtenteEnte = doc.idpfu
				from ctl_doc doc with(nolock) 
						inner join Document_dati_protocollo prot with(nolock) ON doc.id = prot.idheader 
				where doc.id = @linkedDoc

			IF @fascicoloGenerale = ''
			BEGIN

				select @fascicoloGenerale = isnull(FascicoloGenerale,'')
					from ctl_doc with(nolock)
					where id = @linkedDoc

			END

			insert ctl_doc_value ( idHeader, dse_id,[row],[dzt_name],Value )
					select @idDoc,'ALLEGATI_PROTOCOLLO',0, 'Allegato', Allegato
					from CTL_DOC_ALLEGATI with(nolock) 
					where idHeader = @idDoc and isnull(Allegato,'') <> ''


		END
		ELSE IF @tipoDoc IN ('OFFERTA_BT', 'OFFERTA_BE' )
		BEGIN

			declare @nomeCampoAllegato varchar(100)

			set @nomeCampoAllegato = 'Allegato'

			-- CAMBIAMO LA TABELLA DI DEFAULT SULLA QUALE RECUPERARE GLI ALLEGATI DA MANDARE AL PROTOCOLLO. 
			--		IL VINCOLO DELLA TABELLA E' CHE SIA UTILIZZABILE PER UN SALVATAGGIO IN VERTICALE ( CIOE' CON LE COLONNE NOMINATE COME QUELLE DELLA CTL_DOC_VALUE )
			INSERT INTO v_protgen_dati( IdHeader, DZT_Name, Value, data )
				VALUES (@idVProtGen, 'tabellaAllegatiProtocollo', 'Document_Microlotti_DOC_Value' , getdate() )

			-- DIFFERENZIAMO IL CAMPO TECNICO PER ACCEDERE AI FILE TRA BUSTA TECNICA ED ECONOMICA ( busta tecnica ed economica hanno lo stesso id della microlotti dettagli )
			IF @tipoDoc = 'OFFERTA_BE'
			BEGIN

				set @nomeCampoAllegato = 'Allegato_BE'

				INSERT INTO v_protgen_dati( IdHeader, DZT_Name, Value, data )
					VALUES (@idVProtGen, 'allegatoProtocollo', @nomeCampoAllegato , getdate() )

			END

			-- se la gara è monolotto o multilotto mi cambia il criterio di recupero dell'allegato firmato ( ctl_doc_sign o Document_Microlotto_Firme  )
			IF EXISTS ( select idheader from Document_Bando with(nolock) where idHeader = @linkedDoc and Divisione_lotti = '0' ) --SE MONOLOTTO
			BEGIN
				
				insert Document_Microlotti_DOC_Value ( idHeader, dse_id,[row],[dzt_name],Value )
					select @idDoc,'ALLEGATI_PROTOCOLLO',0, @nomeCampoAllegato, case when @tipoDoc = 'OFFERTA_BT' then F3_SIGN_ATTACH else F1_SIGN_ATTACH end
					from CTL_DOC_SIGN with(nolock)
					where idHeader = @idDocPrincipale

			END
			ELSE
			BEGIN
				
				insert Document_Microlotti_DOC_Value ( idHeader, dse_id,[row],[dzt_name],Value )
					select @idDoc,'ALLEGATI_PROTOCOLLO',0, @nomeCampoAllegato, case when @tipoDoc = 'OFFERTA_BT' then F2_SIGN_ATTACH else F1_SIGN_ATTACH end
					from Document_Microlotto_Firme with(nolock) 
					where idHeader = @idDoc

			END

			DECLARE @ModelName varchar(1000)

			set @ModelName = ''

			IF EXISTS ( select idheader from Document_Bando with(nolock) where idHeader = @linkedDoc and Divisione_lotti <> '0' ) --SE MULTILOTTO
			BEGIN
				-- per le multilotto l'id con il quale entrare sulla CTL_DOC_SECTION_MODEL è quello della Document_MicroLotti_Dettagli
				select @ModelName = a.MOD_Name from CTL_DOC_SECTION_MODEL a with(nolock) where a.IdHeader = @idDoc and a.DSE_ID = case when @tipoDoc =  'OFFERTA_BT' then 'OFFERTA_BUSTA_TEC' else 'OFFERTA_BUSTA_ECO' end
			END
			ELSE
			BEGIN
				-- per le monolotto l'id con il quale entrare sulla CTL_DOC_SECTION_MODEL è quello del documento offerta, ctl_doc
				select @ModelName = a.MOD_Name from CTL_DOC_SECTION_MODEL a with(nolock) where a.IdHeader = @idDocPrincipale and a.DSE_ID = case when @tipoDoc =  'OFFERTA_BT' then 'BUSTA_TECNICA' else 'BUSTA_ECONOMICA' end
			END

			--RECUPERO EVENTUALI ALLEGATI PRESENTI SULLE RIGHE DI PRODOTTI
			IF @ModelName <> '' and EXISTS ( select id  
												from  CTL_ModelAttributes with(nolock)
														inner join LIB_Dictionary d WITH(NOLOCK) on d.DZT_Name = MA_DZT_Name and d.DZT_Type=18
												where MA_MOD_ID = @ModelName
			)
			BEGIN
		
				declare @MA_DZT_Name as varchar(500)
				declare @SQL_UPD as nvarchar(max)

				declare CurUpdate Cursor FAST_FORWARD for 
					select MA_DZT_Name 
						from  CTL_ModelAttributes  WITH(NOLOCK) 
								inner join LIB_Dictionary d WITH(NOLOCK) on d.DZT_Name = MA_DZT_Name and d.DZT_Type=18							
						where MA_MOD_ID = @ModelName

				open CurUpdate
				FETCH NEXT FROM CurUpdate  INTO  @MA_DZT_Name

				WHILE @@FETCH_STATUS = 0
				BEGIN
			

					set @SQL_UPD = 'SET NOCOUNT ON

						select ' + @MA_DZT_Name + ' as allegato into #tmp_work_r
							from Document_MicroLotti_Dettagli DM WITH(NOLOCK) 
							where id = ' + CAST (@idDoc as varchar(20)) + ' and TipoDoc = ''OFFERTA'' and ' + @MA_DZT_Name + ' <> '''' 

						insert Document_Microlotti_DOC_Value ( idHeader, dse_id,[row],[dzt_name],Value )
							select ' + CAST(@idDoc as varchar(20)) + ',''ALLEGATI_PROTOCOLLO'',0, ''' + @nomeCampoAllegato + ''', allegato
								from #tmp_work_r t with(nolock)
								where allegato not in ( select value from Document_Microlotti_DOC_Value with(nolock) where idHeader = ' + CAST(@idDoc as varchar(20)) + ' and dse_id = ''ALLEGATI_PROTOCOLLO'' )
						drop table #tmp_work_r '

					exec (@SQL_UPD)

					FETCH NEXT FROM CurUpdate  INTO @MA_DZT_Name 

				END
				CLOSE CurUpdate
				DEALLOCATE CurUpdate

			END



		END
		ELSE IF @tipoDoc IN ('COM_DPE_FORNITORE','COM_DPE_ENTE')
		BEGIN
			
			

			-- CAMBIAMO LA TABELLA DI DEFAULT SULLA QUALE RECUPERARE GLI ALLEGATI DA MANDARE AL PROTOCOLLO. 
			--	IL VINCOLO DELLA TABELLA E' CHE SIA UTILIZZABILE PER UN SALVATAGGIO IN VERTICALE ( CIOE' CON LE COLONNE NOMINATE COME QUELLE DELLA CTL_DOC_VALUE )
			INSERT INTO v_protgen_dati( IdHeader, DZT_Name, Value, data )
				VALUES (@idVProtGen, 'tabellaAllegatiProtocollo', 'Document_COM_DPE_Allegati_Protocollo' , getdate() )

			
			select @fascicoloGenerale = isnull(fascicoloSecondario,'')
				from Document_Com_DPE with(nolock) where IdCom=@linkedDoc

			--RECUPERA GLI ALLEGATI, QUELLO PRINCIPALE E' GIA' STATO INSERITO DAL PROCESSO
			insert Document_COM_DPE_Allegati_Protocollo ( idHeader, dse_id,[row],[dzt_name],Value )
				select @idDoc,'ALLEGATI_PROTOCOLLO',ROW_NUMBER() OVER(ORDER BY idcomall ASC)  as RIGA,'Allegato',Allegato
					from Document_Com_DPE_ALLEGATI 
						where IdCom=@idDocPrincipale
						order by idcomall
			

		END
		ELSE IF @tipoDoc = 'RITIRA_OFFERTA'
		BEGIN
				
			--------------------------
			-- RECUPERO IL MITTENTE --
			--------------------------
			SELECT top 1 @userIdAzi = azi.idAzi
				FROM ctl_doc doc with(nolock)
						INNER JOIN profiliutente pfu with(nolock) ON doc.idpfu = pfu.idpfu
						INNER JOIN aziende azi with(nolock) ON pfu.pfuIdAzi = azi.IdAzi 
				WHERE doc.id = @idDoc 

			--------------------------------------------------------
			-- RECUPERO IL FASCICOLO E IL SUO TITOLARIO DAL BANDO --
			--------------------------------------------------------
			select @fascicoloGenerale = fascicoloSecondario,
				   @titolarioGenerale = titolarioPrimario,
				   @idAziEnte = isnull(doc1.azienda,-1),
				   @idPfuUtenteEnte = doc1.idpfu
				from ctl_doc doc with(nolock) 
					inner join ctl_doc doc1  with(nolock)  on doc1.id=doc.LinkedDoc
					inner join Document_dati_protocollo prot with(nolock) ON doc1.id = prot.idheader 
				where doc.id = @linkedDoc

			IF @fascicoloGenerale = ''
			BEGIN

				select @fascicoloGenerale = isnull(FascicoloGenerale,'')
					from ctl_doc with(nolock) where id = @linkedDoc

			END

			-- NON VA AGGIUNTA LA CIVETTA CHE ELIMINA IL PASSAGGIO DEL DOCUMENTO AL PARER NELLA BLIND PHASE ( COSI' COME FATTO PER L'OFFERTA )
			--	INSERT INTO v_protgen_dati ( IdHeader, DZT_Name, Value, data )
			--		VALUES ( @idVProtGen, 'noPARER', 'YES', getdate() )

			-- AGGIUNTA ALLEGATO DEL PDF FIRMATO COME ALLEGATO PRINCIPALE
			insert ctl_doc_value ( idHeader, dse_id,[row],[dzt_name],Value )
				VALUES (@idDoc, 'ALLEGATI_PROTOCOLLO',0, 'Allegato', @allegatoFirmato)

			-- SE PRESENTE allegato secondario LO AGGIUNGO AL PROTOCOLLO
			if exists( select idROW From ctl_doc_value with(nolock) where idHeader = @idDoc and isnull(value,'') <> '' and DSE_ID = 'FIRMA' AND DZT_NAME = 'Allegato'  )
			begin

			    insert ctl_doc_value ( idHeader, dse_id,[row],[dzt_name],Value )
				    select @idDoc,'ALLEGATI_PROTOCOLLO',1, 'Allegato', value
					    from ctl_doc_value with(nolock) where idHeader = @idDoc and isnull(value,'') <> '' and DSE_ID = 'FIRMA' AND DZT_NAME = 'Allegato'
			
			end

		END


		ELSE IF @tipoDoc in(  'MANIFESTAZIONE_INTERESSE','DOMANDA_PARTECIPAZIONE')
		BEGIN
				
			--------------------------
			-- RECUPERO IL MITTENTE --
			--------------------------
			SELECT top 1 @userIdAzi = azi.idAzi
				FROM ctl_doc doc with(nolock)
						INNER JOIN profiliutente pfu with(nolock) ON doc.idpfu = pfu.idpfu
						INNER JOIN aziende azi with(nolock) ON pfu.pfuIdAzi = azi.IdAzi 
				WHERE doc.id = @idDoc 

			--------------------------------------------------------
			-- RECUPERO IL FASCICOLO E IL SUO TITOLARIO DAL BANDO --
			--------------------------------------------------------
			select @fascicoloGenerale = fascicoloSecondario,
				   @titolarioGenerale = titolarioPrimario,
				   @idAziEnte = isnull(doc.azienda,-1),
				   @idPfuUtenteEnte = doc.idpfu
				from ctl_doc doc with(nolock) 					 
					inner join Document_dati_protocollo prot with(nolock) ON doc.id = prot.idheader 
				where doc.id = @linkedDoc

			IF @fascicoloGenerale = ''
			BEGIN

				select @fascicoloGenerale = isnull(FascicoloGenerale,'')
					from ctl_doc with(nolock) where id = @linkedDoc

			END

			
			-- KPF 313773, GLI ALLEGATI NON POSSO ESSERE INVIATI AL PROTOCOLLO IN QUANTO CIFRATI.
			--		verranno inviati in un momento successivo più avanti
			------AGGIUNTA ALLEGATI SECONDARI solo per la manifestazione
			--IF  @tipoDoc in (  'MANIFESTAZIONE_INTERESSE' )			
			--BEGIN
			--	-- AGGIUNTA ALLEGATI SECONDARI
			--	insert ctl_doc_value ( idHeader, dse_id,[row],[dzt_name],Value )
			--		select @idDoc,'ALLEGATI_PROTOCOLLO',idRow, 'Allegato', Allegato
			--			from CTL_DOC_ALLEGATI with(nolock) where idHeader = @idDoc and isnull(Allegato,'') <> ''			
			--END
			

		END

		ELSE IF @tipoDoc = 'RICHIESTA_ATTI_GARA'
		BEGIN
				
			-- l'allegato è già stato inserito prima della chiamata a questa stored, /report/busta_offerta.asp

			--------------------------
			-- RECUPERO IL MITTENTE --
			--------------------------
			SELECT top 1 @userIdAzi = azi.idAzi
				FROM ctl_doc doc with(nolock)
						INNER JOIN profiliutente pfu with(nolock) ON doc.idpfu = pfu.idpfu
						INNER JOIN aziende azi with(nolock) ON pfu.pfuIdAzi = azi.IdAzi 
				WHERE doc.id = @idDoc 

			--------------------------------------------------------
			-- RECUPERO IL FASCICOLO E IL SUO TITOLARIO DAL BANDO --
			--------------------------------------------------------
			select @fascicoloGenerale = fascicoloSecondario,
				   @titolarioGenerale = titolarioPrimario,
				   @idAziEnte = isnull(doc.azienda,-1),
				   @idPfuUtenteEnte = doc.idpfu
				from ctl_doc doc with(nolock) 
					inner join Document_dati_protocollo prot with(nolock) ON doc.id = prot.idheader 
				where doc.id = @linkedDoc

			IF @fascicoloGenerale = ''
			BEGIN

				select @fascicoloGenerale = isnull(FascicoloGenerale,'')
					from ctl_doc with(nolock) where id = @linkedDoc

			END	
			-- AGGIUNTA ALLEGATI SECONDARI
			insert ctl_doc_value ( idHeader, dse_id,[row],[dzt_name],Value )
				select @idDoc,'ALLEGATI_PROTOCOLLO',idRow, 'Allegato', Allegato
					from CTL_DOC_ALLEGATI with(nolock) where idHeader = @idDoc and isnull(Allegato,'') <> ''

		

		END

		ELSE IF @tipoDoc = 'INVIO_ATTI_GARA'
		BEGIN
				
			-- l'allegato è già stato inserito prima della chiamata a questa stored, /report/busta_offerta.asp

			--------------------------
			-- RECUPERO IL MITTENTE --
			--------------------------
			SELECT top 1 @userIdAzi = azi.idAzi
				FROM ctl_doc doc with(nolock)
						INNER JOIN profiliutente pfu with(nolock) ON doc.idpfu = pfu.idpfu
						INNER JOIN aziende azi with(nolock) ON pfu.pfuIdAzi = azi.IdAzi 
				WHERE doc.id = @idDoc 

			--------------------------------------------------------
			-- RECUPERO IL FASCICOLO E IL SUO TITOLARIO DAL BANDO --
			--------------------------------------------------------
			select @fascicoloGenerale = fascicoloSecondario,
				   @titolarioGenerale = titolarioPrimario,
				   @idAziEnte = isnull(doc.azienda,-1),
				   @idPfuUtenteEnte = doc.idpfu
				from ctl_doc doc with(nolock) 					
					inner join Document_dati_protocollo prot with(nolock) ON doc.LinkedDoc = prot.idheader 
				where doc.id = @linkedDoc

			IF @fascicoloGenerale = ''
			BEGIN

				select @fascicoloGenerale = isnull(FascicoloGenerale,'')
					from ctl_doc with(nolock) where id = @linkedDoc

			END	
			-- AGGIUNTA ALLEGATI SECONDARI
			insert ctl_doc_value ( idHeader, dse_id,[row],[dzt_name],Value )
				select @idDoc,'ALLEGATI_PROTOCOLLO',idRow, 'Allegato', Allegato
					from CTL_DOC_ALLEGATI with(nolock) where idHeader = @idDoc and isnull(Allegato,'') <> ''

		

		END
		ELSE IF @tipoDoc = 'SCRITTURA_PRIVATA'
		BEGIN

			declare @firma1 nvarchar(4000)
			set @idAziEnte = -1

			------------------------------------
			-- AGGIUNGO ALLEGATI FIRMATI -------
			------------------------------------
			select top 1 @firma1 = f1_sign_attach 
				  from CTL_DOC_SIGN with(nolock) where idHeader = @idDoc

			--documento principale firmato
			insert ctl_doc_value ( idHeader, dse_id,[row],[dzt_name],Value )
				VALUES (@idDoc, 'ALLEGATI_PROTOCOLLO',0, 'Allegato', @firma1)

			-- allegati al principale
			insert ctl_doc_value ( idHeader, dse_id,[row],[dzt_name],Value )
					select @idDoc,'ALLEGATI_PROTOCOLLO',0, 'Allegato', Allegato
					from CTL_DOC_ALLEGATI with(nolock) where idHeader = @idDoc and isnull(Allegato,'') <> ''

			------------------------------
			-- RECUPERO IL DESTINATARIO --
			------------------------------

			select @idDocPrincipale = gara.id,
				   @idAziEnte = isnull(gara.azienda,-1),
				   @idPfuUtenteEnte = gara.idpfu
					from ctl_doc a	with(nolock)				     						--SCRITTURA_PRIVATA
							inner join ctl_doc b with(nolock)    ON b.id = a.linkeddoc		--PDA_COMUNICAZIONE_GENERICA 
							inner join ctl_doc pda with(nolock)  ON pda.id = b.linkeddoc	--PDA_MICROLOTTI
							inner join ctl_doc gara with(nolock) ON gara.id = pda.linkeddoc --GARA
					where a.id = @idDoc

			------------------------------------------------------------
			-- RECUPERO IL FASCICOLO E IL SUO TITOLARIO DAL BANDO  -----
			------------------------------------------------------------
			select   @fascicoloGenerale = fascicoloSecondario
					,@titolarioGenerale = titolarioPrimario 
				from Document_dati_protocollo with(nolock) where idHeader = @idDocPrincipale

			IF @fascicoloGenerale = ''
			BEGIN

				select @fascicoloGenerale = isnull(FascicoloGenerale,'')
					from ctl_doc with(nolock) where id = @idDocPrincipale

			END

			-- non c'è più la doppia fascicolazione!
			-- IL FASCICOLO SECONDARIO E' IMPUTATO DALL'UTENTE SULL'RDO MENTRE IL PRINCIPALE è GENERATO IN AUTOMATICO annualmente ED ASSOCIATO
			-- la gestione del fascicolo annuo è implicita nell'algoritmo F005
			--select @fascicoloSecondario = a.fascicoloSecondario 
			--	from Document_dati_protocollo a with(nolock) where idheader = @idDocPrincipale

		END
		ELSE IF @tipoDoc = 'CANCELLA_ISCRIZIONE'
		BEGIN

			select @tipoDocCollegato = b.tipodoc
				from ctl_doc a	with(nolock)				     						--CANCELLA_ISCRIZIONE
						inner join ctl_doc b with(nolock)    ON b.id = a.linkeddoc		--BANDO ME O BANDO SDA
				where a.id = @idDoc

			-- RECUPERO GLI ALLEGATI, IL DOCUMENTO PRINCIPALE INVECE VIENE GENERATO PRIMA DI ENTRARE QUI. E' IL PDF DELLA STAMPA BASE
			insert ctl_doc_value ( idHeader, dse_id,[row],[dzt_name],Value )
				select @idDoc,'ALLEGATI_PROTOCOLLO',idRow, 'Allegato', Allegato
				from CTL_DOC_ALLEGATI with(nolock) where idHeader = @idDoc and isnull(Allegato,'') <> ''


			select @fascicoloGenerale = fascicoloSecondario,
				   @titolarioGenerale = titolarioPrimario
				from Document_dati_protocollo with(nolock) where idHeader = @linkedDoc

			-- Verifo se per questo documento è richiesta la gestione del fascicolo annuale
			exec ProtGenRichiediFascicoloAnnuo @idVProtGen , @IdUser , @tipoDoc , @linkedDoc , @fascicoloGenerale , @tipoDocCollegato , '', @contesto,@AOO, @esitoRichiestaFascicolo output

			IF @esitoRichiestaFascicolo = 1
			BEGIN
				return 0
			END

		END
		ELSE IF @tipoDoc = 'CAMBIO_RUOLO_UTENTE'
		BEGIN

			set @idAziEnte = -1

			-- Se l'utente è solo un PI non ha firmato il pdf, quindi arrivati qui avrò già l'allegato generato in aututomatico inserito nella tabella. 
			IF ( @allegatoFirmato <> '' )
			BEGIN

				-- allegato firmato
				INSERT ctl_doc_value ( idHeader, dse_id,[row],[dzt_name],Value )
						VALUES (@idDoc, 'ALLEGATI_PROTOCOLLO',0, 'Allegato', @allegatoFirmato)	

			END

			--------------------------
			-- RECUPERO IL MITTENTE --
			--------------------------
			SELECT top 1 @userIdAzi = azi.idAzi
				FROM ctl_doc doc with(nolock)
						INNER JOIN profiliutente pfu with(nolock) ON doc.idpfu = pfu.idpfu
						INNER JOIN aziende azi with(nolock) ON pfu.pfuIdAzi = azi.IdAzi 
				WHERE doc.id = @idDoc 

			------------------------------------------------------------------------------------------------------------
			-- RECUPERO IL FASCICOLO UTILIZZATO PER I CAMBIO_RUOLO PER L'ANNO CORRENTE DALLA TABELLA DEI FASCICOLI -----
			------------------------------------------------------------------------------------------------------------
			set @fascicoloGenerale = ''
			select top 1 @fascicoloGenerale = isnull(fascicoloNuovo,'')
				from v_protgen_fascicoli with(nolock) 
				where deleted = 0 and tipoDoc = 'CAMBIO_RUOLO' and dbo.GetColumnValue ( isnull(fascicoloNuovo,''), '.', 1 ) = year(getdate())  and isnull(aoo,'') = isnull(@AOO,'')
				order by id desc

			-- Verifo se per questo documento è richiesta la gestione del fascicolo annuale
			exec ProtGenRichiediFascicoloAnnuo @idVProtGen , @IdUser , @tipoDoc , @linkedDoc , @fascicoloGenerale , 'CAMBIO_RUOLO' , '', '', @AOO,@esitoRichiestaFascicolo output

			IF @esitoRichiestaFascicolo = 1
			BEGIN
				return 0
			END
		END
		ELSE IF @tipoDoc = 'VARIAZIONE_ANAGRAFICA'
		BEGIN

			set @idAziEnte = -1

			-- allegato firmato
			INSERT ctl_doc_value ( idHeader, dse_id,[row],[dzt_name],Value )
					VALUES (@idDoc, 'ALLEGATI_PROTOCOLLO',0, 'Allegato', @allegatoFirmato)	
			--ALLEGATO AttoOperazioneStraordinaria SE PRESENTE
			INSERT ctl_doc_value ( idHeader, dse_id,[row],[dzt_name],Value )
				select @idDoc, 'ALLEGATI_PROTOCOLLO',1, 'Allegato', value
					from ctl_doc_value with(nolock)
						 where IdHeader=@idDoc and DSE_ID='TESTATA' and DZT_Name='AttoOperazioneStraordinaria'

			--------------------------
			-- RECUPERO IL MITTENTE --
			--------------------------
			SELECT top 1 @userIdAzi = azi.idAzi
				FROM ctl_doc doc with(nolock)
						INNER JOIN profiliutente pfu with(nolock) ON doc.idpfu = pfu.idpfu
						INNER JOIN aziende azi with(nolock) ON pfu.pfuIdAzi = azi.IdAzi 
				WHERE doc.id = @idDoc 

			------------------------------------------------------------------------------------------------------------
			-- RECUPERO IL FASCICOLO UTILIZZATO PER LE REGISTRAZIONI PER L'ANNO CORRENTE DALLA TABELLA DEI FASCICOLI ---
			------------------------------------------------------------------------------------------------------------
			set @fascicoloGenerale = ''
			select top 1 @fascicoloGenerale = isnull(fascicoloNuovo,'')
				from v_protgen_fascicoli with(nolock) 
				where deleted = 0 and tipoDoc = 'REGISTRAZIONI' and dbo.GetColumnValue ( isnull(fascicoloNuovo,''), '.', 1 ) = year(getdate())  and isnull(aoo,'') = isnull(@AOO,'')
				order by id desc

			-- Verifo se per questo documento è richiesta la gestione del fascicolo annuale
			exec ProtGenRichiediFascicoloAnnuo @idVProtGen , @IdUser , @tipoDoc , @linkedDoc , @fascicoloGenerale , 'REGISTRAZIONI' , '', '', @AOO,@esitoRichiestaFascicolo output

			IF @esitoRichiestaFascicolo = 1
			BEGIN
				return 0
			END

		END
		ELSE IF @tipoDoc = 'PREGARA'
		BEGIN

			set @idAziEnte = -1

			-- allegato firmato
			INSERT ctl_doc_value ( idHeader, dse_id,[row],[dzt_name],Value )
					VALUES (@idDoc, 'ALLEGATI_PROTOCOLLO',0, 'Allegato', @allegatoFirmato)	
			--ALLEGATO AttoOperazioneStraordinaria SE PRESENTE
			--INSERT ctl_doc_value ( idHeader, dse_id,[row],[dzt_name],Value )
			--	select @idDoc, 'ALLEGATI_PROTOCOLLO',1, 'Allegato', F3_SIGN_ATTACH
			--		from ctl_doc_SIGN with(nolock)
			--			 where IdHeader=@idDoc 
			

			set @fascicoloGenerale = ''

				--------------------------------------------------------------------------------------------------------------
				---- RECUPERO IL FASCICOLO UTILIZZATO PER IL PREGARA PER L'ANNO CORRENTE DALLA TABELLA DEI FASCICOLI ---
				--------------------------------------------------------------------------------------------------------------
				--set @fascicoloGenerale = ''
				--select top 1 @fascicoloGenerale = isnull(fascicoloNuovo,'')
				--	from v_protgen_fascicoli with(nolock) 
				--	where deleted = 0 and tipoDoc = 'PREGARA' and dbo.GetColumnValue ( isnull(fascicoloNuovo,''), '.', 1 ) = year(getdate())  and isnull(aoo,'') = isnull(@AOO,'')
				--	order by id desc

				---- Verifo se per questo documento è richiesta la gestione del fascicolo annuale
				--exec ProtGenRichiediFascicoloAnnuo @idVProtGen , @IdUser , @tipoDoc , @linkedDoc , @fascicoloGenerale , 'PREGARA' , '', '', @AOO,@esitoRichiestaFascicolo output

				--IF @esitoRichiestaFascicolo = 1
				--BEGIN
				--	return 0
				--END

		END
		ELSE IF @tipoDoc = 'VARIAZIONE_ANAGRAFICA_ACCETTA'
		BEGIN
			
			set @idAziEnte = -1

			-- allegato firmato
			INSERT ctl_doc_value ( idHeader, dse_id,[row],[dzt_name],Value )
					VALUES (@idDoc, 'ALLEGATI_PROTOCOLLO',0, 'Allegato', @allegatoFirmato)	


			--------------------------
			-- RECUPERO IL DEST --
			--------------------------
			SELECT top 1 @userIdAzi = azi.idAzi
				FROM ctl_doc doc with(nolock)
						INNER JOIN profiliutente pfu with(nolock) ON doc.idpfu = pfu.idpfu
						INNER JOIN aziende azi with(nolock) ON pfu.pfuIdAzi = azi.IdAzi 
				WHERE doc.id = @idDoc 


			------------------------------------------------------------------------------------------------------------
			-- RECUPERO IL FASCICOLO UTILIZZATO PER LE REGISTRAZIONI PER L'ANNO CORRENTE DALLA TABELLA DEI FASCICOLI ---
			------------------------------------------------------------------------------------------------------------
			set @fascicoloGenerale = ''
			select top 1 @fascicoloGenerale = isnull(fascicoloNuovo,'')
				from v_protgen_fascicoli with(nolock) 
				where deleted = 0 and tipoDoc = 'REGISTRAZIONI' and dbo.GetColumnValue ( isnull(fascicoloNuovo,''), '.', 1 ) = year(getdate())  and isnull(aoo,'') = isnull(@AOO,'')
				order by id desc

			-- Verifo se per questo documento è richiesta la gestione del fascicolo annuale
			exec ProtGenRichiediFascicoloAnnuo @idVProtGen , @IdUser , @tipoDoc , @linkedDoc , @fascicoloGenerale , 'REGISTRAZIONI' , '', '', @AOO,@esitoRichiestaFascicolo output

			IF @esitoRichiestaFascicolo = 1
			BEGIN
				return 0
			END

			

		END
		ELSE IF @tipoDoc = 'PDA_COMUNICAZIONE_RISP'
		BEGIN

			declare @tipoDocCollegato2 varchar(500)
			declare @idDocPrincipale2 INT

			set @idDocPrincipale = -1

			select  @idDocPrincipale = isnull(bando.id, b.id) ,
					@tipoDocCollegato = bando.TipoDoc,
					@tipoDocCollegato2 = b.TipoDoc, --per la Comunicazione al Fornitore della Convenzione.
					@idDocPrincipale2 = b.id--per la Comunicazione al Fornitore della Convenzione.
					,@jumpcheckDocCollegati = isnull(aa.JumpCheck,'')
				from ctl_doc a	with(nolock)				     						 --PDA_COMUNICAZIONE_RISP
						inner join ctl_doc aa with(nolock)    ON aa.id = a.linkeddoc	 --PDA_COMUNICAZIONE_GARA
						inner join ctl_doc b with(nolock)    ON b.id = aa.linkeddoc		 --PDA_COMUNICAZIONE_GENERICA (oppure il documento che ha generato la comunicazione, come ad esempio la convenzione)
						left join profiliutente pb with(nolock) on pb.idpfu = b.IdPfu
						left join ctl_doc bb with(nolock)    ON bb.id = b.linkeddoc	 --PDA_MICROLOTTI
						left join ctl_doc bando with(nolock) ON bando.id = bb.linkeddoc  --bando_gara (o comunque il documento del bando)
				where a.id = @idDoc

			if @jumpcheckDocCollegati  like '%-GARA_COMUNICAZIONE_GENERICA'
			BEGIN
				select  @idDocPrincipale = bando.id ,
					@tipoDocCollegato = bando.TipoDoc					
				from ctl_doc a	with(nolock)				     						 --PDA_COMUNICAZIONE_RISP
						inner join ctl_doc aa with(nolock)    ON aa.id = a.linkeddoc	 --PDA_COMUNICAZIONE_GARA
						inner join ctl_doc b with(nolock)    ON b.id = aa.linkeddoc		 --PDA_COMUNICAZIONE_GENERICA (oppure il documento che ha generato la comunicazione, come ad esempio la convenzione)
						left join profiliutente pb with(nolock) on pb.idpfu = b.IdPfu						
						left join ctl_doc bando with(nolock) ON bando.id = b.linkeddoc  --GARA 
				where a.id = @idDoc
			END
			--------------------------
			-- RECUPERO IL MITTENTE --
			--------------------------
			SELECT top 1 @userIdAzi = azi.idAzi
				FROM ctl_doc doc with(nolock)
						INNER JOIN profiliutente pfu with(nolock) ON doc.idpfu = pfu.idpfu
						INNER JOIN aziende azi with(nolock) ON pfu.pfuIdAzi = azi.IdAzi 
				WHERE doc.id = @idDoc 

			--------------------------------------------------------
			-- RECUPERO IL FASCICOLO E IL SUO TITOLARIO DAL BANDO --
			--------------------------------------------------------
			select  @fascicoloGenerale = fascicoloSecondario,
					@titolarioGenerale = titolarioPrimario,
					@idAziEnte = isnull(doc.azienda,-1),
					@idPfuUtenteEnte = doc.idpfu
				from ctl_doc doc with(nolock) 
					inner join Document_dati_protocollo prot with(nolock) ON doc.id = prot.idheader 
				where doc.id = @idDocPrincipale

			IF @fascicoloGenerale = ''
			BEGIN

				select @fascicoloGenerale = isnull(FascicoloGenerale,'')
					from ctl_doc with(nolock) where id = @idDocPrincipale

			END

			-- Gli allegati presenti nella griglia degli allegati finisco tutti come 'allegati' del documento principale, generato prima di entrare qui
			-- . è il pdf della stampa base
			insert ctl_doc_value ( idHeader, dse_id,[row],[dzt_name],Value )
					select @idDoc,'ALLEGATI_PROTOCOLLO',idRow, 'Allegato', Allegato
					from CTL_DOC_ALLEGATI with(nolock) where idHeader = @idDoc and isnull(Allegato,'') <> ''

		END
		ELSE IF @tipoDoc in ('NOTIER_ISCRIZ', 'NOTIER_ISCRIZ_PA')
		BEGIN

			set @idAziEnte = -1

			--------------------------------
			-- RECUPERO L'IDAZI MITTENTE --
			--------------------------------
			select @userIdAzi =  pfuIdAzi
				from profiliutente with(nolock) 
				where idpfu = @idPfuInCarico

			IF NOT EXISTS ( select * from ctl_doc_value with(nolock) where idheader = @idDoc and dse_id = 'ALLEGATI_PROTOCOLLO' and dzt_name = 'Allegato' and value = @allegatoFirmato )
			BEGIN

				INSERT ctl_doc_value ( idHeader, dse_id,[row],[dzt_name],Value )
					VALUES (@idDoc, 'ALLEGATI_PROTOCOLLO',0, 'Allegato', @allegatoFirmato)
			
			END
				
			---------------------------------------------------------------------------------------------------------------------
			-- RECUPERO IL FASCICOLO UTILIZZATO PER I DOCUMENTI NOTIER_ISCRIZ PER L'ANNO CORRENTE DALLA TABELLA DEI FASCICOLI ---
			---------------------------------------------------------------------------------------------------------------------

			set @fascicoloGenerale = ''
			select top 1 @fascicoloGenerale = isnull(fascicoloNuovo,'')
				from v_protgen_fascicoli with(nolock) 
				where deleted = 0 and tipoDoc = @tipoDoc and dbo.GetColumnValue ( isnull(fascicoloNuovo,''), '.', 1 ) = year(getdate()) and isnull(aoo,'') = isnull(@AOO,'')
				order by id desc

			-- Verifo se per questo documento è richiesta la gestione del fascicolo annuale
			exec ProtGenRichiediFascicoloAnnuo @idVProtGen , @IdUser , @tipoDoc , @linkedDoc , @fascicoloGenerale , @tipoDoc , '', '',@AOO, @esitoRichiestaFascicolo output

			IF @esitoRichiestaFascicolo = 1
			BEGIN
				return 0
			END

		END
		ELSE IF @tipoDoc = 'PDA_COMUNICAZIONE_OFFERTA'
		BEGIN

			-- Il documento principale 
			-- è stato inserito prima dell'invocazione di questa stored dalla clsDownloader
			-- ( è una stampa base pdf )

			set @idDocPrincipale = -1

			select 	@idDocPrincipale = bando.id,
					@tipoDocCollegato = bando.TipoDoc
				from ctl_doc a	with(nolock)				     							--PDA_COMUNICAZIONE_OFFERTA
						inner join ctl_doc b with(nolock)    ON b.id = a.linkeddoc			--PDA_COMUNICAZIONE
						inner join ctl_doc b2 with(nolock)   ON b2.id = b.LinkedDoc			--PDA_MICROLOTTI
						inner join ctl_doc bando with(nolock) ON bando.id = b2.linkeddoc		-- BANDO 
				where a.id = @idDoc

			-- recupero il fascicolo dalla gara
			select   @fascicoloGenerale = isnull(fascicoloSecondario,'')
				from Document_dati_protocollo with(nolock) where idHeader = @idDocPrincipale

			IF @fascicoloGenerale = ''
			BEGIN

				select @fascicoloGenerale = isnull(FascicoloGenerale,'')
					from ctl_doc with(nolock) where id = @idDocPrincipale

			END

			insert ctl_doc_value ( idHeader, dse_id,[row],[dzt_name],Value )
					select @idDoc,'ALLEGATI_PROTOCOLLO',0, 'Allegato', Allegato
					from CTL_DOC_ALLEGATI with(nolock) where idHeader = @idDoc and isnull(Allegato,'') <> ''


		END
		ELSE IF @tipoDoc = 'PDA_COMUNICAZIONE_OFFERTA_RISP'
		BEGIN
				
			-- l'allegato è già stato inserito prima della chiamata a questa stored, /report/busta_off_migliorativa.asp

			--------------------------
			-- RECUPERO IL MITTENTE --
			--------------------------
			SELECT top 1 @userIdAzi = azi.idAzi
				FROM ctl_doc doc with(nolock)
						INNER JOIN profiliutente pfu with(nolock) ON doc.idpfu = pfu.idpfu
						INNER JOIN aziende azi with(nolock) ON pfu.pfuIdAzi = azi.IdAzi 
				WHERE doc.id = @idDoc 

			--------------------------------------------------------
			-- RECUPERO IL FASCICOLO E IL SUO TITOLARIO DAL BANDO --
			--------------------------------------------------------
			select 	@idDocPrincipale = bando.id,
						@tipoDocCollegato = bando.TipoDoc
					from ctl_doc a	with(nolock)				     							
							inner join ctl_doc b with(nolock)    ON b.id = a.linkeddoc	
							inner join ctl_doc b2 with(nolock)   ON b2.id = b.LinkedDoc			
							inner join ctl_doc pda with(nolock) ON pda.id = b2.linkeddoc		
							inner join ctl_doc bando with(nolock) ON bando.id = pda.linkeddoc	
					where a.id = @idDoc

			select @fascicoloGenerale = fascicoloSecondario,
				   @titolarioGenerale = titolarioPrimario,
				   @idAziEnte = isnull(doc.azienda,-1),
				   @idPfuUtenteEnte = doc.idpfu
				from ctl_doc doc with(nolock) 
					inner join Document_dati_protocollo prot with(nolock) ON doc.id = prot.idheader 
				where doc.id = @idDocPrincipale

			IF @fascicoloGenerale = ''
			BEGIN

				select @fascicoloGenerale = isnull(FascicoloGenerale,'')
					from ctl_doc with(nolock) where id = @idDocPrincipale

			END

			-- AGGIUNTO LA CIVETTA CHE ELIMINA IL PASSAGGIO DEL DOCUMENTO AL PARER NELLA BLIND PHASE ( così come fatto per l'offerta )
			INSERT INTO v_protgen_dati ( IdHeader, DZT_Name, Value, data )
					VALUES ( @idVProtGen, 'noPARER', 'YES', getdate() )

			insert ctl_doc_value ( idHeader, dse_id,[row],[dzt_name],Value )
				select @idDoc,'ALLEGATI_PROTOCOLLO',0, 'Allegato', Allegato
				from CTL_DOC_ALLEGATI with(nolock) where idHeader = @idDoc and isnull(Allegato,'') <> ''

		END
		ELSE IF @tipoDoc = 'CONTRATTO_GARA_FORN'
		BEGIN

			set @idAziEnte = -1			

			delete from ctl_doc_value where dse_id = 'ALLEGATI_PROTOCOLLO' and idHeader = @idDoc

			-- Recupero allegato principale
			select top 1 
						idrow, 
						case 
							when ISNULL(AllegatoRisposta,'')<>'' then AllegatoRisposta 
							else Allegato 
						end as Allegato into #tmp_allegato_principale 
				from CTL_DOC_ALLEGATI with(NOLOCK)
					where idHeader=@idDoc order by idrow asc						

			IF NOT EXISTS ( Select * from #tmp_allegato_principale )
			BEGIN
				raiserror ('Errore completamento dati per tipoDoc ''contratto_gara_forn'' %s - Contratto mancante', 16, 1 , @idDoc )
				return 99
			END

			--documento principale
			insert ctl_doc_value ( idHeader, dse_id,[row],[dzt_name],Value )
			  select @idDoc, 'ALLEGATI_PROTOCOLLO',0, 'Allegato', Allegato
			  from #tmp_allegato_principale
			
			--COLLEZIONA GLI ALTRI ALLEGATI
			select idrow, 
						case 
							when ISNULL(AllegatoRisposta,'')<>'' then AllegatoRisposta 
							else Allegato 
						end as Allegato ,
						ROW_NUMBER() OVER(ORDER BY idrow ASC)  as RIGA
						into #tmp_allegato_secondario
				from CTL_DOC_ALLEGATI with(NOLOCK)					
				where idHeader=@idDoc and idrow not in (select idrow from #tmp_allegato_principale)	and ( ISNULL(AllegatoRisposta,'')<>'' or ISNULL(Allegato,'')<>'')
				order by idrow asc	
			
			insert ctl_doc_value ( idHeader, dse_id,[row],[dzt_name],Value )
				select @idDoc, 'ALLEGATI_PROTOCOLLO',RIGA, 'Allegato', Allegato
				from #tmp_allegato_secondario
			
			-- AGGIUNGO IL CONTRATTO GENERATO E FIRMATO SE PRENSENTE
			declare @RIGA as INT
			select @RIGA = max(row) +1 
				from ctl_doc_value where idHeader=@idDoc and dse_id='ALLEGATI_PROTOCOLLO' and [dzt_name]='Allegato'

			insert ctl_doc_value ( idHeader, dse_id,[row],[dzt_name],Value )
				select @idDoc, 'ALLEGATI_PROTOCOLLO',@RIGA, 'Allegato', F1_SIGN_ATTACH
					from CTL_DOC_SIGN  with(nolock)							
					where idHeader = @idDoc 


			-- IL FASCICOLO SECONDARIO E' IMPUTATO DALL'UTENTE SULLA GARA 
			-- recupero il fascicolo secondrio della gara, già recuperato in creazione documento
			select @fascicoloSecondario = a.value 
				from CTL_DOC_Value a with(nolock) where idheader = @idDoc
				and DSE_ID='CONTRATTO' and DZT_Name='fascicoloSecondario'

			-- METADATI AGGIUNTIVI PER MANDARE IL DOCUMENTO IN CONSERVAZIONE

			-- Oggetto del Contratto
			INSERT INTO v_protgen_dati ( IdHeader, DZT_Name, Value, data )
				select top 1 @idVProtGen, 'MS_DESC_FORNITORE', isnull(Value,'Senza Descrizione'), getdate() 
					from CTL_DOC_Value with(nolock)
					where IdHeader = @idDoc and DSE_ID = 'CONTRATTO' and DZT_Name = 'BodyContratto'

			-- Valore del Contratto
			INSERT INTO v_protgen_dati ( IdHeader, DZT_Name, Value, data )
				select top 1 @idVProtGen, 'NUMERO_BU', dbo.FormatMoney( isnull(Value,0)), getdate() 
					from CTL_DOC_Value with(nolock)
					where IdHeader = @idDoc and DSE_ID = 'CONTRATTO' and DZT_Name = 'NewTotal'

			
		END --FINE IF CONTRATTO_GARA_FORN


		-----------------------------------------------------------------------------------
		-- RECUPERO LA CONFIGURAZIONE DOCER ENTRANDO PER TIPODOC , JUMPCHECK E SOTTOTIPO --
		-----------------------------------------------------------------------------------

		declare @attivo varchar(2)
		DECLARE @descFascicolo varchar(500)

		
		set @algoritmo = '-1'
		SET @descFascicolo = ''

		SELECT --@AOO = aoo,
			   --@DenomAOO = denomAOO,
			   @repertorio = repertorio,
		       @UO = uo,
			   @DenomUO = denomUO,
			   @titolario = titolario,
			   @fascicolo = fascicolo,
			   @algoritmo = algoritmo,
			   @attivo = attivo,
			   @descFascicolo = isnull(fascicolo,'')
			from Document_protocollo_docER with(nolock)
			where tipoDoc = @tipoDoc and isnull(jumpCheck,'') = @jumpCheck and isnull(sottoTipo,'') = @sottoTipo and isnull(contesto,'') = @contesto and isnull(aoo,'') = isnull(@AOO,'') and deleted = 0

		-- SE NON HO TROVATO UNA CONFIGURAZIONE SEGNALO L'ERRORE
		IF @algoritmo = '-1'
		BEGIN
			raiserror ('Configurazione DocER non trovata (tabella Document_protocollo_docER) per l''id v_protgen %s. tipodoc: %s - Jumpcheck : %s - sottoTipo : %s - contesto : %s - AOO : %s', 16, 1 , @idVProtGen, @tipoDoc,  @jumpCheck, @sottoTipo, @contesto, @AOO)
			return 99
		END

		-- RECUPERO LA DESCRIZIONE DELL'AOO DAL DOMINIO DELLE AOO
		IF EXISTS ( select DMV_DESCML from lib_domainvalues with(nolock) where dmv_dm_id = 'aoo' and dmv_cod = @AOO )
		BEGIN
			select @DenomAOO = DMV_DESCML from lib_domainvalues with(nolock) where dmv_dm_id = 'aoo' and dmv_cod = @AOO
		END

		--------------------------------------------------------------------------------------------------------------------
		-- RECUPERO EVENTUALI METADATI SPECIFICI DEL DOCUMENTO, SE PRESENTI, PER SOVRASCRIVERLI RISPETTO AI METADATI BASE --
		--------------------------------------------------------------------------------------------------------------------
		SELECT  @fascicoloSecondario = isnull(fascicoloSecondario,'') ,
				@titolarioSecondario = isnull(titolarioSecondario,'') ,
				@documentAOO = isnull(aoo,''),
				@documentDenomAOO = isnull(denomAOO,''),
				@documentUO = isnull(uo,''),
				@documentDenomUO = isnull(denomUO,''),
				@documentRepertorio = isnull(repertorio,'') 
			FROM Document_dati_protocollo WITH(NOLOCK)
			WHERE idheader = @idDoc

		-- i dati presenti sul documento (probabilmente imputati dall'utente) sovrascrivono quelli usati nella configurazione base DocER

		IF @documentUO <> '' 
		BEGIN
			SET @UO = @documentUO 
		END
		IF @documentDenomUO <> '' 
		BEGIN
			SET @DenomUO = @documentDenomUO 
		END
		IF @documentRepertorio <> '' 
		BEGIN
			SET @repertorio = @documentRepertorio 
		END
		--IF @documentAOO <> '' 
		--BEGIN
		--	SET @AOO = @documentAOO 
		--END
		--IF @documentDenomAOO <> '' 
		--BEGIN
		--	SET @DenomAOO = @documentDenomAOO 
		--END

		INSERT INTO v_protgen_dati( IdHeader, DZT_Name, Value, data )
							VALUES (@idVProtGen, 'attivo', @attivo , getdate() )

		INSERT INTO v_protgen_dati( IdHeader, DZT_Name, Value, data )
							VALUES (@idVProtGen, 'algoritmo', @algoritmo , getdate() )

		-- COMMENTATA QUESTA INSERT. VIENE FATTA NELLA PROTGENINSERT
		--INSERT INTO v_protgen_dati( IdHeader, DZT_Name, Value, data )
		--					VALUES (@idVProtGen, 'aoo', @AOO , getdate() )

		INSERT INTO v_protgen_dati( IdHeader, DZT_Name, Value, data )
							VALUES (@idVProtGen, 'denomAOO', @DenomAOO , getdate() )

		INSERT INTO v_protgen_dati( IdHeader, DZT_Name, Value, data )
							VALUES (@idVProtGen, 'uo', @UO, getdate() )

		INSERT INTO v_protgen_dati( IdHeader, DZT_Name, Value, data )
							VALUES (@idVProtGen, 'denomUO', @DenomUO , getdate() )

		INSERT INTO v_protgen_dati( IdHeader, DZT_Name, Value, data )
							VALUES (@idVProtGen, 'Repertorio', @repertorio  , getdate() )


		IF ( isnull(@userIdAzi,0) <> 0 )
		BEGIN
		
			-- aggiungo in tabella il mittente (o il destinatario) del protocollo ( a seconda che il protocollo sia in uscita o in ingresso )
			INSERT INTO v_protgen_dati( IdHeader, DZT_Name, Value, data )
				VALUES (@idVProtGen, 'IdAzi', cast(@userIdAzi as varchar(50)) , getdate() )

		END

		-- se c'era gia un fascicolo usato sul documento principale.. uso quello, altrimenti quello preso dalla configurazione DocER
		-- ( per gestire i casi di imputazione del fascicolo )
		INSERT INTO v_protgen_dati( IdHeader, DZT_Name, Value, data )
							VALUES (@idVProtGen, 'FascicoloGenerale', dbo.NormalizzaFascicolo( isnull(@fascicoloGenerale,@fascicolo) ) , getdate() )

		INSERT INTO v_protgen_dati( IdHeader, DZT_Name, Value, data )
							VALUES (@idVProtGen, 'titolario', isnull(@titolarioGenerale, @titolario) , getdate() )

		INSERT INTO v_protgen_dati( IdHeader, DZT_Name, Value, data )
							VALUES (@idVProtGen, 'fascicoloSecondario', dbo.NormalizzaFascicolo(@fascicoloSecondario ) , getdate() )

		INSERT INTO v_protgen_dati( IdHeader, DZT_Name, Value, data )
							VALUES (@idVProtGen, 'titolarioSecondario', @titolarioSecondario , getdate() )	

		INSERT INTO v_protgen_dati( IdHeader, DZT_Name, Value, data )
							VALUES (@idVProtGen, 'descFascicolo', @descFascicolo , getdate() )	


	END
	ELSE
	BEGIN
		SELECT 'SYS_ATTIVA_PROTOCOLLO_GENERALE non attiva'
	END

		
END








































GO
