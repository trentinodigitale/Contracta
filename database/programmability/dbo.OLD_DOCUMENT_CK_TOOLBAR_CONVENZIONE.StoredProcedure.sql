USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_DOCUMENT_CK_TOOLBAR_CONVENZIONE]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE [dbo].[OLD_DOCUMENT_CK_TOOLBAR_CONVENZIONE](  @DocName nvarchar(500) , @IdDoc as nvarchar(500) , @idUser int ) as
BEGIN
	
	declare @Is_Obblig_F1_Sign_Attach as varchar(10)
	declare @Mod_Name as varchar(500)
	declare @PresenzaAIC as varchar(1)
	declare @Ted_Attivo as varchar(10)
	declare @FascicoloGenerale as varchar(50)
	declare @IdGara as int
	declare @IsGaraTed as varchar(10)
	declare @nExistsGUEE as int
	declare @PresenzaListinoOrdini as varchar(10)
	declare @StatoListinoOrdini as  varchar(100)
	declare @Is_User_Abilitato_Funzioni as int
	declare @Is_User_Rif_Tecnico_Non_Agenzia as int
	declare @Compilatore as int
	declare @PresenzaDM as varchar(1)
	declare @NumDM as int

	DECLARE @sendPCP varchar(10) = '0'			-- abilitazione del comando "Invio dati PCP"
	DECLARE @viewSendPCP varchar(10) = '0'		-- visualizzazione del comando "Invio dati PCP"
	DECLARE @pubblicaConvPCP varchar(10) = '1'	-- abilitazione del comando di pubblicazione convenzione rispetto alle condizioni di invio dati pcp
	DECLARE @statoScheda varchar(100) = ''
	DECLARE @garaPCP varchar(10) = '0'
	DECLARE @readonlyPCP varchar(10) = '0'
	DECLARE @StatoFunzionale VARCHAR(100) = ''
	DECLARE @idPfuInCharge INT = 0
	DECLARE @ProceduraGara VARCHAR(100) = ''
	DECLARE @Pcp_TipoScheda varchar(100) = ''
	DECLARE @sendBase varchar(10) = ''

	set @Is_User_Abilitato_Funzioni = 0
	set @Is_User_Rif_Tecnico_Non_Agenzia = 0

	set @nExistsGUEE = 0

	SET NOCOUNT ON

	select 
		C.Idpfu,
		D.IdRow, 
		D.ID, 
		D.DOC_Owner, 
		D.DOC_Name, 
		D.DataCreazione, 
		C.Protocollo as Protocol, 
		C.Protocollo ,
		D.DescrizioneEstesa, 
		D.StatoConvenzione, 
		D.AZI, 
		D.Plant, 
		D.Deleted, 
		D.AZI_Dest, 
		D.NumOrd, 
		D.Imballo, 
		D.Resa, 
		D.Spedizione, 
		D.Pagamento, 
		D.Valuta, 
		D.Total, 
		D.Completo, 
		D.Allegato, 
		D.Telefono, 
		D.Compilatore, 
		D.RuoloCompilatore, 
		D.TipoOrdine, 
		D.SendingDate, 
		D.ProtocolloBando, 
		D.DataInizio, 
		D.DataFine, 
		D.Merceologia, 
		D.TotaleOrdinato, 
		D.IVA, 
		D.NewTotal, 
		D.RicPropBozza, 
		D.ConvNoMail, 
		D.QtMinTot, 
		D.RicPreventivo, 
		D.TipoImporto, 
		D.TipoEstensione, 
		D.RichiediFirmaOrdine, 
		D.OggettoBando, 
		D.DataProtocolloBando, 
		D.Mandataria, 
		D.ProtocolloContratto, 
		D.ProtocolloListino, 
		D.DataContratto, 
		D.DataListino, 
		D.ReferenteFornitore, 
		D.CodiceFiscaleReferente, 
		D.ReferenteFornitoreHide, 
		D.Ambito,

		D.GestioneQuote ,
		c.caption,
		ISNULL(c.jumpcheck,'') as jumpcheck,
		case when D.DataFine > getdate() then 'NO' else 'SI' end as SCADUTA,

		isnull(D.Stipula_in_forma_pubblica,0)  as Stipula_in_forma_pubblica
		,ISNULL(ConvenzioniInUrgenza,0) as ConvenzioniInUrgenza
		, case
			when c.StatoFunzionale = 'InLavorazione' then 'false'
			else 'true'
		end as ConvenzioneReadOnly
		,
		--flag per abilitare richiamo contratto
		case 
			when 
				( c.StatoFunzionale = 'InLavorazione'  and  ( StatoContratto = 'Inviato' or  StatoContratto = 'Confermato' ) )
				or 
				( ConvenzioniInUrgenza = '1' and statoconvenzione = 'Pubblicato' and  StatoContratto = 'Inviato' )  then 'true'
			else 'false'

		end	as Abilita_Richiamo_Contratto 

		, isnull(PresenzaListinoOrdini,'no') as PresenzaListinoOrdini

	INTO #Temp1 

	FROM CTL_DOC c with (nolock)
			inner join  Document_Convenzione D with (nolock) on D.id=C.id
		WHERE c.id = @IdDoc and c.deleted=0 and c.tipodoc='CONVENZIONE' 


	--recupero dai parametri se F1_SIGN_ATTACH obblig
	select @Is_Obblig_F1_Sign_Attach=dbo.PARAMETRI ('CONVENZIONE_ALLEGATI_FIRMATI','F1_SIGN_ATTACH','Obbligatory','0',-1)


	--recupero presenza AIC e presenza DM nel modello dei prodotti
	set @PresenzaAIC = '0'
	set @PresenzaDM = '0'

	--recupera il modello della sezione prodotti dinamico dalla ctl_doc_section_model
	select @Mod_Name = MOD_Name from ctl_doc_section_model with (nolock) where IdHeader = @IdDoc and DSE_ID='PRODOTTI'

	IF @Mod_Name <>''
	BEGIN
		
		--metto gli attributi in un atemp
		select MA_DZT_Name into #tempMod  
			from CTL_ModelAttributes WITH(INDEX(IX_CTL_ModelAttributes_MA_MOD_ID_MA_DZT_Name_MA_DescML_MA_Pos) nolock) where  MA_MOD_ID = @Mod_Name
		
		if exists(  select MA_DZT_Name from #tempMod where MA_DZT_Name = 'CodiceAIC'	 )
			set @PresenzaAIC = '1'
		
		--se siste CODICE_EAN oppure la coppia CODICE_ARTICOLO_FORNITORE e NumeroRepertorio
		if exists(  select MA_DZT_Name from #tempMod where MA_DZT_Name = 'CODICE_EAN' 	 )
		begin
			set @PresenzaDM = '1'
		end
		else
		begin
			set @NumDM = 0
			select @NumDM = count(*) from #tempMod where MA_DZT_Name = 'CODICE_ARTICOLO_FORNITORE' or MA_DZT_Name = 'NumeroRepertorio'

			if @NumDM = 2
				set @PresenzaDM = '1'

		end

	END

	--recupero se TED attivo dai parametri
	select @Ted_Attivo = dbo.PARAMETRI('SERVICE_REQUEST','TED','ATTIVO','NO',-1)

	--recupero dcondizione per attivare il bottone GESTIONE_GUEE
	--deve essere valorizzato il campo FascicoloGenerale e la gara associata deve avere l'integrazione con il TED
	select @FascicoloGenerale = FascicoloGenerale from ctl_doc with (nolock) where id = @IdDoc
	--recupero gara associata ai lotti della convenzione

	--controllo se esiste il documento GESTIONE_GUUE collegato alla convezione
	if exists (select id from ctl_doc with (nolock) where LinkedDoc = @IdDoc and tipodoc='GESTIONE_GUUE_F03' and deleted=0 )
		set @nExistsGUEE = 1

	set @IdGara = 0

	--select top 1 @IdGara = lg.LinkedDoc
	--	from Document_MicroLotti_Dettagli dettConv  with(nolock) 
	--			-- Relazione per CIG tra la gara e la conv
	--			left join ( 
	--						select  lg.id  , isnull( lg.CIG ,bando.cig ) as cig , lg.tipodoc , lg.voce , lg.NumeroLotto , LinkedDoc 
	--							from Document_MicroLotti_Dettagli lg with(nolock)  
	--								inner join ctl_doc pda with(nolock) ON pda.id = lg.IdHeader and pda.deleted=0 and pda.TipoDoc = 'PDA_MICROLOTTI'
	--								inner join document_bando bando with(nolock) on bando.idHeader=pda.LinkedDoc
	--							where isnull( lg.voce , 0 ) = 0  --and isnull( lg.CIG ,'' ) <> '' 
	--						) as lg  on  lg.cig = dettConv.CIG and lg.tipodoc = 'PDA_MICROLOTTI' and dettConv.NumeroLotto=lg.NumeroLotto 
	--	where dettConv.IdHeader=@IdDoc and dettConv.voce=0 and dettConv.TipoDoc='CONVENZIONE'
	--			and dettConv.StatoRiga not in ('Trasferito') 

	--SE LA GARA E' MULTILOTTO LA CHIAVE(IL CIG) CON LA CONVENZIONE E' PRESENTE SUI LOTTI
	select top 1 @idGara = pda.LinkedDoc
		from Document_MicroLotti_Dettagli dettConv with (nolock)
				inner join Document_MicroLotti_Dettagli lg with(nolock) ON lg.cig = dettConv.CIG and lg.tipodoc = 'PDA_MICROLOTTI' and isnull(lg.voce,0) = 0
				inner join ctl_doc pda with(nolock) ON pda.id = lg.IdHeader and pda.deleted=0 and pda.TipoDoc = 'PDA_MICROLOTTI'
				inner join Document_Bando gara with(nolock) on gara.idHeader = pda.LinkedDoc
				inner join CTL_DOC docGara with(nolock) ON docGara.Id = gara.idHeader and docGara.Deleted = 0 and docGara.StatoFunzionale in ( 'Pubblicato', 'Chiuso', 'PresOfferte', 'InRettifica', 'InAggiudicazione' )
		where dettConv.idheader = @IdDoc and dettConv.tipodoc='CONVENZIONE' and dettConv.StatoRiga not in ('Trasferito')

	--se non è stato trovato l'id della gara dalla precedente select
	IF @idGara = 0
	BEGIN
		
		--- NELLA GARA MONOLOTTO IL CIG NON LO PRENDO DALLA MICROLOTTIDETTAGLI MA DALLA TESTATA DELLA GARA
		select top 1 @idGara = docGara.Id
			from Document_MicroLotti_Dettagli dettConv with (nolock)
					inner join document_bando gara with(nolock) ON gara.CIG = dettConv.CIG
					inner join CTL_DOC docGara with(nolock) ON docGara.Id = gara.idHeader and docGara.Deleted = 0 and docGara.StatoFunzionale in ( 'Pubblicato', 'Chiuso', 'PresOfferte', 'InRettifica', 'InAggiudicazione' )			
			where dettConv.idheader = @IdDoc and dettConv.tipodoc='CONVENZIONE' and dettConv.StatoRiga not in ('Trasferito')

	END

	set @IsGaraTed='0'

	-- se è stato trovato l'id della gara
	IF @IdGara <> 0
	BEGIN

		if exists ( select id from ctl_doc with (nolock) where linkeddoc =@IdGara and tipodoc='PUBBLICA_GARA_TED' and statofunzionale='PubTed'  and deleted=0 )
				set @IsGaraTed = '1'


		-------------------------------------
		---- INIZIO GESTIONE PCP / SCHEDE ---
		-------------------------------------
		SELECT   @ProceduraGara = db.ProceduraGara
				,@Pcp_TipoScheda = pcp_TipoScheda
			FROM Document_PCP_Appalto A with(nolock) 
					inner join document_bando db with(nolock) on db.idHeader = a.idHeader
			WHERE a.idHeader = @IdGara

		--Entro nella nuova gestione di comando invio/inviodatipcp ed editabilità, 
		--	se la gara è nel giro PCP e 
		--		se sulla gara c'è la scheda P1_16 ( così da inviare l'a1_29 )
		--		oppure se sulla gara c'è la scheda P2_16 ( così da inviare l'a2_29 )
		--		oppure se sulla gara c'è la scheda P7_1_2 ( così da inviare l'a7_1_2 )
		--		oppure se sulla gara c'è la scheda P2_19 ( così da inviare l'A2_39 )
		--		oppure se sulla gara c'è la scheda P1_19( così da inviare l'A1_39 )
		--IF dbo.attivo_INTEROP_Gara( @IdGara ) = 1 and @Pcp_TipoScheda IN ('P1_16','P2_16','P7_1_2','P2_19','P1_19','P2_20')
		IF dbo.attivo_INTEROP_Gara( @IdGara ) = 1 and @Pcp_TipoScheda IN ('P1_16','P2_16','P7_1_2','P2_19','P1_19','P1_20')
		BEGIN

			set @statoScheda = '' -- stato vuoto : richiesta di invio scheda non ancora effettuata
			set @garaPCP = '1'	  -- evidenziamo che la gara è nel flusso PCP/INTEROP

			-- essendo attivo il flusso di interop per questa gara dovrò mostrare il comando di "invio dati pcp"
			set @viewSendPCP = '1'

			-- di base il comando di invio dati pcp non sarà attivo. NON deve esserlo ad esempio mentre si sta inviando la scheda ( negli stati intermedi )
			--	e dopo che la scheda si è chiusa
			set @sendPCP = '0'

			-- con il flusso di interop attivo di base non consentiamo la pubblicazione della convenzione, costringendo l'utente a passare dall'invio della scheda
			set @sendBase = '0'

			-- recupero lo stato dell'ultima scheda inviata collegata al documento corrente. in questo punto non ha importanza il tipo
			select top 1 @statoScheda = statoScheda 
				from Document_PCP_Appalto_Schede with(nolock) 
				where IdDoc_Scheda = @IdDoc and bDeleted = 0 and tipoScheda in ('A1_29','A7_1_2','A2_32','A1_32','A1_33','A2_33') 
				order by idRow desc

			--Rendiamo readonly il documento se è stata inviata una scheda e non c'è errore
			IF @statoScheda in ( 'InvioInCorso', 'Creato', 'Confermato', 'SC_CONF', 'AP_CONF', 'CigRecuperati', 'InPubblicazione', 'AV_PUBB', 'AV_RETT', 'AV_N_RETT', 'AV_RICHIESTA_RETT_IN_CORSO' )
			BEGIN
				-- quindi sarà editabile se la scheda non è stata ancora inviata o se c'è un errore, stati : '', 'ErroreCreazione', 'ErroreConferma', 'AP_N_CONF', 'SC_N_CONF', 'AV_N_PUBB'
				SET @readonlyPCP = '1'
			END

			IF @statoScheda IN ( '', 'ErroreCreazione', 'ErroreConferma', 'AP_N_CONF', 'SC_N_CONF', 'AV_N_PUBB' )
			BEGIN
				-- permettiamo l'invio dei dati pcp se la scheda deve essere ancora inviata o se è in uno stato di errore
				set @sendPCP = '1'
			END

			--richiesta : <<A valle di esito operazione POSITIVO il pulsante di Invia/Pubblica si abiliterà.>>
			-- nota : sarà poi la toolbar ad aggiungere le condizioni precedenti per poter pubblicare la convenzione. qui ci limitiamo a ragionare sulla parte PCP
			IF @statoScheda IN ( 'SC_CONF', 'AV_PUBB', 'AV_RETT', 'AV_N_RETT', 'AV_RICHIESTA_RETT_IN_CORSO')
			BEGIN
				--lato pcp permettiamo la pubblicazione della convenzione se la scheda collegata è in uno stato terminale di OK
				set @sendBase = '1'
				SET @readonlyPCP = '1' --quando si è chiuso il giro della scheda il documento deve essere readonly e l'utente deve pubblicare la convenzione
			END

		END --IF dbo.attivo_INTEROP_Gara( @IdGara ) = 1 and @Pcp_TipoScheda = 'P1_16'

	END

	select  @PresenzaListinoOrdini = PresenzaListinoOrdini, 
			@Compilatore=IdPfu 
		from #Temp1

	if @PresenzaListinoOrdini='si'
	begin
		
		select @StatoListinoOrdini = StatoFunzionale from ctl_doc with (nolock) where LinkedDoc = @IdDoc and tipodoc='LISTINO_ORDINI' and Deleted=0

	end

	--controllo se utente loggato è abilitato a lavorare sulle funzioni di manutenzione 
	--:deve essere il compilatore oppure tra i riferimenti tecnici della convenzione
	if @idUser = @Compilatore 
		or 
		exists 
			(
			select top 1 idRow 
				from 
					document_bando_riferimenti with (nolock)
				where 
					idheader= @IdDoc and idPfu = @idUser and RuoloRiferimenti  in ( 'ReferenteTecnico' , 'Notifiche' )
			)
		--KPF 511313 ritorna uno per utenti con profilo Gestore Convenzione
		or exists 
			(
				select top 1 idpfu 
					from 
						ProfiliUtenteAttrib with(nolock) 
					where 
						idpfu=@idUser and dztNome='Profilo' and attValue='GestoreNegoziElettro'
			)

	begin	
		set @Is_User_Abilitato_Funzioni = 1
	end


	--controllo se utente loggato è un riferimento tecnico di un altro ente
	if exists ( 
			select IdDoc from VIEW_CONVENZIONE_AZIENDE_PER_RIFERIMENTO_TECNICO 
				where IdDoc = @IdDoc and Idpfu_RiferimentoTecnico = @idUser and Azienda_RiferimentoTecnico <> Azienda_Compilatore
			  )
	begin
		set @Is_User_Rif_Tecnico_Non_Agenzia = 1
	end

	select 
		D.*,
		case 
			when isnull(D.Stipula_in_forma_pubblica,0) = 1  then 'no'
			when ( ISNULL(F1_SIGN_ATTACH,'') <> ''  and ISNULL(F2_SIGN_ATTACH,'') <> '' ) OR ( @Is_Obblig_F1_Sign_Attach = '0' ) then 'si'
			else 'no' 
		end	as INVIOCONTRATTO
		,ISNULL(c1.Statofunzionale,'')  as StatoContratto  
		,ISNULL(c2.Statofunzionale,'')  as StatoListino 
		
		,case 
			--nel caso Stipula_in_forma_pubblica = SI 
			--oppure ConvenzioniInUrgenza = 1 aloora basta solo il listino confermato	
			--se presente listino ordini deve esserci anche il listino ordini confermato
			when 
				( isnull(D.Stipula_in_forma_pubblica,0) = 1 or isnull(D.ConvenzioniInUrgenza ,0) = 1 )  
				
				AND ISNULL(c2.Statofunzionale,'') = 'Confermato' 
				
				--se presente il listino ordini deve esserci anche il listino ordini confermato
				AND (@PresenzaListinoOrdini <> 'si' or ( @PresenzaListinoOrdini='si' and @StatoListinoOrdini='Confermato' ) )
				
				then 'SI'
			
			when 
				
				ISNULL(c1.Statofunzionale,'') = 'Confermato'  
				
				AND ISNULL(c2.Statofunzionale,'') = 'Confermato' 
				
				--se presente il listino ordini deve esserci anche il listino ordini confermato
				AND (@PresenzaListinoOrdini <> 'si' or (@PresenzaListinoOrdini='si' and @StatoListinoOrdini='Confermato') )
				
				then 'SI'

			else 'NO'

			end as 	PUBBLICA_CONVENZIONE 

		, case when ISNULL(sys2.DZT_ValueDef,'') <> '' then '1' else '0' end as Check_AIC_Enabled

		, @PresenzaAIC as PresenzaAIC
		, case when @Ted_Attivo = 'YES' then 1 else 0 end as ted
		, case when @FascicoloGenerale <> ''  and @IsGaraTed = '1' and @nExistsGUEE = 1 then 1 else 0 end as CAN_GESTIONE_GUEE

			--into 
			--	#Temp2
		, @Is_User_Abilitato_Funzioni as Is_User_Abilitato_Funzioni

		, case when ISNULL(sys3.DZT_ValueDef,'') <> '' then '1' else '0' end as Check_DM_Enabled
		, case
			when isnull(D.Ambito,'') = '2' and @PresenzaDM = '1' then '1'
			else '0' 
		  end as PresenzaDM
		, @Is_User_Rif_Tecnico_Non_Agenzia as Is_User_Rif_Tecnico_Non_Agenzia

	INTO #finalOUT
	from #Temp1 D
			left join ctl_doc_sign with (nolock) on idheader=D.id
			left join ctl_doc c1 with (nolock) on D.id=c1.LinkedDoc and C1.tipodoc='CONTRATTO_CONVENZIONE' and C1.StatoFunzionale <> 'Rifiutato' and c1.deleted = 0
			left join ctl_doc c2 with (nolock) on D.id=c2.LinkedDoc and C2.tipodoc='LISTINO_CONVENZIONE' and C2.StatoFunzionale <> 'Rifiutato' and c2.deleted = 0
			left join LIB_Dictionary sys2 with (nolock) on sys2.DZT_Name='SYS_AIC_URL_PAGE'
			left join LIB_Dictionary sys3 with (nolock) on sys3.DZT_Name='SYS_DM_URL_PAGE'
				
	--introduciamo questa ulteriore select finale per poter spostare qui la condizione di attivazione del comando di "pubblica" della toolbar.
	-- così da poterla riutilizzare senza ripetere questa lunga sfilza di condizioni e superare il limite di caratteri
	select *
		
		, @viewSendPCP as viewSendPCP 
		, @sendPCP as sendPCP
		, @garaPCP as garaPCP
		, @sendBase as sendBase
		, @readonlyPCP as readonlyPCP

		, case when ConvenzioneReadOnly = 'false' and PUBBLICA_CONVENZIONE = 'SI'  
					and ( StatoConvenzione  = ''  or StatoConvenzione   =  'Saved' ) 
					and Is_User_Rif_Tecnico_Non_Agenzia = 0 
			 then '1'
			 else '0'
			 end
			AS attivaPubblica

		from #finalOUT

	drop table #Temp1
	drop table #finalOUT


END
GO
