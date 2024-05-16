USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[DOCUMENT_CK_TOOLBAR_BANDO_CONCORSO]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[DOCUMENT_CK_TOOLBAR_BANDO_CONCORSO] (
  @DocName NVARCHAR(500)
  , @IdDoc AS NVARCHAR(500)
  , @idUser INT
  )
AS
BEGIN
  SET NOCOUNT ON

   --Only for test
  --DECLARE @IdDoc AS NVARCHAR(500) = 254808
  --DECLARE @idUser INT = 45094

  declare @Codifica_Prodotti_Rapida as int
  
  --verifico se attivo il modulo per la codifica rapida dei prodotti dalla gara
  set @Codifica_Prodotti_Rapida = 0
  IF EXISTS (	
				select items 
					from dbo.Split((select DZT_ValueDef from lib_dictionary with(nolock) where DZT_Name='SYS_MODULI_GRUPPI'),',') 
					where items = 'CODIFICA_PRODOTTI_RAPIDA' 
			)
  BEGIN
	set @Codifica_Prodotti_Rapida = 1
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

  --recupero compilatore della gara
  DECLARE @Idpfu INT;

  SELECT 
		@Idpfu = d.IdPfu
	FROM 
		#D d

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
      END AS SCADENZA_INVIO_OFFERTE -- Viene ritornato valore 1 solo nel caso in cui la data di scadenza offerta è terminata!
    , b.TipoBandoGara
    --, CASE 
    --    WHEN TipoDoc = 'TEMPLATE_GARA'
    --      THEN 'TEMPLATE: '
    --    ELSE ''
    --  END
    --  +
    --  CASE 
    --     WHEN b.TipoProceduraCaratteristica = 'AffidamentoSemplificato'
    --       THEN 'Affidamento diretto'
    --     WHEN b.TipoProceduraCaratteristica = 'RDO'
    --       THEN 'Richiesta di Offerta'
    --     WHEN b.ProceduraGara = '15477'
    --       AND b.TipoBandoGara = '2'
    --       THEN 'BandoRistretta' -- Ristretta / Bando
    --     ELSE CASE 
    --       WHEN b.TipoSceltaContraente = 'ACCORDOQUADRO'
    --         THEN 'Accordo Quadro'
    --       ELSE CASE 
    --           WHEN b.TipoBandoGara IN (
    --               '1'
    --               , '4'
    --               , '5'
    --               )
    --             THEN 'Avviso'
    --           WHEN b.TipoBandoGara = '3'
    --             THEN 'Invito'
    --           WHEN b.TipoBandoGara = '2'
    --             THEN 'Bando'
    --           END
    --       END
    --   END AS CaptionDoc
	--,'Bando Concorso' AS CaptionDoc

	,case
		when Proceduragara='15586' then 'Concorso di Idee'
		when Proceduragara='15587' and isnull(TipoProceduraCaratteristica,'') ='ConcorsoInSingolaFase'  then 'Concorso di Progettazione'
		when Proceduragara='15587' and isnull(TipoProceduraCaratteristica,'') ='ConcorsoInDueFasi' and ISNULL(faseconcorso,'')='prima' then 'Concorso di Progettazione I fase'
		when Proceduragara='15587' and isnull(TipoProceduraCaratteristica,'') ='ConcorsoInDueFasi'  and ISNULL(faseconcorso,'')='seconda' then 'Concorso di Progettazione II fase'
		--isnull(FaseConcorso,'')='prima' then ''
	end as CaptionDoc

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
    , CASE 
      WHEN b.DataRiferimentoFine IS NULL
        THEN 'no'
      WHEN b.DataRiferimentoFine < GETDATE()
        THEN 'si'
      ELSE 'no'
      END AS AQ_SCADUTO
	, FaseConcorso
  INTO #D1
  FROM document_bando b WITH (NOLOCK)
		CROSS JOIN #D d
  WHERE b.idheader = @IdDoc;

  DROP TABLE #D

  -- recupera dal primo giro di gara la tipologia e la presenza dei prodotti
  DECLARE @sb_TipoBandoGara VARCHAR(20)
  DECLARE @RichiediProdottiSDA INT

  SELECT
	@sb_TipoBandoGara = sb.TipoBandoGara
    , @RichiediProdottiSDA = sb.RichiediProdotti
  --, @Idpfu = d.IdPfu
  FROM 
		document_bando sb WITH (NOLOCK)
			CROSS JOIN #D1 d
  WHERE sb.idheader = d.linkeddoc;

  -- REUPERA IL RUP DELLA GARA
  DECLARE @UserRUP NVARCHAR(max) -- DA ritornare in output

  SELECT @UserRUP = rup.Value
  FROM ctl_doc_value rup WITH (NOLOCK)
  WHERE rup.idHeader = @idDoc
    AND rup.dzt_name = 'UserRup'
    AND rup.dse_id = 'InfoTec_comune'

  -- RECUPERA il modello della gara
  DECLARE @id_modello VARCHAR(20)

  SELECT @id_modello = idm.Value
  FROM ctl_doc_value idm WITH (NOLOCK)
  WHERE idm.idHeader = @idDoc
    AND idm.dzt_name = 'id_modello'
    AND idm.dse_id = 'TESTATA_PRODOTTI'

  -- RECUPERO SYS
  DECLARE @SYS_ATTIVA_CODICE_REGIONALE VARCHAR(100)
  DECLARE @SYS_MODULI_RESULT VARCHAR(8000)
  DECLARE @SYS_AIC_URL_PAGE VARCHAR(8000)

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
  DECLARE @CTP_Valore VARCHAR(100)
  DECLARE @CTP2_Valore VARCHAR(100)
  DECLARE @EsportazioneFascicoloStato_Valore VARCHAR(1000)

  SET @CTP_Valore = dbo.PARAMETRI('BANDO_GARA-BANDO_SEMPLIFICATO', 'RiammissioneOfferta', 'Riammissione_Offerta_SOLO_RUP', '', -1)
  SET @CTP2_Valore = dbo.PARAMETRI('BANDO_GARA-BANDO_SEMPLIFICATO', 'RiammissioneOfferta', 'Riammissione_Offerta_SOLO_AZI_MASTER', '', -1)
  
  SET @EsportazioneFascicoloStato_Valore = dbo.PARAMETRI('FASCICOLO_DI_GARA', 'EsportazioneFascicolo', 'Stati_Per_Attivazione', '###Chiuso###', -1)

  -- verifica la presenza del codice regionale sul modello
  DECLARE @PRESENZA_COD_REG VARCHAR(2) --  DA ritornare in output

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
  DECLARE @InChargeToApprove VARCHAR(20) -- DA ritornare in output

  SELECT @InChargeToApprove = ap.APS_IdPfu
	FROM ctl_approvalsteps ap WITH (NOLOCK)
		CROSS JOIN #D1 d
	WHERE APS_IsOld = 0
		AND d.TipoDoc = ap.APS_Doc_Type
		AND ap.APS_State = 'InCharge'
		AND ap.APS_ID_DOC = @idDoc

  -- Sorteggio associato alla gara/avviso
  DECLARE @SORTEGGIO VARCHAR(1) --  DA ritornare in output

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
  DECLARE @SORTEGGIO_AVVISO VARCHAR(1) --  DA ritornare in output

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
  DECLARE @CAN_PROROGA VARCHAR(1) --  DA ritornare in output

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
  DECLARE @idCOM INT
  DECLARE @pres_com_A NVARCHAR(200) --  DA ritornare in output

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
  DECLARE @cigInviato VARCHAR(1) -- Da ritornare in output

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
  DECLARE @PresenzaAIC VARCHAR(1)

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

  DECLARE @tedInviato VARCHAR(10) = '0'
  DECLARE @tedAttesaPub VARCHAR(10) = '0'
  DECLARE @tedPubblicato VARCHAR(10) = '0'
  DECLARE @statoFunzPubTed VARCHAR(100) = ''
  DECLARE @idPubTed INT

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

  ------------------------------------------------------
  ------------------------------------------------------
  ------------------------------------------------------

  -- i comandi verranno abilitati se sei un utente che è RUP oppure il compilatore
  DECLARE @abilitaComandi VARCHAR(100);

  SET @abilitaComandi = '1'

  --i comandi vengono disabilitati per l'utente URP
  IF EXISTS (
      SELECT idpfu
      FROM ProfiliUtente
      WHERE IdPfu = @idUser
        AND SUBSTRING(pfuFunzionalita, 150, 1) = '1'
      )
    SET @abilitaComandi = '0'

  --nel caso di o compilatore o RUP il comando viene comunque abilitato anche se sei un URP
  IF (
      @UserRUP = @idUser
      OR @idUser = @Idpfu
      )
    SET @abilitaComandi = '1'

 
 declare @SECONDO_GIRO_AFFID_DIR_DUE_FASI as varchar(10)
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
 declare @AttivaFiltroRup as int
 select @AttivaFiltroRup = dbo.PARAMETRI('GARE', 'PREGARA', 'AttivaFiltro', '0', -1)

 --recupero se attivo il modulo TEMPLATE_GARA
 declare @ATTIVA_MODULO_TEMPLATE_GARA as varchar(10)
 
 set @ATTIVA_MODULO_TEMPLATE_GARA ='no'

 IF EXISTS (
      SELECT items
      FROM dbo.Split((SELECT DZT_ValueDef
                      FROM lib_dictionary WITH (NOLOCK)
                      WHERE DZT_Name = 'SYS_MODULI_GRUPPI'), ',')
      WHERE items = 'TEMPLATE_GARA')
 begin
	set @ATTIVA_MODULO_TEMPLATE_GARA = 'si'
 end

  SELECT b.*
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
    , cp.Valore AS simog_value
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
	, case
		when isnull(FaseConcorso,'') <> 'prima' then 1
		else 0
	  end as CanAggiungiCriteriTecnici

  FROM 
	#D1 b
		LEFT OUTER JOIN MarketPlace m WITH (NOLOCK) ON m.mpidazimaster = b.azienda AND m.mpDeleted = 0
		LEFT OUTER JOIN CTL_Parametri cp WITH (NOLOCK) ON cp.contesto = 'simog' AND cp.oggetto = 'SIMOG_GET' AND cp.Proprieta = 'ATTIVO'
	
END
GO
