USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[RETTIFICA_GARA_TED_CREATE_FROM_RETTIFICA]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









CREATE PROCEDURE [dbo].[RETTIFICA_GARA_TED_CREATE_FROM_RETTIFICA] ( @idDoc int , @IdUser int, @newId int = 0 output )
AS
BEGIN

	-- Il documento RETTIFICA_GARA_TED avrà nel campo idDoc l'id doc del documento da cui si proviene ( ad es. rettifica/proroga/modifica ) e nella colonna LinkedDoc ci sarà l'id della procedura
	--		così da far uscire questo documento nei collegati della gara

	SET NOCOUNT ON

	declare @Id as INT
	declare @Errore as nvarchar(2000)
	--declare @newid as int
	declare @Bando as int
	declare @Body nvarchar( max )
	declare @idRichiestaPubTed int = 0
	declare @idDeltaTed int = 0
	declare @idDocSimog INT = 0
	declare @TYPE_TO varchar(200)
	declare @tipoDocCollegato varchar(100) = ''
	declare @newOggetto nvarchar(max)
	declare @oldOggettoSimog nvarchar(max)

	set @Errore=''	
	set @TYPE_TO = 'RETTIFICA_GARA_TED'

	select @bando = linkedDoc, @tipoDocCollegato = TipoDoc from ctl_doc with(nolock) where id = @idDoc

	select @newId = max(id) from CTL_DOC with(nolock) where IdDoc = @idDoc and deleted = 0 and TipoDoc = @TYPE_TO and StatoFunzionale not in ( 'Annullato', 'Invio_con_errori' )

	IF isnull(@newId,0) = 0
	BEGIN

		select @idRichiestaPubTed = isnull(id,0) from CTL_DOC with(nolock) where LinkedDoc = @Bando and deleted = 0 and TipoDoc in (  'PUBBLICA_GARA_TED'  ) and StatoFunzionale = 'PubTed' 
		select @idDeltaTed = isnull(max(id),0) from CTL_DOC with(nolock) where LinkedDoc = @Bando and deleted = 0 and TipoDoc in (  'DELTA_TED'  ) and StatoFunzionale = 'Inviato' 
		select @idDocSimog = isnull(max(id),0) from CTL_DOC with(nolock) where LinkedDoc = @Bando and deleted = 0 and TipoDoc in (  'RICHIESTA_CIG'  ) and StatoFunzionale = 'Inviato' 

		IF @idRichiestaPubTed = 0
			set @Errore = 'Per effettuare la rettifica dei dati GUUE è necessario aver completato con successo la pubblicazione sulla GUUE'
		
		IF @errore = '' and @idRichiestaPubTed = 0
			set @Errore = 'Per effettuare la rettifica dei dati è necessario aver inviato con successo il documento di Dati GUUE'

		-- se non sono presenti errori
		IF @Errore = ''	
		BEGIN

			declare @bDatiModificati int = 0
									
			select * into #dati_ted from Document_TED_GARA with(nolock) where idHeader = @idDeltaTed
			select * into #dati_amm_ted from Document_TED_AMMINISTRAZIONE with(nolock) where idHeader = @idDeltaTed
			select * into #dati_ted_lotti from Document_TED_LOTTI with(nolock) where idHeader = @idDeltaTed
			select * into #dati_pub_ted from Document_TED_GARA with(nolock) where idHeader = @idRichiestaPubTed


			CREATE TABLE #dati_rettifica
			(
				[SECTION_NUMBER] [varchar](10) NOT NULL,
				[SECTION_TO_MODIFY] [varchar](400) NULL,
				[OLD_VALUE_TEXT] [nvarchar](max) NULL,
				[NEW_VALUE_TEXT] [nvarchar](max) NULL,
				[OLD_VALUE_DATE] [varchar](50) NULL,
				[NEW_VALUE_DATE] [varchar](50) NULL,
				[OLD_VALUE_TIME] [varchar](5) NULL,
				[NEW_VALUE_TIME] [varchar](5) NULL,
				[TED_RETTIFICA_SEZIONE] [nvarchar](max) NULL,
				[TED_RETTIFICA_VAL_OLD] [nvarchar](max) NULL,
				[TED_RETTIFICA_VAL_NEW] [nvarchar](max) NULL,
				[OLD_MAIN_CPV_SEC] [varchar](50) NULL,
				[NEW_MAIN_CPV_SEC] [varchar](50) NULL,
				[CIG_RETTIFICA] varchar(20) NULL
			)

			declare @descMotivoRettifica nvarchar(max) = ''

			--inseriamo l'elenco di rettifiche sulla tabella Document_TED_RETTIFICA
			--	nei campi XX_VALUE_XX	old e new, ci vanno i dati tecnici da passare all'xml del TED.
			--	nei campi TED_RETTIFICA_SEZIONE, TED_RETTIFICA_VAL_OLD e TED_RETTIFICA_VAL_NEW ci vanno i campi visuali da mostrare all'utente dove si dice a parole cosa si fa
			IF @tipoDocCollegato IN ( 'RETTIFICA_GARA', 'PROROGA_GARA' )
			BEGIN

				if @tipoDocCollegato = 'RETTIFICA_GARA'
					select @descMotivoRettifica = note from ctl_doc with(nolock) where id = @idDoc

				if @tipoDocCollegato = 'PROROGA_GARA'
					select @descMotivoRettifica = [value] from CTL_DOC_Value with(nolock) where IdHeader = @idDoc and DSE_ID = 'TESTATA' and DZT_Name = 'body'

				
				-- gli unici dati presenti sui documento di RETTIFICA_GARA e PROROGA_GARA che impatta sui dati TED sono la data che finirà nel campo 'TED_DATA_APERTURA_OFFERTE' ( inviato nel DELTA_TED )
				--	e TED_DATA_SCADENZA_PAG ( inviato nel pubblica ted )
				declare @DataSeduta as varchar(100) -- es 2022-01-14T13:00:00
				declare @DataSedutaTED as varchar(100)

				declare @DataPresentazioneRisposte as varchar(100)
				declare @DataPresentazioneRisposteTED as varchar(100)

				select @DataSeduta = LEFT([value],19)
					from ctl_doc_value with(nolock)
					where idheader = @idDoc and DSE_ID='TESTATA' and DZT_Name='DataSeduta' and value <> ''

				select @DataPresentazioneRisposte = LEFT([value],19)
					from ctl_doc_value with(nolock)
					where idheader = @idDoc and DSE_ID='TESTATA' and DZT_Name='DataPresentazioneRisposte' and value <> ''
				
				select @DataSedutaTED = CONVERT(varchar(19), TED_DATA_APERTURA_OFFERTE , 126) from #dati_ted
				select @DataPresentazioneRisposteTED = CONVERT(varchar(19), TED_DATA_SCADENZA_PAG , 126) from #dati_pub_ted	

				select @newOggetto = value from ctl_doc_value with(nolock) where IdHeader = @idDoc and DSE_ID = 'TESTATA' and DZT_Name='Oggetto'
				select @oldOggettoSimog = body from ctl_doc with(nolock) where id = @idDocSimog

				IF isnull(@DataSeduta,'') <> '' and @DataSeduta <> @DataSedutaTED
				BEGIN

					set @bDatiModificati = 1

					INSERT INTO #dati_rettifica( SECTION_NUMBER, SECTION_TO_MODIFY, OLD_VALUE_DATE, NEW_VALUE_DATE, TED_RETTIFICA_SEZIONE, TED_RETTIFICA_VAL_OLD, TED_RETTIFICA_VAL_NEW) 
								select a.REL_ValueOutput, b.DZT_DescML, @DataSedutaTED, @DataSeduta, 
										'Numero della sezione : ' + a.REL_ValueOutput + '<br/>Punto in cui si trova la data da modificare : ' + b.DZT_DescML,
										@DataSedutaTED, @DataSeduta
									from CTL_Relations a with(nolock)
											left join LIB_Dictionary b with(nolock) on b.DZT_Name = a.REL_ValueInput
									where a.REL_Type = 'TED_CAMPI_SCHEDE' and a.REL_ValueInput = 'TED_DATA_APERTURA_OFFERTE'

				END

				IF isnull(@DataPresentazioneRisposte,'') <> '' and @DataPresentazioneRisposte <> @DataPresentazioneRisposteTED
				BEGIN

					set @bDatiModificati = 1

					INSERT INTO #dati_rettifica( SECTION_NUMBER, SECTION_TO_MODIFY, OLD_VALUE_DATE, NEW_VALUE_DATE, TED_RETTIFICA_SEZIONE, TED_RETTIFICA_VAL_OLD, TED_RETTIFICA_VAL_NEW) 
								select a.REL_ValueOutput, b.DZT_DescML,@DataPresentazioneRisposteTED, @DataPresentazioneRisposte, 
										'Numero della sezione : ' + a.REL_ValueOutput + '<br/>Punto in cui si trova la data da modificare : ' + b.DZT_DescML,
										@DataPresentazioneRisposteTED,@DataPresentazioneRisposte
									from CTL_Relations a with(nolock)
											left join LIB_Dictionary b with(nolock) on b.DZT_Name = a.REL_ValueInput
									where a.REL_Type = 'TED_CAMPI_SCHEDE' and a.REL_ValueInput = 'TED_DATA_SCADENZA_PAG'

				END

				if @newOggetto <> '' and @newOggetto <> @oldOggettoSimog
				begin

					set @bDatiModificati = 1

					INSERT INTO #dati_rettifica( SECTION_NUMBER, SECTION_TO_MODIFY, OLD_VALUE_TEXT, NEW_VALUE_TEXT, TED_RETTIFICA_SEZIONE, TED_RETTIFICA_VAL_OLD, TED_RETTIFICA_VAL_NEW) 
								values ( 'II.1.4', 'Breve Descrizione', @oldOggettoSimog, @newOggetto, 
										'Numero della sezione : II.1.4 <br/>Punto in cui si trova il testo da modificare : Breve Descrizione',
										@oldOggettoSimog, @newOggetto )
									

				end


			END

			IF @tipoDocCollegato = 'BANDO_MODIFICA'
			BEGIN

				declare @newTitolo nvarchar(max) 
				declare @oldTitolo nvarchar(max)

				select @newTitolo = value from ctl_doc_value with(nolock) where IdHeader = @idDoc and DSE_ID='OGGETTO' and DZT_Name='Titolo'

				select @oldTitolo = TED_TITOLO_PROCEDURA_GARA  from #dati_ted

				select @newOggetto = value from ctl_doc_value with(nolock) where IdHeader = @idDoc and DSE_ID='OGGETTO' and DZT_Name='Oggetto'
				select @oldOggettoSimog = body from ctl_doc with(nolock) where id = @idDocSimog

				if @newTitolo <> '' and left(@newTitolo,400) <> @oldTitolo
				begin

					set @bDatiModificati = 1

					INSERT INTO #dati_rettifica( SECTION_NUMBER, SECTION_TO_MODIFY, OLD_VALUE_TEXT, NEW_VALUE_TEXT, TED_RETTIFICA_SEZIONE, TED_RETTIFICA_VAL_OLD, TED_RETTIFICA_VAL_NEW) 
								select a.REL_ValueOutput, b.DZT_DescML, @oldTitolo, @newTitolo, 
										'Numero della sezione : ' + a.REL_ValueOutput + '<br/>Punto in cui si trova il testo da modificare : ' + b.DZT_DescML,
										@oldTitolo, @newTitolo
									from CTL_Relations a with(nolock)
											left join LIB_Dictionary b with(nolock) on b.DZT_Name = a.REL_ValueInput
									where a.REL_Type = 'TED_CAMPI_SCHEDE' and a.REL_ValueInput = 'TED_TITOLO_PROCEDURA_GARA'

				end

				if @newOggetto <> '' and @newOggetto <> @oldOggettoSimog
				begin

					set @bDatiModificati = 1

					INSERT INTO #dati_rettifica( SECTION_NUMBER, SECTION_TO_MODIFY, OLD_VALUE_TEXT, NEW_VALUE_TEXT, TED_RETTIFICA_SEZIONE, TED_RETTIFICA_VAL_OLD, TED_RETTIFICA_VAL_NEW) 
								values ( 'II.1.4', 'Breve Descrizione', @oldOggettoSimog, @newOggetto, 
										'Numero della sezione : II.1.4 <br/>Punto in cui si trova il testo da modificare : Breve Descrizione',
										@oldOggettoSimog, @newOggetto )
									

				end

			END


			IF @tipoDocCollegato = 'DELTA_TED'
			BEGIN

				select * into #dati_ted_new from Document_TED_GARA with(nolock) where idHeader = @idDoc
				select * into #dati_ted_lotti_new from Document_TED_LOTTI with(nolock) where idHeader = @idDoc
				select * into #dati_amm_ted_new from Document_TED_AMMINISTRAZIONE with(nolock) where idHeader = @idDoc
				
						--sez 1
				declare	@TED_FAX varchar(1000),@TED_URL_GENERAL varchar(1000),@TED_URL_BUYER varchar(1000),@TED_APPALTO_CC varchar(1000),@TED_DOCUMENTI_DISPONIBILI varchar(1000),@TED_URL_DOC_DISPONIBILI varchar(1000), @TED_TIPO_AMM_AGG varchar(1000), @TED_SETTORE_PRINCIPALE varchar(1000), @TED_ALTRO_SETTORE_PRINCIPALE varchar(1000), @TED_E_MAIL nvarchar(500)
						
						--sez 2
				declare	@TED_TITOLO_PROCEDURA_GARA varchar(1000), @TED_CPV_GARA varchar(1000), @TED_TIPO_CONTRATTO_APPALTO varchar(1000), @TED_MAX_LOTTI_PARTECIPAZIONE varchar(1000), @TED_NUM_MAX_LOTTI_PARTECIPAZIONE varchar(1000) , @TED_NUM_MAX_LOTTI_OFFERENTE varchar(1000)

						--sez 3
				declare @TED_ELENCO_CONDIZIONI varchar(1000), @TED_INTEGRAZIONE_DISABILI varchar(1000), @TED_LAVORI_PROTETTI varchar(1000), @TED_FLAG_PROFESSIONE_SERVIZI varchar(1000), @TED_PROFESSIONE_SERVIZI varchar(1000),@TED_CONDIZIONI_ESECUZIONE_CONTRATTO varchar(1000),@TED_OBBLIGO_NOMI_ESECUZIONE_CONTRATTO varchar(1000)

						--sez 4
				declare @TED_TIPO_PROCEDURA varchar(1000),@TED_TIPO_OPERATORI_AQ  varchar(1000), @TED_NUM_MAX_PARTECIPANTI_AQ varchar(1000), @TED_ALTRI_ACQUIRENTI_SIS_DINAMICO varchar(1000), @TED_NOTE_AQ_QUATTRO_ANNI  varchar(1000), @TED_AGGIUDICAZIONE_SENZA_NEGOZIAZIONE varchar(1000),
						@TED_FLAG_APP varchar(1000), @TED_NOTE_ASTA_ELETTRONICA varchar(1000),@TED_PERIODO_VALIDITA_OFFERTE varchar(1000), @TED_MESI_VALIDITA_OFFERTE varchar(1000), @TED_LUOGO_APERTURA_OFFERTE varchar(1000), @TED_PERSONE_APERTURA_OFFERTE  varchar(1000)

						--sez 6
				declare @TED_APPALTO_RINNOVABILE  varchar(1000), @TED_TEMPO_STIMATO_PROSSIMI_BANDI varchar(1000),@TED_ORDINATIVO_ELETTRONICO varchar(1000),@TED_FATTURAZIONE_ELETTRONICA varchar(1000), @TED_PAGAMENTI_ELETTRONICI varchar(1000),@TED_INFO_ADD varchar(1000),@TED_URL_SA varchar(1000)

				select 
						--sez 1
						@TED_FAX = TED_FAX,
						@TED_E_MAIL = b.TED_E_MAIL,
						@TED_URL_GENERAL = TED_URL_GENERAL,
						@TED_URL_BUYER = TED_URL_BUYER,
						@TED_APPALTO_CC = dbo.GET_DESC_DOM_S_N(TED_APPALTO_CC), -- dom si/no
						@TED_DOCUMENTI_DISPONIBILI = dbo.GetCodDom2DescML('DOCUMENTI_DISPONIBIL', TED_DOCUMENTI_DISPONIBILI, 'I') ,  --dom
						@TED_URL_DOC_DISPONIBILI = TED_URL_DOC_DISPONIBILI,
						@TED_TIPO_AMM_AGG = dbo.GetCodDom2DescML('AmmAggType', TED_TIPO_AMM_AGG, 'I') ,  --dom
						@TED_SETTORE_PRINCIPALE = dbo.GetCodDom2DescML('SETTORE_PRINCIPALE', TED_SETTORE_PRINCIPALE, 'I') ,  --dom
						@TED_ALTRO_SETTORE_PRINCIPALE = TED_ALTRO_SETTORE_PRINCIPALE,

						--sez 2
						@TED_TITOLO_PROCEDURA_GARA = TED_TITOLO_PROCEDURA_GARA,
						@TED_CPV_GARA = cpv.DMV_CodExt, --cpv
						@TED_TIPO_CONTRATTO_APPALTO = dbo.GetCodDom2DescML('TIPO_CONTRATTO_APPAL', TED_TIPO_CONTRATTO_APPALTO, 'I') ,  --dom
						@TED_MAX_LOTTI_PARTECIPAZIONE = dbo.GetCodDom2DescML('MAX_LOTTI_PARTECIPAZ', TED_MAX_LOTTI_PARTECIPAZIONE, 'I') ,  --dom
						@TED_NUM_MAX_LOTTI_PARTECIPAZIONE = TED_NUM_MAX_LOTTI_PARTECIPAZIONE, --num
						@TED_NUM_MAX_LOTTI_OFFERENTE = TED_NUM_MAX_LOTTI_OFFERENTE, --num

						--sez 3
						@TED_ELENCO_CONDIZIONI = TED_ELENCO_CONDIZIONI, 
						@TED_INTEGRAZIONE_DISABILI = dbo.GET_DESC_DOM_S_N(TED_INTEGRAZIONE_DISABILI), -- dom si/no
						@TED_LAVORI_PROTETTI = dbo.GET_DESC_DOM_S_N(TED_LAVORI_PROTETTI), -- dom si/no
						@TED_FLAG_PROFESSIONE_SERVIZI = dbo.GET_DESC_DOM_S_N(TED_LAVORI_PROTETTI), -- dom si/no
						@TED_PROFESSIONE_SERVIZI = TED_PROFESSIONE_SERVIZI,
						@TED_CONDIZIONI_ESECUZIONE_CONTRATTO = TED_CONDIZIONI_ESECUZIONE_CONTRATTO,
						@TED_OBBLIGO_NOMI_ESECUZIONE_CONTRATTO = dbo.GET_DESC_DOM_S_N(TED_OBBLIGO_NOMI_ESECUZIONE_CONTRATTO), -- dom si/no

						--sez 4
						@TED_TIPO_PROCEDURA = dbo.GetCodDom2DescML('TED_TIPO_PROCEDURA', TED_TIPO_PROCEDURA, 'I') ,  --dom
						@TED_TIPO_OPERATORI_AQ = dbo.GetCodDom2DescML('TIPO_OPERATORI_AQ', TED_TIPO_OPERATORI_AQ, 'I') ,  --dom
						@TED_NUM_MAX_PARTECIPANTI_AQ = TED_NUM_MAX_PARTECIPANTI_AQ, --num
						@TED_ALTRI_ACQUIRENTI_SIS_DINAMICO = dbo.GET_DESC_DOM_S_N(TED_ALTRI_ACQUIRENTI_SIS_DINAMICO), -- dom si/no
						@TED_NOTE_AQ_QUATTRO_ANNI= TED_NOTE_AQ_QUATTRO_ANNI, 
						@TED_AGGIUDICAZIONE_SENZA_NEGOZIAZIONE = dbo.GET_DESC_DOM_S_N(TED_AGGIUDICAZIONE_SENZA_NEGOZIAZIONE), -- dom si/no
						@TED_FLAG_APP = dbo.GET_DESC_DOM_S_N(TED_FLAG_APP), -- dom si/no
						@TED_NOTE_ASTA_ELETTRONICA = TED_NOTE_ASTA_ELETTRONICA,
						@TED_PERIODO_VALIDITA_OFFERTE = CONVERT(varchar(19), TED_PERIODO_VALIDITA_OFFERTE , 126), -- data
						@TED_MESI_VALIDITA_OFFERTE = TED_MESI_VALIDITA_OFFERTE, -- num
						@TED_LUOGO_APERTURA_OFFERTE = TED_LUOGO_APERTURA_OFFERTE, 
						@TED_PERSONE_APERTURA_OFFERTE = TED_PERSONE_APERTURA_OFFERTE,

						--sez 6
						@TED_APPALTO_RINNOVABILE = dbo.GET_DESC_DOM_S_N(TED_APPALTO_RINNOVABILE), -- dom si/no
						@TED_TEMPO_STIMATO_PROSSIMI_BANDI = TED_TEMPO_STIMATO_PROSSIMI_BANDI,
						@TED_ORDINATIVO_ELETTRONICO = dbo.GET_DESC_DOM_S_N(TED_ORDINATIVO_ELETTRONICO), -- dom si/no
						@TED_FATTURAZIONE_ELETTRONICA = dbo.GET_DESC_DOM_S_N(TED_FATTURAZIONE_ELETTRONICA), -- dom si/no
						@TED_PAGAMENTI_ELETTRONICI = dbo.GET_DESC_DOM_S_N(TED_PAGAMENTI_ELETTRONICI), -- dom si/no
						@TED_INFO_ADD = TED_INFO_ADD,
						@TED_URL_SA = c.Value

					from #dati_ted_new a 
							inner join #dati_amm_ted_new b on b.idHeader = a.idHeader
							left join ctl_doc_value c with(nolock) on c.IdHeader = a.idHeader and c.DSE_ID = 'GARA_SEZ_6_2' and c.DZT_Name = 'TED_URL_SA'
							left join LIB_DomainValues cpv with(nolock) on cpv.DMV_DM_ID = 'CODICE_CPV' and cpv.DMV_Deleted = 0 and cpv.DMV_Cod = a.TED_CPV_GARA

				declare @TED_E_MAIL_OLD nvarchar(500),@TED_FAX_OLD varchar(1000),@TED_URL_GENERAL_OLD varchar(1000),@TED_URL_BUYER_OLD varchar(1000),@TED_APPALTO_CC_OLD varchar(1000),@TED_DOCUMENTI_DISPONIBILI_OLD varchar(1000),@TED_URL_DOC_DISPONIBILI_OLD varchar(1000), @TED_TIPO_AMM_AGG_OLD varchar(1000), @TED_SETTORE_PRINCIPALE_OLD varchar(1000), @TED_ALTRO_SETTORE_PRINCIPALE_OLD varchar(1000)
				declare	@TED_TITOLO_PROCEDURA_GARA_OLD varchar(1000), @TED_CPV_GARA_OLD varchar(1000), @TED_TIPO_CONTRATTO_APPALTO_OLD varchar(1000), @TED_MAX_LOTTI_PARTECIPAZIONE_OLD varchar(1000), @TED_NUM_MAX_LOTTI_PARTECIPAZIONE_OLD varchar(1000) , @TED_NUM_MAX_LOTTI_OFFERENTE_OLD varchar(1000)
				declare @TED_ELENCO_CONDIZIONI_OLD varchar(1000), @TED_INTEGRAZIONE_DISABILI_OLD varchar(1000), @TED_LAVORI_PROTETTI_OLD varchar(1000), @TED_FLAG_PROFESSIONE_SERVIZI_OLD varchar(1000), @TED_PROFESSIONE_SERVIZI_OLD varchar(1000),@TED_CONDIZIONI_ESECUZIONE_CONTRATTO_OLD varchar(1000),@TED_OBBLIGO_NOMI_ESECUZIONE_CONTRATTO_OLD varchar(1000)
				declare @TED_TIPO_PROCEDURA_OLD varchar(1000),@TED_TIPO_OPERATORI_AQ_OLD  varchar(1000), @TED_NUM_MAX_PARTECIPANTI_AQ_OLD varchar(1000), @TED_ALTRI_ACQUIRENTI_SIS_DINAMICO_OLD varchar(1000), @TED_NOTE_AQ_QUATTRO_ANNI_OLD  varchar(1000), @TED_AGGIUDICAZIONE_SENZA_NEGOZIAZIONE_OLD varchar(1000),
						@TED_FLAG_APP_OLD varchar(1000), @TED_NOTE_ASTA_ELETTRONICA_OLD varchar(1000),@TED_PERIODO_VALIDITA_OFFERTE_OLD varchar(1000), @TED_MESI_VALIDITA_OFFERTE_OLD varchar(1000), @TED_LUOGO_APERTURA_OFFERTE_OLD varchar(1000), @TED_PERSONE_APERTURA_OFFERTE_OLD  varchar(1000)
				declare @TED_APPALTO_RINNOVABILE_OLD  varchar(1000), @TED_TEMPO_STIMATO_PROSSIMI_BANDI_OLD varchar(1000),@TED_ORDINATIVO_ELETTRONICO_OLD varchar(1000),@TED_FATTURAZIONE_ELETTRONICA_OLD varchar(1000), @TED_PAGAMENTI_ELETTRONICI_OLD varchar(1000),@TED_INFO_ADD_OLD varchar(1000),@TED_URL_SA_OLD varchar(1000)

				select 
						--sez 1
						@TED_FAX_OLD = TED_FAX,
						@TED_E_MAIL_OLD = b.TED_E_MAIL,
						@TED_URL_GENERAL_OLD = TED_URL_GENERAL,
						@TED_URL_BUYER_OLD = TED_URL_BUYER,
						@TED_APPALTO_CC_OLD = dbo.GET_DESC_DOM_S_N(TED_APPALTO_CC), -- dom si/no
						@TED_DOCUMENTI_DISPONIBILI_OLD = dbo.GetCodDom2DescML('DOCUMENTI_DISPONIBIL', TED_DOCUMENTI_DISPONIBILI, 'I') ,  --dom
						@TED_URL_DOC_DISPONIBILI_OLD = TED_URL_DOC_DISPONIBILI,
						@TED_TIPO_AMM_AGG_OLD = dbo.GetCodDom2DescML('AmmAggType', TED_TIPO_AMM_AGG, 'I') ,  --dom
						@TED_SETTORE_PRINCIPALE_OLD = dbo.GetCodDom2DescML('SETTORE_PRINCIPALE', TED_SETTORE_PRINCIPALE, 'I') ,  --dom
						@TED_ALTRO_SETTORE_PRINCIPALE_OLD = TED_ALTRO_SETTORE_PRINCIPALE,

						--sez 2
						@TED_TITOLO_PROCEDURA_GARA_OLD = TED_TITOLO_PROCEDURA_GARA,
						@TED_CPV_GARA_OLD = cpv.DMV_CodExt, --cpv
						@TED_TIPO_CONTRATTO_APPALTO_OLD = dbo.GetCodDom2DescML('TIPO_CONTRATTO_APPAL', TED_TIPO_CONTRATTO_APPALTO, 'I') ,  --dom
						@TED_MAX_LOTTI_PARTECIPAZIONE_OLD = dbo.GetCodDom2DescML('MAX_LOTTI_PARTECIPAZ', TED_MAX_LOTTI_PARTECIPAZIONE, 'I') ,  --dom
						@TED_NUM_MAX_LOTTI_PARTECIPAZIONE_OLD = TED_NUM_MAX_LOTTI_PARTECIPAZIONE, --num
						@TED_NUM_MAX_LOTTI_OFFERENTE_OLD = TED_NUM_MAX_LOTTI_OFFERENTE, --num

						--sez 3
						@TED_ELENCO_CONDIZIONI_OLD = TED_ELENCO_CONDIZIONI, 
						@TED_INTEGRAZIONE_DISABILI_OLD = dbo.GET_DESC_DOM_S_N(TED_INTEGRAZIONE_DISABILI), -- dom si/no
						@TED_LAVORI_PROTETTI_OLD = dbo.GET_DESC_DOM_S_N(TED_LAVORI_PROTETTI), -- dom si/no
						@TED_FLAG_PROFESSIONE_SERVIZI_OLD = dbo.GET_DESC_DOM_S_N(TED_LAVORI_PROTETTI), -- dom si/no
						@TED_PROFESSIONE_SERVIZI_OLD = TED_PROFESSIONE_SERVIZI,
						@TED_CONDIZIONI_ESECUZIONE_CONTRATTO_OLD = TED_CONDIZIONI_ESECUZIONE_CONTRATTO,
						@TED_OBBLIGO_NOMI_ESECUZIONE_CONTRATTO_OLD = dbo.GET_DESC_DOM_S_N(TED_OBBLIGO_NOMI_ESECUZIONE_CONTRATTO), -- dom si/no

						--sez 4
						@TED_TIPO_PROCEDURA_OLD = dbo.GetCodDom2DescML('TED_TIPO_PROCEDURA', TED_TIPO_PROCEDURA, 'I') ,  --dom
						@TED_TIPO_OPERATORI_AQ_OLD = dbo.GetCodDom2DescML('TIPO_OPERATORI_AQ', TED_TIPO_OPERATORI_AQ, 'I') ,  --dom
						@TED_NUM_MAX_PARTECIPANTI_AQ_OLD = TED_NUM_MAX_PARTECIPANTI_AQ, --num
						@TED_ALTRI_ACQUIRENTI_SIS_DINAMICO_OLD = dbo.GET_DESC_DOM_S_N(TED_ALTRI_ACQUIRENTI_SIS_DINAMICO), -- dom si/no
						@TED_NOTE_AQ_QUATTRO_ANNI_OLD = TED_NOTE_AQ_QUATTRO_ANNI, 
						@TED_AGGIUDICAZIONE_SENZA_NEGOZIAZIONE_OLD = dbo.GET_DESC_DOM_S_N(TED_AGGIUDICAZIONE_SENZA_NEGOZIAZIONE), -- dom si/no
						@TED_FLAG_APP_OLD = dbo.GET_DESC_DOM_S_N(TED_FLAG_APP), -- dom si/no
						@TED_NOTE_ASTA_ELETTRONICA_OLD = TED_NOTE_ASTA_ELETTRONICA,
						@TED_PERIODO_VALIDITA_OFFERTE_OLD = CONVERT(varchar(19), TED_PERIODO_VALIDITA_OFFERTE , 126), -- data
						@TED_MESI_VALIDITA_OFFERTE_OLD = TED_MESI_VALIDITA_OFFERTE, -- num
						@TED_LUOGO_APERTURA_OFFERTE_OLD = TED_LUOGO_APERTURA_OFFERTE, 
						@TED_PERSONE_APERTURA_OFFERTE_OLD = TED_PERSONE_APERTURA_OFFERTE,

						--sez 6
						@TED_APPALTO_RINNOVABILE_OLD = dbo.GET_DESC_DOM_S_N(TED_APPALTO_RINNOVABILE), -- dom si/no
						@TED_TEMPO_STIMATO_PROSSIMI_BANDI_OLD = TED_TEMPO_STIMATO_PROSSIMI_BANDI,
						@TED_ORDINATIVO_ELETTRONICO_OLD = dbo.GET_DESC_DOM_S_N(TED_ORDINATIVO_ELETTRONICO), -- dom si/no
						@TED_FATTURAZIONE_ELETTRONICA_OLD = dbo.GET_DESC_DOM_S_N(TED_FATTURAZIONE_ELETTRONICA), -- dom si/no
						@TED_PAGAMENTI_ELETTRONICI_OLD = dbo.GET_DESC_DOM_S_N(TED_PAGAMENTI_ELETTRONICI), -- dom si/no
						@TED_INFO_ADD_OLD = TED_INFO_ADD,
						@TED_URL_SA_OLD = c.Value

					from #dati_ted a 
							inner join #dati_amm_ted b on b.idHeader = a.idHeader
							left join ctl_doc_value c with(nolock) on c.IdHeader = a.idHeader and c.DSE_ID = 'GARA_SEZ_6_2' and c.DZT_Name = 'TED_URL_SA'
							left join LIB_DomainValues cpv with(nolock) on cpv.DMV_DM_ID = 'CODICE_CPV' and cpv.DMV_Deleted = 0 and cpv.DMV_Cod = a.TED_CPV_GARA

				if @TED_FAX <> @TED_FAX_OLD
				begin

					set @bDatiModificati = 1

					INSERT INTO #dati_rettifica( SECTION_NUMBER, SECTION_TO_MODIFY, OLD_VALUE_TEXT, NEW_VALUE_TEXT, TED_RETTIFICA_SEZIONE, TED_RETTIFICA_VAL_OLD, TED_RETTIFICA_VAL_NEW) 
								select a.REL_ValueOutput, b.DZT_DescML, 
										@TED_FAX_OLD, @TED_FAX, 
										'Numero della sezione : ' + a.REL_ValueOutput + '<br/>Punto in cui si trova il testo da modificare : ' + b.DZT_DescML,
										@TED_FAX_OLD, @TED_FAX
									from CTL_Relations a with(nolock)
											left join LIB_Dictionary b with(nolock) on b.DZT_Name = a.REL_ValueInput
									where a.REL_Type = 'TED_CAMPI_SCHEDE' and a.REL_ValueInput = 'TED_FAX'

				end

				if @TED_E_MAIL <> @TED_E_MAIL_OLD
				begin

					set @bDatiModificati = 1

					INSERT INTO #dati_rettifica( SECTION_NUMBER, SECTION_TO_MODIFY, OLD_VALUE_TEXT, NEW_VALUE_TEXT, TED_RETTIFICA_SEZIONE, TED_RETTIFICA_VAL_OLD, TED_RETTIFICA_VAL_NEW) 
								select a.REL_ValueOutput, b.DZT_DescML, 
										@TED_E_MAIL_OLD, @TED_E_MAIL, 
										'Numero della sezione : ' + a.REL_ValueOutput + '<br/>Punto in cui si trova il testo da modificare : ' + b.DZT_DescML,
										@TED_E_MAIL_OLD, @TED_E_MAIL
									from CTL_Relations a with(nolock)
											left join LIB_Dictionary b with(nolock) on b.DZT_Name = a.REL_ValueInput
									where a.REL_Type = 'TED_CAMPI_SCHEDE' and a.REL_ValueInput = 'TED_E_MAIL'

				end

				if @TED_URL_GENERAL <> @TED_URL_GENERAL_OLD
				begin

					set @bDatiModificati = 1

					INSERT INTO #dati_rettifica( SECTION_NUMBER, SECTION_TO_MODIFY, OLD_VALUE_TEXT, NEW_VALUE_TEXT, TED_RETTIFICA_SEZIONE, TED_RETTIFICA_VAL_OLD, TED_RETTIFICA_VAL_NEW) 
								select a.REL_ValueOutput, b.DZT_DescML, 
										@TED_URL_GENERAL_OLD, @TED_URL_GENERAL, 
										'Numero della sezione : ' + a.REL_ValueOutput + '<br/>Punto in cui si trova il testo da modificare : ' + b.DZT_DescML,
										@TED_URL_GENERAL_OLD, @TED_URL_GENERAL
									from CTL_Relations a with(nolock)
											left join LIB_Dictionary b with(nolock) on b.DZT_Name = a.REL_ValueInput
									where a.REL_Type = 'TED_CAMPI_SCHEDE' and a.REL_ValueInput = 'TED_URL_GENERAL'

				end

				if @TED_URL_BUYER <> @TED_URL_BUYER_OLD
				begin

					set @bDatiModificati = 1

					INSERT INTO #dati_rettifica( SECTION_NUMBER, SECTION_TO_MODIFY, OLD_VALUE_TEXT, NEW_VALUE_TEXT, TED_RETTIFICA_SEZIONE, TED_RETTIFICA_VAL_OLD, TED_RETTIFICA_VAL_NEW) 
								select a.REL_ValueOutput, b.DZT_DescML, 
										@TED_URL_BUYER_OLD, @TED_URL_BUYER, 
										'Numero della sezione : ' + a.REL_ValueOutput + '<br/>Punto in cui si trova il testo da modificare : ' + b.DZT_DescML,
										@TED_URL_BUYER_OLD, @TED_URL_BUYER
									from CTL_Relations a with(nolock)
											left join LIB_Dictionary b with(nolock) on b.DZT_Name = a.REL_ValueInput
									where a.REL_Type = 'TED_CAMPI_SCHEDE' and a.REL_ValueInput = 'TED_URL_BUYER'

				end

				if @TED_APPALTO_CC <> @TED_APPALTO_CC_OLD
				begin

					set @bDatiModificati = 1

					INSERT INTO #dati_rettifica( SECTION_NUMBER, SECTION_TO_MODIFY, OLD_VALUE_TEXT, NEW_VALUE_TEXT, TED_RETTIFICA_SEZIONE, TED_RETTIFICA_VAL_OLD, TED_RETTIFICA_VAL_NEW) 
								select a.REL_ValueOutput, b.DZT_DescML, 
										@TED_APPALTO_CC_OLD, @TED_APPALTO_CC, 
										'Numero della sezione : ' + a.REL_ValueOutput + '<br/>Punto in cui si trova il testo da modificare : ' + b.DZT_DescML,
										@TED_APPALTO_CC_OLD, @TED_APPALTO_CC
									from CTL_Relations a with(nolock)
											left join LIB_Dictionary b with(nolock) on b.DZT_Name = a.REL_ValueInput
									where a.REL_Type = 'TED_CAMPI_SCHEDE' and a.REL_ValueInput = 'TED_APPALTO_CC'

				end

				if @TED_DOCUMENTI_DISPONIBILI <> @TED_DOCUMENTI_DISPONIBILI_OLD
				begin

					set @bDatiModificati = 1

					INSERT INTO #dati_rettifica( SECTION_NUMBER, SECTION_TO_MODIFY, OLD_VALUE_TEXT, NEW_VALUE_TEXT, TED_RETTIFICA_SEZIONE, TED_RETTIFICA_VAL_OLD, TED_RETTIFICA_VAL_NEW) 
								select a.REL_ValueOutput, b.DZT_DescML, 
										@TED_DOCUMENTI_DISPONIBILI_OLD, @TED_DOCUMENTI_DISPONIBILI, 
										'Numero della sezione : ' + a.REL_ValueOutput + '<br/>Punto in cui si trova il testo da modificare : ' + b.DZT_DescML,
										@TED_DOCUMENTI_DISPONIBILI_OLD, @TED_DOCUMENTI_DISPONIBILI
									from CTL_Relations a with(nolock)
											left join LIB_Dictionary b with(nolock) on b.DZT_Name = a.REL_ValueInput
									where a.REL_Type = 'TED_CAMPI_SCHEDE' and a.REL_ValueInput = 'TED_DOCUMENTI_DISPONIBILI'

				end

				if @TED_URL_DOC_DISPONIBILI <> @TED_URL_DOC_DISPONIBILI_OLD
				begin

					set @bDatiModificati = 1

					INSERT INTO #dati_rettifica( SECTION_NUMBER, SECTION_TO_MODIFY, OLD_VALUE_TEXT, NEW_VALUE_TEXT, TED_RETTIFICA_SEZIONE, TED_RETTIFICA_VAL_OLD, TED_RETTIFICA_VAL_NEW) 
								select a.REL_ValueOutput, b.DZT_DescML, 
										@TED_URL_DOC_DISPONIBILI_OLD, @TED_URL_DOC_DISPONIBILI, 
										'Numero della sezione : ' + a.REL_ValueOutput + '<br/>Punto in cui si trova il testo da modificare : ' + b.DZT_DescML,
										@TED_URL_DOC_DISPONIBILI_OLD, @TED_URL_DOC_DISPONIBILI
									from CTL_Relations a with(nolock)
											left join LIB_Dictionary b with(nolock) on b.DZT_Name = a.REL_ValueInput
									where a.REL_Type = 'TED_CAMPI_SCHEDE' and a.REL_ValueInput = 'TED_URL_DOC_DISPONIBILI'

				end

				if @TED_TIPO_AMM_AGG <> @TED_TIPO_AMM_AGG_OLD
				begin

					set @bDatiModificati = 1

					INSERT INTO #dati_rettifica( SECTION_NUMBER, SECTION_TO_MODIFY, OLD_VALUE_TEXT, NEW_VALUE_TEXT, TED_RETTIFICA_SEZIONE, TED_RETTIFICA_VAL_OLD, TED_RETTIFICA_VAL_NEW) 
								select a.REL_ValueOutput, b.DZT_DescML, 
										@TED_TIPO_AMM_AGG_OLD, @TED_TIPO_AMM_AGG, 
										'Numero della sezione : ' + a.REL_ValueOutput + '<br/>Punto in cui si trova il testo da modificare : ' + b.DZT_DescML,
										@TED_TIPO_AMM_AGG_OLD, @TED_TIPO_AMM_AGG
									from CTL_Relations a with(nolock)
											left join LIB_Dictionary b with(nolock) on b.DZT_Name = a.REL_ValueInput
									where a.REL_Type = 'TED_CAMPI_SCHEDE' and a.REL_ValueInput = 'TED_TIPO_AMM_AGG'

				end

				if @TED_SETTORE_PRINCIPALE <> @TED_SETTORE_PRINCIPALE_OLD
				begin

					set @bDatiModificati = 1

					INSERT INTO #dati_rettifica( SECTION_NUMBER, SECTION_TO_MODIFY, OLD_VALUE_TEXT, NEW_VALUE_TEXT, TED_RETTIFICA_SEZIONE, TED_RETTIFICA_VAL_OLD, TED_RETTIFICA_VAL_NEW) 
								select a.REL_ValueOutput, b.DZT_DescML, 
										@TED_SETTORE_PRINCIPALE_OLD, @TED_SETTORE_PRINCIPALE, 
										'Numero della sezione : ' + a.REL_ValueOutput + '<br/>Punto in cui si trova il testo da modificare : ' + b.DZT_DescML,
										@TED_SETTORE_PRINCIPALE_OLD, @TED_SETTORE_PRINCIPALE
									from CTL_Relations a with(nolock)
											left join LIB_Dictionary b with(nolock) on b.DZT_Name = a.REL_ValueInput
									where a.REL_Type = 'TED_CAMPI_SCHEDE' and a.REL_ValueInput = 'TED_SETTORE_PRINCIPALE'

				end

				if @TED_ALTRO_SETTORE_PRINCIPALE <> @TED_ALTRO_SETTORE_PRINCIPALE_OLD
				begin

					set @bDatiModificati = 1

					INSERT INTO #dati_rettifica( SECTION_NUMBER, SECTION_TO_MODIFY, OLD_VALUE_TEXT, NEW_VALUE_TEXT, TED_RETTIFICA_SEZIONE, TED_RETTIFICA_VAL_OLD, TED_RETTIFICA_VAL_NEW) 
								select a.REL_ValueOutput, b.DZT_DescML, 
										@TED_ALTRO_SETTORE_PRINCIPALE_OLD, @TED_ALTRO_SETTORE_PRINCIPALE, 
										'Numero della sezione : ' + a.REL_ValueOutput + '<br/>Punto in cui si trova il testo da modificare : ' + b.DZT_DescML,
										@TED_ALTRO_SETTORE_PRINCIPALE_OLD, @TED_ALTRO_SETTORE_PRINCIPALE
									from CTL_Relations a with(nolock)
											left join LIB_Dictionary b with(nolock) on b.DZT_Name = a.REL_ValueInput
									where a.REL_Type = 'TED_CAMPI_SCHEDE' and a.REL_ValueInput = 'TED_ALTRO_SETTORE_PRINCIPALE'

				end

				if @TED_TITOLO_PROCEDURA_GARA <> @TED_TITOLO_PROCEDURA_GARA_OLD
				begin

					set @bDatiModificati = 1

					INSERT INTO #dati_rettifica( SECTION_NUMBER, SECTION_TO_MODIFY, OLD_VALUE_TEXT, NEW_VALUE_TEXT, TED_RETTIFICA_SEZIONE, TED_RETTIFICA_VAL_OLD, TED_RETTIFICA_VAL_NEW) 
								select a.REL_ValueOutput, b.DZT_DescML, 
										@TED_TITOLO_PROCEDURA_GARA_OLD, @TED_TITOLO_PROCEDURA_GARA, 
										'Numero della sezione : ' + a.REL_ValueOutput + '<br/>Punto in cui si trova il testo da modificare : ' + b.DZT_DescML,
										@TED_TITOLO_PROCEDURA_GARA_OLD, @TED_TITOLO_PROCEDURA_GARA
									from CTL_Relations a with(nolock)
											left join LIB_Dictionary b with(nolock) on b.DZT_Name = a.REL_ValueInput
									where a.REL_Type = 'TED_CAMPI_SCHEDE' and a.REL_ValueInput = 'TED_TITOLO_PROCEDURA_GARA'

				end

				if @TED_CPV_GARA <> @TED_CPV_GARA_OLD
				begin

					set @bDatiModificati = 1
					-- TIPO CPV
					INSERT INTO #dati_rettifica( SECTION_NUMBER, SECTION_TO_MODIFY, OLD_MAIN_CPV_SEC, NEW_MAIN_CPV_SEC, TED_RETTIFICA_SEZIONE, TED_RETTIFICA_VAL_OLD, TED_RETTIFICA_VAL_NEW) 
								select a.REL_ValueOutput, b.DZT_DescML, 
										@TED_CPV_GARA_OLD, @TED_CPV_GARA, 
										'Numero della sezione : ' + a.REL_ValueOutput + '<br/>Punto in cui si trova il testo da modificare : ' + b.DZT_DescML,
										@TED_CPV_GARA_OLD, @TED_CPV_GARA
									from CTL_Relations a with(nolock)
											left join LIB_Dictionary b with(nolock) on b.DZT_Name = a.REL_ValueInput
									where a.REL_Type = 'TED_CAMPI_SCHEDE' and a.REL_ValueInput = 'TED_CPV_GARA'

				end

				if @TED_TIPO_CONTRATTO_APPALTO <> @TED_TIPO_CONTRATTO_APPALTO_OLD
				begin

					set @bDatiModificati = 1

					INSERT INTO #dati_rettifica( SECTION_NUMBER, SECTION_TO_MODIFY, OLD_VALUE_TEXT, NEW_VALUE_TEXT, TED_RETTIFICA_SEZIONE, TED_RETTIFICA_VAL_OLD, TED_RETTIFICA_VAL_NEW) 
								select a.REL_ValueOutput, b.DZT_DescML, 
										@TED_TIPO_CONTRATTO_APPALTO_OLD, @TED_TIPO_CONTRATTO_APPALTO, 
										'Numero della sezione : ' + a.REL_ValueOutput + '<br/>Punto in cui si trova il testo da modificare : ' + b.DZT_DescML,
										@TED_TIPO_CONTRATTO_APPALTO_OLD, @TED_TIPO_CONTRATTO_APPALTO
									from CTL_Relations a with(nolock)
											left join LIB_Dictionary b with(nolock) on b.DZT_Name = a.REL_ValueInput
									where a.REL_Type = 'TED_CAMPI_SCHEDE' and a.REL_ValueInput = 'TED_TIPO_CONTRATTO_APPALTO'

				end

				if @TED_MAX_LOTTI_PARTECIPAZIONE <> @TED_MAX_LOTTI_PARTECIPAZIONE_OLD
				begin

					set @bDatiModificati = 1

					INSERT INTO #dati_rettifica( SECTION_NUMBER, SECTION_TO_MODIFY, OLD_VALUE_TEXT, NEW_VALUE_TEXT, TED_RETTIFICA_SEZIONE, TED_RETTIFICA_VAL_OLD, TED_RETTIFICA_VAL_NEW) 
								select a.REL_ValueOutput, b.DZT_DescML, 
										@TED_MAX_LOTTI_PARTECIPAZIONE_OLD, @TED_MAX_LOTTI_PARTECIPAZIONE, 
										'Numero della sezione : ' + a.REL_ValueOutput + '<br/>Punto in cui si trova il testo da modificare : ' + b.DZT_DescML,
										@TED_MAX_LOTTI_PARTECIPAZIONE_OLD, @TED_MAX_LOTTI_PARTECIPAZIONE
									from CTL_Relations a with(nolock)
											left join LIB_Dictionary b with(nolock) on b.DZT_Name = a.REL_ValueInput
									where a.REL_Type = 'TED_CAMPI_SCHEDE' and a.REL_ValueInput = 'TED_MAX_LOTTI_PARTECIPAZIONE'

				end

				if @TED_NUM_MAX_LOTTI_PARTECIPAZIONE <> @TED_NUM_MAX_LOTTI_PARTECIPAZIONE_OLD
				begin

					set @bDatiModificati = 1

					INSERT INTO #dati_rettifica( SECTION_NUMBER, SECTION_TO_MODIFY, OLD_VALUE_TEXT, NEW_VALUE_TEXT, TED_RETTIFICA_SEZIONE, TED_RETTIFICA_VAL_OLD, TED_RETTIFICA_VAL_NEW) 
								select a.REL_ValueOutput, b.DZT_DescML, 
										@TED_NUM_MAX_LOTTI_PARTECIPAZIONE_OLD, @TED_NUM_MAX_LOTTI_PARTECIPAZIONE, 
										'Numero della sezione : ' + a.REL_ValueOutput + '<br/>Punto in cui si trova il testo da modificare : ' + b.DZT_DescML,
										@TED_NUM_MAX_LOTTI_PARTECIPAZIONE_OLD, @TED_NUM_MAX_LOTTI_PARTECIPAZIONE
									from CTL_Relations a with(nolock)
											left join LIB_Dictionary b with(nolock) on b.DZT_Name = a.REL_ValueInput
									where a.REL_Type = 'TED_CAMPI_SCHEDE' and a.REL_ValueInput = 'TED_NUM_MAX_LOTTI_PARTECIPAZIONE'

				end

				if @TED_NUM_MAX_LOTTI_OFFERENTE <> @TED_NUM_MAX_LOTTI_OFFERENTE_OLD
				begin

					set @bDatiModificati = 1

					INSERT INTO #dati_rettifica( SECTION_NUMBER, SECTION_TO_MODIFY, OLD_VALUE_TEXT, NEW_VALUE_TEXT, TED_RETTIFICA_SEZIONE, TED_RETTIFICA_VAL_OLD, TED_RETTIFICA_VAL_NEW) 
								select a.REL_ValueOutput, b.DZT_DescML, 
										@TED_NUM_MAX_LOTTI_OFFERENTE_OLD, @TED_NUM_MAX_LOTTI_OFFERENTE, 
										'Numero della sezione : ' + a.REL_ValueOutput + '<br/>Punto in cui si trova il testo da modificare : ' + b.DZT_DescML,
										@TED_NUM_MAX_LOTTI_OFFERENTE_OLD, @TED_NUM_MAX_LOTTI_OFFERENTE
									from CTL_Relations a with(nolock)
											left join LIB_Dictionary b with(nolock) on b.DZT_Name = a.REL_ValueInput
									where a.REL_Type = 'TED_CAMPI_SCHEDE' and a.REL_ValueInput = 'TED_NUM_MAX_LOTTI_OFFERENTE'

				end

				if @TED_ELENCO_CONDIZIONI <> @TED_ELENCO_CONDIZIONI_OLD
				begin

					set @bDatiModificati = 1

					INSERT INTO #dati_rettifica( SECTION_NUMBER, SECTION_TO_MODIFY, OLD_VALUE_TEXT, NEW_VALUE_TEXT, TED_RETTIFICA_SEZIONE, TED_RETTIFICA_VAL_OLD, TED_RETTIFICA_VAL_NEW) 
								select a.REL_ValueOutput, b.DZT_DescML, 
										@TED_ELENCO_CONDIZIONI_OLD, @TED_ELENCO_CONDIZIONI, 
										'Numero della sezione : ' + a.REL_ValueOutput + '<br/>Punto in cui si trova il testo da modificare : ' + b.DZT_DescML,
										@TED_ELENCO_CONDIZIONI_OLD, @TED_ELENCO_CONDIZIONI
									from CTL_Relations a with(nolock)
											left join LIB_Dictionary b with(nolock) on b.DZT_Name = a.REL_ValueInput
									where a.REL_Type = 'TED_CAMPI_SCHEDE' and a.REL_ValueInput = 'TED_ELENCO_CONDIZIONI'

				end

				if @TED_INTEGRAZIONE_DISABILI <> @TED_INTEGRAZIONE_DISABILI_OLD
				begin

					set @bDatiModificati = 1

					INSERT INTO #dati_rettifica( SECTION_NUMBER, SECTION_TO_MODIFY, OLD_VALUE_TEXT, NEW_VALUE_TEXT, TED_RETTIFICA_SEZIONE, TED_RETTIFICA_VAL_OLD, TED_RETTIFICA_VAL_NEW) 
								select a.REL_ValueOutput, b.DZT_DescML, 
										@TED_INTEGRAZIONE_DISABILI_OLD, @TED_INTEGRAZIONE_DISABILI, 
										'Numero della sezione : ' + a.REL_ValueOutput + '<br/>Punto in cui si trova il testo da modificare : ' + b.DZT_DescML,
										@TED_INTEGRAZIONE_DISABILI_OLD, @TED_INTEGRAZIONE_DISABILI
									from CTL_Relations a with(nolock)
											left join LIB_Dictionary b with(nolock) on b.DZT_Name = a.REL_ValueInput
									where a.REL_Type = 'TED_CAMPI_SCHEDE' and a.REL_ValueInput = 'TED_INTEGRAZIONE_DISABILI'

				end

				if @TED_LAVORI_PROTETTI <> @TED_LAVORI_PROTETTI_OLD
				begin

					set @bDatiModificati = 1

					INSERT INTO #dati_rettifica( SECTION_NUMBER, SECTION_TO_MODIFY, OLD_VALUE_TEXT, NEW_VALUE_TEXT, TED_RETTIFICA_SEZIONE, TED_RETTIFICA_VAL_OLD, TED_RETTIFICA_VAL_NEW) 
								select a.REL_ValueOutput, b.DZT_DescML, 
										@TED_LAVORI_PROTETTI_OLD, @TED_LAVORI_PROTETTI, 
										'Numero della sezione : ' + a.REL_ValueOutput + '<br/>Punto in cui si trova il testo da modificare : ' + b.DZT_DescML,
										@TED_LAVORI_PROTETTI_OLD, @TED_LAVORI_PROTETTI
									from CTL_Relations a with(nolock)
											left join LIB_Dictionary b with(nolock) on b.DZT_Name = a.REL_ValueInput
									where a.REL_Type = 'TED_CAMPI_SCHEDE' and a.REL_ValueInput = 'TED_LAVORI_PROTETTI'

				end

				if @TED_FLAG_PROFESSIONE_SERVIZI <> @TED_FLAG_PROFESSIONE_SERVIZI_OLD
				begin

					set @bDatiModificati = 1

					INSERT INTO #dati_rettifica( SECTION_NUMBER, SECTION_TO_MODIFY, OLD_VALUE_TEXT, NEW_VALUE_TEXT, TED_RETTIFICA_SEZIONE, TED_RETTIFICA_VAL_OLD, TED_RETTIFICA_VAL_NEW) 
								select a.REL_ValueOutput, b.DZT_DescML, 
										@TED_FLAG_PROFESSIONE_SERVIZI_OLD, @TED_FLAG_PROFESSIONE_SERVIZI, 
										'Numero della sezione : ' + a.REL_ValueOutput + '<br/>Punto in cui si trova il testo da modificare : ' + b.DZT_DescML,
										@TED_FLAG_PROFESSIONE_SERVIZI_OLD, @TED_FLAG_PROFESSIONE_SERVIZI
									from CTL_Relations a with(nolock)
											left join LIB_Dictionary b with(nolock) on b.DZT_Name = a.REL_ValueInput
									where a.REL_Type = 'TED_CAMPI_SCHEDE' and a.REL_ValueInput = 'TED_FLAG_PROFESSIONE_SERVIZI'

				end

				if @TED_PROFESSIONE_SERVIZI <> @TED_PROFESSIONE_SERVIZI_OLD
				begin

					set @bDatiModificati = 1

					INSERT INTO #dati_rettifica( SECTION_NUMBER, SECTION_TO_MODIFY, OLD_VALUE_TEXT, NEW_VALUE_TEXT, TED_RETTIFICA_SEZIONE, TED_RETTIFICA_VAL_OLD, TED_RETTIFICA_VAL_NEW) 
								select a.REL_ValueOutput, b.DZT_DescML, 
										@TED_PROFESSIONE_SERVIZI_OLD, @TED_PROFESSIONE_SERVIZI, 
										'Numero della sezione : ' + a.REL_ValueOutput + '<br/>Punto in cui si trova il testo da modificare : ' + b.DZT_DescML,
										@TED_PROFESSIONE_SERVIZI_OLD, @TED_PROFESSIONE_SERVIZI
									from CTL_Relations a with(nolock)
											left join LIB_Dictionary b with(nolock) on b.DZT_Name = a.REL_ValueInput
									where a.REL_Type = 'TED_CAMPI_SCHEDE' and a.REL_ValueInput = 'TED_PROFESSIONE_SERVIZI'

				end

				if @TED_CONDIZIONI_ESECUZIONE_CONTRATTO <> @TED_CONDIZIONI_ESECUZIONE_CONTRATTO_OLD
				begin

					set @bDatiModificati = 1

					INSERT INTO #dati_rettifica( SECTION_NUMBER, SECTION_TO_MODIFY, OLD_VALUE_TEXT, NEW_VALUE_TEXT, TED_RETTIFICA_SEZIONE, TED_RETTIFICA_VAL_OLD, TED_RETTIFICA_VAL_NEW) 
								select a.REL_ValueOutput, b.DZT_DescML, 
										@TED_CONDIZIONI_ESECUZIONE_CONTRATTO_OLD, @TED_CONDIZIONI_ESECUZIONE_CONTRATTO, 
										'Numero della sezione : ' + a.REL_ValueOutput + '<br/>Punto in cui si trova il testo da modificare : ' + b.DZT_DescML,
										@TED_CONDIZIONI_ESECUZIONE_CONTRATTO_OLD, @TED_CONDIZIONI_ESECUZIONE_CONTRATTO
									from CTL_Relations a with(nolock)
											left join LIB_Dictionary b with(nolock) on b.DZT_Name = a.REL_ValueInput
									where a.REL_Type = 'TED_CAMPI_SCHEDE' and a.REL_ValueInput = 'TED_CONDIZIONI_ESECUZIONE_CONTRATTO'

				end

				if @TED_OBBLIGO_NOMI_ESECUZIONE_CONTRATTO <> @TED_OBBLIGO_NOMI_ESECUZIONE_CONTRATTO_OLD
				begin

					set @bDatiModificati = 1

					INSERT INTO #dati_rettifica( SECTION_NUMBER, SECTION_TO_MODIFY, OLD_VALUE_TEXT, NEW_VALUE_TEXT, TED_RETTIFICA_SEZIONE, TED_RETTIFICA_VAL_OLD, TED_RETTIFICA_VAL_NEW) 
								select a.REL_ValueOutput, b.DZT_DescML, 
										@TED_OBBLIGO_NOMI_ESECUZIONE_CONTRATTO_OLD, @TED_OBBLIGO_NOMI_ESECUZIONE_CONTRATTO, 
										'Numero della sezione : ' + a.REL_ValueOutput + '<br/>Punto in cui si trova il testo da modificare : ' + b.DZT_DescML,
										@TED_OBBLIGO_NOMI_ESECUZIONE_CONTRATTO_OLD, @TED_OBBLIGO_NOMI_ESECUZIONE_CONTRATTO
									from CTL_Relations a with(nolock)
											left join LIB_Dictionary b with(nolock) on b.DZT_Name = a.REL_ValueInput
									where a.REL_Type = 'TED_CAMPI_SCHEDE' and a.REL_ValueInput = 'TED_OBBLIGO_NOMI_ESECUZIONE_CONTRATTO'

				end

				if @TED_TIPO_PROCEDURA <> @TED_TIPO_PROCEDURA_OLD
				begin

					set @bDatiModificati = 1

					INSERT INTO #dati_rettifica( SECTION_NUMBER, SECTION_TO_MODIFY, OLD_VALUE_TEXT, NEW_VALUE_TEXT, TED_RETTIFICA_SEZIONE, TED_RETTIFICA_VAL_OLD, TED_RETTIFICA_VAL_NEW) 
								select a.REL_ValueOutput, b.DZT_DescML, 
										@TED_TIPO_PROCEDURA_OLD, @TED_TIPO_PROCEDURA, 
										'Numero della sezione : ' + a.REL_ValueOutput + '<br/>Punto in cui si trova il testo da modificare : ' + b.DZT_DescML,
										@TED_TIPO_PROCEDURA_OLD, @TED_TIPO_PROCEDURA
									from CTL_Relations a with(nolock)
											left join LIB_Dictionary b with(nolock) on b.DZT_Name = a.REL_ValueInput
									where a.REL_Type = 'TED_CAMPI_SCHEDE' and a.REL_ValueInput = 'TED_TIPO_PROCEDURA'

				end

				if @TED_TIPO_OPERATORI_AQ <> @TED_TIPO_OPERATORI_AQ_OLD
				begin

					set @bDatiModificati = 1

					INSERT INTO #dati_rettifica( SECTION_NUMBER, SECTION_TO_MODIFY, OLD_VALUE_TEXT, NEW_VALUE_TEXT, TED_RETTIFICA_SEZIONE, TED_RETTIFICA_VAL_OLD, TED_RETTIFICA_VAL_NEW) 
								select a.REL_ValueOutput, b.DZT_DescML, 
										@TED_TIPO_OPERATORI_AQ_OLD, @TED_TIPO_OPERATORI_AQ, 
										'Numero della sezione : ' + a.REL_ValueOutput + '<br/>Punto in cui si trova il testo da modificare : ' + b.DZT_DescML,
										@TED_TIPO_OPERATORI_AQ_OLD, @TED_TIPO_OPERATORI_AQ
									from CTL_Relations a with(nolock)
											left join LIB_Dictionary b with(nolock) on b.DZT_Name = a.REL_ValueInput
									where a.REL_Type = 'TED_CAMPI_SCHEDE' and a.REL_ValueInput = 'TED_TIPO_OPERATORI_AQ'

				end

				if @TED_NUM_MAX_PARTECIPANTI_AQ <> @TED_NUM_MAX_PARTECIPANTI_AQ_OLD
				begin

					set @bDatiModificati = 1

					INSERT INTO #dati_rettifica( SECTION_NUMBER, SECTION_TO_MODIFY, OLD_VALUE_TEXT, NEW_VALUE_TEXT, TED_RETTIFICA_SEZIONE, TED_RETTIFICA_VAL_OLD, TED_RETTIFICA_VAL_NEW) 
								select a.REL_ValueOutput, b.DZT_DescML, 
										@TED_NUM_MAX_PARTECIPANTI_AQ_OLD, @TED_NUM_MAX_PARTECIPANTI_AQ, 
										'Numero della sezione : ' + a.REL_ValueOutput + '<br/>Punto in cui si trova il testo da modificare : ' + b.DZT_DescML,
										@TED_NUM_MAX_PARTECIPANTI_AQ_OLD, @TED_NUM_MAX_PARTECIPANTI_AQ
									from CTL_Relations a with(nolock)
											left join LIB_Dictionary b with(nolock) on b.DZT_Name = a.REL_ValueInput
									where a.REL_Type = 'TED_CAMPI_SCHEDE' and a.REL_ValueInput = 'TED_NUM_MAX_PARTECIPANTI_AQ'

				end

				if @TED_ALTRI_ACQUIRENTI_SIS_DINAMICO <> @TED_ALTRI_ACQUIRENTI_SIS_DINAMICO_OLD
				begin

					set @bDatiModificati = 1

					INSERT INTO #dati_rettifica( SECTION_NUMBER, SECTION_TO_MODIFY, OLD_VALUE_TEXT, NEW_VALUE_TEXT, TED_RETTIFICA_SEZIONE, TED_RETTIFICA_VAL_OLD, TED_RETTIFICA_VAL_NEW) 
								select a.REL_ValueOutput, b.DZT_DescML, 
										@TED_ALTRI_ACQUIRENTI_SIS_DINAMICO_OLD, @TED_ALTRI_ACQUIRENTI_SIS_DINAMICO, 
										'Numero della sezione : ' + a.REL_ValueOutput + '<br/>Punto in cui si trova il testo da modificare : ' + b.DZT_DescML,
										@TED_ALTRI_ACQUIRENTI_SIS_DINAMICO_OLD, @TED_ALTRI_ACQUIRENTI_SIS_DINAMICO
									from CTL_Relations a with(nolock)
											left join LIB_Dictionary b with(nolock) on b.DZT_Name = a.REL_ValueInput
									where a.REL_Type = 'TED_CAMPI_SCHEDE' and a.REL_ValueInput = 'TED_ALTRI_ACQUIRENTI_SIS_DINAMICO'

				end

				if @TED_NOTE_AQ_QUATTRO_ANNI <> @TED_NOTE_AQ_QUATTRO_ANNI_OLD
				begin

					set @bDatiModificati = 1

					INSERT INTO #dati_rettifica( SECTION_NUMBER, SECTION_TO_MODIFY, OLD_VALUE_TEXT, NEW_VALUE_TEXT, TED_RETTIFICA_SEZIONE, TED_RETTIFICA_VAL_OLD, TED_RETTIFICA_VAL_NEW) 
								select a.REL_ValueOutput, b.DZT_DescML, 
										@TED_NOTE_AQ_QUATTRO_ANNI_OLD, @TED_NOTE_AQ_QUATTRO_ANNI, 
										'Numero della sezione : ' + a.REL_ValueOutput + '<br/>Punto in cui si trova il testo da modificare : ' + b.DZT_DescML,
										@TED_NOTE_AQ_QUATTRO_ANNI_OLD, @TED_NOTE_AQ_QUATTRO_ANNI
									from CTL_Relations a with(nolock)
											left join LIB_Dictionary b with(nolock) on b.DZT_Name = a.REL_ValueInput
									where a.REL_Type = 'TED_CAMPI_SCHEDE' and a.REL_ValueInput = 'TED_NOTE_AQ_QUATTRO_ANNI'

				end

				if @TED_AGGIUDICAZIONE_SENZA_NEGOZIAZIONE <> @TED_AGGIUDICAZIONE_SENZA_NEGOZIAZIONE_OLD
				begin

					set @bDatiModificati = 1

					INSERT INTO #dati_rettifica( SECTION_NUMBER, SECTION_TO_MODIFY, OLD_VALUE_TEXT, NEW_VALUE_TEXT, TED_RETTIFICA_SEZIONE, TED_RETTIFICA_VAL_OLD, TED_RETTIFICA_VAL_NEW) 
								select a.REL_ValueOutput, b.DZT_DescML, 
										@TED_AGGIUDICAZIONE_SENZA_NEGOZIAZIONE_OLD, @TED_AGGIUDICAZIONE_SENZA_NEGOZIAZIONE, 
										'Numero della sezione : ' + a.REL_ValueOutput + '<br/>Punto in cui si trova il testo da modificare : ' + b.DZT_DescML,
										@TED_AGGIUDICAZIONE_SENZA_NEGOZIAZIONE_OLD, @TED_AGGIUDICAZIONE_SENZA_NEGOZIAZIONE
									from CTL_Relations a with(nolock)
											left join LIB_Dictionary b with(nolock) on b.DZT_Name = a.REL_ValueInput
									where a.REL_Type = 'TED_CAMPI_SCHEDE' and a.REL_ValueInput = 'TED_AGGIUDICAZIONE_SENZA_NEGOZIAZIONE'

				end

				if @TED_FLAG_APP <> @TED_FLAG_APP_OLD
				begin

					set @bDatiModificati = 1

					INSERT INTO #dati_rettifica( SECTION_NUMBER, SECTION_TO_MODIFY, OLD_VALUE_TEXT, NEW_VALUE_TEXT, TED_RETTIFICA_SEZIONE, TED_RETTIFICA_VAL_OLD, TED_RETTIFICA_VAL_NEW) 
								select a.REL_ValueOutput, b.DZT_DescML, 
										@TED_FLAG_APP_OLD, @TED_FLAG_APP, 
										'Numero della sezione : ' + a.REL_ValueOutput + '<br/>Punto in cui si trova il testo da modificare : ' + b.DZT_DescML,
										@TED_FLAG_APP_OLD, @TED_FLAG_APP
									from CTL_Relations a with(nolock)
											left join LIB_Dictionary b with(nolock) on b.DZT_Name = a.REL_ValueInput
									where a.REL_Type = 'TED_CAMPI_SCHEDE' and a.REL_ValueInput = 'TED_FLAG_APP'

				end

				if @TED_NOTE_ASTA_ELETTRONICA <> @TED_NOTE_ASTA_ELETTRONICA_OLD
				begin

					set @bDatiModificati = 1

					INSERT INTO #dati_rettifica( SECTION_NUMBER, SECTION_TO_MODIFY, OLD_VALUE_TEXT, NEW_VALUE_TEXT, TED_RETTIFICA_SEZIONE, TED_RETTIFICA_VAL_OLD, TED_RETTIFICA_VAL_NEW) 
								select a.REL_ValueOutput, b.DZT_DescML, 
										@TED_NOTE_ASTA_ELETTRONICA_OLD, @TED_NOTE_ASTA_ELETTRONICA, 
										'Numero della sezione : ' + a.REL_ValueOutput + '<br/>Punto in cui si trova il testo da modificare : ' + b.DZT_DescML,
										@TED_NOTE_ASTA_ELETTRONICA_OLD, @TED_NOTE_ASTA_ELETTRONICA
									from CTL_Relations a with(nolock)
											left join LIB_Dictionary b with(nolock) on b.DZT_Name = a.REL_ValueInput
									where a.REL_Type = 'TED_CAMPI_SCHEDE' and a.REL_ValueInput = 'TED_NOTE_ASTA_ELETTRONICA'

				end

				if @TED_PERIODO_VALIDITA_OFFERTE <> @TED_PERIODO_VALIDITA_OFFERTE_OLD
				begin

					set @bDatiModificati = 1

					--data
					INSERT INTO #dati_rettifica( SECTION_NUMBER, SECTION_TO_MODIFY, OLD_VALUE_TEXT, NEW_VALUE_TEXT, TED_RETTIFICA_SEZIONE, TED_RETTIFICA_VAL_OLD, TED_RETTIFICA_VAL_NEW) 
								select a.REL_ValueOutput, b.DZT_DescML, 
										@TED_PERIODO_VALIDITA_OFFERTE_OLD, @TED_PERIODO_VALIDITA_OFFERTE, 
										'Numero della sezione : ' + a.REL_ValueOutput + '<br/>Punto in cui si trova il testo da modificare : ' + b.DZT_DescML,
										@TED_PERIODO_VALIDITA_OFFERTE_OLD, @TED_PERIODO_VALIDITA_OFFERTE
									from CTL_Relations a with(nolock)
											left join LIB_Dictionary b with(nolock) on b.DZT_Name = a.REL_ValueInput
									where a.REL_Type = 'TED_CAMPI_SCHEDE' and a.REL_ValueInput = 'TED_PERIODO_VALIDITA_OFFERTE'

				end

				if @TED_MESI_VALIDITA_OFFERTE <> @TED_MESI_VALIDITA_OFFERTE_OLD
				begin

					set @bDatiModificati = 1

					INSERT INTO #dati_rettifica( SECTION_NUMBER, SECTION_TO_MODIFY, OLD_VALUE_TEXT, NEW_VALUE_TEXT, TED_RETTIFICA_SEZIONE, TED_RETTIFICA_VAL_OLD, TED_RETTIFICA_VAL_NEW) 
								select a.REL_ValueOutput, b.DZT_DescML, 
										@TED_MESI_VALIDITA_OFFERTE_OLD, @TED_MESI_VALIDITA_OFFERTE, 
										'Numero della sezione : ' + a.REL_ValueOutput + '<br/>Punto in cui si trova il testo da modificare : ' + b.DZT_DescML,
										@TED_MESI_VALIDITA_OFFERTE_OLD, @TED_MESI_VALIDITA_OFFERTE
									from CTL_Relations a with(nolock)
											left join LIB_Dictionary b with(nolock) on b.DZT_Name = a.REL_ValueInput
									where a.REL_Type = 'TED_CAMPI_SCHEDE' and a.REL_ValueInput = 'TED_MESI_VALIDITA_OFFERTE'

				end

				if @TED_LUOGO_APERTURA_OFFERTE <> @TED_LUOGO_APERTURA_OFFERTE_OLD
				begin

					set @bDatiModificati = 1

					INSERT INTO #dati_rettifica( SECTION_NUMBER, SECTION_TO_MODIFY, OLD_VALUE_TEXT, NEW_VALUE_TEXT, TED_RETTIFICA_SEZIONE, TED_RETTIFICA_VAL_OLD, TED_RETTIFICA_VAL_NEW) 
								select a.REL_ValueOutput, b.DZT_DescML, 
										@TED_LUOGO_APERTURA_OFFERTE_OLD, @TED_LUOGO_APERTURA_OFFERTE, 
										'Numero della sezione : ' + a.REL_ValueOutput + '<br/>Punto in cui si trova il testo da modificare : ' + b.DZT_DescML,
										@TED_LUOGO_APERTURA_OFFERTE_OLD, @TED_LUOGO_APERTURA_OFFERTE
									from CTL_Relations a with(nolock)
											left join LIB_Dictionary b with(nolock) on b.DZT_Name = a.REL_ValueInput
									where a.REL_Type = 'TED_CAMPI_SCHEDE' and a.REL_ValueInput = 'TED_LUOGO_APERTURA_OFFERTE'

				end

				if @TED_PERSONE_APERTURA_OFFERTE <> @TED_PERSONE_APERTURA_OFFERTE_OLD
				begin

					set @bDatiModificati = 1

					INSERT INTO #dati_rettifica( SECTION_NUMBER, SECTION_TO_MODIFY, OLD_VALUE_TEXT, NEW_VALUE_TEXT, TED_RETTIFICA_SEZIONE, TED_RETTIFICA_VAL_OLD, TED_RETTIFICA_VAL_NEW) 
								select a.REL_ValueOutput, b.DZT_DescML, 
										@TED_PERSONE_APERTURA_OFFERTE_OLD, @TED_PERSONE_APERTURA_OFFERTE, 
										'Numero della sezione : ' + a.REL_ValueOutput + '<br/>Punto in cui si trova il testo da modificare : ' + b.DZT_DescML,
										@TED_PERSONE_APERTURA_OFFERTE_OLD, @TED_PERSONE_APERTURA_OFFERTE
									from CTL_Relations a with(nolock)
											left join LIB_Dictionary b with(nolock) on b.DZT_Name = a.REL_ValueInput
									where a.REL_Type = 'TED_CAMPI_SCHEDE' and a.REL_ValueInput = 'TED_PERSONE_APERTURA_OFFERTE'

				end

				if @TED_APPALTO_RINNOVABILE <> @TED_APPALTO_RINNOVABILE_OLD
				begin

					set @bDatiModificati = 1

					INSERT INTO #dati_rettifica( SECTION_NUMBER, SECTION_TO_MODIFY, OLD_VALUE_TEXT, NEW_VALUE_TEXT, TED_RETTIFICA_SEZIONE, TED_RETTIFICA_VAL_OLD, TED_RETTIFICA_VAL_NEW) 
								select a.REL_ValueOutput, b.DZT_DescML, 
										@TED_APPALTO_RINNOVABILE_OLD, @TED_APPALTO_RINNOVABILE, 
										'Numero della sezione : ' + a.REL_ValueOutput + '<br/>Punto in cui si trova il testo da modificare : ' + b.DZT_DescML,
										@TED_APPALTO_RINNOVABILE_OLD, @TED_APPALTO_RINNOVABILE
									from CTL_Relations a with(nolock)
											left join LIB_Dictionary b with(nolock) on b.DZT_Name = a.REL_ValueInput
									where a.REL_Type = 'TED_CAMPI_SCHEDE' and a.REL_ValueInput = 'TED_APPALTO_RINNOVABILE'

				end

				if @TED_TEMPO_STIMATO_PROSSIMI_BANDI <> @TED_TEMPO_STIMATO_PROSSIMI_BANDI_OLD
				begin

					set @bDatiModificati = 1

					INSERT INTO #dati_rettifica( SECTION_NUMBER, SECTION_TO_MODIFY, OLD_VALUE_TEXT, NEW_VALUE_TEXT, TED_RETTIFICA_SEZIONE, TED_RETTIFICA_VAL_OLD, TED_RETTIFICA_VAL_NEW) 
								select a.REL_ValueOutput, b.DZT_DescML, 
										@TED_TEMPO_STIMATO_PROSSIMI_BANDI_OLD, @TED_TEMPO_STIMATO_PROSSIMI_BANDI, 
										'Numero della sezione : ' + a.REL_ValueOutput + '<br/>Punto in cui si trova il testo da modificare : ' + b.DZT_DescML,
										@TED_TEMPO_STIMATO_PROSSIMI_BANDI_OLD, @TED_TEMPO_STIMATO_PROSSIMI_BANDI
									from CTL_Relations a with(nolock)
											left join LIB_Dictionary b with(nolock) on b.DZT_Name = a.REL_ValueInput
									where a.REL_Type = 'TED_CAMPI_SCHEDE' and a.REL_ValueInput = 'TED_TEMPO_STIMATO_PROSSIMI_BANDI'

				end

				if @TED_ORDINATIVO_ELETTRONICO <> @TED_ORDINATIVO_ELETTRONICO_OLD
				begin

					set @bDatiModificati = 1

					INSERT INTO #dati_rettifica( SECTION_NUMBER, SECTION_TO_MODIFY, OLD_VALUE_TEXT, NEW_VALUE_TEXT, TED_RETTIFICA_SEZIONE, TED_RETTIFICA_VAL_OLD, TED_RETTIFICA_VAL_NEW) 
								select a.REL_ValueOutput, b.DZT_DescML, 
										@TED_ORDINATIVO_ELETTRONICO_OLD, @TED_ORDINATIVO_ELETTRONICO, 
										'Numero della sezione : ' + a.REL_ValueOutput + '<br/>Punto in cui si trova il testo da modificare : ' + b.DZT_DescML,
										@TED_ORDINATIVO_ELETTRONICO_OLD, @TED_ORDINATIVO_ELETTRONICO
									from CTL_Relations a with(nolock)
											left join LIB_Dictionary b with(nolock) on b.DZT_Name = a.REL_ValueInput
									where a.REL_Type = 'TED_CAMPI_SCHEDE' and a.REL_ValueInput = 'TED_ORDINATIVO_ELETTRONICO'

				end

				if @TED_FATTURAZIONE_ELETTRONICA <> @TED_FATTURAZIONE_ELETTRONICA_OLD
				begin

					set @bDatiModificati = 1

					INSERT INTO #dati_rettifica( SECTION_NUMBER, SECTION_TO_MODIFY, OLD_VALUE_TEXT, NEW_VALUE_TEXT, TED_RETTIFICA_SEZIONE, TED_RETTIFICA_VAL_OLD, TED_RETTIFICA_VAL_NEW) 
								select a.REL_ValueOutput, b.DZT_DescML, 
										@TED_FATTURAZIONE_ELETTRONICA_OLD, @TED_FATTURAZIONE_ELETTRONICA, 
										'Numero della sezione : ' + a.REL_ValueOutput + '<br/>Punto in cui si trova il testo da modificare : ' + b.DZT_DescML,
										@TED_FATTURAZIONE_ELETTRONICA_OLD, @TED_FATTURAZIONE_ELETTRONICA
									from CTL_Relations a with(nolock)
											left join LIB_Dictionary b with(nolock) on b.DZT_Name = a.REL_ValueInput
									where a.REL_Type = 'TED_CAMPI_SCHEDE' and a.REL_ValueInput = 'TED_FATTURAZIONE_ELETTRONICA'

				end

				if @TED_PAGAMENTI_ELETTRONICI <> @TED_PAGAMENTI_ELETTRONICI_OLD
				begin

					set @bDatiModificati = 1

					INSERT INTO #dati_rettifica( SECTION_NUMBER, SECTION_TO_MODIFY, OLD_VALUE_TEXT, NEW_VALUE_TEXT, TED_RETTIFICA_SEZIONE, TED_RETTIFICA_VAL_OLD, TED_RETTIFICA_VAL_NEW) 
								select a.REL_ValueOutput, b.DZT_DescML, 
										@TED_PAGAMENTI_ELETTRONICI_OLD, @TED_PAGAMENTI_ELETTRONICI, 
										'Numero della sezione : ' + a.REL_ValueOutput + '<br/>Punto in cui si trova il testo da modificare : ' + b.DZT_DescML,
										@TED_PAGAMENTI_ELETTRONICI_OLD, @TED_PAGAMENTI_ELETTRONICI
									from CTL_Relations a with(nolock)
											left join LIB_Dictionary b with(nolock) on b.DZT_Name = a.REL_ValueInput
									where a.REL_Type = 'TED_CAMPI_SCHEDE' and a.REL_ValueInput = 'TED_PAGAMENTI_ELETTRONICI'

				end

				if @TED_INFO_ADD <> @TED_INFO_ADD_OLD
				begin

					set @bDatiModificati = 1

					INSERT INTO #dati_rettifica( SECTION_NUMBER, SECTION_TO_MODIFY, OLD_VALUE_TEXT, NEW_VALUE_TEXT, TED_RETTIFICA_SEZIONE, TED_RETTIFICA_VAL_OLD, TED_RETTIFICA_VAL_NEW) 
								select a.REL_ValueOutput, b.DZT_DescML, 
										@TED_INFO_ADD_OLD, @TED_INFO_ADD, 
										'Numero della sezione : ' + a.REL_ValueOutput + '<br/>Punto in cui si trova il testo da modificare : ' + b.DZT_DescML,
										@TED_INFO_ADD_OLD, @TED_INFO_ADD
									from CTL_Relations a with(nolock)
											left join LIB_Dictionary b with(nolock) on b.DZT_Name = a.REL_ValueInput
									where a.REL_Type = 'TED_CAMPI_SCHEDE' and a.REL_ValueInput = 'TED_INFO_ADD'

				end

				if @TED_URL_SA <> @TED_URL_SA_OLD
				begin

					set @bDatiModificati = 1

					INSERT INTO #dati_rettifica( SECTION_NUMBER, SECTION_TO_MODIFY, OLD_VALUE_TEXT, NEW_VALUE_TEXT, TED_RETTIFICA_SEZIONE, TED_RETTIFICA_VAL_OLD, TED_RETTIFICA_VAL_NEW) 
								select a.REL_ValueOutput, b.DZT_DescML, 
										@TED_URL_SA_OLD, @TED_URL_SA, 
										'Numero della sezione : ' + a.REL_ValueOutput + '<br/>Punto in cui si trova il testo da modificare : ' + b.DZT_DescML,
										@TED_URL_SA_OLD, @TED_URL_SA
									from CTL_Relations a with(nolock)
											left join LIB_Dictionary b with(nolock) on b.DZT_Name = a.REL_ValueInput
									where a.REL_Type = 'TED_CAMPI_SCHEDE' and a.REL_ValueInput = 'AddrS6Type_TED_URL_SA'

				end


				declare @TED_LUOGO_ESECUZIONE_PRINCIPALE varchar(1000), @TED_ACCETTATE_VARIANTI varchar(1000), @TED_DESCRIZIONE_OPZIONI varchar(1000), @TED_FLAG_APPALTO_PROGETTO_UE varchar(1000), @TED_APPALTO_PROGETTO_UE varchar(1000)
				declare @TED_LUOGO_ESECUZIONE_PRINCIPALE_OLD varchar(1000), @TED_ACCETTATE_VARIANTI_OLD varchar(1000), @TED_DESCRIZIONE_OPZIONI_OLD varchar(1000), @TED_FLAG_APPALTO_PROGETTO_UE_OLD varchar(1000), @TED_APPALTO_PROGETTO_UE_OLD varchar(1000)

				declare @cig varchar(20) = ''

				-- ITERIAMO SUI LOTTI DEL DOCUMENTO DI RICHIESTA RETTIFICA PRENDENDO SOLTANTO LE COLONNE EDITABILI
				DECLARE curs CURSOR FAST_FORWARD FOR
					select a.[CIG], a.[TED_LUOGO_ESECUZIONE_PRINCIPALE], a.[TED_ACCETTATE_VARIANTI], a.[TED_DESCRIZIONE_OPZIONI], a.[TED_FLAG_APPALTO_PROGETTO_UE], a.[TED_APPALTO_PROGETTO_UE],
									b.[TED_LUOGO_ESECUZIONE_PRINCIPALE], b.[TED_ACCETTATE_VARIANTI], b.[TED_DESCRIZIONE_OPZIONI], b.[TED_FLAG_APPALTO_PROGETTO_UE], b.[TED_APPALTO_PROGETTO_UE] 
						from #dati_ted_lotti_new a
								inner join #dati_ted_lotti b on b.CIG = a.CIG

				OPEN curs 
				FETCH NEXT FROM curs INTO @cig, @TED_LUOGO_ESECUZIONE_PRINCIPALE,@TED_ACCETTATE_VARIANTI,@TED_DESCRIZIONE_OPZIONI,@TED_FLAG_APPALTO_PROGETTO_UE,@TED_APPALTO_PROGETTO_UE,
												@TED_LUOGO_ESECUZIONE_PRINCIPALE_OLD,@TED_ACCETTATE_VARIANTI_OLD,@TED_DESCRIZIONE_OPZIONI_OLD,@TED_FLAG_APPALTO_PROGETTO_UE_OLD,@TED_APPALTO_PROGETTO_UE_OLD

				WHILE @@FETCH_STATUS = 0   
				BEGIN  

					--select * from ctl_relations where REL_Type = 'TED_CAMPI_SCHEDE' and REL_ValueInput = 'TED_APPALTO_PROGETTO_UE'

					IF isnull(@TED_LUOGO_ESECUZIONE_PRINCIPALE,'') <> isnull(@TED_LUOGO_ESECUZIONE_PRINCIPALE_OLD,'')
					BEGIN
						INSERT INTO #dati_rettifica( CIG_RETTIFICA, SECTION_NUMBER, SECTION_TO_MODIFY, OLD_VALUE_TEXT, NEW_VALUE_TEXT, TED_RETTIFICA_SEZIONE, TED_RETTIFICA_VAL_OLD, TED_RETTIFICA_VAL_NEW) 
								select @cig, a.REL_ValueOutput, b.DZT_DescML, @TED_LUOGO_ESECUZIONE_PRINCIPALE_OLD, @TED_LUOGO_ESECUZIONE_PRINCIPALE, 
										'Numero della sezione : ' + a.REL_ValueOutput + '<br/>Punto in cui si trova il testo da modificare : ' + b.DZT_DescML + '<br/>CIG : ' + @cig,
										@TED_LUOGO_ESECUZIONE_PRINCIPALE_OLD, @TED_LUOGO_ESECUZIONE_PRINCIPALE
									from CTL_Relations a with(nolock)
											left join LIB_Dictionary b with(nolock) on b.DZT_Name = a.REL_ValueInput
									where a.REL_Type = 'TED_CAMPI_SCHEDE' and a.REL_ValueInput = 'TED_LUOGO_ESECUZIONE_PRINCIPALE'
					END

					IF isnull(@TED_ACCETTATE_VARIANTI,'') <> isnull(@TED_ACCETTATE_VARIANTI_OLD,'')
					BEGIN

						set @TED_ACCETTATE_VARIANTI = case @TED_ACCETTATE_VARIANTI when 'S' then 'SI' when 'N' then 'NO' else '' end
						set @TED_ACCETTATE_VARIANTI_OLD = case @TED_ACCETTATE_VARIANTI_OLD when 'S' then 'SI' when 'N' then 'NO' else '' end

						INSERT INTO #dati_rettifica( CIG_RETTIFICA, SECTION_NUMBER, SECTION_TO_MODIFY, OLD_VALUE_TEXT, NEW_VALUE_TEXT, TED_RETTIFICA_SEZIONE, TED_RETTIFICA_VAL_OLD, TED_RETTIFICA_VAL_NEW) 
								select @cig, a.REL_ValueOutput, b.DZT_DescML, 
										@TED_ACCETTATE_VARIANTI_OLD, 
										@TED_ACCETTATE_VARIANTI, 
										'Numero della sezione : ' + a.REL_ValueOutput + '<br/>Punto in cui si trova il testo da modificare : ' + b.DZT_DescML + '<br/>CIG : ' + @cig,
										@TED_ACCETTATE_VARIANTI_OLD, 
										@TED_ACCETTATE_VARIANTI
									from CTL_Relations a with(nolock)
											left join LIB_Dictionary b with(nolock) on b.DZT_Name = a.REL_ValueInput
									where a.REL_Type = 'TED_CAMPI_SCHEDE' and a.REL_ValueInput = 'TED_ACCETTATE_VARIANTI'
					END
			
					IF isnull(@TED_DESCRIZIONE_OPZIONI,'') <> isnull(@TED_DESCRIZIONE_OPZIONI_OLD,'')
					BEGIN

						INSERT INTO #dati_rettifica( CIG_RETTIFICA, SECTION_NUMBER, SECTION_TO_MODIFY, OLD_VALUE_TEXT, NEW_VALUE_TEXT, TED_RETTIFICA_SEZIONE, TED_RETTIFICA_VAL_OLD, TED_RETTIFICA_VAL_NEW) 
								select @cig, a.REL_ValueOutput, b.DZT_DescML, 
										@TED_DESCRIZIONE_OPZIONI_OLD, 
										@TED_DESCRIZIONE_OPZIONI, 
										'Numero della sezione : ' + a.REL_ValueOutput + '<br/>Punto in cui si trova il testo da modificare : ' + b.DZT_DescML + '<br/>CIG : ' + @cig,
										@TED_DESCRIZIONE_OPZIONI_OLD, 
										@TED_DESCRIZIONE_OPZIONI
									from CTL_Relations a with(nolock)
											left join LIB_Dictionary b with(nolock) on b.DZT_Name = a.REL_ValueInput
									where a.REL_Type = 'TED_CAMPI_SCHEDE' and a.REL_ValueInput = 'TED_DESCRIZIONE_OPZIONI'
					END

					IF isnull(@TED_FLAG_APPALTO_PROGETTO_UE,'') <> isnull(@TED_FLAG_APPALTO_PROGETTO_UE_OLD,'')
					BEGIN

						set @TED_FLAG_APPALTO_PROGETTO_UE = case @TED_FLAG_APPALTO_PROGETTO_UE when 'S' then 'SI' when 'N' then 'NO' else '' end
						set @TED_FLAG_APPALTO_PROGETTO_UE_OLD = case @TED_FLAG_APPALTO_PROGETTO_UE_OLD when 'S' then 'SI' when 'N' then 'NO' else '' end

						INSERT INTO #dati_rettifica( CIG_RETTIFICA, SECTION_NUMBER, SECTION_TO_MODIFY, OLD_VALUE_TEXT, NEW_VALUE_TEXT, TED_RETTIFICA_SEZIONE, TED_RETTIFICA_VAL_OLD, TED_RETTIFICA_VAL_NEW) 
								select @cig, a.REL_ValueOutput, b.DZT_DescML, 
										@TED_FLAG_APPALTO_PROGETTO_UE_OLD, 
										@TED_FLAG_APPALTO_PROGETTO_UE, 
										'Numero della sezione : ' + a.REL_ValueOutput + '<br/>Punto in cui si trova il testo da modificare : ' + b.DZT_DescML + '<br/>CIG : ' + @cig,
										@TED_FLAG_APPALTO_PROGETTO_UE_OLD, 
										@TED_FLAG_APPALTO_PROGETTO_UE
									from CTL_Relations a with(nolock)
											left join LIB_Dictionary b with(nolock) on b.DZT_Name = a.REL_ValueInput
									where a.REL_Type = 'TED_CAMPI_SCHEDE' and a.REL_ValueInput = 'TED_FLAG_APPALTO_PROGETTO_UE'
					END

					IF isnull(@TED_APPALTO_PROGETTO_UE,'') <> isnull(@TED_APPALTO_PROGETTO_UE_OLD,'')
					BEGIN

						INSERT INTO #dati_rettifica( CIG_RETTIFICA, SECTION_NUMBER, SECTION_TO_MODIFY, OLD_VALUE_TEXT, NEW_VALUE_TEXT, TED_RETTIFICA_SEZIONE, TED_RETTIFICA_VAL_OLD, TED_RETTIFICA_VAL_NEW) 
								select @cig, a.REL_ValueOutput, b.DZT_DescML, 
										@TED_APPALTO_PROGETTO_UE_OLD, 
										@TED_APPALTO_PROGETTO_UE, 
										'Numero della sezione : ' + a.REL_ValueOutput + '<br/>Punto in cui si trova il testo da modificare : ' + b.DZT_DescML + '<br/>CIG : ' + @cig,
										@TED_APPALTO_PROGETTO_UE_OLD, 
										@TED_APPALTO_PROGETTO_UE
									from CTL_Relations a with(nolock)
											left join LIB_Dictionary b with(nolock) on b.DZT_Name = a.REL_ValueInput
									where a.REL_Type = 'TED_CAMPI_SCHEDE' and a.REL_ValueInput = 'TED_APPALTO_PROGETTO_UE'
					END

					FETCH NEXT FROM curs INTO @cig, @TED_LUOGO_ESECUZIONE_PRINCIPALE,@TED_ACCETTATE_VARIANTI,@TED_DESCRIZIONE_OPZIONI,@TED_FLAG_APPALTO_PROGETTO_UE,@TED_APPALTO_PROGETTO_UE,
													@TED_LUOGO_ESECUZIONE_PRINCIPALE_OLD,@TED_ACCETTATE_VARIANTI_OLD,@TED_DESCRIZIONE_OPZIONI_OLD,@TED_FLAG_APPALTO_PROGETTO_UE_OLD,@TED_APPALTO_PROGETTO_UE_OLD

				END  

				CLOSE curs   
				DEALLOCATE curs

				drop table #dati_ted_new
				drop table #dati_ted_lotti_new
				drop table #dati_amm_ted_new

			END

			IF @bDatiModificati = 1
			BEGIN

				INSERT into CTL_DOC (IdPfu,  TipoDoc  , idpfuincharge ,Azienda ,LinkedDoc, IdDoc, Titolo )
					select  @IdUser, @TYPE_TO , @IdUser ,Azienda, @Bando , @idDoc, 'Rettifica Dati GUUE'
						from ctl_doc with(nolock)
						where id=@idDoc		

				set @newId = SCOPE_IDENTITY()

				insert into Document_TED_GARA( idHeader, id_gara, TED_VER_PUB_NO_DOC_OJS, TED_MOTIVO_RETTIFICA, TED_INFO_ADD_MODIFICA )
						select @newid, id_gara, TED_VER_PUB_NO_DOC_OJS, '1', @descMotivoRettifica
							from Document_TED_GARA with(nolock)
							where idheader = @idRichiestaPubTed

				insert into Document_TED_RETTIFICA( [idHeader], [SECTION_NUMBER], [SECTION_TO_MODIFY], [OLD_VALUE_TEXT], [NEW_VALUE_TEXT], [OLD_VALUE_DATE], [NEW_VALUE_DATE], [OLD_VALUE_TIME], [NEW_VALUE_TIME], [TED_RETTIFICA_SEZIONE], [TED_RETTIFICA_VAL_OLD], [TED_RETTIFICA_VAL_NEW], [OLD_MAIN_CPV_SEC], [NEW_MAIN_CPV_SEC] )
									select @newid, [SECTION_NUMBER], [SECTION_TO_MODIFY], [OLD_VALUE_TEXT], [NEW_VALUE_TEXT], [OLD_VALUE_DATE], [NEW_VALUE_DATE], [OLD_VALUE_TIME], [NEW_VALUE_TIME], [TED_RETTIFICA_SEZIONE], [TED_RETTIFICA_VAL_OLD], [TED_RETTIFICA_VAL_NEW], [OLD_MAIN_CPV_SEC], [NEW_MAIN_CPV_SEC]
										from #dati_rettifica

				--IF @tipoDocCollegato <> 'DELTA_TED' -- ??
				--BEGIN

					-- appena viene creato il documento di rettifica passiamo il documento richiedente nello stato di 'InAttesaTed'
					--		così da "bloccarlo" fintanto che questo documento non viene inviato con successo o annullato ( o in errore ? )
					update ctl_doc
							set StatoFunzionale = 'InAttesaTed'
						where id = @idDoc

				--END

			END

			drop table #dati_ted
			drop table #dati_pub_ted
			drop table #dati_ted_lotti
			drop table #dati_amm_ted

		END

	END


	if  ISNULL(@newId,0) <> 0
	begin

		select @newId as id, @TYPE_TO as TYPE_TO
	
	end
	else
	begin

		select 'Errore' as id , @Errore as Errore

	end
END










GO
