USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_BANDO_GARA_SEC_EDIT]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[OLD_BANDO_GARA_SEC_EDIT] ( @idProc INT, @secName varchar(100) = '', @IdUser int=0)
AS

	SET NOCOUNT ON

	-- Questa stored serve per accentrare le logiche di editabilità di tutte le sezioni del BANDO_GARA.

	--	E' stata creata a seguito della necessità di aggiungere una readonly condition su tutte le sezioni meno che sul quelle degli atti.
	--	La condizione di readonly di default bloccherà l'editabilità della gara se (condizioni in AND ) :
	--		1. ho creato l'appalto lato PCP/ANAC ( quindi ho valorizzato il campo "Id Appalto ANAC", colonna pcp_CodiceAppalto )
	--		2. NON sono sul secondo giro di una procedura in 2 fasi con interop ( nella seconda fase quindi NON devo rendere readonly tutto anche se ho pcp_CodiceAppalto, ottenuto nella prima fase )
	--	NOTA : In questa condizione per sbloccare la gara bisogna passare da un cancella appalto

	--	Per tutte quelle sezioni che invece avevano gia una condizione di readonly la spostiamo qui sotto un IF con il nome della sezione ed alla precedente
	--		logica aggiungiamo quella di default sopra citata.

	--	ATTENZIONE : Questa stored è invocata su quasi tutte le sezioni del bando_gara e del bando_semplificato ( molto numerose !! ) quindi fare molta attenzione
	--					alle performance. Se bisogna aggiungere delle select cercare di farle solo quando serve

	DECLARE @pcp_CodiceAppalto VARCHAR(100) = ''
	DECLARE @garaInterop INT = 0
	DECLARE @secondaFaseInterop INT = 0
	DECLARE @tipobandogara varchar(10)
	DECLARE @readOnly INT = 0
	DECLARE @TipoProceduraCaratteristica varchar(100) = ''
	DECLARE @ProceduraGara varchar(100) = ''
	DECLARE @TipoSceltaContraente varchar(100) = ''
	DECLARE @GestioneQuote varchar(100) = ''
	DECLARE @StatoFunzionale varchar(500) = ''
	DECLARE @GESTIONE_PCP_RUP varchar(10) = 'NO'
	DECLARE @UserRUP varchar(50)
	

	--recupero se la gestione PCP attiva solo per il RUP
	select @GESTIONE_PCP_RUP = dbo.PARAMETRI('GESTIONE_PCP_RUP', 'ATTIVA', 'DefaultValue', 'NO', -1)

	select @pcp_CodiceAppalto = pcp_CodiceAppalto
		from Document_PCP_Appalto with (nolock)
		where idHeader = @idProc

	set @garaInterop = dbo.attivo_INTEROP_Gara(@idProc) --select sulla Document_E_FORM_CONTRACT_NOTICE e lib_dictionary

	select  @tipobandogara = tipobandogara,
			@TipoProceduraCaratteristica = TipoProceduraCaratteristica,
			@TipoSceltaContraente = TipoSceltaContraente,
			@GestioneQuote = GestioneQuote,
			@ProceduraGara = ProceduraGara 
		from Document_Bando with(nolock)
		where idHeader = @idProc

	SELECT 
		@UserRUP = rup.Value
	FROM 
		CTL_DOC_Value rup WITH (NOLOCK)
	WHERE rup.idHeader = @idProc AND rup.dzt_name = 'UserRup' AND rup.dse_id = 'InfoTec_comune'


	-- se sono su di una gara con il giro interop/pcp e se sono su un invito ad eccezione degli affidamenti diretti
	IF @garaInterop = 1 and @tipobandogara = '3' and @ProceduraGara <> '15583'
	BEGIN
	
		--verifico se mi trovo sulla seconda fase
		IF EXISTS ( select ab.id 
						from ctl_doc I with (nolock) -- invito
								inner join ctl_doc AB with (nolock) on AB.id = I.linkeddoc  -- salgo su avviso / bando
																		and AB.TipoDoc = I.TipoDoc 
						where I.id = @idProc 
					)
		BEGIN
			set @secondaFaseInterop = 1
		END

	END

	------------------------
	-- CONDIZIONE DI BASE --
	------------------------
	IF @garaInterop = 1 and @pcp_CodiceAppalto <> '' and @secondaFaseInterop = 0
		set @readOnly = 1

	IF @secName IN ( 'PRODOTTI','INTEROP','INTEROP_PCP','CRITERI_ECO_RIGHE','InfoTec_SIMOG','CRITERI_ECO','CRITERI_ECO_TESTATA','DGUE' )
	BEGIN

		--se la gara è del giro di interop/pcp ed ho creato l'appalto lato anac OPPURE se sono su una seconda fase di un giro interop ( in questo caso le sez elencate devono essere lavorate nella prima fase, readonly sulla seconda )
		IF ( @garaInterop = 1 and @pcp_CodiceAppalto <> '' ) OR @secondaFaseInterop = 1
			set @readOnly = 1

	END
	ELSE IF @secName = 'TESTATA_PRODOTTI'
	BEGIN
		
		IF @TipoProceduraCaratteristica = 'RilancioCompetitivo' 
			OR ( @garaInterop = 1 and @pcp_CodiceAppalto <> '' ) 
			OR @secondaFaseInterop = 1
		BEGIN
			set @readOnly = 1
		END

	END
	ELSE IF @secName IN ( 'CRITERI_AQ_EREDITA_TEC' )
	BEGIN

		IF EXISTS ( select a.id 
						from ctl_doc a with(nolock) 
								inner join CTL_DOC_Value b with(nolock) on IdHeader=LinkedDoc 
																	and DSE_ID='InfoTec_comune' 
																	and DZT_Name='BloccaCriteriEreditati' 
																	and [row] = 0 and [Value] = '1'
						where a.id = @idProc
				 ) OR @readOnly = 1
		BEGIN
			set @readOnly = 1
		END

	END
	ELSE IF @secName = 'REQUISITI'
	BEGIN

		set @readOnly = @readOnly

		-- Questa select non ha più senso avendo dismesso il simog per le nuove gare
		--select IdRow 
		--	from CTL_DOC_Value with(nolock) 
		--	where IdHeader = @idProc and DSE_ID = 'SIMOG_WS' and DZT_Name = 'EsitoPubblicazione' and Value = 'OK'

	END
	ELSE IF @secName = 'ENTI'
	BEGIN

		IF ( @TipoSceltaContraente = 'ACCORDOQUADRO' and ISNULL(@GestioneQuote,'') <> 'senzaquote' )
				OR
			@readOnly = 1
		BEGIN

			SET @readOnly = 1

		END

	END
	ELSE IF @secName = 'DOCUMENTAZIONE'
	BEGIN
		-- Metto qui questa select per eseguirla il meno possibile. cioè solo se siamo in readonly e non sempre
		SELECT @StatoFunzionale = statoFunzionale
			FROM ctl_doc with(nolock)
			WHERE id = @idProc

		IF (  @StatoFunzionale = 'InApprove' and @GESTIONE_PCP_RUP = 'YES' and @UserRUP = @IdUser   )	
		BEGIN
			SET @readOnly = 0
		END
		ELSE
		BEGIN
			SET @readOnly = 1
		END

	END

	IF @readOnly = 1
	BEGIN

		-- Condizione paracadute per far tornare le sezioni in EDIT anche se dovrebbero essere readonly.
		--		utile per gestire ad esempio i casi di readonly per invio completato su PCP ( e non si può fare cancella appalto )
		--		ma i controlli successivi all'invio/pubblicazione bloccano. L'utente si ritroverebbe impossibilitato a correggere i dati.
		--		In questo caso lanciare un attività di manutenzione per inserire un record di questo tipo : 
		--		INSERT INTO CTL_Relations ( REL_Type, REL_ValueInput, REL_ValueOutput ) VALUES ( 'SBLOCCO_EDIT_GARA', 'ID_DOC', 123123 )

		IF EXISTS ( select REL_idRow from CTL_Relations with(nolock) where REL_Type = 'SBLOCCO_EDIT_GARA' and REL_ValueInput = 'ID_DOC' and REL_ValueOutput = CAST(@idProc as varchar) )
		BEGIN
			set @readOnly = 0
		END
		ELSE
		BEGIN


			-- Metto qui questa select per eseguirla il meno possibile. cioè solo se siamo in readonly e non sempre
			SELECT @StatoFunzionale = statoFunzionale
				FROM ctl_doc with(nolock)
				WHERE id = @idProc

			-- esplodo la logica che c'era dietro questa condizione di readonly di testata : <<and  not ( InStr( 1 , GARE_IN_MODIFICA_O_RETTIFICA , Id ) > 0 and StatoFunzionale = 'InRettifica' )>>
			IF @StatoFunzionale = 'InRettifica'
			BEGIN

				DECLARE @gareInRettifica varchar(max)
				SET @gareInRettifica = dbo.GetBandiInRettificaOModifica() --ES : ,303228,307730,327184,329868,410870,416172,416257,473627,

				--se l'id della gara sulla quale mi trovo è presente nell'elenco
				IF CHARINDEX( ',' + CAST(@idProc as varchar) + ',' , @gareInRettifica ) > 0
				BEGIN
					set @readOnly = 0
				END

			END
		
		END

	END

	IF @readOnly = 1
		select 'SEZIONE_READONLY' as SEC_READ_ONLY
	ELSE
		select top 0 'SEZIONE_EDITABILE' as SEC_READ_ONLY




	
GO
