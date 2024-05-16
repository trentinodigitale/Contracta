USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_SCRITTURA_PRIVATA_CREATE_FROM_AGGIUDICAZIONE_DEF]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE  PROCEDURE [dbo].[OLD2_SCRITTURA_PRIVATA_CREATE_FROM_AGGIUDICAZIONE_DEF] 
	( @idDoc int , @IdUser int  )
AS
BEGIN
	SET NOCOUNT ON;

	declare @Id as int
	declare @IdCom as int
	declare @IdAggiudicatario as int
	declare @EnteAggiudicatrice as int
	declare @IdPda as int
	declare @IdBando as int
	declare @ProtocolloBando as varchar(50)
	declare @DataBando as datetime
	declare @Fascicolo as varchar(50)
	declare @DataRiferimentoInizio as datetime
	declare @DataScadenzaOfferta as datetime
	declare @ProtocolloOfferta as varchar(50)
	declare @DataOfferta as datetime
	declare @TotaleAggiudicato as float
	declare @OggettoBando as nvarchar(max)
	declare @ModelloBando as varchar(500)
	declare @IdOfferta as int
	declare @Testo as nvarchar(max)
	declare @idpfuOfferta as int
	declare @cig as varchar(100)
	declare @NumRow as int
	declare @TipoDocBando as varchar(500)
	declare @Errore as nvarchar(2000)
	set @Errore = ''

	set @NumRow=1


	declare @DivisioneLotti as varchar(10)
		
		
	
	--recupero info dal dettaglio del lotto aggiudicato
	select @IdCom=idheader,@IdAggiudicatario=IdAziAggiudicataria from Document_comunicazione_StatoLotti where id=@idDoc
	
	--recupero IDPDA dalla comunicazione
	select @IdPda=linkeddoc from ctl_doc where id=@IdCom

	--recupero IDBANDO dalla PDA
	select @IdBando=linkeddoc from ctl_doc where id=@IdPda
	
	--recupero tipodoc del bando
	select @TipoDocBando=Tipodoc from ctl_doc with(nolock) where id=@IdBando
	


	--recupero ente che ha emesso il bando e info del bando
	select 
			@DataBando=DataInvio,@ProtocolloBando=Protocollo,@Fascicolo=Fascicolo,@EnteAggiudicatrice=azienda 
			,@DataRiferimentoInizio=DataRiferimentoInizio,@DataScadenzaOfferta=DataScadenzaOfferta,@DivisioneLotti =  Divisione_Lotti,
			@OggettoBando=Body,@ModelloBando=TipoBando,@cig=cig
		from 
			ctl_doc inner join document_bando on id=idheader
		where 
			id=@IdBando

	--recupero protocolloofferta dataofferta
	select 
			@IdOfferta=Id,@idpfuOfferta=idpfu,@ProtocolloOfferta=Protocollo, @DataOfferta = DataInvio
		from 
			ctl_doc 
		where 
			TIPODOC='OFFERTA' and linkeddoc=@IdBando and Azienda=@IdAggiudicatario and statofunzionale='Inviato'
	
	--recupero totale dei lotti aggiudicati
	select 		
		@TotaleAggiudicato=sum(Importo) 
		from ( 
			select 
				distinct Importo , IdAziAggiudicataria , NumeroLotto
				from 
					Document_comunicazione_StatoLotti
				where 
					IdAziAggiudicataria=@IdAggiudicatario and idheader=@IdCom
			) as a

	--select top 1 protocollobando,datainizioriferimento,* from document_bando
	--recupero ultimo doc SCRITTURA_PRIVATA publbicato legato all'offerta
	set @Id = -1
	select @Id=id from ctl_doc where deleted = 0 and tipodoc='SCRITTURA_PRIVATA' and statofunzionale not in ('Confermato','InLavorazione','Inviata','Rifiutato') and linkeddoc=@IdCom and Destinatario_azi=@IdAggiudicatario
	
	if @Id = -1 
	begin
	
	
		-- verifico che non ci siano lotti in aggiudicazione condizionata
		if exists ( 
					select * 
						from Document_comunicazione_StatoLotti cl with(nolock) 
						
							inner join CTL_DOC CC with(NOLOCK) on CC.Id=cl.idheader --COMUNICAZIONE
							inner join ctl_doc c1   with(nolock) on CC.linkedDoc=c1.id and C1.tipodoc='PDA_MICROLOTTI' ----
							inner join document_microlotti_dettagli PDA_LOTTI with(nolock) on PDA_LOTTI.idheader=c1.id and PDA_LOTTI.tipodoc= 'PDA_MICROLOTTI' and PDA_LOTTI.NumeroLotto=cl.NumeroLotto and PDA_LOTTI.voce=0

						where cl.id=@idDoc and PDA_LOTTI.Statoriga <> 'AggiudicazioneDef'
		)
		begin
			-- 
			set @Errore = 'Per la generazione del contratto è necessario portare a termine i controlli di aggiudicazione'

		end
		else
		begin


			--generare nuovo protocollo per il doc offerta_partecipante
			insert into CTL_DOC 
				( IdPfu,Titolo, TipoDoc, Azienda, Body,
				ProtocolloRiferimento, Fascicolo, LinkedDoc, Destinatario_Azi ,idPfuInCharge ) 
				values 
					( @IdUser,'Scrittura Privata', 'SCRITTURA_PRIVATA', @EnteAggiudicatrice ,  @OggettoBando,
					@ProtocolloBando, @Fascicolo, @IdCom , @IdAggiudicatario , @IdUser )   

			set @Id=@@IDENTITY
			--inserisco una riga su ctl_doc_value con utente che ha presentato l'offerta
			insert into CTL_DOC_Value
				( IdHeader, DSE_ID, Row, DZT_Name, Value)
				values
				( @Id, 'DOCUMENT', '0', 'UtenteOfferta', @idpfuOfferta)

			--inserisco la riga nella ctl_approvalStep
			insert into ctl_approvalsteps 
				(APS_Doc_Type,APS_ID_DOC,APS_State,APS_Note,APS_Allegato,APS_UserProfile,APS_Idpfu,APS_IsOld)
				 select top 1 'SCRITTURA_PRIVATA',@Id,'Compiled','','',isnull( attvalue,''),@IdUser,0 
					 from profiliutenteattrib p  
					 where  p.idpfu = @IdUser and dztnome = 'UserRoleDefault'


			--inserisco nella CTL_DOC_VALUE i campi aggiuntivi
			insert into CTL_DOC_Value
				( IdHeader, DSE_ID, Row, DZT_Name, Value)
					values
					( @Id, 'DOCUMENT', '0', 'DataBando', convert(varchar(19),@DataBando,126))

			--inserisco nella CTL_DOC_VALUE i campi aggiuntivi
			insert into CTL_DOC_Value
				( IdHeader, DSE_ID, Row, DZT_Name, Value)
					values
					( @Id, 'DOCUMENT', '0', 'DataRiferimentoInizio', convert(varchar(19),@DataRiferimentoInizio ,126))

			--inserisco nella CTL_DOC_VALUE i campi aggiuntivi
			insert into CTL_DOC_Value
				( IdHeader, DSE_ID, Row, DZT_Name, Value)
					values
					( @Id, 'DOCUMENT', '0', 'DataScadenzaOfferta', convert(varchar(19),@DataScadenzaOfferta  ,126))
		
			--inserisco nella CTL_DOC_VALUE i campi aggiuntivi
			insert into CTL_DOC_Value
				( IdHeader, DSE_ID, Row, DZT_Name, Value)
					values
					( @Id, 'DOCUMENT', '0', 'ProtocolloOfferta', @ProtocolloOfferta )
		

			--inserisco nella CTL_DOC_VALUE i campi aggiuntivi
			insert into CTL_DOC_Value
				( IdHeader, DSE_ID, Row, DZT_Name, Value)
					values
					( @Id, 'DOCUMENT', '0', 'DataRisposta', convert(varchar(19),@DataOfferta  ,126)  )
		
			--inserisco nella CTL_DOC_VALUE i campi aggiuntivi
			insert into CTL_DOC_Value
				( IdHeader, DSE_ID, Row, DZT_Name, Value)
					values
					( @Id, 'CONTRATTO', '0', 'NewTotal', str(@TotaleAggiudicato,20,5) )
	
			--inserisco il modello da utilizzarte
			insert into CTL_DOC_SECTION_MODEL
				( IdHeader, DSE_ID, MOD_Name)
					values
					( @Id , 'BENI' , 'MODELLI_LOTTI_' + @ModelloBando + '_MOD_SCRITTURA_PRIVATA'	)	
				



			----inserisco i lotti aggiudicati nei dettagli
			--insert into Document_MicroLotti_Dettagli
			--	( IdHeader, TipoDoc, Graduatoria, Sorteggio, Posizione, Aggiudicata, Exequo, StatoRiga, EsitoRiga, ValoreOfferta, NumeroLotto, Descrizione, Qty, PrezzoUnitario, CauzioneMicrolotto, CIG, CodiceATC, PrincipioAttivo, FormaFarmaceutica, Dosaggio, Somministrazione, UnitadiMisura, Quantita, ImportoBaseAstaUnitaria, ImportoAnnuoLotto, ImportoTriennaleLotto, NoteLotto, CodiceAIC, QuantitaConfezione, ClasseRimborsoMedicinale, PrezzoVenditaConfezione, AliquotaIva, ScontoUlteriore, EstremiGURI, PrezzoUnitarioOfferta, PrezzoUnitarioRiferimento, TotaleOffertaUnitario, ScorporoIVA, PrezzoVenditaConfezioneIvaEsclusa, PrezzoVenditaUnitario, ScontoOffertoUnitario, ScontoObbligatorioUnitario, DenominazioneProdotto, RagSocProduttore, CodiceProdotto, MarcaturaCE, NumeroRepertorio, NumeroCampioni, Versamento, PrezzoInLettere, importoBaseAsta, CampoTesto_1, CampoTesto_2, CampoTesto_3, CampoTesto_4, CampoTesto_5, CampoTesto_6, CampoTesto_7, CampoTesto_8, CampoTesto_9, CampoTesto_10, CampoNumerico_1, CampoNumerico_2, CampoNumerico_3, CampoNumerico_4, CampoNumerico_5, CampoNumerico_6, CampoNumerico_7, CampoNumerico_8, CampoNumerico_9, CampoNumerico_10, Voce, idHeaderLotto, CampoAllegato_1, CampoAllegato_2, CampoAllegato_3, CampoAllegato_4, CampoAllegato_5, NumeroRiga, PunteggioTecnico, ValoreEconomico, PesoVoce, ValoreImportoLotto, Variante, CONTRATTO, CODICE_AZIENDA_SANITARIA, CODICE_REGIONALE, DESCRIZIONE_CODICE_REGIONALE, TARGET, MATERIALE, LATEX_FREE, MISURE, VOLUME, ALTRE_CARATTERISTICHE, CONFEZIONAMENTO_PRIMARIO, PESO_CONFEZIONE, DIMENSIONI_CONFEZIONE, TEMPERATURA_CONSERVAZIONE, QUANTITA_PRODOTTO_SINGOLO_PEZZO, UM_QUANTITA_PRODOTTO_SINGOLO_PEZZO, UM_DOSAGGIO, PARTITA_IVA_FORNITORE, RAGIONE_SOCIALE_FORNITORE, CODICE_ARTICOLO_FORNITORE, DENOMINAZIONE_ARTICOLO_FORNITORE, DATA_INIZIO_PERIODO_VALIDITA, DATA_FINE_PERIODO_VALIDITA, RIFERIMENTO_TEMPORALE_FABBISOGNO, FABBISOGNO_PREVISTO, PREZZO_OFFERTO_PER_UM, CONTENUTO_DI_UM_CONFEZIONE, PREZZO_CONFEZIONE_IVA_ESCLUSA, PREZZO_PEZZO, SCHEDA_PRODOTTO, CODICE_CND, DESCRIZIONE_CND, CODICE_CPV, DESCRIZIONE_CODICE_CPV, LIVELLO, CERTIFICAZIONI, CARATTERISTICHE_SOCIALI_AMBIENTALI, PREZZO_BASE_ASTA_UM_IVA_ESCLUSA, VALORE_BASE_ASTA_IVA_ESCLUSA, RAGIONE_SOCIALE_ATTUALE_FORNITORE, PREZZO_UM_IVA_ESCLUSA_ATTUALE_FORNITORE, DATA_ULTIMO_CONTRATTO, UM_UNITA_POSOLOGICA_CONTENUTA_INTERNO_DEL_BANCALE, VALORE_COMPLESSIVO_OFFERTA, NOTE_ENTI_STRUTTURE_AMMINISTRAZIONI, NOTE_OPERATORE_ECONOMICO, ONERI_SICUREZZA, PARTITA_IVA_DEPOSITARIO, RAGIONE_SOCIALE_DEPOSITARIO, IDENTIFICATIVO_OGGETTO_INIZIATIVA, AREA_MERCEOLOGICA, PERC_SCONTO_FISSATA_PER_LEGGE, ULTERIORE_PERC_DI_SCONTO_FISSATA_DA_AIFA1, ULTERIORE_PERC_DI_SCONTO_FISSATA_DA_AIFA2, ADESIONE_PAYBACK	)	
			--select 		
			--	@Id, 'SCRITTURA_PRIVATA', Graduatoria, Sorteggio, Posizione, Aggiudicata, Exequo, StatoRiga, EsitoRiga, ValoreOfferta, NumeroLotto, Descrizione, Qty, PrezzoUnitario, CauzioneMicrolotto, case @DivisioneLotti when '0' then @cig else CIG end, CodiceATC, PrincipioAttivo, FormaFarmaceutica, Dosaggio, Somministrazione, UnitadiMisura, Quantita, ImportoBaseAstaUnitaria, ImportoAnnuoLotto, ImportoTriennaleLotto, NoteLotto, CodiceAIC, QuantitaConfezione, ClasseRimborsoMedicinale, PrezzoVenditaConfezione, AliquotaIva, ScontoUlteriore, EstremiGURI, PrezzoUnitarioOfferta, PrezzoUnitarioRiferimento, TotaleOffertaUnitario, ScorporoIVA, PrezzoVenditaConfezioneIvaEsclusa, PrezzoVenditaUnitario, ScontoOffertoUnitario, ScontoObbligatorioUnitario, DenominazioneProdotto, RagSocProduttore, CodiceProdotto, MarcaturaCE, NumeroRepertorio, NumeroCampioni, Versamento, PrezzoInLettere, importoBaseAsta, CampoTesto_1, CampoTesto_2, CampoTesto_3, CampoTesto_4, CampoTesto_5, CampoTesto_6, CampoTesto_7, CampoTesto_8, CampoTesto_9, CampoTesto_10, CampoNumerico_1, CampoNumerico_2, CampoNumerico_3, CampoNumerico_4, CampoNumerico_5, CampoNumerico_6, CampoNumerico_7, CampoNumerico_8, CampoNumerico_9, CampoNumerico_10, Voce, idHeaderLotto, CampoAllegato_1, CampoAllegato_2, CampoAllegato_3, CampoAllegato_4, CampoAllegato_5, NumeroRiga, PunteggioTecnico, ValoreEconomico, PesoVoce, ValoreImportoLotto, Variante, CONTRATTO, CODICE_AZIENDA_SANITARIA, CODICE_REGIONALE, DESCRIZIONE_CODICE_REGIONALE, TARGET, MATERIALE, LATEX_FREE, MISURE, VOLUME, ALTRE_CARATTERISTICHE, CONFEZIONAMENTO_PRIMARIO, PESO_CONFEZIONE, DIMENSIONI_CONFEZIONE, TEMPERATURA_CONSERVAZIONE, QUANTITA_PRODOTTO_SINGOLO_PEZZO, UM_QUANTITA_PRODOTTO_SINGOLO_PEZZO, UM_DOSAGGIO, PARTITA_IVA_FORNITORE, RAGIONE_SOCIALE_FORNITORE, CODICE_ARTICOLO_FORNITORE, DENOMINAZIONE_ARTICOLO_FORNITORE, DATA_INIZIO_PERIODO_VALIDITA, DATA_FINE_PERIODO_VALIDITA, RIFERIMENTO_TEMPORALE_FABBISOGNO, FABBISOGNO_PREVISTO, PREZZO_OFFERTO_PER_UM, CONTENUTO_DI_UM_CONFEZIONE, PREZZO_CONFEZIONE_IVA_ESCLUSA, PREZZO_PEZZO, SCHEDA_PRODOTTO, CODICE_CND, DESCRIZIONE_CND, CODICE_CPV, DESCRIZIONE_CODICE_CPV, LIVELLO, CERTIFICAZIONI, CARATTERISTICHE_SOCIALI_AMBIENTALI, PREZZO_BASE_ASTA_UM_IVA_ESCLUSA, VALORE_BASE_ASTA_IVA_ESCLUSA, RAGIONE_SOCIALE_ATTUALE_FORNITORE, PREZZO_UM_IVA_ESCLUSA_ATTUALE_FORNITORE, DATA_ULTIMO_CONTRATTO, UM_UNITA_POSOLOGICA_CONTENUTA_INTERNO_DEL_BANCALE, VALORE_COMPLESSIVO_OFFERTA, NOTE_ENTI_STRUTTURE_AMMINISTRAZIONI, NOTE_OPERATORE_ECONOMICO, ONERI_SICUREZZA, PARTITA_IVA_DEPOSITARIO, RAGIONE_SOCIALE_DEPOSITARIO, IDENTIFICATIVO_OGGETTO_INIZIATIVA, AREA_MERCEOLOGICA, PERC_SCONTO_FISSATA_PER_LEGGE, ULTERIORE_PERC_DI_SCONTO_FISSATA_DA_AIFA1, ULTERIORE_PERC_DI_SCONTO_FISSATA_DA_AIFA2, ADESIONE_PAYBACK	
			--from 
			--	document_pda_offerte DPO 
			--	inner join DOCUMENT_MICROLOTTI_DETTAGLI DMDO on DPO.idrow=DMDO.idheader and DMDO.TipoDoc='PDA_OFFERTE'  
			--where 
			--	DPO.idheader=@IdPda and DPO.idazipartecipante=@IdAggiudicatario
			--	and
			--		( NumeroLotto in (select 
			--							NumeroLotto
			--						from 
			--							Document_comunicazione_StatoLotti
			--						where 
			--							IdAziAggiudicataria=@IdAggiudicatario and idheader=@IdCom)
			--		or
			--		@DivisioneLotti = '0'
			--		)
			
			--	and  
			--		( ( @DivisioneLotti = '0' and voce <> 0 ) or @DivisioneLotti <> '0' )
		
			--determino nel caso non a lotti se ho righe multiple (voce 0,1,ecc...) oppure no (solo voce 0)
			if @DivisioneLotti='0'
			begin
			  --select @NumRow = count(*) from document_microlotti_dettagli with (nolock) where idheader=@IdBando and tipodoc=@TipoDocBando
			  --recuperiamo le righe dall'offerta che dovrebbe essere uguale
			  select @NumRow = count(*) from document_microlotti_dettagli with (nolock) where idheader=@IdOfferta and tipodoc='OFFERTA'
			end

			declare @idRow INT
			declare @NewIdRow INT

			declare CurProg Cursor Static for 

				select 
					DMDO.id as idrow 
					from 
						document_pda_offerte DPO 
							inner join DOCUMENT_MICROLOTTI_DETTAGLI DMDO on DPO.idrow=DMDO.idheader and DMDO.TipoDoc='PDA_OFFERTE'  
					where 
						DPO.idheader=@IdPda and DPO.idazipartecipante=@IdAggiudicatario
						and
							( 
								NumeroLotto in (select 
												NumeroLotto
											from 
												Document_comunicazione_StatoLotti
											where 
												IdAziAggiudicataria=@IdAggiudicatario and idheader=@IdCom)
								or
								@DivisioneLotti = '0'
							)
			
						and  
							( ( @DivisioneLotti = '0' and ( ( voce <> 0 and @NumRow <> 1) or ( voce = 0 and @NumRow=1) ) ) or @DivisioneLotti <> '0' )
			

			open CurProg

			FETCH NEXT FROM CurProg INTO @idrow

			WHILE @@FETCH_STATUS = 0
			BEGIN
			
				INSERT into Document_MicroLotti_Dettagli ( IdHeader,TipoDoc )
					select @id , 'SCRITTURA_PRIVATA' as TipoDoc

				set @NewIdRow=scope_identity()
				
				-- ricopio tutti i valori
				exec COPY_RECORD  'Document_MicroLotti_Dettagli'  ,@idrow  , @NewIdRow, ',Id,IdHeader,TipoDoc'


				--se divisione_lotti =0 aggiorno il cig
				if @DivisioneLotti = '0' 
				begin
					update Document_MicroLotti_Dettagli set cig = @cig where id=@NewIdRow
				end

				FETCH NEXT FROM CurProg INTO @idrow

			END 

			CLOSE CurProg
			DEALLOCATE CurProg	


			--valorizzo il campo TESTO
			set @Testo = dbo.CNV ('ML_TESTO_CONTRATTO_SCRITTURA_PRIVATA','I')
		
			--rimpiazzo il tag #document.descrizione_bando#
			set @Testo = replace(@Testo,'#document.descrizione_bando#', @OggettoBando )

			--rimpiazzo il tag #document.dettagli_lotti#
			declare @DettagliLotti as nvarchar(max)
			set @DettagliLotti=''
			declare @NumeroLotto as varchar(50)
			declare @descrizione as varchar(50)


			if @DivisioneLotti <> '0'
			begin
				--recupero i lotti aggiudicati
				DECLARE crsTemplate CURSOR STATIC FOR 	

					select numerolotto,descrizione 
						from 
							Document_MicroLotti_Dettagli	
						where
							idheader=@IdOfferta and tipodoc='OFFERTA'
							and NumeroLotto in (select 
												NumeroLotto
											from 
												Document_comunicazione_StatoLotti
											where 
												IdAziAggiudicataria=@IdAggiudicatario and idheader=@IdCom)
							and voce=0

				OPEN crsTemplate

				FETCH NEXT FROM crsTemplate INTO @NumeroLotto,@descrizione
				WHILE @@FETCH_STATUS = 0
				BEGIN
			
					set @DettagliLotti = @DettagliLotti + '<li>' + @NumeroLotto + ' - ' + @Descrizione + '</li>'

					FETCH NEXT FROM crsTemplate INTO @NumeroLotto,@descrizione
				END

				CLOSE crsTemplate 
				DEALLOCATE crsTemplate 		

				set @Testo = replace(@Testo,'#document.dettagli_lotti#', @DettagliLotti )

			end
			else
			begin

				set @Testo = replace(@Testo,'Relativa ai seguenti lotti:<br/>
	<ul>
	#document.dettagli_lotti#
	</ul>', '' )
			
			end	

			--set @Testo = replace(@Testo,'#document.dettagli_lotti#', @DettagliLotti )

			
			--inserisco nella CTL_DOC_VALUE i campi aggiuntivi
			insert into CTL_DOC_Value
				( IdHeader, DSE_ID, Row, DZT_Name, Value)
				values
				( @Id, 'CONTRATTO', '0', 'Template', @Testo )
			

			--inserisco cronologia
		end
	end
	
	-- rirorna l'id del documento
	--select @Id as id
	
	if @Errore = ''
	begin
		-- rirorna l'id della nuova comunicazione appena creata
		select @Id as id
	
	end
	else
	begin
		-- rirorna l'errore
		select 'Errore' as id , @Errore as Errore
	end	
	
END









GO
