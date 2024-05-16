USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[DELTA_TED_CREATE_FROM_BANDO]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[DELTA_TED_CREATE_FROM_BANDO] ( @idDoc int , @IdUser int, @bModifica int = 0, @bRettifica int = 0, @newid as int = 0 output )
AS
BEGIN

	SET NOCOUNT ON

	declare @Id as INT
	declare @Idazi as INT
	declare @Errore as nvarchar(2000)
	--declare @newid as int
	declare @Bando as int
	declare @Rup varchar(50) = ''
	declare @RupName nvarchar(1000)
	declare @idRichiestaPubTed int = 0
	declare @idDeltaTed int = 0
	declare @TED_E_MAIL as nvarchar(500)
	declare @TED_ADDRESS as nvarchar(500)
	declare @TED_OFFICIALNAME as nvarchar(500)
	declare @TED_TOWN as nvarchar(500)
	declare @TED_COUNTRY as nvarchar(20)
	declare @TED_PHONE as nvarchar(50)
	declare @TED_FAX as nvarchar(50)
	declare @TED_POSTAL_CODE as nvarchar(50)

	set @Errore=''	

	if @bRettifica = 0
	begin

		---CERCO UN DOCUMENTO DI DELTA_TED NON ANNULLATO
		IF @bModifica = 0
			select @newId = max(id) from CTL_DOC  with(nolock) where LinkedDoc = @idDoc and deleted = 0 and TipoDoc in (  'DELTA_TED'  ) and StatoFunzionale <> 'Annullato' and isnull(JumpCheck,'') = ''
		ELSE
			select @newId = max(id) from CTL_DOC  with(nolock) where LinkedDoc = @idDoc and deleted = 0 and TipoDoc in (  'DELTA_TED'  ) and StatoFunzionale not in ( 'Inviato' , 'Annullato','Invio_con_errori' )  and JumpCheck = 'MODIFICA'

	end
	else
	begin

		select @newId = max(id) from CTL_DOC  with(nolock) where LinkedDoc = @idDoc and deleted = 0 and TipoDoc in (  'DELTA_TED'  ) and StatoFunzionale not in ( 'Inviato' , 'Annullato','Invio_con_errori' )  and JumpCheck = 'RETTIFICA'

	end

	IF @newId is null
	BEGIN

		set @Bando = @idDoc

		---------------------------------------------------------------------------------
		--- CONTROLLI/PREREQUISITI BLOCCANTI PER LA CREAZIONE DEL DOCUMENTO DELTA_TED ---
		---------------------------------------------------------------------------------

		IF NOT EXISTS ( select idRow from Document_Bando with(nolock) where idHeader = @bando and RichiestaCigSimog = 'si' )
		BEGIN
			set @Errore = 'Per l''invio dati GUUE è obbligatorio avere messo ''si'' al campo ''Richiesta CIG su SIMOG'''
		END

		if @bRettifica = 1
		begin

			select @idRichiestaPubTed = isnull(id,0) from CTL_DOC with(nolock) where LinkedDoc = @Bando and deleted = 0 and TipoDoc in (  'PUBBLICA_GARA_TED'  ) and StatoFunzionale = 'PubTed' 
			select @idDeltaTed = isnull(id,0) from CTL_DOC with(nolock) where LinkedDoc = @Bando and deleted = 0 and TipoDoc in (  'DELTA_TED'  ) and StatoFunzionale = 'Inviato' 

			IF @idRichiestaPubTed = 0
				set @Errore = 'Per effettuare la rettifica dei dati GUUE è necessario aver completato con successo la pubblicazione sulla GUUE'
		
			IF @errore = '' and @idRichiestaPubTed = 0
				set @Errore = 'Per effettuare la rettifica dei dati è necessario aver inviato con successo il documento di Dati GUUE'

		end

		declare @idDocSimog INT = NULL
		select @idDocSimog = max(id) from ctl_doc S with(nolock) where  S.LinkedDoc = @bando and S.deleted = 0 and s.TipoDoc = 'RICHIESTA_CIG' and S.StatoFunzionale =  'Inviato' 

		IF @Errore = '' and ISNULL(@idDocSimog,0) = 0
		BEGIN
			set @Errore = 'Per l''invio dati GUUE è obbligatorio avere un documento di richiesta cig nello stato di ''Inviato'''
		END

		IF @Errore = '' and EXISTS ( select idrow from Document_SIMOG_GARA with(nolock) where idHeader = @idDocSimog and dbo.TED_GET_TIPO_PROCEDURA( ID_SCELTA_CONTRAENTE ) is null )
		BEGIN
			set @Errore = 'Invio dati al GUEE non possibile. La scelta del contraente selezionata sulla richiesta CIG non è supportata dal sistema di destinazione'
		END

		select @Rup = isnull(Value,'') from ctl_doc_value  with(nolock) where idheader = @Bando and dse_id = 'InfoTec_comune' and dzt_name = 'UserRUP' 

		IF @Errore = '' and @Rup = ''
		BEGIN
			set @Errore = 'Per l''invio dati GUUE è obbligatoria la scelta del rup'
		END

		select * into #lotti from VIEW_TED_DATI_LOTTI where idGara = @Bando

		IF @Errore = '' and EXISTS ( select idGara from #lotti with(nolock) where isnull(CIG,'') = ''  )
		BEGIN
			set @Errore = 'Invio dati al GUUE non possibile. Per proseguire è necessario eseguire il comando Aggiorna Cig e Numero Gara'
		END

		IF @Errore = '' and EXISTS ( select idrow from Document_Bando with(nolock) where idHeader = @Bando and DataAperturaOfferte is null )
		BEGIN
			set @Errore = 'Invio dati al GUUE non possibile. Per proseguire è necessario valorizzare l''informazione data prima seduta'
		END

		if @Errore = ''
		begin

			if exists ( select idrow from ctl_doc_value with(nolock) where idheader = @Bando and dse_id = 'TESTATA_PRODOTTI'  and dzt_name='esitoRiga' and value like '%State_ERR%' )
				set @Errore = 'Operazione non consentita in quanto sono presenti anomalie da correggere nell''Elenco Prodotti. Prima di procedere con la richiesta, dopo aver cliccato su ok...'
		end
		

		IF @Errore = '' and @bModifica = 1
		BEGIN

			if not exists ( select id from CTL_DOC  with(nolock) where LinkedDoc = @idDoc and deleted = 0 and TipoDoc in (  'DELTA_TED'  ) and StatoFunzionale in ( 'Inviato' ,'Invio_con_errori') )
				set @Errore = 'Per effettuare la modifica occorre che prima sia stata eseguita una Richiesta invio dati GUUE'

			if @Errore = '' and exists ( select id from CTL_DOC  with(nolock) where LinkedDoc = @idDoc and deleted = 0 and TipoDoc in (  'DELTA_TED'  ) and StatoFunzionale = 'InvioInCorso' )
				set @Errore = 'Per effettuare la modifica occorre che la Richiesta invio dati GUUE abbia terminato l''invio dei dati'

		END

		-- se non sono presenti errori
		if @Errore = ''
		begin

			declare @AzioneProposta varchar(100)
			
			if @bModifica = 0 and @bRettifica = 0
				set @AzioneProposta = dbo.CNV('TED - Inserimento', 'I')
			else
				set @AzioneProposta = dbo.CNV('TED - Modifica','I')

			select @Idazi = azienda from ctl_doc with(nolock) where id = @idDoc		
			select @RupName = pfuNome from ProfiliUtente with(nolock) where IdPfu = cast( @Rup as int )

			declare @OldRichiesta INT = 0

			select @OldRichiesta = MAX(id)
				from CTL_DOC with(nolock)
				where LinkedDoc = @idDoc and deleted = 0 and TipoDoc in (  'DELTA_TED'  ) and StatoFunzionale in( 'Inviato' ,'Invio_con_errori')

			INSERT INTO CTL_DOC (IdPfu,  TipoDoc, Titolo, idpfuincharge ,Azienda ,body,LinkedDoc, JumpCheck, PrevDoc, Caption, Deleted)
				VALUES ( @IdUser,'DELTA_TED' ,case when @bRettifica = 1 then 'Richiesta rettifica dati GUUE'
												   when @bModifica = 1 then 'Richiesta modifica dati GUUE' 
												   else 'Richiesta invio dati GUUE' end, 
												@IdUser ,@Idazi ,'',@idDoc, 
												case when @bRettifica = 1 then 'RETTIFICA' 
													 when @bModifica = 1 then 'MODIFICA' 
													 else '' end, 
												@OldRichiesta,
												case when @bRettifica = 1 then 'Richiesta rettifica dati GUUE'
													 when @bModifica = 1 then 'Richiesta modifica dati GUUE' 
											    end, 1 )

			set @newId = SCOPE_IDENTITY()

			select * into #gara from VIEW_TED_DATI_GARA where id = @idDoc
			select * into #amministrazione from VIEW_TED_DATI_AMMINISTRAZIONE where IdAzi = @Idazi

			INSERT INTO Document_TED_AMMINISTRAZIONE ( [idHeader], [TED_OFFICIALNAME], [TED_NATIONALID], [TED_ADDRESS], [TED_TOWN], [TED_NUTS], [TED_POSTAL_CODE], [TED_COUNTRY], [TED_CONTACT_POINT], [TED_PHONE], [TED_FAX], [TED_E_MAIL], [TED_URL_GENERAL], [TED_URL_BUYER] ) 
					select  @newid, [TED_OFFICIALNAME], [TED_NATIONALID], [TED_ADDRESS], [TED_TOWN], [TED_NUTS], [TED_POSTAL_CODE], [TED_COUNTRY], LEFT(@RupName,300) , [TED_PHONE], [TED_FAX], [TED_E_MAIL], [TED_URL_GENERAL], [TED_URL_BUYER]
						from #amministrazione

			
			IF @bModifica = 0 
			BEGIN

				INSERT INTO Document_TED_GARA (	[idHeader], [id_gara], [TED_TITOLO_PROCEDURA_GARA], [TED_CPV_GARA], [TED_TIPO_CONTRATTO_APPALTO], [TED_MAX_LOTTI_PARTECIPAZIONE], [TED_NUM_MAX_LOTTI_PARTECIPAZIONE], [TED_NUM_MAX_LOTTI_OFFERENTE], [TED_FLAG_SA_AGG_GRUPPI_LOTTI], [TED_APPALTO_CC], [TED_URL_VERSIONE_ELETTRONICA], [TED_URL_DOC_DISPONIBILI], [TED_INFO_AGGIUNTIVE], [TED_DOCUMENTI_DISPONIBILI], [TED_TIPO_AMM_AGG], [TED_SETTORE_PRINCIPALE], [TED_ALTRO_SETTORE_PRINCIPALE], [TED_APPALTO_RINNOVABILE], [TED_TEMPO_STIMATO_PROSSIMI_BANDI], [TED_ORDINATIVO_ELETTRONICO], [TED_FATTURAZIONE_ELETTRONICA], [TED_PAGAMENTI_ELETTRONICI], [TED_INFO_ADD], [TED_REVIEW_PROCEDURE], [TED_ELENCO_CONDIZIONI], [TED_CRITERI_ECONOMICI], [TED_CRITERI_TECNICI], [TED_INTEGRAZIONE_DISABILI], [TED_LAVORI_PROTETTI], [TED_FLAG_PROFESSIONE_SERVIZI], [TED_PROFESSIONE_SERVIZI], [TED_CONDIZIONI_ESECUZIONE_CONTRATTO], [TED_OBBLIGO_NOMI_ESECUZIONE_CONTRATTO], [TED_TIPO_PROCEDURA], [TED_FLAG_PROCEDURA_ACCELLERATA], [TED_TIPO_OPERATORI_AQ], [TED_NUM_MAX_PARTECIPANTI_AQ], [TED_ALTRI_ACQUIRENTI_SIS_DINAMICO], [TED_NOTE_AQ_QUATTRO_ANNI], [TED_REDUCTION_RECOURSE], [TED_AGGIUDICAZIONE_SENZA_NEGOZIAZIONE], [TED_NOTE_ASTA_ELETTRONICA], [TED_FLAG_APP], [TED_PERIODO_VALIDITA_OFFERTE], [TED_MESI_VALIDITA_OFFERTE], [TED_DATA_APERTURA_OFFERTE], [TED_LUOGO_APERTURA_OFFERTE], [TED_PERSONE_APERTURA_OFFERTE] )
					select @newId, [id_gara], [TED_TITOLO_PROCEDURA_GARA], [TED_CPV_GARA], [TED_TIPO_CONTRATTO_APPALTO], null as [TED_MAX_LOTTI_PARTECIPAZIONE], [TED_NUM_MAX_LOTTI_PARTECIPAZIONE], [TED_NUM_MAX_LOTTI_OFFERENTE], [TED_FLAG_SA_AGG_GRUPPI_LOTTI], [TED_APPALTO_CC], [TED_URL_VERSIONE_ELETTRONICA], [TED_URL_DOC_DISPONIBILI], [TED_INFO_AGGIUNTIVE], [TED_DOCUMENTI_DISPONIBILI], [TED_TIPO_AMM_AGG], [TED_SETTORE_PRINCIPALE], [TED_ALTRO_SETTORE_PRINCIPALE], [TED_APPALTO_RINNOVABILE], [TED_TEMPO_STIMATO_PROSSIMI_BANDI], [TED_ORDINATIVO_ELETTRONICO], [TED_FATTURAZIONE_ELETTRONICA], [TED_PAGAMENTI_ELETTRONICI], [TED_INFO_ADD], [TED_REVIEW_PROCEDURE], [TED_ELENCO_CONDIZIONI], [TED_CRITERI_ECONOMICI], [TED_CRITERI_TECNICI], [TED_INTEGRAZIONE_DISABILI], [TED_LAVORI_PROTETTI], [TED_FLAG_PROFESSIONE_SERVIZI], [TED_PROFESSIONE_SERVIZI], [TED_CONDIZIONI_ESECUZIONE_CONTRATTO], [TED_OBBLIGO_NOMI_ESECUZIONE_CONTRATTO], [TED_TIPO_PROCEDURA], [TED_FLAG_PROCEDURA_ACCELLERATA], [TED_TIPO_OPERATORI_AQ], [TED_NUM_MAX_PARTECIPANTI_AQ], [TED_ALTRI_ACQUIRENTI_SIS_DINAMICO], [TED_NOTE_AQ_QUATTRO_ANNI], [TED_REDUCTION_RECOURSE], [TED_AGGIUDICAZIONE_SENZA_NEGOZIAZIONE], [TED_NOTE_ASTA_ELETTRONICA], [TED_FLAG_APP], [TED_PERIODO_VALIDITA_OFFERTE], [TED_MESI_VALIDITA_OFFERTE], [TED_DATA_APERTURA_OFFERTE], [TED_LUOGO_APERTURA_OFFERTE], [TED_PERSONE_APERTURA_OFFERTE]
						from #gara

				INSERT INTO Document_TED_LOTTI ( [idHeader],AzioneProposta,StatoRichiestaLOTTO,  CIG, [TED_LOT_NO], [TED_TITOLO_APPALTO], [TED_LUOGO_ESECUZIONE_PRINCIPALE], [TED_CRITERIO_AGG_LOTTO], [TED_TIPO_CRITERIO], [TED_CRITERIO_COSTO], [TED_CRITERIO_PREZZO], [TED_ACCETTATE_VARIANTI], [TED_DESCRIZIONE_OPZIONI], [TED_PRES_OFFERTE_CATALOGO_ELETTRONICO], [TED_FLAG_APPALTO_PROGETTO_UE], [TED_APPALTO_PROGETTO_UE], [NotEditable], IMPORTO_ATTUAZIONE_SICUREZZA,IMPORTO_LOTTO, IMPORTO_OPZIONI )
					select @newId, @AzioneProposta,'', CIG,[TED_LOT_NO], [TED_TITOLO_APPALTO], [TED_LUOGO_ESECUZIONE_PRINCIPALE], [TED_CRITERIO_AGG_LOTTO], [TED_TIPO_CRITERIO], [TED_CRITERIO_COSTO], [TED_CRITERIO_PREZZO], [TED_ACCETTATE_VARIANTI], [TED_DESCRIZIONE_OPZIONI], [TED_PRES_OFFERTE_CATALOGO_ELETTRONICO], [TED_FLAG_APPALTO_PROGETTO_UE], [TED_APPALTO_PROGETTO_UE], [NotEditable], IMPORTO_ATTUAZIONE_SICUREZZA,IMPORTO_LOTTO, IMPORTO_OPZIONI
						from #lotti
						order by TED_LOT_NO

			END
			ELSE
			BEGIN

				-- prendiamo i dati di gara dalla precedente richiesta TED
				INSERT INTO Document_TED_GARA (	[idHeader], [id_gara], [TED_TITOLO_PROCEDURA_GARA], [TED_CPV_GARA], [TED_TIPO_CONTRATTO_APPALTO], [TED_MAX_LOTTI_PARTECIPAZIONE], [TED_NUM_MAX_LOTTI_PARTECIPAZIONE], [TED_NUM_MAX_LOTTI_OFFERENTE], [TED_FLAG_SA_AGG_GRUPPI_LOTTI], [TED_APPALTO_CC], [TED_URL_VERSIONE_ELETTRONICA], [TED_URL_DOC_DISPONIBILI], [TED_INFO_AGGIUNTIVE], [TED_DOCUMENTI_DISPONIBILI], [TED_TIPO_AMM_AGG], [TED_SETTORE_PRINCIPALE], [TED_ALTRO_SETTORE_PRINCIPALE], [TED_APPALTO_RINNOVABILE], [TED_TEMPO_STIMATO_PROSSIMI_BANDI], [TED_ORDINATIVO_ELETTRONICO], [TED_FATTURAZIONE_ELETTRONICA], [TED_PAGAMENTI_ELETTRONICI], [TED_INFO_ADD], [TED_REVIEW_PROCEDURE], [TED_ELENCO_CONDIZIONI], [TED_CRITERI_ECONOMICI], [TED_CRITERI_TECNICI], [TED_INTEGRAZIONE_DISABILI], [TED_LAVORI_PROTETTI], [TED_FLAG_PROFESSIONE_SERVIZI], [TED_PROFESSIONE_SERVIZI], [TED_CONDIZIONI_ESECUZIONE_CONTRATTO], [TED_OBBLIGO_NOMI_ESECUZIONE_CONTRATTO], [TED_TIPO_PROCEDURA], [TED_FLAG_PROCEDURA_ACCELLERATA], [TED_TIPO_OPERATORI_AQ], [TED_NUM_MAX_PARTECIPANTI_AQ], [TED_ALTRI_ACQUIRENTI_SIS_DINAMICO], [TED_NOTE_AQ_QUATTRO_ANNI], [TED_REDUCTION_RECOURSE], [TED_AGGIUDICAZIONE_SENZA_NEGOZIAZIONE], [TED_NOTE_ASTA_ELETTRONICA], [TED_FLAG_APP], [TED_PERIODO_VALIDITA_OFFERTE], [TED_MESI_VALIDITA_OFFERTE], [TED_DATA_APERTURA_OFFERTE], [TED_LUOGO_APERTURA_OFFERTE], [TED_PERSONE_APERTURA_OFFERTE] )
					select @newId, [id_gara], [TED_TITOLO_PROCEDURA_GARA], [TED_CPV_GARA], [TED_TIPO_CONTRATTO_APPALTO],  [TED_MAX_LOTTI_PARTECIPAZIONE], [TED_NUM_MAX_LOTTI_PARTECIPAZIONE], [TED_NUM_MAX_LOTTI_OFFERENTE], [TED_FLAG_SA_AGG_GRUPPI_LOTTI], [TED_APPALTO_CC], [TED_URL_VERSIONE_ELETTRONICA], [TED_URL_DOC_DISPONIBILI], [TED_INFO_AGGIUNTIVE], [TED_DOCUMENTI_DISPONIBILI],  [TED_TIPO_AMM_AGG], [TED_SETTORE_PRINCIPALE], [TED_ALTRO_SETTORE_PRINCIPALE], [TED_APPALTO_RINNOVABILE], [TED_TEMPO_STIMATO_PROSSIMI_BANDI], [TED_ORDINATIVO_ELETTRONICO], [TED_FATTURAZIONE_ELETTRONICA], [TED_PAGAMENTI_ELETTRONICI], [TED_INFO_ADD], [TED_REVIEW_PROCEDURE], [TED_ELENCO_CONDIZIONI], [TED_CRITERI_ECONOMICI], [TED_CRITERI_TECNICI], [TED_INTEGRAZIONE_DISABILI], [TED_LAVORI_PROTETTI], [TED_FLAG_PROFESSIONE_SERVIZI], [TED_PROFESSIONE_SERVIZI], [TED_CONDIZIONI_ESECUZIONE_CONTRATTO], [TED_OBBLIGO_NOMI_ESECUZIONE_CONTRATTO], [TED_TIPO_PROCEDURA], [TED_FLAG_PROCEDURA_ACCELLERATA], [TED_TIPO_OPERATORI_AQ], [TED_NUM_MAX_PARTECIPANTI_AQ], [TED_ALTRI_ACQUIRENTI_SIS_DINAMICO], [TED_NOTE_AQ_QUATTRO_ANNI], [TED_REDUCTION_RECOURSE], [TED_AGGIUDICAZIONE_SENZA_NEGOZIAZIONE], [TED_NOTE_ASTA_ELETTRONICA], [TED_FLAG_APP], [TED_PERIODO_VALIDITA_OFFERTE], [TED_MESI_VALIDITA_OFFERTE], [TED_DATA_APERTURA_OFFERTE], [TED_LUOGO_APERTURA_OFFERTE], [TED_PERSONE_APERTURA_OFFERTE]
						from Document_TED_GARA with(nolock)
						where idHeader = @OldRichiesta
						
				declare @newIdGara INT
				set @newIdGara = SCOPE_IDENTITY()

				--aggiorniamo i dati di testata con i dati aggiornati della gara
				update Document_TED_GARA
						set id_gara = g.id_gara,
							TED_TITOLO_PROCEDURA_GARA = g.TED_TITOLO_PROCEDURA_GARA,
							TED_CPV_GARA = g.TED_CPV_GARA,
							TED_TIPO_CONTRATTO_APPALTO = g.TED_TIPO_CONTRATTO_APPALTO,
							--TED_MAX_LOTTI_PARTECIPAZIONE = g.TED_MAX_LOTTI_PARTECIPAZIONE,
							TED_DOCUMENTI_DISPONIBILI = g.TED_DOCUMENTI_DISPONIBILI,
							TED_DATA_APERTURA_OFFERTE = g.TED_DATA_APERTURA_OFFERTE
					from Document_TED_GARA
							cross join #gara g
					where idRow = @newIdGara

				declare @mail_amministrazione nvarchar(500)
				declare @fax_amministrazione nvarchar(500)
				declare @sito_amministrazione nvarchar(2000)
				declare @sito_buyer_amministrazione nvarchar(2000)

				select  @mail_amministrazione = TED_E_MAIL,
						@fax_amministrazione = TED_FAX,
						@sito_amministrazione = TED_URL_GENERAL,
						@sito_buyer_amministrazione = TED_URL_BUYER
					from Document_TED_AMMINISTRAZIONE with(nolock) 
					where idHeader = @OldRichiesta

				update Document_TED_AMMINISTRAZIONE
						set TED_E_MAIL = @mail_amministrazione,
							TED_FAX = @fax_amministrazione,
							TED_URL_GENERAL = @sito_amministrazione,
							TED_URL_BUYER = @sito_buyer_amministrazione
					where idHeader = @newid

				--Caso insert/update prendiamo i dati sia dalla gara che dalla precedente richiesta al TED
				INSERT INTO Document_TED_LOTTI ( [idHeader],AzioneProposta,StatoRichiestaLOTTO,  CIG, [TED_LOT_NO], [TED_TITOLO_APPALTO], [TED_LUOGO_ESECUZIONE_PRINCIPALE], [TED_CRITERIO_AGG_LOTTO], [TED_TIPO_CRITERIO], [TED_CRITERIO_COSTO], [TED_CRITERIO_PREZZO], [TED_ACCETTATE_VARIANTI], [TED_DESCRIZIONE_OPZIONI], [TED_PRES_OFFERTE_CATALOGO_ELETTRONICO], [TED_FLAG_APPALTO_PROGETTO_UE], [TED_APPALTO_PROGETTO_UE], [NotEditable], IMPORTO_ATTUAZIONE_SICUREZZA,IMPORTO_LOTTO, IMPORTO_OPZIONI )
					select @newId, @AzioneProposta,'', d.CIG, d.[TED_LOT_NO], d.[TED_TITOLO_APPALTO], d.[TED_LUOGO_ESECUZIONE_PRINCIPALE], d.[TED_CRITERIO_AGG_LOTTO], 
								l.[TED_TIPO_CRITERIO], l.[TED_CRITERIO_COSTO], l.[TED_CRITERIO_PREZZO], l.[TED_ACCETTATE_VARIANTI], 
								l.[TED_DESCRIZIONE_OPZIONI], d.[TED_PRES_OFFERTE_CATALOGO_ELETTRONICO], l.[TED_FLAG_APPALTO_PROGETTO_UE], 
								l.[TED_APPALTO_PROGETTO_UE], d.[NotEditable], d.IMPORTO_ATTUAZIONE_SICUREZZA, d.IMPORTO_LOTTO, d.IMPORTO_OPZIONI
						from #lotti d
								left join Document_TED_LOTTI l with(nolock) on  l.idheader = @OldRichiesta and d.CIG = l.CIG
						order by d.TED_LOT_NO

				declare @actionDelete varchar(200) = dbo.CNV('TED - Cancellazione','I')

				--Recuperiamo i lotti da cancellare
				INSERT INTO Document_TED_LOTTI ( [idHeader],AzioneProposta,StatoRichiestaLOTTO, CIG,NotEditable)
					select @newId, @actionDelete ,'', l.CIG, ' TED_LOT_NO TED_TITOLO_APPALTO TED_LUOGO_ESECUZIONE_PRINCIPALE TED_CRITERIO_AGG_LOTTO TED_TIPO_CRITERIO TED_CRITERIO_COSTO TED_CRITERIO_COSTO_TEC TED_CRITERIO_PREZZO TED_ACCETTATE_VARIANTI TED_DESCRIZIONE_OPZIONI TED_PRES_OFFERTE_CATALOGO_ELETTRONICO TED_FLAG_APPALTO_PROGETTO_UE TED_APPALTO_PROGETTO_UE IMPORTO_LOTTO IMPORTO_ATTUAZIONE_SICUREZZA IMPORTO_OPZIONI '
						from document_TED_LOTTI l with(nolock) 
								left join #lotti d on  d.CIG = l.CIG
						where l.idheader = @OldRichiesta  and d.CIG is null and l.AzioneProposta <> @actionDelete
						order by l.TED_LOT_NO

			END

			DECLARE @multiLotto INT = 0
			DECLARE @totLotti INT = 0

			select @totLotti = count(*) from Document_TED_LOTTI with(nolock) where idHeader = @newid

			IF @totLotti > 1
				set @multiLotto = 1

			if @multiLotto = 0
			begin

				update Document_TED_GARA
						set NotEditable = isnull(NotEditable,'') + ' TED_MAX_LOTTI_PARTECIPAZIONE TED_NUM_MAX_LOTTI_PARTECIPAZIONE TED_NUM_MAX_LOTTI_OFFERENTE ',
						TED_MAX_LOTTI_PARTECIPAZIONE=NULL,
						TED_FLAG_SA_AGG_GRUPPI_LOTTI=''
					where idHeader = @newid
				
			end

			-- Dati richiesti da IC : 
			--	Organismo responsabile delle procedure di ricorso: TAR Emilia Romagna – Bologna, Via D’Azeglio n. 54, Bologna 40123, Italia, telefono 0514293101 fax 051 307834.
			set @TED_OFFICIALNAME = ''
			select @TED_OFFICIALNAME = dbo.PARAMETRI ('AddrS6Type','TED_OFFICIALNAME','DefaultValue','TAR Emilia-Romagna, sede di Bologna',-1)
				
			INSERT INTO CTL_DOC_VALUE (IdHeader, row, DSE_ID, DZT_Name, value) 
				select @newid, 0, 'GARA_SEZ_6_2','TED_OFFICIALNAME', @TED_OFFICIALNAME --TED_OFFICIALNAME
				--	from #amministrazione

			IF @bModifica = 0 
			BEGIN
				
				--recupero valore di default dal parametro
				set @TED_E_MAIL = ''
				select @TED_E_MAIL = dbo.PARAMETRI ('AddrS6Type','TED_E_MAIL','DefaultValue','tarbo-segrprotocolloamm@ga-cert.it',-1)
				
				INSERT INTO CTL_DOC_VALUE (IdHeader, row, DSE_ID, DZT_Name, value) 
					select @newid, 0, 'GARA_SEZ_6_2','TED_E_MAIL',@TED_E_MAIL --, TED_E_MAIL
			END
			ELSE
			BEGIN
				INSERT INTO CTL_DOC_VALUE (IdHeader, row, DSE_ID, DZT_Name, value) 
					select @newid, 0, DSE_ID, DZT_Name, value
						from CTL_DOC_Value with(nolock)
						where IdHeader = @OldRichiesta and dse_id = 'GARA_SEZ_6_2' and DZT_Name = 'TED_E_MAIL'
			END


			--recupero i valori di default da parametri
			set @TED_ADDRESS = ''
			select @TED_ADDRESS = dbo.PARAMETRI ('AddrS6Type','TED_ADDRESS','DefaultValue','Via D''Azeglio n. 54',-1)
			
			INSERT INTO CTL_DOC_VALUE (IdHeader, row, DSE_ID, DZT_Name, value) 
				select @newid, 0, 'GARA_SEZ_6_2','TED_ADDRESS', @TED_ADDRESS --TED_ADDRESS
					--from #amministrazione
			
			set @TED_TOWN = ''
			select @TED_TOWN = dbo.PARAMETRI ('AddrS6Type','TED_TOWN','DefaultValue','Bologna',-1)
			
			INSERT INTO CTL_DOC_VALUE (IdHeader, row, DSE_ID, DZT_Name, value) 
				select @newid, 0, 'GARA_SEZ_6_2','TED_TOWN', @TED_TOWN--TED_TOWN
					--from #amministrazione

			set @TED_POSTAL_CODE = ''
			select @TED_POSTAL_CODE = dbo.PARAMETRI ('AddrS6Type','TED_POSTAL_CODE','DefaultValue','40123',-1)
			
			INSERT INTO CTL_DOC_VALUE (IdHeader, row, DSE_ID, DZT_Name, value) 
				select @newid, 0, 'GARA_SEZ_6_2','TED_POSTAL_CODE', @TED_POSTAL_CODE--TED_POSTAL_CODE
					--from #amministrazione
			
			set @TED_COUNTRY = ''
			select @TED_COUNTRY = dbo.PARAMETRI ('AddrS6Type','TED_COUNTRY','DefaultValue','IT',-1)

			INSERT INTO CTL_DOC_VALUE (IdHeader, row, DSE_ID, DZT_Name, value) 
				select @newid, 0, 'GARA_SEZ_6_2','TED_COUNTRY',@TED_COUNTRY--, TED_COUNTRY
					--from #amministrazione
			
			set @TED_PHONE = ''
			select @TED_PHONE = dbo.PARAMETRI ('AddrS6Type','TED_PHONE','DefaultValue','0514293101',-1)

			INSERT INTO CTL_DOC_VALUE (IdHeader, row, DSE_ID, DZT_Name, value) 
				select @newid, 0, 'GARA_SEZ_6_2','TED_PHONE',@TED_PHONE --, TED_PHONE
					--from #amministrazione
			
			set @TED_FAX = ''
			select @TED_FAX = dbo.PARAMETRI ('AddrS6Type','TED_FAX','DefaultValue','051307834',-1)

			INSERT INTO CTL_DOC_VALUE (IdHeader, row, DSE_ID, DZT_Name, value) 
				select @newid, 0, 'GARA_SEZ_6_2','TED_FAX',@TED_FAX --, TED_FAX
					--from #amministrazione

			
					
			IF @bModifica = 0 
			BEGIN
				INSERT INTO CTL_DOC_VALUE (IdHeader, row, DSE_ID, DZT_Name, value) 
					select @newid, 0, 'GARA_SEZ_6_2','TED_URL_SA','' --, TED_URL_SA
			END
			ELSE
			BEGIN
				INSERT INTO CTL_DOC_VALUE (IdHeader, row, DSE_ID, DZT_Name, value) 
					select @newid, 0, DSE_ID, DZT_Name, value
						from CTL_DOC_Value with(nolock)
						where IdHeader = @OldRichiesta and dse_id = 'GARA_SEZ_6_2' and DZT_Name = 'TED_URL_SA'
			END


			update CTL_DOC
					set Deleted = 0
				where Id = @newid

		END --if @Errore = ''

	END --IF @newId is null

	if  ISNULL(@newId,0) <> 0
	begin

		-- rirorna l'id del doc da aprire
		select @newId as id, 'DELTA_TED' as TYPE_TO
	
	end
	else
	begin

		select 'Errore' as id , @Errore as Errore

	end
END










GO
