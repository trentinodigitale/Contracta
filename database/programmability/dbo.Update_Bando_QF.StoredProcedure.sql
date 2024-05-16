USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[Update_Bando_QF]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[Update_Bando_QF] ( @IdBando int  , @IdVar int , @IdPfu int )
AS
BEGIN
	
	--declare @id int
	--declare @ListaAlbi varchar(4000)
	--declare @Errore nvarchar(max)

	--declare @ImportoBando FLOAT
	--declare @TipoBando varchar(1000)
	--declare @RichiestaQuesito varchar(10)
	--declare @ClasseIscriz varchar(1000)
	--declare @ProceduraGara varchar(100)
	--declare @TipoBandoGara varchar(10)
	--declare @CriterioAggiudicazioneGara varchar(100)
	--declare @CriterioFormulazioneOfferte varchar(100)
	--declare @OffAnomale varchar(10)
	--declare @TipoAppaltoGara varchar(10)
	--declare @Conformita varchar(10)
	--declare @Divisione_lotti varchar(10)
	--declare @TipoIVA varchar(10)

	--declare @modelloProdotti varchar(1000)

	SET NOCOUNT ON

	/*
	set @Id = 0
	set @Errore = ''
	 
	select @id = id from CTL_DOC with(nolock) 
		where PrevDoc = @IdFrom and TipoDoc = 'BANDO_QF' 
				and Deleted = 1 
				and StatoFunzionale <> 'Pubblicato'
				and isnull(jumpcheck,'')='Variazione_QF'

	IF @id = 0
	BEGIN

		INSERT INTO CTL_DOC ( IdPfu, TipoDoc, StatoDoc, Titolo, Body, Azienda, StrutturaAziendale, 
				ProtocolloRiferimento,  Fascicolo, LinkedDoc, StatoFunzionale ,Versione, caption, JumpCheck,PrevDoc,deleted )
			SELECT @idUser ,  'BANDO_QF' , 'Saved' , 'Variazione di ''' + isnull (titolo,'') + '''', 'Variazione di ' + cast(d.Body as nvarchar(max))  , d.azienda, null,
					d.Protocollo  , Fascicolo  ,  null  ,'InLavorazione' , '', 'Variazione Elenco Fornitori', 'Variazione_QF',@IdFrom,1
				from CTL_DOC d with(nolock)
						left join aziende az with(nolock) on az.idazi = d.Azienda
				where Id = @IdFrom

		set @Id = SCOPE_IDENTITY()

		set @ImportoBando = 0
		set @TipoBando = ''
		set @RichiestaQuesito = '0'
		set @ClasseIscriz = ''
		set @ProceduraGara = '15478' --negoziata
		set @TipoBandoGara = '3' --invito
		set @CriterioAggiudicazioneGara = '15532' --prezzo + basso
		set @CriterioFormulazioneOfferte = '15536' -- al prezzo
		set @OffAnomale = '16310' --valutazione
		set @TipoAppaltoGara = '1' --forniture
		set @Conformita = 'No'
		set @Divisione_lotti = '0' --no
		set @TipoIVA = '3'

		*/

		------------------------------------------------------------------
		-- sulla ctl_doc per adesso  aggiorniamo solo oggetto e note
		------------------------------------------------------------------

		declare @body nvarchar(max)
		declare @note nvarchar(max)

		select @body = Body , @note = Note 
			from ctl_doc with (nolock)
				where id = @IdVar

		
		update ctl_doc
			set   Body = @body , note =  @note 
		where id = @IdBando

		------------------------------------------------------------------
		
		delete from Document_Bando where idHeader = @IdBando

		INSERT INTO Document_Bando ( TipoProceduraCaratteristica,
						idHeader, ImportoBando, dataCreazione, FAX , Ufficio, TipoBando, TipoAppalto, RichiestaQuesito,  ClasseIscriz, RichiediProdotti, ProceduraGara, 
						TipoBandoGara       , CriterioAggiudicazioneGara, ImportoBaseAsta, Iva, ImportoBaseAsta2, Oneri, CriterioFormulazioneOfferte, CalcoloAnomalia, 
						OffAnomale, NumeroIndizione, DataIndizione, ClausolaFideiussoria, VisualizzaNotifiche, CUP, CIG, TipoAppaltoGara,  Conformita, Divisione_lotti,
						NumDec, DirezioneEspletante, ModalitadiPartecipazione, TipoIVA, EvidenzaPubblica,Concessione,EnteProponente,RupProponente, ArtClasMerceologica ,Merceologia, [AreaValutazione] )
			select  TipoProceduraCaratteristica,
						@IdBando, ImportoBando, dataCreazione, FAX , Ufficio, TipoBando, TipoAppalto, RichiestaQuesito,  ClasseIscriz, RichiediProdotti, ProceduraGara, 
						TipoBandoGara       , CriterioAggiudicazioneGara, ImportoBaseAsta, Iva, ImportoBaseAsta2, Oneri, CriterioFormulazioneOfferte, CalcoloAnomalia, 
						OffAnomale, NumeroIndizione, DataIndizione, ClausolaFideiussoria, VisualizzaNotifiche, CUP, CIG, TipoAppaltoGara,  Conformita, Divisione_lotti,
						NumDec, DirezioneEspletante, ModalitadiPartecipazione, TipoIVA, EvidenzaPubblica,Concessione,EnteProponente,RupProponente, ArtClasMerceologica ,Merceologia, [AreaValutazione]
				from Document_Bando with(nolock)
					where idHeader = @IdVar


		-----------------------------------------------------------------------------------------
		
		delete from Document_Bando_DocumentazioneRichiesta where idHeader = @IdBando

		insert into Document_Bando_DocumentazioneRichiesta
			(  [idHeader], [TipoInterventoDocumentazione], [LineaDocumentazione], [DescrizioneRichiesta], [AllegatoRichiesto], [Obbligatorio], [TipoFile], [AnagDoc], [NotEditable], [RichiediFirma], [AreaValutazione], [Punteggio], [DataScadenza], [Peso], [AllegatoValutatore], [Note], [TipoValutazione], [EMAS] )
		select 
			@IdBando, [TipoInterventoDocumentazione], [LineaDocumentazione], [DescrizioneRichiesta], [AllegatoRichiesto], [Obbligatorio], [TipoFile], [AnagDoc], [NotEditable], [RichiediFirma], [AreaValutazione], [Punteggio], [DataScadenza], [Peso], [AllegatoValutatore], [Note], [TipoValutazione], [EMAS]
				from Document_Bando_DocumentazioneRichiesta with (nolock)
					where idHeader = @IdVar

		-----------------------------------------------------------------------------------------


		delete from CTL_DOC_ALLEGATI where idHeader = @IdBando
		
		insert into CTL_DOC_ALLEGATI
			( [idHeader], [Descrizione], [Allegato], [Obbligatorio], [AnagDoc], [DataEmissione], [Interno], [Modified], [NotEditable], [TipoFile], [DataScadenza], [DSE_ID], [EvidenzaPubblica], [RichiediFirma], [FirmeRichieste], [AllegatoRisposta], [EsitoRiga]	 )
			select 
				@IdBando, [Descrizione], [Allegato], [Obbligatorio], [AnagDoc], [DataEmissione], [Interno], [Modified], [NotEditable], [TipoFile], [DataScadenza], [DSE_ID], [EvidenzaPubblica], [RichiediFirma], [FirmeRichieste], [AllegatoRisposta], [EsitoRiga]	
					from CTL_DOC_ALLEGATI with (nolock)
						where idHeader = @IdVar

		-----------------------------------------------------------------------------------------
		
		delete from Document_Bando_Riferimenti where idHeader = @IdBando
		
		insert into Document_Bando_Riferimenti
			( [idHeader], idpfu, RuoloRiferimenti 	 )
			select 
				@IdBando, idpfu, RuoloRiferimenti
					from Document_Bando_Riferimenti with (nolock)
						where idHeader = @IdVar

		-----------------------------------------------------------------------------------------

		delete from CTL_DOC_Destinatari where idHeader = @IdBando
		
		insert into CTL_DOC_Destinatari
			(   [idHeader], [IdPfu], [IdAzi], [aziRagioneSociale], [aziPartitaIVA], [aziE_Mail], [aziIndirizzoLeg], [aziLocalitaLeg], [aziProvinciaLeg], [aziStatoLeg], [aziCAPLeg], [aziTelefono1], [aziFAX], [aziDBNumber], [aziSitoWeb], [CDDStato], [Seleziona], [NumRiga], [CodiceFiscale], [StatoIscrizione], [DataIscrizione], [DataScadenzaIscrizione], [DataSollecito], [Id_Doc], [DataConferma], [NumeroInviti], [ordinamento], [Is_Group]	 )
			select 
				@IdBando, [IdPfu], [IdAzi], [aziRagioneSociale], [aziPartitaIVA], [aziE_Mail], [aziIndirizzoLeg], [aziLocalitaLeg], [aziProvinciaLeg], [aziStatoLeg], [aziCAPLeg], [aziTelefono1], [aziFAX], [aziDBNumber], [aziSitoWeb], [CDDStato], [Seleziona], [NumRiga], [CodiceFiscale], [StatoIscrizione], [DataIscrizione], [DataScadenzaIscrizione], [DataSollecito], [Id_Doc], [DataConferma], [NumeroInviti], [ordinamento], [Is_Group]
					from CTL_DOC_Destinatari with (nolock)
						where idHeader = @IdVar

		
			-----------------------------------------------------------------------------------------

			insert into CTL_ApprovalSteps 
					( APS_Doc_Type , APS_ID_DOC    , APS_State     , APS_Note			 , APS_IdPfu , APS_UserProfile		, APS_IsOld , APS_Date ) 
			select     TipoDoc     , id            , 'Modificato'        , 'Documento variato' , @IdPfu , isnull( attvalue,'') , 1         , getdate() 
				from ctl_doc d 
					left outer join profiliutenteattrib p on d.idpfu = p.idpfu and dztnome = 'UserRoleDefault'  
			where id = @IdBando
						

	--END --if per cercare un rdo già creata

	--IF @Errore = ''
	--BEGIN

	--	-- rirorna l'id della nuova comunicazione appena creata
	--	select @Id as id

	--END
	--ELSE
	--BEGIN

	--	-- rirorna l'errore
	--	select 'Errore' as id , @Errore as Errore

	--END

	

END

GO
