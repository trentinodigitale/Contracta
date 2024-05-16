USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_usp_CopiaBANDO]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROC [dbo].[OLD2_usp_CopiaBANDO] (@IdDocIn INT , @IdPfuIn INT)
AS
BEGIN

DECLARE @TipoDoc	   			 VARCHAR(200)
DECLARE @IdBando	             INT
DECLARE @IdNewBando	             INT

	---recupero TipoDoc e Id del Bando che sto modificando
	Select @TipoDoc=TipoDoc,@IdBando=id from ctl_doc where id=(Select linkedDoc from ctl_doc where id=@IdDocIn)

	--Faccio la insert nella CTL_DOC del nuovo bando mettendolo a deleted=1
	INSERT into CTL_DOC ( IdPfu, IdDoc, TipoDoc, StatoDoc, Data, Protocollo, PrevDoc, Deleted, Titolo, Body, Azienda, StrutturaAziendale, DataInvio, DataScadenza, ProtocolloRiferimento, ProtocolloGenerale, Fascicolo, Note, DataProtocolloGenerale, LinkedDoc, SIGN_HASH, SIGN_ATTACH, SIGN_LOCK, JumpCheck, StatoFunzionale, Destinatario_User, Destinatario_Azi, RichiestaFirma, NumeroDocumento, DataDocumento, Versione, VersioneLinkedDoc, GUID, idPfuInCharge, CanaleNotifica, URL_CLIENT, Caption )
		select IdPfu, IdDoc, TipoDoc, StatoDoc, Data, Protocollo, PrevDoc, 1, Titolo, Body, Azienda, StrutturaAziendale, DataInvio, DataScadenza, ProtocolloRiferimento, ProtocolloGenerale, Fascicolo, Note, DataProtocolloGenerale, LinkedDoc, SIGN_HASH, SIGN_ATTACH, SIGN_LOCK, JumpCheck, StatoFunzionale, Destinatario_User, Destinatario_Azi, RichiestaFirma, NumeroDocumento, DataDocumento, 'PRECEDENTE', VersioneLinkedDoc, GUID, idPfuInCharge, CanaleNotifica, URL_CLIENT, Caption 
		from ctl_doc where id=@IdBando
	set @IdNewBando = @@identity				
	-- ricopio tutti i valori
	exec COPY_RECORD  'CTL_DOC'  ,@IdBando  , @IdNewBando , ' TipoDoc,Deleted '	
	---vado ad avvalorare PrevDoc sul BandoCorrente 
	Update ctl_doc set PrevDoc=@IdNewBando where id=@IdBando

	
	--copio sezione TESTATA
	insert into DOCUMENT_BANDO
	( idHeader, SoggettiAmmessi, ImportoBando, MaxNumeroIniziative, MaxFinanziabile, dataCreazione, DataEstenzioneInizio, DataEstenzioneFine, FAX, DataRiferimentoInizio, DataRiferimentoFine, DataPresentazioneRisposte, StatoBando, Ufficio, NumeroBUR, DataBUR, dgrN, dgrDel, TipoBando, TipoAppalto, RichiestaQuesito, ReceivedQuesiti, RecivedIstanze, MotivoEstensionePeriodo, ClasseIscriz, RichiediProdotti, ProceduraGara, TipoBandoGara, CriterioAggiudicazioneGara, ImportoBaseAsta, Iva, ImportoBaseAsta2, Oneri, CriterioFormulazioneOfferte, CalcoloAnomalia, OffAnomale, NumeroIndizione, DataIndizione, gg_QuesitiScadenza, DataTermineQuesiti, ClausolaFideiussoria, VisualizzaNotifiche, CUP, CIG, GG_OffIndicativa, HH_OffIndicativa, MM_OffIndicativa, DataScadenzaOffIndicativa, GG_Offerta, HH_Offerta, MM_Offerta, DataScadenzaOfferta, GG_PrimaSeduta, HH_PrimaSeduta, MM_PrimaSeduta, DataAperturaOfferte, TipoAppaltoGara, ProtocolloBando, DataRevoca, Conformita, Divisione_lotti, NumDec, DirezioneEspletante, DataProtocolloBando, ModalitadiPartecipazione, TipoIVA, EvidenzaPubblica, Opzioni, Complex)		
		select 
				@IdNewBando , SoggettiAmmessi, ImportoBando, MaxNumeroIniziative, MaxFinanziabile, dataCreazione, DataEstenzioneInizio, DataEstenzioneFine, FAX, DataRiferimentoInizio, DataRiferimentoFine, DataPresentazioneRisposte, StatoBando, Ufficio, NumeroBUR, DataBUR, dgrN, dgrDel, TipoBando, TipoAppalto, RichiestaQuesito, ReceivedQuesiti, RecivedIstanze, MotivoEstensionePeriodo, ClasseIscriz, RichiediProdotti, ProceduraGara, TipoBandoGara, CriterioAggiudicazioneGara, ImportoBaseAsta, Iva, ImportoBaseAsta2, Oneri, CriterioFormulazioneOfferte, CalcoloAnomalia, OffAnomale, NumeroIndizione, DataIndizione, gg_QuesitiScadenza, DataTermineQuesiti, ClausolaFideiussoria, VisualizzaNotifiche, CUP, CIG, GG_OffIndicativa, HH_OffIndicativa, MM_OffIndicativa, DataScadenzaOffIndicativa, GG_Offerta, HH_Offerta, MM_Offerta, DataScadenzaOfferta, GG_PrimaSeduta, HH_PrimaSeduta, MM_PrimaSeduta, DataAperturaOfferte, TipoAppaltoGara, ProtocolloBando, DataRevoca, Conformita, Divisione_lotti, NumDec, DirezioneEspletante, DataProtocolloBando, ModalitadiPartecipazione, TipoIVA, EvidenzaPubblica, Opzioni, Complex
			from 
				Document_Bando 
			where idheader=@IdBando
	
	--AZIONI PER I DOCUMENTI DI TIPO BANDO e BANDO_SDA
	IF ( @TipoDoc in ( 'BANDO','BANDO_SDA' ))
	BEGIN
		---Ricopio la sezione DOCUMENTAZIONE
		Insert into CTL_DOC_ALLEGATI
		( idHeader, Descrizione, Allegato, Obbligatorio, AnagDoc, DataEmissione, Interno, Modified, NotEditable, TipoFile, DataScadenza, DSE_ID)
		select @IdNewBando , Descrizione, Allegato, Obbligatorio, AnagDoc, DataEmissione, Interno, Modified, NotEditable, TipoFile, DataScadenza, DSE_ID
		from
		CTL_DOC_ALLEGATI where idheader=@IdBando

		---Ricopio la sezione DOCUMENTAZIONE_RICHIESTA
		Insert into Document_Bando_DocumentazioneRichiesta
		( idHeader, TipoInterventoDocumentazione, LineaDocumentazione, DescrizioneRichiesta, AllegatoRichiesto, Obbligatorio, TipoFile, AnagDoc, NotEditable, RichiediFirma)
		select @IdNewBando , TipoInterventoDocumentazione, LineaDocumentazione, DescrizioneRichiesta, AllegatoRichiesto, Obbligatorio, TipoFile, AnagDoc, NotEditable, RichiediFirma
		from Document_Bando_DocumentazioneRichiesta where idheader=@IdBando

		---Ricopio la sezione RIFERIMENTI
		Insert into Document_Bando_Riferimenti
		( idHeader, idPfu, RuoloRiferimenti )
		select @IdNewBando , idPfu, RuoloRiferimenti
		from Document_Bando_Riferimenti where idheader=@IdBando

		---Ricopio la sezione COMMISSIONE
		insert into Document_Bando_Commissione
		( idHeader, idPfu, RuoloCommissione )
		select @IdNewBando, idPfu, RuoloCommissione 
		from Document_Bando_Commissione  where idheader=@IdBando

		---Ricopio la sezione RISORSE
		insert into Document_Bando_LineaIntervento
		(idHeader, Linea, TipoIntervento, DocumentoIstanza, Importo, FormulaValutazione)
		select @IdNewBando, Linea, TipoIntervento, DocumentoIstanza, Importo, FormulaValutazione
		from Document_Bando_LineaIntervento  where idheader=@IdBando

		---Ricopio la sezione CONTROLLI
		insert into Document_Bando_Controlli
		( idHeader, IdControlli, Sezione, TipoControllo, Auto_Manuale, CriterioTec, CriterioDesc, RangeDa, RangeA, NumDec, TipoCampo, Sort, Sanabile, TipoInterventoControllo, LineaControllo)
		select @IdNewBando,IdControlli, Sezione, TipoControllo, Auto_Manuale, CriterioTec, CriterioDesc, RangeDa, RangeA, NumDec, TipoCampo, Sort, Sanabile, TipoInterventoControllo, LineaControllo
		from Document_Bando_Controlli  where idheader=@IdBando

		---Ricopio la sezione ISCRITTI
		insert into CTL_DOC_Destinatari
		( idHeader, IdPfu, IdAzi, aziRagioneSociale, aziPartitaIVA, aziE_Mail, aziIndirizzoLeg, aziLocalitaLeg, aziProvinciaLeg, aziStatoLeg, aziCAPLeg, aziTelefono1, aziFAX, aziDBNumber, aziSitoWeb, CDDStato, Seleziona, NumRiga, CodiceFiscale, StatoIscrizione, DataIscrizione, DataScadenzaIscrizione, DataSollecito, Id_Doc)
		select @IdNewBando , IdPfu, IdAzi, aziRagioneSociale, aziPartitaIVA, aziE_Mail, aziIndirizzoLeg, aziLocalitaLeg, aziProvinciaLeg, aziStatoLeg, aziCAPLeg, aziTelefono1, aziFAX, aziDBNumber, aziSitoWeb, CDDStato, Seleziona, NumRiga, CodiceFiscale, StatoIscrizione, DataIscrizione, DataScadenzaIscrizione, DataSollecito, Id_Doc
		from CTL_DOC_Destinatari where idheader=@IdBando
		

	END

	IF ( @TipoDoc in ( 'BANDO_SDA' ))
	BEGIN
		--RICOPIO LA TESTATA PRODOTTI
		insert into CTL_DOC_Value(IdHeader, DSE_ID, Row, DZT_Name, Value )
		Select @IdNewBando, DSE_ID, Row, DZT_Name, Value
		from CTL_DOC_Value where IdHeader=@IdBando and DSE_ID='TESTATA_PRODOTTI'

		--RICOPIO IL MODELLO DINAMICO
		insert into CTL_DOC_SECTION_MODEL ( IdHeader, DSE_ID, MOD_Name)
		select @IdNewBando,DSE_ID, MOD_Name
		from CTL_DOC_SECTION_MODEL where IdHeader=@IdBando

		--RICOPIO PRODOTTI			
		declare @IdRow2 INT
		declare @Idr INT
		declare CurProg Cursor Static for 
		select d.id as IdRow2
			from Document_MicroLotti_Dettagli d where d.idheader = @IdBando
		order by  d.Id

		open CurProg

		FETCH NEXT FROM CurProg
		INTO @IdRow2
			WHILE @@FETCH_STATUS = 0
				BEGIN
					INSERT into Document_MicroLotti_Dettagli ( IdHeader,TipoDoc,StatoRiga )
						select @IdNewBando , '' as TipoDoc,'' as StatoRiga
					set @idr = @@identity				
					-- ricopio tutti i valori
					exec COPY_RECORD  'Document_MicroLotti_Dettagli'  ,@IdRow2  , @idr , ',Id,IdHeader,'			 
						FETCH NEXT FROM CurProg
					INTO @IdRow2
					END 

		CLOSE CurProg
		DEALLOCATE CurProg		
			 
		--RICOPIO ENTI ADERENTI
		insert into CTL_DOC_Value(IdHeader, DSE_ID, Row, DZT_Name, Value )
		Select @IdNewBando, DSE_ID, Row, DZT_Name, Value
		from CTL_DOC_Value where IdHeader=@IdBando and DSE_ID='ENTI'

	END

	IF ( @TipoDoc in ( 'BANDO_SEMPLIFICATO' ,'BANDO_GARA'))
	BEGIN
		---Ricopio la sezione DOCUMENTAZIONE
		Insert into CTL_DOC_ALLEGATI
		( idHeader, Descrizione, Allegato, Obbligatorio, AnagDoc, DataEmissione, Interno, Modified, NotEditable, TipoFile, DataScadenza, DSE_ID)
		select @IdNewBando , Descrizione, Allegato, Obbligatorio, AnagDoc, DataEmissione, Interno, Modified, NotEditable, TipoFile, DataScadenza, DSE_ID
		from
		CTL_DOC_ALLEGATI where idheader=@IdBando

		---Ricopio la sezione DOCUMENTAZIONE_RICHIESTA
		Insert into Document_Bando_DocumentazioneRichiesta
		( idHeader, TipoInterventoDocumentazione, LineaDocumentazione, DescrizioneRichiesta, AllegatoRichiesto, Obbligatorio, TipoFile, AnagDoc, NotEditable, RichiediFirma)
		select @IdNewBando , TipoInterventoDocumentazione, LineaDocumentazione, DescrizioneRichiesta, AllegatoRichiesto, Obbligatorio, TipoFile, AnagDoc, NotEditable, RichiediFirma
		from Document_Bando_DocumentazioneRichiesta where idheader=@IdBando

		---Ricopio la sezione RIFERIMENTI
		Insert into Document_Bando_Riferimenti
		( idHeader, idPfu, RuoloRiferimenti )
		select @IdNewBando , idPfu, RuoloRiferimenti
		from Document_Bando_Riferimenti where idheader=@IdBando	

		---Ricopio la sezione DESTINATARI
		insert into CTL_DOC_Destinatari
		( idHeader, IdPfu, IdAzi, aziRagioneSociale, aziPartitaIVA, aziE_Mail, aziIndirizzoLeg, aziLocalitaLeg, aziProvinciaLeg, aziStatoLeg, aziCAPLeg, aziTelefono1, aziFAX, aziDBNumber, aziSitoWeb, CDDStato, Seleziona, NumRiga, CodiceFiscale, StatoIscrizione, DataIscrizione, DataScadenzaIscrizione, DataSollecito, Id_Doc)
		select @IdNewBando , IdPfu, IdAzi, aziRagioneSociale, aziPartitaIVA, aziE_Mail, aziIndirizzoLeg, aziLocalitaLeg, aziProvinciaLeg, aziStatoLeg, aziCAPLeg, aziTelefono1, aziFAX, aziDBNumber, aziSitoWeb, CDDStato, Seleziona, NumRiga, CodiceFiscale, StatoIscrizione, DataIscrizione, DataScadenzaIscrizione, DataSollecito, Id_Doc
		from CTL_DOC_Destinatari where idheader=@IdBando

		--RICOPIO I RECORD CHE SONO NELLA CTL_DOC_VALUE
		insert into CTL_DOC_Value(IdHeader, DSE_ID, Row, DZT_Name, Value )
		Select @IdNewBando, DSE_ID, Row, DZT_Name, Value
		from CTL_DOC_Value where IdHeader=@IdBando

		--RICOPIO IL MODELLO DINAMICO
		insert into CTL_DOC_SECTION_MODEL ( IdHeader, DSE_ID, MOD_Name)
		select @IdNewBando,DSE_ID, MOD_Name
		from CTL_DOC_SECTION_MODEL where IdHeader=@IdBando

		--RICOPIO PRODOTTI			
		declare @IdRow3 INT
		declare @Idr2 INT
		declare CurProg Cursor Static for 
		select d.id as IdRow3
			from Document_MicroLotti_Dettagli d where d.idheader = @IdBando and TipoDoc=@TipoDoc
		order by  d.Id

		open CurProg

		FETCH NEXT FROM CurProg
		INTO @IdRow3
			WHILE @@FETCH_STATUS = 0
				BEGIN
					INSERT into Document_MicroLotti_Dettagli ( IdHeader,TipoDoc,StatoRiga )
						select @IdNewBando , '' as TipoDoc,'' as StatoRiga
					set @idr2 = @@identity				
					-- ricopio tutti i valori
					exec COPY_RECORD  'Document_MicroLotti_Dettagli'  ,@IdRow3  , @idr2 , ',Id,IdHeader,'			 
						FETCH NEXT FROM CurProg
					INTO @IdRow3
					END 

		CLOSE CurProg
		DEALLOCATE CurProg			

	END

	IF ( @TipoDoc in ( 'BANDO_GARA' ))
	BEGIN
	--RICOPIO CRITERI
	insert into Document_Microlotto_Valutazione (idHeader, TipoDoc, CriterioValutazione, DescrizioneCriterio, PunteggioMax, Formula, AttributoCriterio )
	select @IdNewBando, TipoDoc, CriterioValutazione, DescrizioneCriterio, PunteggioMax, Formula, AttributoCriterio 
		from Document_Microlotto_Valutazione where idheader=@IdBando

	END


	--rettifico idhedaerlotto del nuovo bando creato
	-- update Document_MicroLotti_Dettagli  
	-- set idHeaderLotto = id
	-- where idHeader=@IdNewBando and TipoDoc = @TipoDoc

	----  associo le voci ai lotti
	--update Document_MicroLotti_Dettagli  
	--  set idHeaderLotto = idHL
	-- from Document_MicroLotti_Dettagli a
	--  inner join ( select idHeaderLotto as idHL ,  idHeader as idH , NumeroLotto as NL 
	--	 from Document_MicroLotti_Dettagli 
	--	 where idHeader=@IdNewBando and TipoDoc = @TipoDoc and voce = 0 
	--   ) as b on a.idHeader = b.idH and  a.NumeroLotto = b.NL
	--  where idHeader=@IdNewBando and TipoDoc = @TipoDoc


	  -----------------------------------
	--- RETTIFICO idHeaderLotto -------
	-----------------------------------

	select numerolotto as nl, min(id) as idX into #temp_idHeaderLotto
		from Document_MicroLotti_Dettagli with(nolock)
		where tipoDoc = @TipoDoc and IdHeader = @IdNewBando
		group by numerolotto

	update Document_MicroLotti_Dettagli 
		set idheaderlotto = a.idX
	FROM Document_MicroLotti_Dettagli 
			inner join #temp_idHeaderLotto a on NumeroLotto = nl 
	where tipoDoc = @TipoDoc and IdHeader = @IdNewBando 



END








GO
