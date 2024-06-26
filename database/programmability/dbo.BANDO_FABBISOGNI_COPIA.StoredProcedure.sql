USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[BANDO_FABBISOGNI_COPIA]    Script Date: 5/16/2024 2:38:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE PROCEDURE [dbo].[BANDO_FABBISOGNI_COPIA] ( @idDoc int , @IdUser int ,@IdNewDoc int = 0 output, @copiaRicercaOE int = 0 )
AS
BEGIN

	--DECLARE @IdNewDoc as int
	DECLARE @Id as int
	DECLARE @IdNewRicerca as int
	DECLARE @IdOldRicerca as int
	DECLARE @IdNewMod as int
	DECLARE @IdNewModMicrolotto as int
	DECLARE @IdOLDModMicrolotto as int

	DECLARE @tipoDoc varchar(500)

	declare @prefissoTitolo nvarchar(4000)

	set @id = -1
	set @idNewRicerca = -1
	set @idOldRicerca = -1
	set @IdNewMod = -1
	set @IdNewModMicrolotto = -1
	set @IdOLDModMicrolotto = -1

	select @tipoDoc = a.TipoDoc 
		from ctl_doc a with(nolock) 
		where id = @idDoc

	-- comando di copia modifico il titolo
	
	
	SET @prefissoTitolo = 'Copia di '
	

	--copio sezione DOCUMENT
	insert into CTL_DOC	(IdPfu, IdDoc, TipoDoc, StatoDoc, Data, Protocollo, PrevDoc, Deleted, Titolo, Body, Azienda, StrutturaAziendale, DataInvio, DataScadenza, ProtocolloRiferimento, ProtocolloGenerale, Fascicolo, Note, DataProtocolloGenerale, LinkedDoc, SIGN_HASH, SIGN_ATTACH, SIGN_LOCK, JumpCheck, StatoFunzionale, Destinatario_User, Destinatario_Azi, RichiestaFirma, NumeroDocumento, DataDocumento, Versione, VersioneLinkedDoc, idPfuInCharge, CanaleNotifica, URL_CLIENT, Caption)
		select 			@IdUser, IdDoc, TipoDoc, 'Saved', getdate(), '', 0, 0, dbo.Normalizza_COL_TABLE('CTL_DOC','titolo', @prefissoTitolo + Titolo ) , Body, Azienda, StrutturaAziendale, null, null, null, null, '', Note, null, LinkedDoc, '', '', 0, JumpCheck, 'InLavorazione', Destinatario_User, Destinatario_Azi, RichiestaFirma, NumeroDocumento, DataDocumento, '2', VersioneLinkedDoc, @IdUser, CanaleNotifica, URL_CLIENT, Caption
			from ctl_doc with(nolock) where id=@idDoc

	set @IdNewDoc = scope_identity()	

	--copio sezione TESTATA
	

		insert into DOCUMENT_BANDO ( idHeader, SoggettiAmmessi, ImportoBando, MaxNumeroIniziative, MaxFinanziabile, dataCreazione, DataEstenzioneInizio, DataEstenzioneFine, FAX, DataRiferimentoInizio, DataRiferimentoFine, DataPresentazioneRisposte, StatoBando, Ufficio, NumeroBUR, DataBUR, dgrN, dgrDel, TipoBando, TipoAppalto, RichiestaQuesito, ReceivedQuesiti, RecivedIstanze, MotivoEstensionePeriodo, ClasseIscriz, RichiediProdotti, ProceduraGara, TipoBandoGara, CriterioAggiudicazioneGara, ImportoBaseAsta, Iva, ImportoBaseAsta2, Oneri, CriterioFormulazioneOfferte, CalcoloAnomalia, OffAnomale, NumeroIndizione, DataIndizione, gg_QuesitiScadenza, DataTermineQuesiti, ClausolaFideiussoria, VisualizzaNotifiche, CUP, CIG, GG_OffIndicativa, HH_OffIndicativa, MM_OffIndicativa, DataScadenzaOffIndicativa, GG_Offerta, HH_Offerta, MM_Offerta, DataScadenzaOfferta, GG_PrimaSeduta, HH_PrimaSeduta, MM_PrimaSeduta, DataAperturaOfferte, TipoAppaltoGara, ProtocolloBando, DataRevoca, Conformita, Divisione_lotti, NumDec, DirezioneEspletante, DataProtocolloBando, ModalitadiPartecipazione, TipoIVA, EvidenzaPubblica ,Complex,RichiestaCampionatura,TipoGiudizioTecnico,TipoProceduraCaratteristica,GeneraConvenzione,TipoSceltaContraente,TipoAccordoQuadro,TipoAggiudicazione,RegoleAggiudicatari,ListaAlbi,TipologiaDiAcquisto,Appalto_Verde,Acquisto_Sociale,Motivazione_Appalto_Verde,Motivazione_Acquisto_Sociale,Riferimento_Gazzetta,Data_Pubblicazione_Gazzetta,BaseAstaUnitaria,IdentificativoIniziativa, DataTermineRispostaQuesiti, Merceologia,CPV, ModalitaAnomalia_ECO, ModalitaAnomalia_TEC)
			select @IdNewDoc, SoggettiAmmessi, ImportoBando, MaxNumeroIniziative, MaxFinanziabile, getdate(), DataEstenzioneInizio, DataEstenzioneFine, FAX, DataRiferimentoInizio, DataRiferimentoFine, NULL, 'InPreparazione', Ufficio, NumeroBUR, DataBUR, dgrN, dgrDel, TipoBando, TipoAppalto, RichiestaQuesito, 0, 0, MotivoEstensionePeriodo, ClasseIscriz, RichiediProdotti, ProceduraGara, TipoBandoGara, CriterioAggiudicazioneGara, ImportoBaseAsta, Iva, ImportoBaseAsta2, Oneri, CriterioFormulazioneOfferte, CalcoloAnomalia, OffAnomale, NumeroIndizione, DataIndizione, gg_QuesitiScadenza, NULL, ClausolaFideiussoria, VisualizzaNotifiche, CUP, CIG, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,NULL,NULL, NULL, NULL, TipoAppaltoGara, '', NULL, Conformita, Divisione_lotti, NumDec, DirezioneEspletante, null, ModalitadiPartecipazione, TipoIVA, EvidenzaPubblica,Complex,RichiestaCampionatura,TipoGiudizioTecnico,TipoProceduraCaratteristica,GeneraConvenzione,TipoSceltaContraente,TipoAccordoQuadro,TipoAggiudicazione,RegoleAggiudicatari,ListaAlbi,TipologiaDiAcquisto,Appalto_Verde,Acquisto_Sociale,Motivazione_Appalto_Verde,Motivazione_Acquisto_Sociale,Riferimento_Gazzetta,Data_Pubblicazione_Gazzetta,BaseAstaUnitaria,IdentificativoIniziativa, NULL, Merceologia,CPV, ModalitaAnomalia_ECO, ModalitaAnomalia_TEC
			from Document_Bando with(nolock) where idheader=@idDoc

	
	--copio sezione DOCUMENTAZIONE
	insert into	CTL_DOC_ALLEGATI (idHeader, Descrizione, Allegato, Obbligatorio, AnagDoc, DataEmissione, Interno, Modified, NotEditable, TipoFile, DataScadenza,DSE_ID,EvidenzaPubblica)
		select 				@IdNewDoc, Descrizione, Allegato, Obbligatorio, AnagDoc, DataEmissione, Interno, Modified, NotEditable, TipoFile, DataScadenza,DSE_ID,EvidenzaPubblica
			from CTL_DOC_ALLEGATI with(nolock) where idheader=@idDoc	

	
	--copio sezione RIFERIMENTI 
	insert into Document_Bando_Riferimenti (idHeader, idPfu, RuoloRiferimenti)
		select @IdNewDoc,@IdUser,RuoloRiferimenti from	Document_Bando_Riferimenti with(nolock) where idheader=@idDoc

	insert into Document_dati_protocollo ( idHeader)
			values (  @IdNewDoc )

	-- Tutte le sezioni salvate sulla ctl_doc_value
	insert into CTL_DOC_VALUE (IdHeader, DSE_ID, Row, DZT_Name, Value)
		select 	@IdNewDoc, DSE_ID, Row, DZT_Name, Value
			from CTL_DOC_VALUE with(nolock)	where idheader=@idDoc --and DSE_ID <> 'TESTATA_PRODOTTI'


	

	-----------------------------------------------------------------------------------------------------
	---	GENERO PER COPIA LA CONFIGURAZIONE DEL MODELLO ASSOCIATO CON TUTTO QUELLO CHE NE CONSEGUE -------
	-----------------------------------------------------------------------------------------------------

	IF EXISTS ( Select ID from ctl_doc with(nolock) where linkedDoc=@idDoc and StatoFunzionale IN ( 'Pubblicato', 'InLavorazione' ) and tipodoc like 'CONFIG_MODELLI%' and deleted = 0 )
	BEGIN		-- Aggiunto lo statoFunzionale InLavorazione nel recupero, perchè se si è aperto e salvato il modello non lo recupererei +

		declare @id_old_mod as int
		declare @cod_old_mod as varchar(4000)	
		declare @name_old_mod as varchar(4000)	

		Select top 1 @id_old_mod=id, @cod_old_mod=Titolo  
			from ctl_doc with(nolock)
			where linkedDoc=@idDoc and StatoFunzionale IN ( 'Pubblicato', 'InLavorazione' ) and tipodoc like 'CONFIG_MODELLI%' and deleted = 0 
			order by id desc

		set @name_old_mod = 'MODELLO_BASE_FABBISOGNI_' + @cod_old_mod + '%'
		
			
		-- Lascio data, dataInvio, protocollo ed idPFU uguali a quelli originali. 
		insert into ctl_doc	(IdPfu, IdDoc, TipoDoc, StatoDoc, Data, Protocollo, PrevDoc, Deleted, Titolo, Body, Azienda, StrutturaAziendale, DataInvio, DataScadenza, ProtocolloRiferimento, ProtocolloGenerale, Fascicolo, Note, DataProtocolloGenerale, LinkedDoc, SIGN_HASH, SIGN_ATTACH, SIGN_LOCK, JumpCheck, StatoFunzionale, Destinatario_User, Destinatario_Azi, RichiestaFirma, NumeroDocumento, DataDocumento, Versione, VersioneLinkedDoc, idPfuInCharge, CanaleNotifica, URL_CLIENT, Caption)
				select @IdUser, IdDoc, TipoDoc, StatoDoc, data, protocollo, 0, 0, Titolo, Body, Azienda, StrutturaAziendale, DataInvio, null, null, null, '', Note, null, @IdNewDoc, '', '', 0, JumpCheck, 'InLavorazione', Destinatario_User, Destinatario_Azi, RichiestaFirma, NumeroDocumento, DataDocumento, null, null, idPfuInCharge, CanaleNotifica, URL_CLIENT, Caption
				from ctl_doc with(nolock)
				where id = @id_old_mod

		set @IdNewMod = scope_identity()

		-- Aggiorno il codice modello con il nuovo id
		UPDATE CTL_DOC
			set titolo = replace(titolo, @idDoc,@IdNewDoc)
		WHERE ID = @IdNewMod

		UPDATE DOCUMENT_BANDO
			set TipoBando = replace(TipoBando, @idDoc,@IdNewDoc)
		WHERE idHeader = @IdNewDoc

		insert into CTL_DOC_VALUE ( IdHeader, DSE_ID, Row, DZT_Name, Value)
			select @IdNewMod, DSE_ID, Row, DZT_Name, Value
			from CTL_DOC_VALUE with(nolock)
			where idheader = @id_old_mod

		insert into Document_Vincoli ( IdHeader, Espressione, Descrizione, EsitoRiga, Seleziona)
			select @IdNewMod,Espressione, Descrizione, EsitoRiga, Seleziona
			from Document_Vincoli with(nolock)
			where IdHeader = @id_old_mod

		--copio i record nella CTL_DOC_SECTION_MODEL
		insert into CTL_DOC_SECTION_MODEL ( IdHeader, DSE_ID, MOD_Name)
			select @IdNewMod, CM.DSE_ID, MOD_Name
			from CTL_DOC_SECTION_MODEL CM with(nolock)
				inner join CTL_DOC C with(nolock) ON C.Id=@id_old_mod
				inner join LIB_DocumentSections with(nolock) on DSE_DOC_ID=C.TipoDoc and DSE_Param like '%DYNAMIC_MODEL=yes%'						
			where IdHeader = @id_old_mod and CM.DSE_ID=LIB_DocumentSections.DSE_ID
			


		-- sostituita la like con i % avanti e dietro con una solo nella parte terminale, con la speranza che sfrutti l'indice sulla tabella

		insert into CTL_Models( MOD_ID, MOD_Name, MOD_DescML, MOD_Type, MOD_Sys, MOD_help, MOD_Param, MOD_Module, MOD_Template )
			select replace(MOD_ID,@idDoc,@IdNewDoc), replace(MOD_Name,@idDoc,@IdNewDoc), replace(MOD_DescML,@idDoc,@IdNewDoc), MOD_Type, MOD_Sys, MOD_help, MOD_Param, MOD_Module, MOD_Template 
			from CTL_Models with(nolock) where mod_id like @name_old_mod


		INSERT INTO CTL_ModelAttributes ( MA_MOD_ID, MA_DZT_Name, MA_DescML, MA_Pos, MA_Len, MA_Order, MA_Module)
			select replace(MA_MOD_ID,@idDoc,@IdNewDoc), MA_DZT_Name, MA_DescML, MA_Pos, MA_Len, MA_Order, MA_Module
			from CTL_ModelAttributes with(nolock) where MA_MOD_ID like @name_old_mod

		INSERT INTO CTL_ModelAttributeProperties (MAP_MA_MOD_ID, MAP_MA_DZT_Name, MAP_Propety, MAP_Value, MAP_Module)
			select replace(MAP_MA_MOD_ID,@idDoc,@IdNewDoc), MAP_MA_DZT_Name, MAP_Propety, MAP_Value, MAP_Module
			from CTL_ModelAttributeProperties with(nolock) where MAP_MA_MOD_ID like @name_old_mod



		

		-- aggiorno la tabella del dominio
		exec INIT_DOMINIO_AttributoCriterio  @IdNewMod 
	END

	-------------------------------------------------------------------------------------------------------------------------
	------- SGANCIO IL MODELLO PRECEDENTEMENTE ASSOCIATO E ASSOCIO QUELLO NUOVO. SPECIFICO PER IL NUOVO DOCUMENTO DI COPIA --
	-------------------------------------------------------------------------------------------------------------------------
	UPDATE CTL_DOC_VALUE
		SET VALUE = @IdNewMod
	WHERE IdHeader = @IdNewDoc and DSE_ID = 'TESTATA_PRODOTTI' AND DZT_Name = 'id_modello'

	--copio modelli legati al documento e sostituisco gli eventuali riferimenti nei codici modelli
	insert into CTL_DOC_SECTION_MODEL( IdHeader, DSE_ID, MOD_Name )		
		select @IdNewMod, CM.DSE_ID, MOD_Name
			from CTL_DOC_SECTION_MODEL CM with(nolock)
				inner join CTL_DOC C with(nolock) ON C.Id=@idDoc
				inner join LIB_DocumentSections with(nolock) on DSE_DOC_ID=C.TipoDoc and DSE_Param like '%DYNAMIC_MODEL=yes%'						
			where IdHeader = @idDoc and CM.DSE_ID=LIB_DocumentSections.DSE_ID
	
	--Enrico 2017-01-16 - COMMENTATO VECCHIO MODO DI PRECARICARE I PRODOTTI DAL BANDO ALL'OFFERTA sostituito con INSERT_RECORD_NEW

	--declare @idRow INT
	--declare @NewIdRow INT

	--declare CurProg Cursor Static for 
	--		select id from Document_MicroLotti_Dettagli with(nolock) where IdHeader=@idDoc and tipoDoc = @tipoDoc order by id

	--open CurProg

	--FETCH NEXT FROM CurProg INTO @idrow

	--WHILE @@FETCH_STATUS = 0
	--BEGIN

	--	INSERT into Document_MicroLotti_Dettagli ( IdHeader,TipoDoc,StatoRiga )
	--		select @IdNewDoc , '' as TipoDoc,'' as StatoRiga

	--	set @NewIdRow=scope_identity()
				
	--	-- ricopio tutti i valori
	--	exec COPY_RECORD  'Document_MicroLotti_Dettagli'  ,@idrow  , @NewIdRow, ',Id,IdHeader,'



	--	FETCH NEXT FROM CurProg INTO @idrow

	--END 

	--CLOSE CurProg
	--DEALLOCATE CurProg	


	declare @Filter as varchar(500)
	declare @DestListField as varchar(500)

	set @Filter = ' Tipodoc=''' + @tipoDoc + ''' '
	set @DestListField = ' ''' + @tipoDoc + ''' as TipoDoc, '''' as StatoRiga '
		  
	exec INSERT_RECORD_NEW 'Document_MicroLotti_Dettagli', @idDoc, @IdNewDoc, 'IdHeader', 
						' Id,IdHeader,TipoDoc,StatoRiga ', 
						@Filter, 
						' TipoDoc, StatoRiga ', 
						@DestListField,
						' id '



	-----------------------------------
	--- RETTIFICO idHeaderLotto -------
	-----------------------------------

	select isnull(numerolotto,-1) as nl, min(id) as idX into #temp_idHeaderLotto
		from Document_MicroLotti_Dettagli with(nolock)
		where tipoDoc = @tipoDoc and IdHeader = @idNewDoc
		group by numerolotto

	update Document_MicroLotti_Dettagli 
		set idheaderlotto = a.idX
	FROM Document_MicroLotti_Dettagli 
			inner join #temp_idHeaderLotto a on isnull(numerolotto,-1) = nl 
	where tipoDoc = @tipoDoc and IdHeader = @idNewDoc 

	-----------------------------------
	--- Svuoto numero partecipanti -------
	-----------------------------------
	 update CTL_DOC_Value set value = 0 
	 where IdHeader=	@idNewDoc and 	
	   	 DSE_ID='NUMERO_PARTECIPANTI' and DZT_Name='NUMEROPARTECIPANTI'

END




















GO
