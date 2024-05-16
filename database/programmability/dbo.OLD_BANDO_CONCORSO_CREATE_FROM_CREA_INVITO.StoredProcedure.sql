USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_BANDO_CONCORSO_CREATE_FROM_CREA_INVITO]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE PROCEDURE [dbo].[OLD_BANDO_CONCORSO_CREATE_FROM_CREA_INVITO] 
	( @idDoc int  , @idUser int )
AS
BEGIN
	
	declare @id int
	declare @idRow int
	declare @ProtocolBG  varchar(50)
	declare @TipoBandoGara varchar(100)
	declare @ProceduraGara varchar(100)
	declare @num INT
	declare @idPda INT
	declare @giroRistetta int
	declare @RichiestaCigSimog  varchar(50)
	declare @NumeroGara as varchar(100)
	declare @IdPregara as int
	declare @Lista_Enti_abilitati_RCig as varchar (4000)
	declare @idAzi INT
	declare @EvidenzaPubblica_Parametro as varchar(10)
	declare @IdBando as int

	set @Id = 0

	SET NOCOUNT ON

	

	--Mi recupero l'id del bando prima fase dalla PDA in INPUT
	select @IdBando = linkeddoc
		from
			CTL_DOC with (nolock)
			where id = @IdDoc

	-- cerca una versione precedente del documento BANDO_CONCORSO II FASE
	select @Id = id 
		from CTL_DOC with(nolock)
			where LinkedDoc = @IdBando and TipoDoc = 'BANDO_CONCORSO' and deleted = 0 --and StatoDoc = 'Saved' 

	--se non viene trovato allora si crea il nuovo documento
	if isnull(@Id , 0 ) = 0 
	begin

		declare @strDesc varchar(200)

		set  @strDesc = dbo.CNV( 'Invito dal Concorso' , 'I' ) 
				

		select @ProtocolBG = Fascicolo--ProtocolBG
			from CTL_DOC
			where Id = @idDoc

		---------------------------------------------------
		-- PASSO LO STATO FUNZIONALE DELLA GARA A CHIUSO --
		---------------------------------------------------
		update CTL_DOC 
				set statofunzionale = 'Chiuso' 
			where id = @IdBando 

		
		-- genero la testata del documento
		insert into CTL_DOC ( IdPfu, TipoDoc, StatoDoc, Titolo, Body, Azienda, StrutturaAziendale, 
								ProtocolloRiferimento,  Fascicolo, LinkedDoc, StatoFunzionale ,Versione )
						select @idUser as IdPfu ,  'BANDO_CONCORSO' , 'Saved' ,  @strDesc + ' ' + d.Protocollo , d.Body , Azienda ,   StrutturaAziendale
								, d.Protocollo  , '' as Fascicolo ,  Id  ,'InLavorazione' , d.Versione
							from 
								CTL_DOC d with(nolock)
							where Id = @IdBando

		-- Recupero l'id del nuovo documento BANDO CONCORSO
		set @Id = SCOPE_IDENTITY()

		----Se sul documento di partenza è presente la RIGAZERO la inserisco anche sull'invito
		--IF EXISTS (select * from ctl_doc_value where idheader = @idDoc and DSE_ID = 'TESTATA_PRODOTTI' and DZT_Name = 'RigaZero' and Value = '1')
		--BEGIN
		--	insert into CTL_DOC_Value (IdHeader,DSE_ID,DZT_Name,Value) values (@Id,'TESTATA_PRODOTTI','RigaZero','1')
		--END
		
		
		----settaggio RichiestaCigSimog
		--IF (select dbo.attivoSimog())=1
		--	 set @RichiestaCigSimog= 'si'
		--ELSE 
		--	 set @RichiestaCigSimog=null

		--select @idazi = pfuidazi from profiliutente with(nolock) where idpfu = @idUser

		----se azienda corrente non è tra gli enti abilitati setto @richiestaCIG a no
		--select  @Lista_Enti_abilitati_RCig= dbo.PARAMETRI('GROUP_SIMOG','ENTI_ABILITATI','DefaultValue','',-1)
		--if @Lista_Enti_abilitati_RCig <> '' and CHARINDEX (',' + cast(@idazi as varchar(20)) + ',', ',' + @Lista_Enti_abilitati_RCig + ',') = 0
		--	set @RichiestaCigSimog = 'no'


		-- inserico i dati base del bando
		insert into Document_Bando (
										[idHeader], [SoggettiAmmessi], [ImportoBando], [MaxNumeroIniziative], 
										[MaxFinanziabile], [dataCreazione], [DataEstenzioneInizio], [DataEstenzioneFine], 
										[FAX], [DataRiferimentoInizio], [DataRiferimentoFine], [DataPresentazioneRisposte], 
										[StatoBando], [Ufficio], [NumeroBUR], [DataBUR], [dgrN], [dgrDel], [TipoBando], 
										[TipoAppalto], [RichiestaQuesito], [ReceivedQuesiti], [RecivedIstanze], 
										[MotivoEstensionePeriodo], [ClasseIscriz], [RichiediProdotti], [ProceduraGara], 
										[TipoBandoGara], [CriterioAggiudicazioneGara], [ImportoBaseAsta], [Iva], 
										[ImportoBaseAsta2], [Oneri], [CriterioFormulazioneOfferte], [CalcoloAnomalia], 
										[OffAnomale], [NumeroIndizione], [DataIndizione], [gg_QuesitiScadenza], 
										[DataTermineQuesiti], [ClausolaFideiussoria], [VisualizzaNotifiche], [CUP], 
										[CIG], [GG_OffIndicativa], [HH_OffIndicativa], [MM_OffIndicativa], 
										[DataScadenzaOffIndicativa], [GG_Offerta], [HH_Offerta], [MM_Offerta], 
										[DataScadenzaOfferta], [GG_PrimaSeduta], [HH_PrimaSeduta], [MM_PrimaSeduta], 
										[DataAperturaOfferte], [TipoAppaltoGara], [ProtocolloBando], [DataRevoca], 
										[Conformita], [Divisione_lotti], [NumDec], [DirezioneEspletante], [DataProtocolloBando],
										[ModalitadiPartecipazione], [TipoIVA], [EvidenzaPubblica], [Opzioni], [Complex], 
										[RichiestaCampionatura], [TipoGiudizioTecnico], [TipoProceduraCaratteristica], 
										[GeneraConvenzione], [ListaAlbi], [Appalto_Verde], [Acquisto_Sociale], 
										[Motivazione_Appalto_Verde], [Motivazione_Acquisto_Sociale], [Riferimento_Gazzetta], 
										[Data_Pubblicazione_Gazzetta], [BaseAstaUnitaria], [IdentificativoIniziativa], 
										[DataTermineRispostaQuesiti], [TipoSceltaContraente], [TipoAccordoQuadro], 
										[TipoAggiudicazione], [RegoleAggiudicatari], [TipologiaDiAcquisto], [Merceologia], 
										[CPV], [DataChiusura], [ModalitaAnomalia_TEC], [ModalitaAnomalia_ECO], [Num_max_lotti_offerti], 
										[Richiesta_terna_subappalto], [RichiediDocumentazione], [Controllo_superamento_importo_gara], 
										[TipoSedutaGara], [StatoChat], [Concessione], [Comunicazione_Iniziativa], 
										[RichiestaCigSimog], [EnteProponente], [RupProponente], [Visualizzazione_Offerta_Tecnica],
										[InversioneBuste], [GestioneQuote], [Accordo_di_Servizio], [FuoriPiattaforma], [AppaltoInEmergenza],
										[MotivazioneDiEmergenza], [DestinatariNotifica], [TipoSoglia], [AreaValutazione], [ArtClasMerceologica], 
										[CATEGORIE_MERC], [W9GACAM], [W9SISMA], [W9APOUSCOMP], [W3PROCEDUR], [W3PREINFOR], [W3TERMINE], 
										[DESCRIZIONE_OPZIONI], [RichiestaTED], [DataDirittoOblio], [Appalto_PNRR_PNC], [Appalto_PNRR], 
										[Appalto_PNC], [Motivazione_Appalto_PNRR], [Motivazione_Appalto_PNC], [ID_MOTIVO_DEROGA], 
										[FLAG_MISURE_PREMIALI], [ID_MISURA_PREMIALE], [FLAG_PREVISIONE_QUOTA], [QUOTA_FEMMINILE], 
										[QUOTA_GIOVANILE], [PresenzaCatalogo], [CategoriaDiSpesa], [GenderEquality], [GenderEqualityMotivazione],
										[DPCM], [Importo_Progettazione_Succ], [Importo_Opera], [Importo_Altri_Concorrenti], [PrevistaAssPremi],
										[PrevistaFaseSucc], [EstrazionePartecipanti], 
										[DataPrevistaAvvioSecondaFase], [FaseConcorso]
								   )
			select
					@Id, [SoggettiAmmessi], [ImportoBando], [MaxNumeroIniziative], 
					[MaxFinanziabile], [dataCreazione], [DataEstenzioneInizio], [DataEstenzioneFine], 
					[FAX], null as [DataRiferimentoInizio], [DataRiferimentoFine], [DataPresentazioneRisposte], 
					[StatoBando], [Ufficio], [NumeroBUR], [DataBUR], [dgrN], [dgrDel], [TipoBando], 
					[TipoAppalto], [RichiestaQuesito], 0 as [ReceivedQuesiti], 0 as [RecivedIstanze], 
					[MotivoEstensionePeriodo], [ClasseIscriz], [RichiediProdotti], [ProceduraGara], 
					'3' as TipoBandoGara , [CriterioAggiudicazioneGara], [ImportoBaseAsta], [Iva], 
					[ImportoBaseAsta2], [Oneri], [CriterioFormulazioneOfferte], [CalcoloAnomalia], 
					[OffAnomale], [NumeroIndizione], [DataIndizione], [gg_QuesitiScadenza], 
					null as [DataTermineQuesiti], [ClausolaFideiussoria], '0' as [VisualizzaNotifiche], [CUP], 
					[CIG], [GG_OffIndicativa], [HH_OffIndicativa], [MM_OffIndicativa], 
					[DataScadenzaOffIndicativa], [GG_Offerta], [HH_Offerta], [MM_Offerta], 
					null as [DataScadenzaOfferta], [GG_PrimaSeduta], [HH_PrimaSeduta], [MM_PrimaSeduta], 
					null as [DataAperturaOfferte], [TipoAppaltoGara], [ProtocolloBando], [DataRevoca], 
					[Conformita], [Divisione_lotti], [NumDec], [DirezioneEspletante], [DataProtocolloBando],
					[ModalitadiPartecipazione], [TipoIVA], '0' as [EvidenzaPubblica], [Opzioni], [Complex], 
					[RichiestaCampionatura], [TipoGiudizioTecnico], [TipoProceduraCaratteristica], 
					[GeneraConvenzione], [ListaAlbi], [Appalto_Verde], [Acquisto_Sociale], 
					[Motivazione_Appalto_Verde], [Motivazione_Acquisto_Sociale], [Riferimento_Gazzetta], 
					[Data_Pubblicazione_Gazzetta], [BaseAstaUnitaria], [IdentificativoIniziativa], 
					null as [DataTermineRispostaQuesiti], [TipoSceltaContraente], [TipoAccordoQuadro], 
					[TipoAggiudicazione], [RegoleAggiudicatari], [TipologiaDiAcquisto], [Merceologia], 
					[CPV], [DataChiusura], [ModalitaAnomalia_TEC], [ModalitaAnomalia_ECO], [Num_max_lotti_offerti], 
					[Richiesta_terna_subappalto], [RichiediDocumentazione], [Controllo_superamento_importo_gara], 
					[TipoSedutaGara],  [StatoChat], [Concessione], [Comunicazione_Iniziativa], 
					[RichiestaCigSimog], [EnteProponente], [RupProponente], [Visualizzazione_Offerta_Tecnica],
					[InversioneBuste], [GestioneQuote], [Accordo_di_Servizio], [FuoriPiattaforma], [AppaltoInEmergenza],
					[MotivazioneDiEmergenza], [DestinatariNotifica], [TipoSoglia], [AreaValutazione], [ArtClasMerceologica], 
					[CATEGORIE_MERC], [W9GACAM], [W9SISMA], [W9APOUSCOMP], [W3PROCEDUR], [W3PREINFOR], [W3TERMINE], 
					[DESCRIZIONE_OPZIONI], [RichiestaTED], [DataDirittoOblio], [Appalto_PNRR_PNC], [Appalto_PNRR], 
					[Appalto_PNC], [Motivazione_Appalto_PNRR], [Motivazione_Appalto_PNC], [ID_MOTIVO_DEROGA], 
					[FLAG_MISURE_PREMIALI], [ID_MISURA_PREMIALE], [FLAG_PREVISIONE_QUOTA], [QUOTA_FEMMINILE], 
					[QUOTA_GIOVANILE], [PresenzaCatalogo], [CategoriaDiSpesa], [GenderEquality], [GenderEqualityMotivazione],
					[DPCM], [Importo_Progettazione_Succ], [Importo_Opera], [Importo_Altri_Concorrenti], [PrevistaAssPremi],
					[PrevistaFaseSucc], [EstrazionePartecipanti], 
					[DataPrevistaAvvioSecondaFase], 'seconda'
				from 
					Document_Bando with (nolock)
				where idheader = @IdBando
					

		--setto per la testata un modello specifico per i campi non editabili
		insert into CTL_DOC_SECTION_MODEL(idheader,DSE_ID,MOD_Name)
			values(@Id, 'TESTATA', 'BANDO_CONCORSO_TESTATA_INVITO')

		--riporto il campo UserRup dal primo giro
		insert into CTL_DOC_Value
			( [IdHeader], [DSE_ID], [Row], [DZT_Name], [Value] )
			select 
				@Id as idheader , dse_id,row,dzt_name,value
				from
					CTL_DOC_Value with (nolock)
				where IdHeader = @IdBando and DSE_ID='InfoTec_comune' and DZT_Name='UserRUP'

		insert into Document_dati_protocollo ( idHeader)
									  values (  @Id )

		--Riporto gli atti di gara
		insert into CTL_DOC_ALLEGATI(
										[idHeader], [Descrizione], [Allegato], [Obbligatorio], [AnagDoc], [DataEmissione],
										[Interno], [Modified], [NotEditable], [TipoFile], [DataScadenza], [DSE_ID], 
										[EvidenzaPubblica], [RichiediFirma], [FirmeRichieste], [AllegatoRisposta], [EsitoRiga], [TemplateAllegato]
									)
			select 
				@Id as idHeader, [Descrizione], [Allegato], [Obbligatorio], [AnagDoc], [DataEmissione], [Interno],
				[Modified], [NotEditable], [TipoFile], [DataScadenza], [DSE_ID], [EvidenzaPubblica], [RichiediFirma],
				[FirmeRichieste], [AllegatoRisposta], [EsitoRiga], [TemplateAllegato] 
				from 
					CTL_DOC_ALLEGATI with (nolock)
				where idheader = @IdBando

		--Riporto le INFORMAZIONI TECNICHE
		insert into CTL_DOC_VALUE([IdHeader], [DSE_ID], [Row], [DZT_Name], [Value])
			select 
				@Id as idHeader, [DSE_ID], [Row], [DZT_Name], [Value]
				from 
					CTL_DOC_VALUE with (nolock)
				where idheader = @IdBando and DSE_ID = 'InfoTec_DefinizionePremi_griglia'


		-- Riporto le informazioni della BUSTA DOCUMENTAZIONE con dse_id diverso rendendo questi record creati per copia NON EDITABILI
		insert into Document_Bando_DocumentazioneRichiesta (
															[idHeader], [TipoInterventoDocumentazione], [LineaDocumentazione], [DescrizioneRichiesta], [AllegatoRichiesto], [Obbligatorio], [TipoFile], [AnagDoc],
															[NotEditable], [RichiediFirma], [AreaValutazione], [Punteggio], [DataScadenza], [Peso], [AllegatoValutatore], [Note], [TipoValutazione], [EMAS], [DSE_ID]
														   )
			select 
				@Id, [TipoInterventoDocumentazione], [LineaDocumentazione], [DescrizioneRichiesta], [AllegatoRichiesto], [Obbligatorio], [TipoFile], [AnagDoc],
				' FNZ_DEL DescrizioneRichiesta TipoFile Obbligatorio ', [RichiediFirma], [AreaValutazione], [Punteggio], [DataScadenza], [Peso], [AllegatoValutatore], [Note], [TipoValutazione], [EMAS], 'DOCUMENTAZIONE_RICHIESTA_PRIMAFASE'
				from 
					Document_Bando_DocumentazioneRichiesta with (nolock)
				where idheader = @IdBando and DSE_ID = 'DOCUMENTAZIONE_RICHIESTA'


		--  Riporto i RIFERIMENTI
		insert into Document_Bando_Riferimenti([idHeader], [idPfu], [RuoloRiferimenti])
			select 
				@Id, [idPfu], [RuoloRiferimenti]
				from 
					Document_Bando_Riferimenti with (nolock)
				where idheader = @IdBando




		-- SE L'UTENTE HA EFFETTUATO UN SORTEGGIO PUBBLICO CONGELO I DESTINATARI TRA QUELLI SORTEGGIATI
		--IF EXISTS ( select id from CTL_DOC sortPub with(nolock) where sortPub.LinkedDoc = @idDoc and sortPub.TipoDoc = 'SORTEGGIO_PUBBLICO' and sortPub.Deleted = 0 and sortPub.StatoFunzionale = 'Confermato' )
		--		OR
		--	@giroRistetta = 1
		--BEGIN

		--	IF @giroRistetta = 0
		--	BEGIN

		--		insert into CTL_DOC_Destinatari ( idHeader, CodiceFiscale, IdPfu, IdAzi, aziRagioneSociale, aziPartitaIVA, aziE_Mail, aziIndirizzoLeg, aziLocalitaLeg, aziProvinciaLeg, aziStatoLeg, aziCAPLeg, aziTelefono1, aziFAX, aziDBNumber, aziSitoWeb, CDDStato, Seleziona, NumRiga, ordinamento)
		--			select   @Id , ISNULL(a.CodiceFiscale,c.vatValore_FT) as CodiceFiscale, a.IdPfu, a.IdAzi, a.aziRagioneSociale, a.aziPartitaIVA, a.aziE_Mail, a.aziIndirizzoLeg, a.aziLocalitaLeg, a.aziProvinciaLeg, a.aziStatoLeg, a.aziCAPLeg, a.aziTelefono1, a.aziFAX, a.aziDBNumber, a.aziSitoWeb, CDDStato, Seleziona, NumRiga, a.ordinamento
		--			from CTL_DOC_Destinatari a with(nolock)
		--					inner join aziende b on b.idazi=a.idazi
		--					left join DM_Attributi c on c.lnk=b.IdAzi and c.idApp=1 and c.dztNome='Codicefiscale'
		--					inner join CTL_DOC sortPub on sortPub.LinkedDoc = @idDoc and sortPub.TipoDoc = 'SORTEGGIO_PUBBLICO' and sortPub.Deleted = 0 and sortPub.StatoFunzionale = 'Confermato'	
		--					inner join 	Document_AziSortPub sb on sb.idAzi = a.IdAzi and sb.idHeader = sortPub.id
		--			where a.idheader = @idDoc and isnull(StatoIscrizione,'') = ''

		--	END
		--	BEGIN

				insert into CTL_DOC_Destinatari ( idHeader, CodiceFiscale, IdPfu, IdAzi, aziRagioneSociale, aziPartitaIVA, aziE_Mail, aziIndirizzoLeg, aziLocalitaLeg, aziProvinciaLeg, aziStatoLeg, aziCAPLeg, aziTelefono1, aziFAX, aziDBNumber, aziSitoWeb, CDDStato, Seleziona, NumRiga, ordinamento)
					select   @Id , ISNULL(a.CodiceFiscale,c.vatValore_FT) as CodiceFiscale, IdPfu, a.IdAzi, a.aziRagioneSociale, a.aziPartitaIVA, a.aziE_Mail, a.aziIndirizzoLeg, a.aziLocalitaLeg, a.aziProvinciaLeg, a.aziStatoLeg, a.aziCAPLeg, a.aziTelefono1, a.aziFAX, a.aziDBNumber, a.aziSitoWeb, CDDStato, Seleziona, a.NumRiga, ordinamento
					from CTL_DOC_Destinatari a with(nolock)
							inner join aziende b with (nolock) on b.idazi=a.idazi
							inner join Document_PDA_OFFERTE pdaOff with (nolock) on pdaOff.IdHeader = @IdDoc and pdaOff.StatoPDA = '2' and pdaOff.idAziPartecipante = b.IdAzi
							left join DM_Attributi c with (nolock) on c.lnk=b.IdAzi and c.idApp=1 and c.dztNome='Codicefiscale'
					where a.idheader = @IdBando --and isnull(StatoIscrizione,'') = ''

				--Mi setto dei modelli ANONIMI per i destinatari su entrambe le sezioni
				insert into CTL_DOC_SECTION_MODEL(idheader,DSE_ID,MOD_Name)
					values
						(@Id, 'DESTINATARI_1', 'BANDO_CONCORSO_DESTINATARI_ANONIMO'),
						(@Id, 'DESTINATARI_INT', 'BANDO_CONCORSO_DESTINATARI_ANONIMO')

			--END


			set @num=1

			declare CurProg Cursor Static for 
											select idRow 
											from CTL_DOC_Destinatari 
											where idHeader = @Id	
											order by ordinamento

			open CurProg
			FETCH NEXT FROM CurProg INTO @idrow

			WHILE @@FETCH_STATUS = 0
			BEGIN

				update CTL_DOC_Destinatari 
						set NumRiga=@num 
					where idrow=@idrow
				 
				set @num = @num + 1
				 			 
				FETCH NEXT FROM CurProg INTO @idrow

			END 

			CLOSE CurProg
			DEALLOCATE CurProg

		--END

	END

	--exec BANDO_GARA_DEFINIZIONE_STRUTTURA @id


	--recupero numero gara dalla gara
	--select @NumeroGara=cig from document_bando  with (nolock) where  idHeader =  @id 

	----se numerogara presente su una richiesta CIG non associato ad un'altra gara 
	
	----recupero le gare che hanno associate una richiesta cig nello stato inviata 
	--select 
	--	G.id
	--	into #tempCigara
	--from
	--	CTL_DOC G with (nolock)
	--		inner join Document_Bando with (nolock) on idHeader = G.id
	--		inner join CTL_DOC RIC_CIG with (nolock) on  RIC_CIG.LinkedDoc = G.Id and RIC_CIG.tipodoc in ('RICHIESTA_CIG','RICHIESTA_SMART_CIG') and RIC_CIG.StatoFunzionale ='inviato' and  RIC_CIG.Deleted =0
	--		left join Document_SIMOG_GARA DSG with (nolock) on DSG.idHeader =  RIC_CIG.id  
	--		left join Document_SIMOG_LOTTI DSL with (nolock) on DSL.idheader =  RIC_CIG.id  
	--		left join Document_SIMOG_SMART_CIG DSC with (nolock) on DSC.idHeader =  RIC_CIG.Id
	--where 
	--	G.TipoDoc in ('BANDO_CONCORSO') and G.Deleted = 0 and G.Id <> @id
	--	and  (
	--			--presente su una richiesta smart cig
	--			( divisione_lotti = '0' and DSC.smart_cig = @NumeroGara )
	--			or
	--			--presente su numero gara si una richiesta cig a lotti
	--			( divisione_lotti <> '0' and DSG.id_gara  = @NumeroGara )
	--			or 
	--			--presente sui lotti di una richiesta cig non a lotti 
	--			( divisione_lotti = '0' and DSL.cig  = @NumeroGara )
	--		)

	
	
     --e presente su un pregara non ancora utilizzato su nessuna gara allora faccio 
	 --recupero numero gara della gara
	
	--if not exists (select * from #tempCigara)
	--begin

	--	set @IdPregara=0

	--	select 
	--		--RIC_CIG.id
	--		--into #tempCigPreGara
	--		@IdPregara = G.Id 
	--	from
	--		CTL_DOC G with (nolock)
	--			inner join Document_Bando with (nolock) on idHeader = G.id
	--			inner join CTL_DOC RIC_CIG with (nolock) on  RIC_CIG.LinkedDoc = G.Id and RIC_CIG.tipodoc in ('RICHIESTA_CIG','RICHIESTA_SMART_CIG')  and RIC_CIG.StatoFunzionale ='inviato' and  RIC_CIG.Deleted =0
	--			left join Document_SIMOG_GARA DSG with (nolock) on DSG.idHeader =  RIC_CIG.id  
	--			left join Document_SIMOG_LOTTI DSL with (nolock) on DSL.idheader =  RIC_CIG.id 
	--			left join Document_SIMOG_SMART_CIG DSC with (nolock) on DSC.idHeader =  RIC_CIG.Id
	--	where 
	--		G.TipoDoc in ('PREGARA') and G.Deleted = 0 and G.StatoFunzionale  in ( 'Completo' ,'Concluso')
	--		and  (
	--				--presente su una richiesta smart cig
	--				(  DSC.smart_cig = @NumeroGara ) --divisione_lotti = '0' and
	--				or
	--				--presente su numero gara di una richiesta cig a lotti
	--				(  DSG.id_gara  = @NumeroGara ) --divisione_lotti <> '0' and
	--				or 
	--				--presente sui lotti di una richiesta cig non a lotti 
	--				(  DSL.cig  = @NumeroGara ) --divisione_lotti = '0' and
	--			)

	--	if @IdPregara <> 0 
	--		exec ASSOCIA_RICHIESTACIG_GARA_FROM_PREGARA  @IdPregara ,  @id,  @idUser

	--	--associao alla gara il pregara
	--	insert into CTL_DOC_Value ( IdHeader , DSE_ID , DZT_Name , Value )
	--		values
	--			(@id , 'InfoTec_comune', 'IdDocPreGara', cast(@IdPregara as varchar(100) ) )

	--end


	----recupero @EvidenzaPubblica_Parametro dai parametri
	--select @EvidenzaPubblica_Parametro = dbo.PARAMETRI('NUOVA_PROCEDURA-SAVE:INVITO','EvidenzaPubblica','DefaultValue','NULL',-1)
	--if @EvidenzaPubblica_Parametro <> 'NULL'
	--begin
	--	update Document_Bando 
	--		set EvidenzaPubblica = @EvidenzaPubblica_Parametro
	--		where idheader= @id
	--end


	-- rirorna l'id del BANDO CONCORSO SECONDA FASE
	select @id as id

END

GO
