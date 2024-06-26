USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[DOCUMENT_CK_TOOLBAR_BANDO_GARA]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE PROCEDURE [dbo].[DOCUMENT_CK_TOOLBAR_BANDO_GARA] 
(
	@DocName NVARCHAR(500),
	@IdDoc NVARCHAR(500),
	@idUser INT
)
AS
BEGIN

	SET NOCOUNT ON

	DECLARE @AziendaCompilatore as int
	DECLARE @Codifica_Prodotti_Rapida as int
	DECLARE @ProceduraGara_AB as varchar(50)

	DECLARE @Idpfu INT

	DECLARE @UserRUP VARCHAR(50)
	DECLARE @id_modello VARCHAR(20)
	DECLARE @SYS_ATTIVA_CODICE_REGIONALE VARCHAR(100)
	DECLARE @SYS_MODULI_RESULT VARCHAR(8000)
	DECLARE @SYS_AIC_URL_PAGE VARCHAR(8000)
	DECLARE @CTP_Valore VARCHAR(100)
	DECLARE @CTP2_Valore VARCHAR(100)
	DECLARE @EsportazioneFascicoloStato_Valore VARCHAR(1000)
	DECLARE @InChargeToApprove VARCHAR(20)
	DECLARE @PRESENZA_COD_REG VARCHAR(2)
	DECLARE @SORTEGGIO VARCHAR(1)  
	DECLARE @SORTEGGIO_AVVISO VARCHAR(1)
	DECLARE @CAN_PROROGA VARCHAR(1)
	DECLARE @cigInviato VARCHAR(1)
	DECLARE @idCOM INT
	DECLARE @pres_com_A NVARCHAR(200)

	DECLARE @StatoFunzionale varchar(200) = ''
	DECLARE @deleted INT = 0
	DECLARE @ProceduraGara varchar(100) = ''

	DECLARE @sb_TipoBandoGara VARCHAR(20)
	DECLARE @RichiediProdottiSDA INT
	DECLARE @PresenzaAIC VARCHAR(1)
  	DECLARE @tedInviato VARCHAR(10) = '0'
	DECLARE @tedAttesaPub VARCHAR(10) = '0'
	DECLARE @tedPubblicato VARCHAR(10) = '0'
	DECLARE @statoFunzPubTed VARCHAR(100) = ''
	DECLARE @idPubTed INT
	DECLARE @abilitaComandi VARCHAR(100);
	DECLARE @SECONDO_GIRO_AFFID_DIR_DUE_FASI as varchar(10)
	DECLARE @AttivaFiltroRup as int
	DECLARE @ATTIVA_MODULO_TEMPLATE_GARA as varchar(10)

	DECLARE @attivo_INTEROP_Gara as int
	DECLARE @SECONDA_FASE_INTEROP as int
	DECLARE @IdAvvisoBando as int
	DECLARE @TipoBandoGara as varchar(10)
	DECLARE @CAN_PCP_PUBBLICA_AVVISO as varchar(10)
	DECLARE @pcp_TipoScheda as varchar(100) = ''
	DECLARE @pcp_StatoScheda as varchar(100) = ''
	DECLARE @pcp_CodiceAppalto varchar(500)
	DECLARE @SYS_MODULI_GRUPPI varchar(max) = ''
	DECLARE @bAttivaCan29 varchar(1) = '0'

	DECLARE @confermaAppalto varchar(10) = '0'
	DECLARE @viewConfermaAppalto varchar(10) = '0'
	DECLARE @cancellaAppalto varchar(10) = '0'
	DECLARE @viewCancellaAppalto varchar(10) = '0'
	DECLARE @recuperaCIG varchar(10) = '0'
	DECLARE @viewRecuperaCIG varchar(10) = '0'
	DECLARE @pubblicaAvviso varchar(10) = '0'
	DECLARE @viewPubblicaAvviso varchar(10) = '0'
	DECLARE @viewEsitoOperazione varchar(10) = '0'
	DECLARE @attivaEsitoOperazione varchar(10) = '0'
	DECLARE @viewEsitoOperazioneSync varchar(10) = '0'
	DECLARE @attivaEsitoOperazioneSync varchar(10) = '0'
	DECLARE @viewConsultaAvviso varchar(10) = '0'
	DECLARE @attivaConsultaAvviso varchar(10) = '0'

	DECLARE @attivaRettificaProroga varchar(10) = '1'
	DECLARE @viewEsitoOperazioneRett varchar(10) = '0'
	DECLARE @attivaEsitoOperazioneRett varchar(10) = '0'

	DECLARE @menuPCP varchar(10) = '0'
	DECLARE @viewMenuPCP varchar(10) = '0'

	DECLARE @schedaSenzaPubblicazioneAvviso varchar(10) = '0'
	DECLARE @traceEsitoPubGara INT = 0 --traccia di esito pubblicazione avviso letta dalla cronologia pcp

	DECLARE @sendGaraPCP varchar(10) = '1'
	DECLARE @GESTIONE_PCP_RUP varchar(10) = 'NO'

	DECLARE @affidamentoSenzaNegoziazioneCaption varchar(100) = ''

	--recupero se la gestione PCP attiva solo per il RUP
	select @GESTIONE_PCP_RUP = dbo.PARAMETRI('GESTIONE_PCP_RUP', 'ATTIVA', 'DefaultValue', 'NO', -1)

	SET @CAN_PCP_PUBBLICA_AVVISO = '1'
	SET @SECONDA_FASE_INTEROP = 0

	--RECUPERO SE ATTIVO SULLA GARA INTEROP/PCP
	set @attivo_INTEROP_Gara = dbo.attivo_INTEROP_Gara(@IdDoc)

	SELECT @SYS_MODULI_GRUPPI = DZT_ValueDef 
		from lib_dictionary with(nolock) 
		where DZT_Name='SYS_MODULI_GRUPPI'

	--verifico se attivo il modulo per la codifica rapida dei prodotti dalla gara
	set @Codifica_Prodotti_Rapida = 0
	IF EXISTS (	
				select items 
					from dbo.Split(@SYS_MODULI_GRUPPI,',') 
					where items = 'CODIFICA_PRODOTTI_RAPIDA' 
			)
	BEGIN
		SET @Codifica_Prodotti_Rapida = 1
	END

	-- recupero i dati principali dal documento
	SELECT d.Id
			, d.IdPfu
			, d.IdDoc
			, d.TipoDoc
			, d.StatoDoc
			, d.Data
			, d.Protocollo
			, d.PrevDoc
			, CAST(d.Deleted AS INT) AS deleted
			, d.Titolo
			, d.Body
			, d.Azienda
			, d.StrutturaAziendale
			, d.DataInvio
			, d.DataScadenza
			, d.ProtocolloRiferimento
			, d.ProtocolloGenerale
			, d.Fascicolo
			, d.Note
			, d.DataProtocolloGenerale
			, d.LinkedDoc
			, d.SIGN_HASH
			, d.SIGN_ATTACH
			, d.SIGN_LOCK
			, d.JumpCheck
			, d.StatoFunzionale
			, d.Destinatario_User
			, d.Destinatario_Azi
			, d.RichiestaFirma
			, d.NumeroDocumento
			, d.DataDocumento
			, d.Versione
			, d.VersioneLinkedDoc
			, d.GUID
			, d.idPfuInCharge
			, d.CanaleNotifica
			, d.URL_CLIENT
			, d.Caption
			, d.StatoFunzionale AS S_F
			, dbo.ListRiferimentiBando(d.id, 'quesiti') AS ListRiferimentiBando
		INTO #D
		FROM CTL_DOC d WITH (NOLOCK)
		WHERE id = @iddoc

  --recupero dati dalla CTL_DOC inserendole in variabili di appoggio
  SELECT @Idpfu = d.IdPfu,
		 @IdAvvisoBando = isnull(LinkedDoc,0),
		 @StatoFunzionale = StatoFunzionale,
		 @deleted = deleted
	FROM #D d

  -- recupero le informazioni dal BANDO e le aggiungo al risultato temporaneo
  SELECT d.*
    , CASE 
      WHEN GETDATE() >= b.DataAperturaOfferte
        AND d.StatoFunzionale <> 'InLavorazione'
        THEN '1'
      ELSE '0'
      END AS APERTURA_OFFERTE
    , CASE 
      WHEN GETDATE() >= b.DataScadenzaOfferta
        AND d.StatoFunzionale <> 'InLavorazione'
        THEN '1'
      ELSE '0'
      END AS SCADENZA_INVIO_OFFERTE
    , b.TipoBandoGara
    , CASE 
        WHEN TipoDoc = 'TEMPLATE_GARA'
          THEN 'TEMPLATE: '
        ELSE ''
      END
      +
      CASE 
         WHEN b.TipoProceduraCaratteristica = 'AffidamentoSemplificato'
           THEN 'Affidamento diretto'
         WHEN b.TipoProceduraCaratteristica = 'RDO'
           THEN 'Richiesta di Offerta'
         WHEN b.ProceduraGara = '15477'
           AND b.TipoBandoGara = '2'
           THEN 'BandoRistretta' -- Ristretta / Bando
         ELSE CASE 
           WHEN b.TipoSceltaContraente = 'ACCORDOQUADRO'
             THEN 'Accordo Quadro'
           ELSE CASE 
               WHEN b.TipoBandoGara IN (
                   '1'
                   , '4'
                   , '5'
                   )
                 THEN 'Avviso'
               WHEN b.TipoBandoGara = '3'
                 THEN 'Invito'
               WHEN b.TipoBandoGara = '2'
                 THEN 'Bando'
               END
           END
       END AS CaptionDoc
    , CASE 
      WHEN (
          b.TipoBandoGara IN (
            '1'
            , '4'
            )
          AND b.ProceduraGara = '15478'
          ) --Negoziata / Avviso
        OR (
          b.TipoBandoGara IN ('2')
          AND b.ProceduraGara = '15477'
          ) -- Ristretta / Bando
        OR (
          b.TipoBandoGara IN (
            '4'
            , '5'
            )
          AND b.ProceduraGara = '15583'
          ) -- affidamento a 2 fasi
        THEN '1'
      ELSE '0'
      END PRIMA_FASE
    , ISNULL(b.TipoProceduraCaratteristica, '') AS TipoProceduraCaratteristica
    , b.Divisione_lotti
    , b.tipobando
    , CASE 
      WHEN GETDATE() >= b.DataPresentazioneRisposte
        THEN '1'
      ELSE '0'
      END AS BANDO_FABB_SCADUTO
    , ISNULL(b.GeneraConvenzione, '0') AS GeneraConvenzione
    , b.ProceduraGara
    , b.RichiestaCigSimog
    , b.RichiestaTED
    , b.TipoSceltaContraente
	, isnull(b.RecivedIstanze,0) as RecivedIstanze
    , CASE 
      WHEN b.DataRiferimentoFine IS NULL
        THEN 'no'
      WHEN b.DataRiferimentoFine < GETDATE()
        THEN 'si'
      ELSE 'no'
      END AS AQ_SCADUTO
  INTO #D1
  FROM document_bando b WITH (NOLOCK)
		CROSS JOIN #D d
  WHERE b.idheader = @IdDoc

  DROP TABLE #D

  select @ProceduraGara = ProceduraGara
	from #D1


	-- recupera dal primo giro di gara la tipologia e la presenza dei prodotti
	SELECT  @sb_TipoBandoGara = sb.TipoBandoGara,
			@ProceduraGara_AB = sb.proceduraGara,
			@RichiediProdottiSDA = sb.RichiediProdotti,
			@TipoBandoGara = d.TipoBandoGara
	FROM document_bando sb WITH (NOLOCK)
			CROSS JOIN #D1 d
	WHERE sb.idheader = d.linkeddoc

  -- REUPERA IL RUP DELLA GARA
  SELECT @UserRUP = rup.Value
	  FROM ctl_doc_value rup WITH (NOLOCK)
	  WHERE rup.idHeader = @idDoc
		AND rup.dzt_name = 'UserRup'
		AND rup.dse_id = 'InfoTec_comune'

  -- RECUPERA il modello della gara
  SELECT @id_modello = idm.Value
	  FROM ctl_doc_value idm WITH (NOLOCK)
	  WHERE idm.idHeader = @idDoc
		AND idm.dzt_name = 'id_modello'
		AND idm.dse_id = 'TESTATA_PRODOTTI'

  -- RECUPERO SYS
  SELECT @SYS_ATTIVA_CODICE_REGIONALE = DZT_ValueDef
	  FROM LIB_Dictionary D2 WITH (NOLOCK)
	  WHERE D2.DZT_Name = 'SYS_ATTIVA_CODICE_REGIONALE'

  SELECT @SYS_MODULI_RESULT = DZT_ValueDef
	  FROM LIB_Dictionary D2 WITH (NOLOCK)
	  WHERE D2.DZT_Name = 'SYS_MODULI_RESULT'

  SELECT @SYS_AIC_URL_PAGE = DZT_ValueDef
	  FROM LIB_Dictionary D2 WITH (NOLOCK)
	  WHERE D2.DZT_Name = 'SYS_AIC_URL_PAGE'

  -- RECUPERO PARAMETRI
  SET @CTP_Valore = dbo.PARAMETRI('BANDO_GARA-BANDO_SEMPLIFICATO', 'RiammissioneOfferta', 'Riammissione_Offerta_SOLO_RUP', '', -1)
  SET @CTP2_Valore = dbo.PARAMETRI('BANDO_GARA-BANDO_SEMPLIFICATO', 'RiammissioneOfferta', 'Riammissione_Offerta_SOLO_AZI_MASTER', '', -1)
  
  SET @EsportazioneFascicoloStato_Valore = dbo.PARAMETRI('FASCICOLO_DI_GARA', 'EsportazioneFascicolo', 'Stati_Per_Attivazione', '###Chiuso###', -1)

  -- verifica la presenza del codice regionale sul modello
  SET @PRESENZA_COD_REG = 'NO'

  SELECT @PRESENZA_COD_REG = CASE 
		  WHEN ISNULL(cod.idrow, '') = ''
			THEN 'NO'
		  WHEN ISNULL(cod.idrow, '') <> ''
			AND @SYS_ATTIVA_CODICE_REGIONALE = 'YES'
			THEN 'SI'
		  END
	  FROM ctl_doc_value cod WITH (NOLOCK)
	  WHERE cod.idHeader = @id_modello
		AND cod.dzt_name = 'DZT_Name'
		AND cod.dse_id = 'MODELLI'
		AND cod.Value = 'Codice_Regionale'

	-- recupera approvatore
	SELECT @InChargeToApprove = ap.APS_IdPfu
		FROM ctl_approvalsteps ap WITH (NOLOCK)
			CROSS JOIN #D1 d
		WHERE APS_IsOld = 0
			AND d.TipoDoc = ap.APS_Doc_Type
			AND ap.APS_State = 'InCharge'
			AND ap.APS_ID_DOC = @idDoc

	  -- Sorteggio associato alla gara/avviso
	  IF EXISTS (
		  SELECT id
		  FROM CTL_DOC sortPub WITH (NOLOCK)
		  WHERE sortPub.LinkedDoc = @idDoc
			AND sortPub.TipoDoc = 'SORTEGGIO_PUBBLICO'
			AND sortPub.Deleted = 0
		  )
		SET @SORTEGGIO = '1'
	  ELSE
		SET @SORTEGGIO = '0'

	  -- Se siamo nel giro di invito, verifico la presenza del sorteggio pubblico associato alla precedente fase di avviso
	  IF EXISTS (
		  SELECT d.id
		  FROM CTL_DOC sortPub2 WITH (NOLOCK)
			 CROSS JOIN #D1 d
		  WHERE sortPub2.LinkedDoc = d.LinkedDoc
					 AND @sb_TipoBandoGara = '1'
					 AND sortPub2.TipoDoc = 'SORTEGGIO_PUBBLICO'
					 AND sortPub2.Deleted = 0
		  )
		SET @SORTEGGIO_AVVISO = '1'
	  ELSE
		SET @SORTEGGIO_AVVISO = '0'

	  --VERIFICA SE SONO PRESENTI ANALISI_FABBISOGNI
	  SET @CAN_PROROGA = '0'

	  SELECT @CAN_PROROGA = CASE 
		  WHEN d.StatoFunzionale IN (
			  'Inviato'
			  , 'Completato'
			  )
			AND analisi.id IS NULL
			THEN '1'
		  ELSE '0'
		  END
	  FROM #D1 d
			LEFT JOIN ctl_doc ANALISI WITH (NOLOCK) ON ANALISI.LinkedDoc = d.id
				AND ANALISI.TipoDoc = 'ANALISI_FABBISOGNI'
				AND ANALISI.Deleted = 0

	  --RECUPERO PRESIDENTE COMMISSIONE A
	  SET @pres_com_A = 0

	  SELECT @idCOM = COM.id
		  FROM ctl_doc COM WITH (NOLOCK)
		  WHERE COM.linkeddoc = @idDoc
			AND COM.tipodoc = 'COMMISSIONE_PDA'
			AND COM.deleted = 0
			AND COM.statofunzionale = 'pubblicato'

	  SELECT @pres_com_A = ISNULL(CU.UtenteCommissione, 0)
		  FROM Document_CommissionePda_Utenti CU WITH (NOLOCK)
		  WHERE CU.idheader = @idCOM
			AND CU.TipoCommissione = 'A'
			AND CU.ruolocommissione = '15548'

	  -- Recupero la presenza della richiesta CIG inviata
	  IF EXISTS (
		  SELECT rcig.id
		  FROM ctl_doc rCig WITH (NOLOCK)
		  WHERE rCig.LinkedDoc = @IdDoc
			AND rCig.TipoDoc IN (
			  'RICHIESTA_CIG'
			  , 'RICHIESTA_SMART_CIG'
			  )
			AND rCig.Deleted = 0
			AND rCig.StatoFunzionale IN (
			  'Inviato'
			  , 'Invio_con_errori'
			  )
		  )
		SET @cigInviato = '1'
	  ELSE
		SET @cigInviato = '0'


	-- Verifica la presenza della colonna AIC
	  IF EXISTS (
		  SELECT MA_MOD_ID
		  FROM ctl_doc_section_model x WITH (NOLOCK)
		  INNER JOIN CTL_ModelAttributes(NOLOCK) ON MA_MOD_ID = x.MOD_Name
			AND MA_DZT_Name = 'CodiceAIC'
		  WHERE x.IdHeader = @IdDoc
			AND x.DSE_ID = 'PRODOTTI'
		  )
		SET @PresenzaAIC = '1'
	  ELSE
		SET @PresenzaAIC = '0'

	  IF EXISTS (
		  SELECT id
		  FROM #d1
		  WHERE RichiestaTED = 'si'
		  )
	  BEGIN

		IF EXISTS (
			SELECT id
				FROM ctl_doc rTed WITH (NOLOCK)
				WHERE rTed.LinkedDoc = @IdDoc
				  AND rTed.TipoDoc = 'DELTA_TED'
				  AND rTed.Deleted = 0
				  AND rTed.StatoFunzionale IN (
					'Inviato'
					, 'Invio_con_errori'
					)
			)
		  SET @tedInviato = '1'

		-- commentiamo perchè non permettiam più di annullare una richiesta di pubblicazione di un formulario di rettifica. ma solo di pubblicazione gara
		--select @idPubTed = max(id) from ctl_doc rPubTed with(nolock) where rPubTed.LinkedDoc = @IdDoc and rPubTed.TipoDoc = 'PUBBLICA_GARA_TED' and rPubTed.Deleted = 0
		--select @statoFunzPubTed = StatoFunzionale from ctl_doc with(nolock) where id = @idPubTed
    
		--IF @statoFunzPubTed = 'InAttesaPubTed' or EXISTS ( select id from ctl_doc with(nolock) where LinkedDoc = @IdDoc and TipoDoc = 'RETTIFICA_GARA_TED' and Deleted = 0 and StatoFunzionale = 'InAttesaPubTed' )
		--	set @tedAttesaPub = '1'

		IF EXISTS (
			SELECT TOP 1 id
				FROM ctl_doc WITH (NOLOCK)
				WHERE LinkedDoc = @IdDoc
				  AND TipoDoc = 'PUBBLICA_GARA_TED'
				  AND Deleted = 0
				  AND StatoFunzionale = 'InAttesaPubTed'
			)
		  SET @tedAttesaPub = '1'

		--IF @statoFunzPubTed = 'PubTed'
		IF EXISTS (
			SELECT TOP 1 id
				FROM ctl_doc WITH (NOLOCK)
				WHERE LinkedDoc = @IdDoc
				  AND TipoDoc = 'PUBBLICA_GARA_TED'
				  AND Deleted = 0
				  AND StatoFunzionale = 'PubTed'
			)
		  SET @tedPubblicato = '1'
	  END

	-- i comandi verranno abilitati se sei un utente che è RUP oppure il compilatore
	SET @abilitaComandi = '1'

	--i comandi vengono disabilitati per l'utente URP
	IF EXISTS (
				SELECT idpfu
					FROM ProfiliUtente with(nolock)
					WHERE IdPfu = @idUser AND SUBSTRING(pfuFunzionalita, 150, 1) = '1'
		)
		SET @abilitaComandi = '0'

	--nel caso di o compilatore o RUP il comando viene comunque abilitato anche se sei un URP
	IF ( @UserRUP = @idUser OR @idUser = @Idpfu )
		SET @abilitaComandi = '1'

 
 	set @SECONDO_GIRO_AFFID_DIR_DUE_FASI = '0'

	 --se sono su un affidamento diretto vedo se vengo dalla prima fase di un AFFIDAMENTO A DUE FASI
	 if exists (select id from #D1 where ProceduraGara='15583')
	 begin
		--se tipobandogara del linkeddoc (prima fase) è un avviso aperto/destinatari
		--allora sono sul secondo giro DELL'AFFIDAMENTO A DUE FASI
		if @sb_TipoBandoGara in ('4','5')
		begin
			set @SECONDO_GIRO_AFFID_DIR_DUE_FASI = '1'
		end
	 end
 
 	--recupero paraemtro che indica se devo applicare il filtro per RUP sulla funzione "Seleziona Pregara"
	select @AttivaFiltroRup = dbo.PARAMETRI('GARE', 'PREGARA', 'AttivaFiltro', '0', -1)

	--recupero se attivo il modulo TEMPLATE_GARA
	 set @ATTIVA_MODULO_TEMPLATE_GARA ='no'

	 IF EXISTS (
		  SELECT items
		  FROM dbo.Split(@SYS_MODULI_GRUPPI, ',')
		  WHERE items = 'TEMPLATE_GARA')
	 begin
		set @ATTIVA_MODULO_TEMPLATE_GARA = 'si'
	 end


	--recupero azienda del compilatore
	set @AziendaCompilatore=0

	select @AziendaCompilatore= isnull(pfuidazi,-1) 
		from profiliutente with (nolock) 
		where idpfu = @Idpfu 
  
  
  -- Controllo se esiste il modulo SIMOG_GGAP nel SYS_MODULI_GRUPPI (caso per Insiel)
	DECLARE @isSimogGgap INT = CASE 
                              WHEN (SELECT CHARINDEX('SIMOG_GGAP', @SYS_MODULI_GRUPPI)) > 1 
								THEN 1
								ELSE 0
                              END

	-------------------------------------
	------ GESTIONE DEI COMANDI PCP -----
	-------------------------------------
	IF @attivo_INTEROP_Gara = 1
	BEGIN

		--RECUPERO TIPO SCHEDA PCP
		SELECT  @pcp_TipoScheda = pcp_TipoScheda,
				@pcp_CodiceAppalto = pcp_CodiceAppalto
			FROM Document_PCP_Appalto with(nolock)
			WHERE idHeader=@IdDoc

		SELECT top 1 @pcp_StatoScheda = statoScheda
			FROM Document_PCP_Appalto_Schede with(nolock)
			WHERE idHeader = @IdDoc and bDeleted = 0 and tipoScheda = @pcp_TipoScheda
			ORDER BY idRow desc


		-- Per gestire la retrocompatibilità, cioè le gare con operazioni pcp effettuate prima dell'attività che ha introdotto la gestione dello stato scheda, andiamo a vedere nella cronologia PCP 
		--	se è stata effettuata una chiamata di esito pubblicazione avviso ( a prescindere dalla colonna 'statoRichiesta' )
		IF @pcp_StatoScheda = ''
		BEGIN

			-- se abbiamo lo stato della scheda non serve fare la select sulla cronologia pcp
			IF EXISTS ( select top 1 idRow from Services_Integration_Request with(nolock) where integrazione = 'PCP' and operazioneRichiesta = 'esito-operazione' and idRichiesta = @IdDoc )
			BEGIN
				set @traceEsitoPubGara = 1
			END

		END

		IF @pcp_TipoScheda = 'P7_2'
		BEGIN
			--per disabilitare il comando Pubblica Avviso per la PCP
			set @CAN_PCP_PUBBLICA_AVVISO ='0'
		END

		--determino se sono sulla seconda fase interop
		--per adesso quando sono su invito  del doppio giro 
		--avviso-negoziata / bando-ristretta 
		IF @IdAvvisoBando <> 0 and @TipoBandoGara='3'and @DocName not in ( 'BANDO_SEMPLIFICATO','BANDO_SEMPLIFICATO_IN_APPROVE' )
		BEGIN

			SET @SECONDA_FASE_INTEROP = CASE when (	(@sb_TipoBandoGara='1' and @ProceduraGara_AB='15478') --avviso negoziata
													 OR
													(@sb_TipoBandoGara='2' and @ProceduraGara_AB='15477') -- bando - ristretta
												) then '1'
										END
		END

		IF EXISTS ( select REL_idRow from CTL_Relations with(nolock) where REL_Type = 'PCP' AND REL_ValueInput = 'SCHEDE_NO_PUBB_AVVISO' and REL_ValueOutput = @pcp_TipoScheda )
		BEGIN
			set @schedaSenzaPubblicazioneAvviso = '1'
		END


		--CONFERMA APPALTO : '', 'ErroreCreazione', 'AppaltoCancellato' -- farlo sparire per gli affidamenti diretti
		--		per gestire il pregresso ( gare che non avevano la gestione dello stato scheda ) - Conferma Appalto : se pcp_codiceAppalto è valorizzato si disattiva
		set @confermaAppalto = case when @StatoFunzionale IN ( 'InLavorazione','InApprove' ) 
											and 
										( 
											@pcp_StatoScheda in ( '', 'ErroreCreazione', 'AppaltoCancellato' ) --gestione pulita per stato scheda
												OR 
											( @pcp_StatoScheda = '' and isnull(@pcp_codiceAppalto,'') = '' ) --gestione per la retrocompatibilità
										) 
									then '1' 
									else '0' 
								end

		set @viewConfermaAppalto = case when @deleted = '0' and @ProceduraGara <> '15583' and @SECONDA_FASE_INTEROP = '0' then '1' else '0' end --se gara interop, non AD, non seconda fase interop

		--CANCELLA APPALTO : 'Creato', 'Confermato', 'AP_IN_CONF','AP_N_CONF', 'AP_CONF_MAX_RETRY' -- farlo sparire per la scheda P7_2 -- per gli AD farlo comparire solo dopo aver creato l'appalto ?
		--		per la retrocompatibilità : Cancella Appalto : se pcp_codiceAppalto è valorizzato si attiva e la select per la sentinella di pubblicaAvviso NON deve avere esito positivo
		--	evo: il cancella appalto non si può fare solo se l'appalto è pubblicato lato anac, altrimenti si. quindi aggiungo gli stati coerenti con questa cosa
		set @cancellaAppalto = case when @StatoFunzionale IN ( 'InLavorazione','InApprove' ) 
											AND
										  ( @pcp_StatoScheda in ( 'Creato', 'Confermato', 'AP_CONF', 'AP_IN_CONF','AP_N_CONF', 'AP_CONF_MAX_RETRY', 'AP_CONF_NO_ESITO', 'CigRecuperati', 'ErroreCigRecuperati' ) --gestione pulita per stato scheda
													OR 
											    ( @pcp_StatoScheda = '' and isnull(@pcp_codiceAppalto,'') <> '' and @traceEsitoPubGara = 0 ) --gestione per la retrocompatibilità
											)	then '1' 
												else '0' 
									 end 

		set @viewCancellaAppalto = case when @pcp_TipoScheda IN ( '', 'P7_2' ) or ( @ProceduraGara = '15583' and isnull(@pcp_codiceAppalto,'') = '' ) or @SECONDA_FASE_INTEROP = '1' 
										 then '0' else '1' 
									end --faccio sparire il comando di cancella se non c'è il tipo scheda o se P7_2 o se AD senza codice appalto o seconda fase interop

		--Recupera Cig 	 : 'ErroreCigRecuperati'
		set @recuperaCIG = case when  @StatoFunzionale IN ( 'InLavorazione','InApprove' ) and @pcp_StatoScheda = 'ErroreCigRecuperati' then '1' else '0' end 
		set @viewRecuperaCIG = case when ( @deleted = '0' and @ProceduraGara <> '15583' and @SECONDA_FASE_INTEROP = '0' ) or @pcp_StatoScheda = 'ErroreCigRecuperati' then '1' else '0' end

		--Pubblica Avviso  : 'CigRecuperati', 'AV_PUBB_MAX_RETRY', 'AV_N_PUBB'	 -- Il comando sparisce per le schede che non prevedono pubblicazione -- per gli AD farlo comparire solo dopo aver creato l'appalto ? 
		set @pubblicaAvviso = case when  @StatoFunzionale IN ( 'InLavorazione','InApprove' ) and @pcp_StatoScheda IN ( 'CigRecuperati', 'AV_PUBB_MAX_RETRY', 'AV_N_PUBB' ) and @CAN_PCP_PUBBLICA_AVVISO  = '1' then '1' else '0' end
		set @viewPubblicaAvviso = case when ( @deleted = '0' and (@ProceduraGara <> '15583' or @pcp_TipoScheda = 'A3_6' ) and @SECONDA_FASE_INTEROP = '0' and @schedaSenzaPubblicazioneAvviso = '0' ) then '1' else '0' end

		set @menuPCP = case when  @StatoFunzionale IN ( 'InLavorazione','InApprove' ) then '1' else '0' end

		--IL MENU DELLA PCP SI VEDE SE NONO AFFIDAMENTO DIRETTO E NON SONO SULLA SECONDA FASE E ATTIVA LAPCP
		--E (IL PARAMETRO DELLA GESTIONE PER IL RUP = NO OPPURE IL PARAMETRO VALE YES E L'UTENTE COLLEGATO è IL RUP)
		set @viewMenuPCP = case 
								when @deleted = '0' and @ProceduraGara <> '15583' and @SECONDA_FASE_INTEROP = '0' and @pcp_TipoScheda <> ''
									and ( @GESTIONE_PCP_RUP='NO' Or ( @GESTIONE_PCP_RUP='YES' and @UserRUP = @idUser ) ) then '1' 
								else '0' 
							end

		set @viewEsitoOperazione = case when @pcp_StatoScheda = 'AV_PUBB_MAX_RETRY' then '1' else '0' end
		set @attivaEsitoOperazione = case when @pcp_StatoScheda = 'AV_PUBB_MAX_RETRY' then '1' else '0' end

		set @viewEsitoOperazioneSync = case when @pcp_StatoScheda IN ( 'AV_IN_PUBB','AV_PUBB_NO_ESITO', 'AV_RICHIESTA_PUBB_IN_CORSO' ) then '1' else '0' end
		set @attivaEsitoOperazioneSync = case when @pcp_StatoScheda IN ( 'AV_IN_PUBB','AV_PUBB_NO_ESITO', 'AV_RICHIESTA_PUBB_IN_CORSO' ) then '1' else '0' end

		set @attivaRettificaProroga = case when @pcp_StatoScheda IN ( 'AV_RICHIESTA_RETT_IN_CORSO' ) then '0' else '1' end

		set @viewEsitoOperazioneRett = case when @pcp_StatoScheda IN ( 'AV_RICHIESTA_RETT_IN_CORSO' ) then '1' else '0' end
		set @attivaEsitoOperazioneRett = case when @pcp_StatoScheda IN ( 'AV_RICHIESTA_RETT_IN_CORSO' ) then '1' else '0' end

		--MOSTRO IL CONSULTA AVVISO SE L'AVVISO È PUBBLICATO E SE NON HO ANCORA RECUPERATO I DATI DI PUBBLICAZIONE 
		IF @pcp_StatoScheda IN ('AV_PUBB','AV_RETT', 'AV_N_RETT', 'AV_RICHIESTA_RETT_IN_CORSO')
		BEGIN

			IF --ci basiamo solo sulla PVL per capire se permettere o meno il consulta-avviso dall'interfaccia
				--NOT EXISTS ( -- GUUE / TED
				--				select top 1 IdRow
				--					from ctl_doc_value a with(nolock) 
				--					where a.idHeader = @IdDoc and a.dse_id = 'InfoTec_DatePub' and a.DZT_Name = 'Pubblicazioni' and a.value = '01'

				--			)
				--	AND
				NOT EXISTS ( -- Pubblicità Valore Legale 
								select top 1 IdRow
									from ctl_doc_value a with(nolock) 
									where a.idHeader = @IdDoc and a.dse_id = 'InfoTec_DatePub' and a.DZT_Name = 'Pubblicazioni' and a.value = 'PVL'
						)
			BEGIN
				set @viewConsultaAvviso = '1'
				set @attivaConsultaAvviso = '1'
			END
		END

		

		--Invio della gara. Permettere il click quando : 
		--	* gara che non prevede pcp ( gara senza "Codice appalto interno" ) logiche identiche a prima.
		--	* gara che prevede PCP ma siamo su di un affidamento diretto ( ProceduraGara = '15583' ) 
		--	* gara che prevede PCP, non siamo su un affidamento diretto, stato scheda in ( 'AV_IN_PUBB', 'AV_PUBB' )
		--	* gara che prevede PCP, scheda nella relazione delle schede senza pubblicazione avviso. Stati scheda = "CigRecuperati"
		--	* gara che prevede PCP, seconda fase di una gara pcp che prevede la doppia fase 
		--  * per gestire il pregresso, gare in lavorazione con operazione fatte prima dell'attività che va a gestire lo stato scheda, se c'è la scheda e la sentinella di richiesta pubblicazione avviso
		--  * gara che prevede la PCP la cui gestione è prevista solo per il rup e l'utente collegato non è il RUP è il PI
		--IF ( @ProceduraGara = '15583' ) -- affidamento diretto
		--		OR
		--	( @ProceduraGara <> '15583' and @pcp_TipoScheda <> '' and @pcp_StatoScheda IN ( 'AV_IN_PUBB', 'AV_PUBB' )  ) -- gara NON affidamento diretto, che prevede l'invio di una scheda/appalto, con stato pubblicato o in pubblicazione
		--		OR
		--	( @ProceduraGara <> '15583' and @pcp_TipoScheda <> '' and @schedaSenzaPubblicazioneAvviso = '1' and @pcp_StatoScheda = 'CigRecuperati' ) -- gara NON affidamento diretto, che prevede l'invio di una scheda/appalto, con stato 'CigRecuperati' se sono su una scheda che non prevede la pubblicazione avviso
		--		OR
		--	( @ProceduraGara <> '15583' and @pcp_TipoScheda <> '' and @SECONDA_FASE_INTEROP = '1' ) -- gara NON affidamento diretto, che prevede l'invio di una scheda/appalto, dove l'innesco pcp è stato fatto sul primo giro, quindi sulla seconda fase devo poter inviare la gara a prescindere da pcp
		--		OR
		--	( @pcp_StatoScheda = '' and @ProceduraGara <> '15583' and @pcp_TipoScheda <> '' and @traceEsitoPubGara = 1 ) -- retrocompatibilità: stato scheda non presente, gara non AD, tipo scheda presente, nel log c'è una richiesta di pubblicazione avviso
		--		OR
		--	( @ProceduraGara <> '15583' and @pcp_TipoScheda <> '' and @GESTIONE_PCP_RUP ='YES' and @UserRUP <> @iduser )
		--BEGIN
		--	SET @sendGaraPCP = '1'
		--END
		--ELSE
		--BEGIN
		--	SET @sendGaraPCP = '0'
		--END
		SET @sendGaraPCP = dbo.CanSend_GaraPCP(@IdDoc,@ProceduraGara,@pcp_TipoScheda,
							@pcp_StatoScheda,@schedaSenzaPubblicazioneAvviso,@SECONDA_FASE_INTEROP,
							@traceEsitoPubGara,@GESTIONE_PCP_RUP,@UserRUP,
							@iduser)

		if exists(select IdHeader from CTL_DOC_Value with(nolock) where IdHeader = @IdDoc and DSE_ID = 'INFO' and DZT_Name = 'sendGaraPCP')
		begin
			update CTL_DOC_Value set Value = @sendGaraPCP where IdHeader = @IdDoc and DSE_ID = 'INFO' and DZT_Name = 'sendGaraPCP'
		end
		else
		begin
			insert into CTL_DOC_Value (IdHeader, DSE_ID, Row, DZT_Name, Value) 
				values (@IdDoc, 'INFO', 0, 'sendGaraPCP', @sendGaraPCP)
		end
		 ----se è stato generato con successo un cn16
		--IF EXISTS ( select top 1 idrow from Document_E_FORM_PAYLOADS with(nolock) where idHeader = @idDoc and operationType = 'CN16' )
		--BEGIN
		--	--se la gara è interamente revocata o se è andata deserta
		--	IF EXISTS ( select Id from #D1 where StatoFunzionale = 'revocato' or ( StatoFunzionale = 'chiuso' and RecivedIstanze = 0 ) )
		--		set @bAttivaCan29 = '1'
		--END

		-- Valorizzo la variabile @affidamentoSenzaNegoziazioneCaption se mi trovo nel tipodoc AFFIDAMENTO_SENZA_NEGOZIAZIONE
		IF ((select isnull(tipodoc,'') from CTL_DOC with(nolock) where Id = @IdDoc) = 'AFFIDAMENTO_SENZA_NEGOZIAZIONE')
		BEGIN
			SET @affidamentoSenzaNegoziazioneCaption = 
				CASE 
					WHEN @pcp_TipoScheda = 'AD5' THEN 'Affidamento Senza Negoziazione'
					WHEN @pcp_TipoScheda = 'AD3' THEN 'Affidamento Diretto > 5.000 €'
					WHEN @pcp_TipoScheda = 'A3_6' THEN 'Affidamento societa in house'
					ELSE '' 
			END
		END

	END

	if exists(select IdHeader from CTL_DOC_Value with(nolock) where IdHeader = @IdDoc and DSE_ID = 'INFO' and DZT_Name = 'sendGaraPCP')
	begin
		update CTL_DOC_Value set Value = @sendGaraPCP where IdHeader = @IdDoc and DSE_ID = 'INFO' and DZT_Name = 'sendGaraPCP'
	end
	else
	begin
		insert into CTL_DOC_Value (IdHeader, DSE_ID, Row, DZT_Name, Value) 
			values (@IdDoc, 'INFO', 0, 'sendGaraPCP', @sendGaraPCP)
	end

  SELECT 
	
		
	b.*
    , CASE
        --DOMANDA PARTECIPAZIONE
        WHEN b.ProceduraGara = '15477' AND b.TipoBandoGara = '2' THEN '0'
        --MANIFESTAZIONE_INTERESSE
        WHEN b.ProceduraGara = '15478' AND b.TipoBandoGara = '1' THEN '0'
        --NON VEDIAMO IL COMANDO PER GARE NON APPARTENENTI AZIMASTER E DOVE RICHIESTO SUL CLIENTE solo per gare dell'ente aziMaster
        WHEN ISNULL(@CTP2_Valore, 0) = '1' AND m.IdMp IS NULL THEN '0'
        ELSE '1'
      END AS RIAM_OFF_VIS_COMANDO
    , CASE 
      WHEN SUBSTRING(isnull(@SYS_MODULI_RESULT, ''), 245, 1) = '1' /* and b.RichiestaCigSimog = 'si'*/
        THEN 1
      ELSE 0
      END AS simog
    , CASE --ATTIVAZIONE COMANDO RIAMMISSIONE OFFERTA SOLO AL RUP
      WHEN ISNULL(@CTP_Valore, '0') = '1'
        THEN '1'
      ELSE '0'
      END AS RIAM_OFF_ATT_SOLO_RUP
    , CASE 
      WHEN ISNULL(@SYS_AIC_URL_PAGE, '') <> ''
        THEN '1'
      ELSE '0'
      END AS Check_AIC_Enabled
    -- valori recuperati in precedenza
    , @UserRUP AS UserRUP
    , @PRESENZA_COD_REG AS PRESENZA_COD_REG
    , @InChargeToApprove AS InChargeToApprove
    , @SORTEGGIO AS SORTEGGIO
    , @SORTEGGIO_AVVISO AS SORTEGGIO_AVVISO
    , @CAN_PROROGA AS CAN_PROROGA
    , @pres_com_A AS pres_com_A
    , @cigInviato AS cigInviato
    , @PresenzaAIC AS PresenzaAIC
    , @RichiediProdottiSDA AS RichiediProdottiSDA
    , CASE 
      WHEN dbo.PARAMETRI('SERVICE_REQUEST', 'TED', 'ATTIVO', 'NO', - 1) = 'YES'
        THEN 1
      ELSE 0
      END AS ted
    , @tedInviato AS tedInviato
    , @tedAttesaPub AS tedAttesaPub
    , @tedPubblicato AS tedPubblicato
	, case when ( b.proceduragara = '15478' and tipobandogara = '1' ) or  -- NEGOZIATA AVVISO
				( b.proceduragara = '15477' and tipobandogara = '2' )  or --  BANDO RISTRETTA 
				( b.proceduragara = '15583' and tipobandogara in ('4','5') ) -- AFFIDAMENTO DIRETTO  AVVISO APERTO -- AVVISO CON DESTINATARI
			then 'NO' 
			else cp.Valore 
	  end AS simog_value
    , b.StatoFunzionale -- questo campo veniva usato sulla toolbar ma non era ritornato dalla stored
    , @abilitaComandi AS abilitaComandi
    --, CASE WHEN b.TipoDoc = 'TEMPLATE_GARA'
    --    THEN '1'
    --    ELSE '0'
    --  END AS IsDoc_TEMPLATE_GARA
	, @ATTIVA_MODULO_TEMPLATE_GARA as ATTIVA_MODULO_TEMPLATE_GARA
	, @Codifica_Prodotti_Rapida as Codifica_Prodotti_Rapida
	, case 
		when CHARINDEX('###' + b.StatoFunzionale + '###', @EsportazioneFascicoloStato_Valore) > 0
			then 1 -- Controllo se negli stati del parametro c'è un match
		else 
			0 -- Disabilito il campo
	  end as EsportazioneFascicoloAttivo

	, @SECONDO_GIRO_AFFID_DIR_DUE_FASI as SECONDO_GIRO_AFFID_DIR_DUE_FASI
	, @AttivaFiltroRup as AttivaFiltroRup
	, @AziendaCompilatore as AziendaCompilatore
    , @isSimogGgap AS isGgap
	, @bAttivaCan29 as attivaCan29deserta 
	, @attivo_INTEROP_Gara as attivo_INTEROP_Gara
	, @SECONDA_FASE_INTEROP as SECONDA_FASE_INTEROP
	, @CAN_PCP_PUBBLICA_AVVISO as CAN_PCP_PUBBLICA_AVVISO

	-- COLONNE UTILI AL MENU PCP E A FAR EVOLVERE LE LOGICHE DI ATTIVAZIONE DEL COMANDO DI 'INVIO'
	, @confermaAppalto as pcp_confermaAppalto
	, @viewConfermaAppalto as pcp_viewConfermaAppalto
	, @cancellaAppalto as pcp_cancellaAppalto
	, @viewCancellaAppalto as pcp_viewCancellaAppalto
	, @recuperaCIG as pcp_recuperaCIG
	, @viewRecuperaCIG as pcp_viewRecuperaCIG
	, @pubblicaAvviso as pcp_pubblicaAvviso
	, @viewPubblicaAvviso as pcp_viewPubblicaAvviso
	, @menuPCP as menuPCP
	, @viewMenuPCP as viewMenuPCP
	, @sendGaraPCP as sendGaraPCP
	, @viewEsitoOperazione as viewEsitoOperazione
	, @attivaEsitoOperazione as attivaEsitoOperazione
	, @viewEsitoOperazioneSync as viewEsitoOperazioneSync
	, @attivaEsitoOperazioneSync as attivaEsitoOperazioneSync
	, @viewConsultaAvviso as viewConsultaAvviso
	, @attivaConsultaAvviso as attivaConsultaAvviso
	, @attivaRettificaProroga as attivaRettificaProroga
	, @attivaEsitoOperazioneRett as attivaEsitoOperazioneRett
	, @viewEsitoOperazioneRett as viewEsitoOperazioneRett
	, @affidamentoSenzaNegoziazioneCaption as CaptionAffidamentoSenzaNegoziazione
	, @pcp_StatoScheda as pcp_StatoScheda
  FROM #D1 b
		LEFT OUTER JOIN MarketPlace m WITH (NOLOCK) ON m.mpidazimaster = b.azienda AND m.mpDeleted = 0
		LEFT OUTER JOIN CTL_Parametri cp WITH (NOLOCK) ON cp.contesto = 'simog' AND cp.oggetto = 'SIMOG_GET' AND cp.Proprieta = 'ATTIVO'
	
END
GO
