USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_AFFIDAMENTO_SEMPLIFICATO_CREATE_FROM_OE]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO










CREATE  PROCEDURE [dbo].[OLD2_AFFIDAMENTO_SEMPLIFICATO_CREATE_FROM_OE] 
	( @idDoc int , @IdUser int  )
AS
BEGIN
	SET NOCOUNT ON;


	declare @Id as INT
	declare @Errore as nvarchar(2000)
	declare @Azienda as int
	declare @IdPfu as INT
	declare @TipoProceduraCaratteristica as varchar(100)
	declare @DirezioneEspletante as varchar(100)
	declare @EvidenzaPubblica as char(1)
	declare @ProceduraGara as varchar (20) 
	declare @TipoBandoGara as varchar (20)
	declare @CriterioAggiudicazioneGara as varchar (20)
	declare @CriterioFormulazioneOfferte as varchar (20)
	declare @Divisione_lotti as varchar(1)
	declare @RichiestaQuesito  as char(1)
	declare @Conformita as varchar (20)
	declare @Appalto_Verde as varchar (10)
	declare @Acquisto_Sociale as varchar (10)
	declare @AppaltoInEmergenza as varchar (10)
	declare @TipoSedutaGara as varchar (20)
	declare @RichiestaCampionatura as varchar (20)
	declare @Complex as int
	declare @VisualizzaNotifiche as varchar (20)
	declare @Num_max_lotti_offerti as int
	declare @DestinatariNotifica as  varchar (10)
	declare @ModalitadiPartecipazione  as  varchar (20)

	declare @StatoFunzionale as varchar (200)
	declare @CodiceModello varchar(200)
	declare @IdModello as int
	declare @Ambito as varchar(100)
	declare @PrevDoc as int
	declare @TipoAppaltoGara as int
	declare @GeneraConvenzione as char(1)
	declare @RichiestaCigSimog as varchar(2)

	set @Errore = ''
	
	
	if @Errore = '' 
	begin
	
		--recupero azienda utente collegato
		select @Azienda = pfuidazi from profiliutente  with (nolock) WHERE idpfu = @IdUser

		-- genero il record per il nuovo documento, cancellato logicamente per evitare che sia visibile se non finalizza le operazioni	
		INSERT into CTL_DOC 
				( IdPfu,  TipoDoc, Azienda ,  StrutturaAziendale , Caption , statofunzionale,versione)
				values
				( @IdUser  ,  'BANDO_GARA' , @Azienda ,  cast( @Azienda as varchar) + '#' + '\0000\0000' , 'Nuovo Affidamento Semplificato', 'InLavorazioneCreaModello','2')
				
		set @Id = SCOPE_IDENTITY()


		--imposto il campo UserRup 
		--se utente collegato presente nei responsibili RUP_PDG
		if exists ( Select DMV_COD from ELENCO_RESPONSABILI where idpfu =  @IdUser  and RUOLO in ('RUP_PDG')  and DMV_COD = @IdUser)
		begin
			insert into CTL_DOC_Value
				( [IdHeader], [DSE_ID], [Row], [DZT_Name], [Value] )
				values
				( @Id, 'InfoTec_comune' , 0 , 'UserRUP' , @IdUser )
		end
		
		--aggiungo nella CTL_DOC_DESTINATARI l'azienda destinataria selezionata
		--come utente dell'azienda destinataria quale prendo ? 
		insert into CTL_DOC_Destinatari
					(idHeader, IdPfu, IdAzi, aziRagioneSociale, aziPartitaIVA, aziE_Mail, aziIndirizzoLeg, aziLocalitaLeg, aziProvinciaLeg, aziStatoLeg, aziCAPLeg, aziTelefono1, aziFAX, aziDBNumber, aziSitoWeb)
				select @Id as idHeader, null as IdPfu, IdAzi, aziRagioneSociale, aziPartitaIVA, aziE_Mail, aziIndirizzoLeg, aziLocalitaLeg, aziProvinciaLeg, aziStatoLeg, aziCAPLeg, aziTelefono1, aziFAX, aziDBNumber, aziSitoWeb
					from aziende with (nolock)
						where idazi = @idDoc 


		--imposto gli attibuti come richiesto
		--Affidamento Diretto				--ProceduraGara e TipoBandoGara
		--Solo al prezzo più basso			-- CriterioAggiudicazioneGara
		--Solo ad importo (no % ribasso)	-- CriterioFormulazioneOfferte
		--Solo lotto singolo				-- Divisione_lotti
		--Solo richiesta Smart Cig
		--Un solo operatore economico
		--No gestione quesiti				-- RichiestaQuesito
		

		set @TipoProceduraCaratteristica='AffidamentoSemplificato'
		set @DirezioneEspletante = cast( @Azienda as varchar) + '#' + '\0000\0000'
		set @EvidenzaPubblica = '0'
		set @ProceduraGara = '15583'
		set @TipoBandoGara = '3'
		set @CriterioAggiudicazioneGara = '15531'
		set @CriterioFormulazioneOfferte = '15536'
		set @Divisione_lotti = '0'
		set @RichiestaQuesito = '2'
		set @Conformita= 'No'
		set @Appalto_Verde= 'no'
		set @Acquisto_Sociale= 'no'
		set @AppaltoInEmergenza= 'no'
		set @TipoSedutaGara= 'no'
		set @RichiestaCampionatura= '0'
		set @Complex = 0 
		set @VisualizzaNotifiche = '1'
		set @Num_max_lotti_offerti= 1
		set @DestinatariNotifica = '0'
		set @ModalitadiPartecipazione = '16308'
		set @Ambito = '3' -- ALTRI BENI
		--set @TipoAppaltoGara = '3' Servizi
		set @TipoAppaltoGara = ''
		set @GeneraConvenzione = '0'
		set @RichiestaCigSimog = 'si'

		-- aggiunge il record sul bando				
		insert into Document_Bando 
				( idHeader ,  TipoProceduraCaratteristica , DirezioneEspletante , EvidenzaPubblica,
					ProceduraGara, TipoBandoGara, CriterioAggiudicazioneGara,CriterioFormulazioneOfferte,Divisione_lotti,
					RichiestaQuesito,Conformita,EnteProponente , RupProponente , Appalto_Verde, Acquisto_Sociale, 
					AppaltoInEmergenza, TipoSedutaGara, RichiestaCampionatura, Complex, VisualizzaNotifiche ,  
					Num_max_lotti_offerti, DestinatariNotifica,ModalitadiPartecipazione,TipoAppaltoGara,GeneraConvenzione, RichiestaCigSimog  )
				values
				 ( @id, @TipoProceduraCaratteristica, @DirezioneEspletante, @EvidenzaPubblica, 
					@ProceduraGara, @TipoBandoGara, @CriterioAggiudicazioneGara, @CriterioFormulazioneOfferte, @Divisione_lotti, 
					@RichiestaQuesito, @Conformita, @DirezioneEspletante , @IdUser, @Appalto_Verde, @Acquisto_Sociale, 
					@AppaltoInEmergenza, @TipoSedutaGara, @RichiestaCampionatura, @Complex, @VisualizzaNotifiche, 
					@Num_max_lotti_offerti, @DestinatariNotifica,@ModalitadiPartecipazione,@TipoAppaltoGara,@GeneraConvenzione,@RichiestaCigSimog )	
			


		insert into Document_Bando_Riferimenti ( idHeader, idPfu  ) 
			values( @id , @IdUser ) 

		-- aggiunge i modelli personalizzati pr gestire le RDO
		--insert into CTL_DOC_SECTION_MODEL ( IdHeader, DSE_ID, MOD_Name ) 
		--	values( @id , 'TESTATA' , 'BANDO_GARA_TESTATA_AFFIDAMENTISEMPLIFICATI' )
		exec BANDO_GARA_DEFINIZIONE_STRUTTURA @id 

		--aggiungo il record nella Document_dati_protocollo 
		insert into Document_dati_protocollo ( idHeader)
 			values (  @id )

				
		--RECUPERO MODELLO PER I PRODOTTI DI GARA
		
		set @CodiceModello = ''
		set @IdModello = 0
		set @StatoFunzionale =''
		--select 
		--	@IdModello =id, @StatoFunzionale = statofunzionale , @CodiceModello=titolo
		--	 from 
		--		ctl_doc  with (nolock)

		--	 where guid = '545CFA76-3FFA-4347-A1C3-05035113EA14' --da cambiare con il guid del modello che vado a pubblicare
		--			and tipodoc='CONFIG_MODELLI_LOTTI' and deleted=0
		select 
			@IdModello =id, @StatoFunzionale = statofunzionale , @CodiceModello=titolo
			 from 
				ctl_doc  with (nolock)
					inner join ctl_Doc_value with (nolock) on idheader = id and DSE_ID = 'AMBITO' and DZT_Name = 'MacroAreaMerc' and value=@Ambito
			 where 
				tipodoc='CONFIG_MODELLI_LOTTI' and  versione='AFFIDAMENTO_DIRETTO_SEMPLIFICATO' and linkeddoc = 0

		if isnull( @CodiceModello , '' ) = '' 
		begin
			update ctl_doc set StatoFunzionale = 'InLavorazione' where id = @id
		end
		else
		begin
			
			set @PrevDoc = @IdModello

			while @StatoFunzionale <> 'Pubblicato' and @IdModello <> 0 
			begin
				set @IdModello = 0
				set @StatoFunzionale = ''
				set @CodiceModello = ''

				select @IdModello =id, @StatoFunzionale = statofunzionale , @CodiceModello=titolo
					 from ctl_Doc with (nolock) where prevdoc = @PrevDoc and tipodoc='CONFIG_MODELLI_LOTTI' and deleted=0
														and linkeddoc = 0
				
				set @PrevDoc = 	@IdModello
					
			end
		
			
			-- se ho trovato il modello pubblicato
			if isnull( @CodiceModello , '' ) <> '' 
			begin
		
				update document_bando set TipoBando = @CodiceModello + '_MONOLOTTO' where idheader = @id   
				
				insert into ctl_doc_value ( [IdHeader], [DSE_ID], [Row], [DZT_Name], [Value] ) values ( @Id , 'TESTATA_PRODOTTI' , 0 , 'TipoBandoScelta' ,  @CodiceModello + '_MONOLOTTO' ) 


				--associo l'ambito del modello sulla gara
				--select @Ambito=value from CTL_DOC_VALUE with (nolock) 
				--	where idheader = @IdModello and DSE_ID = 'AMBITO' and DZT_Name = 'MacroAreaMerc'
				
				insert into ctl_doc_value ( [IdHeader], [DSE_ID], [Row], [DZT_Name], [Value] ) values ( @Id , 'TESTATA_PRODOTTI' , 0 , 'Ambito' , @Ambito ) 

			end
			else
			begin
				update ctl_doc set StatoFunzionale = 'InLavorazione' where id = @id
			end 


			--setto il punteggio economico a 100
			insert into ctl_doc_value ( [IdHeader], [DSE_ID], [Row], [DZT_Name], [Value] ) values ( @Id , 'CRITERI_ECO' , 0 , 'PunteggioEconomico' , '100' ) 

			-- metto prima la riga 0 che rappresenta la gara
			insert into Document_MicroLotti_Dettagli
					   ( IdHeader, numerolotto , voce , NumeroRiga, TipoDoc, Descrizione )
				select @id, 1 , 0 , 0 , 'BANDO_GARA', '' as Descrizione
			
			
			--inizializzo le buste ATTI e DOCUMENTAZIONE DELLA GARA
			exec INIT_DOCUMENTI_GARA  @id, @IdUser 

			

		end
	end
		
	if @Errore = ''
	begin
		-- rirorna l'id della nuova comunicazione appena creata
		select @Id as id, 'BANDO_GARA' as TYPE_TO , 'BANDO_GARA' as JSCRIPT
	
	end
	else
	begin
		-- rirorna l'errore
		select 'Errore' as id , @Errore as Errore 
	end
END


















GO
