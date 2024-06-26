USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_CK_SEC_BANDO_GARA]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[OLD_CK_SEC_BANDO_GARA] 
(
	@SectionName AS VARCHAR(255),
	@IdDoc AS VARCHAR(255),
	@IdUser AS VARCHAR(255)
)
AS
BEGIN

  -- verifico se la sezione puo essere aperta.
  SET NOCOUNT ON

  DECLARE @idPfu INT
  DECLARE @idPDA INT

  SET @idPDA = @IdDoc

  DECLARE @Blocco NVARCHAR(1000)

  SET @Blocco = ''

  DECLARE @tipoDoc VARCHAR(500)
  DECLARE @tb VARCHAR(50)
  DECLARE @pg VARCHAR(50)
  DECLARE @Divisione_lotti VARCHAR(50)
  DECLARE @VisualizzaNotifiche AS VARCHAR(10)
  DECLARE @DataScadenzaOfferta AS DATETIME
  DECLARE @DataAperturaOfferte AS DATETIME
  DECLARE @Comunicazione_Iniziativa AS VARCHAR(2)
  DECLARE @TipoProceduraCaratteristica VARCHAR(100)
  DECLARE @IdAziBando AS INT
  DECLARE @Conformita VARCHAR(20)
  DECLARE @CriterioAggiudicazioneGara VARCHAR(20)
  DECLARE @TipoSceltaContraente AS VARCHAR(100)
  DECLARE @richiestoSimog VARCHAR(10)
  DECLARE @Compilatore AS INT
  DECLARE @Rup AS INT
  DECLARE @statoFunzionale varchar(500) = ''
  declare @attivo_INTEROP_Gara as int

  --aggiunto per gestire le sezioni da vedere sulle copie dei bandi fatte alla modifica del BANDO
  DECLARE @del VARCHAR(20)

  SELECT @del = deleted
    , @IdAziBando = azienda
    , @tipoDoc = tipoDoc
    , @Compilatore = idpfu
	, @statoFunzionale = StatoFunzionale
  FROM CTL_DOC WITH (NOLOCK)
  WHERE id = @IdDoc

  SET @richiestoSimog = ''
  SET @Blocco = ''

  SELECT @pg = ProceduraGara
    , @tb = TipoBandoGara
    , @TipoProceduraCaratteristica = TipoProceduraCaratteristica
    , @Divisione_lotti = Divisione_lotti
    , @VisualizzaNotifiche = VisualizzaNotifiche
    , @DataScadenzaOfferta = DataScadenzaOfferta
    , @DataAperturaOfferte = DataAperturaOfferte
    , @CriterioAggiudicazioneGara = CriterioAggiudicazioneGara
    , @Conformita = Conformita
    , @TipoSceltaContraente = isnull(TipoSceltaContraente, '')
    , @Comunicazione_Iniziativa = ISNULL(Comunicazione_Iniziativa, 'no')
    , @richiestoSimog = isnull(RichiestaCigSimog, '')
  FROM document_bando WITH (NOLOCK)
  WHERE idheader = @IdDoc


  --VEDO SE ATTIVO INTEROP SULLA GARA
  set @attivo_INTEROP_Gara = dbo.attivo_INTEROP_Gara(@iddoc)

  IF @tb = '2' AND @pg = '15477' -- Bando - Ristretta
  BEGIN
	
	--SE NOT ATTIVO INTEROP COME PRIMA
	--ALTRIMENTI TUTTO VISIBILE
	IF @SectionName IN (
				'PRODOTTI'
				, 'ECONOMICA'
				, 'TECNICA'
				, 'LISTA_LOTTI'
				, 'CRITERI'
				, 'COMMISSIONE'
				, 'DESTINATARI'
				)
			BEGIN
			  SET @Blocco = 'NON_VISIBILE'
			END
	
	
  END

  --SE ATTIVO INTEROP E RISTRETTA - BANDO ALLORA VISUALIZZO LE SEZIONI
  --select @attivo_INTEROP_Gara

  if @attivo_INTEROP_Gara=1 and @tb = '2' AND @pg = '15477' -- Bando - Ristretta
  BEGIN
	IF @SectionName 
			IN (
				'PRODOTTI'
				, 'ECONOMICA'
				, 'TECNICA'
				, 'LISTA_LOTTI'
				, 'CRITERI'
				, 'COMMISSIONE'
				, 'DESTINATARI'
				)

			BEGIN
			  SET @Blocco = ''
			END
  END


  IF @tb = '3' AND @pg = '15477' -- Invito - Ristretta
  BEGIN
    SET @Blocco = ''
  END

  -- Se Avviso - Negoziata oppure Avviso di un Affidamento a 2 fasi
  IF (
      (
        @tb = '1'
        AND @pg = '15478'
        )
      OR (
        @tb IN (
          '4'
          , '5'
          )
        AND @pg = '15583'
        )
      )
  BEGIN
    	IF upper(@SectionName) IN (
			'PRODOTTI'
			/*, 'DOCUMENTAZIONE_RICHIESTA'*/
			, 'ECONOMICA'
			, 'TECNICA'
			, 'LISTA_LOTTI'
			, 'CRITERI'
			, 'COMMISSIONE'
			, 'DESTINATARI'
			)
		BEGIN
		  SET @Blocco = 'NON_VISIBILE'
		END
	
	
		-- SE E' ATTIVO IL SIMOG MOSTRO SEMPRE LA SEZIONE TECH_INFO
		IF upper(@SectionName) = 'TECH_INFO'
		  AND dbo.attivoSimog() = 0 and dbo.attivoPCP ()=0
		BEGIN
		  SET @Blocco = 'NON_VISIBILE'
		END

		--se sono su AFFIDAMENTO a 2 FASI con AVVISO CON DESTINATARI
		--la sezione DESTINATARI e' VISIBILE
		IF upper(@SectionName) = 'DESTINATARI'
		  AND @tb = '5'
		  AND @pg = '15583'
		BEGIN
		  SET @Blocco = ''
		END


		--SE ATTIVO INTEROP PER AVVISO -NEGOZITA VISUALIZZO LE SEZIONI
		if @attivo_INTEROP_Gara = 1 and @tb = '1' AND @pg = '15478'
		begin
			IF upper(@SectionName) IN (
										'PRODOTTI'
										, 'ECONOMICA'
										, 'TECNICA'
										, 'LISTA_LOTTI'
										, 'CRITERI'
										, 'COMMISSIONE'
										, 'DESTINATARI'
										)
			BEGIN
			  SET @Blocco = ''
			END
		end

  END




  IF (@tb = '3' AND @pg = '15478') -- Invito - Negoziata
  BEGIN
    SET @Blocco = ''
  END

  IF @del = '1'
    AND @SectionName IN (
      'APPROVAL'
      , 'DOC'
      , 'ALLEGATI_RETTIFICA'
      )
  BEGIN
    SET @Blocco = 'NON_VISIBILE'
  END
  
  IF @SectionName IN ('TECH_INFO')
    AND dbo.attivoSimog() = 0  and dbo.attivoPCP () = 0
    AND (
      @TipoProceduraCaratteristica = 'RDO'	
      OR @pg = '15479' OR @pg = '15583' --RICHIESTA PREVENTIVO oppure AFFIDAMENTO DIRETTO
     )
  BEGIN
    SET @Blocco = 'NON_VISIBILE'
  END

  IF @SectionName IN ('LISTA_LOTTI')
    AND @Divisione_lotti = 0
  BEGIN
    SET @Blocco = 'NON_VISIBILE'
  END

  IF @SectionName IN ('PRODOTTI')
    AND @Divisione_lotti = 0
    IF @Blocco = ''
      SET @Blocco = 'CAPTION:Prodotti'

  --if @SectionName = 'LISTA_OFFERTE'
  --BEGIN	
  --	If 	@VisualizzaNotifiche = '1'  --1 significa=si 0 significa=no
  --	BEGIN
  --		IF getdate() > @DataScadenzaOfferta
  --			set @Blocco = ''
  --		ELSE
  --			set @Blocco = 'La visualizzazione delle offerte è disponibile al superamento della data "Termine Presentazioni Offerte"'
  --	END
  --	ELSE
  --	BEGIN
  --		IF  getdate() > @DataAperturaOfferte
  --			set @Blocco = ''
  --		ELSE
  --			set @Blocco = 'La visualizzazione delle offerte è disponibile al superamento della data "Data Prima Seduta"'
  --	END		
  --END

  IF @SectionName = 'LISTA_OFFERTE'
  BEGIN
    -- Se Avviso - Negoziata oppure Avviso di AFFIDAMENTO DIRETTO 2 FASI
    -- nascondo 
    IF ((@tb = '1' AND @pg = '15478') OR (@tb IN ('4', '5') AND @pg = '15583'))
    BEGIN
      SET @Blocco = 'NON_VISIBILE'
    END
    ELSE
    BEGIN
      IF @VisualizzaNotifiche = '0' -- 1 => significa=si, 0 => significa=no
      BEGIN
        IF getdate() > @DataScadenzaOfferta
        BEGIN
          SET @Blocco = ''
        END
        ELSE
        BEGIN
          --BANDO di RISTRETTA
          IF @pg = '15477'
            AND @tb = '2'
            SET @Blocco = 'La visualizzazione delle domande è disponibile al superamento della data "Termine Presentazione Risposte"'
          ELSE
            SET @Blocco = 'La visualizzazione delle offerte è disponibile al superamento della data "Termine Presentazioni Offerte"'
        END
      END
      ELSE
      BEGIN
        SET @Blocco = ''
      END

      --BANDO di RISTRETTA
      IF @pg = '15477'
        AND @tb = '2'
      BEGIN
        IF @Blocco = ''
          SET @Blocco = 'CAPTION:Domande Ricevute'
        ELSE
          SET @Blocco = 'CAPTION:Domande Ricevute~' + @Blocco
      END
    END
  END

  IF @SectionName = 'TESTATA_PRODOTTI'
  BEGIN
    --se si tratta di un utente non dell'ente blocco
    IF NOT EXISTS (SELECT idpfu
						FROM profiliutente with(nolock)
						WHERE pfuidazi = @IdAziBando AND idpfu = @IdUser) AND @tipoDoc <> 'TEMPLATE_GARA'
    --if @IdUser=-20
      SET @Blocco = 'la visualizzazione della testata prodotti è riservata agli utenti dell''ente'
  END

  -- il folder ECONOMICA( che rappresenta l'elenco dei prodotti che il fornitore va a riempire ) ed ELENCO_LOTTI ( che ha lo stesso scopo )
  -- vengono visualizzati in modo alternativo 
  -- 15532 = OEV

  -- Nascondere la busta tecnica quando 'conformita = no e criterio al prezzo' oppure a lotti
  IF @SectionName = 'TECNICA'
    AND (
      @Divisione_lotti <> '0'
      OR (
        isnull(@Conformita, 'No') = 'No'
        AND @CriterioAggiudicazioneGara <> '15532'
        AND @CriterioAggiudicazioneGara <> '25532'
        )
      )
  BEGIN
    SET @Blocco = 'NON_VISIBILE'
  END
  ELSE
  BEGIN
    -- Se sto sulla sezione di busta economica e tecnica, e non sono a lotti e sono su OEV o con conformità devo visualizzare sia la busta tecnica che economica
    IF @SectionName IN (
        'ECONOMICA'
        , 'TECNICA'
        )
      AND @Divisione_lotti = '0'
      AND (
        @CriterioAggiudicazioneGara = '15532'
        OR @CriterioAggiudicazioneGara = '25532'
        OR isnull(@Conformita, 'No') <> 'No'
        )
    BEGIN
      SET @blocco = @blocco
    END
    ELSE
    BEGIN
      IF @Conformita = 'Ex-Ante'
        OR @CriterioAggiudicazioneGara = '15532'
        OR @CriterioAggiudicazioneGara = '25532'
        OR @Divisione_lotti <> '0'
        IF @SectionName IN (
            'ECONOMICA'
            , 'TECNICA'
            )
          SET @Blocco = 'NON_VISIBILE'
    END
  END

  IF @Divisione_lotti = '0'
    IF @SectionName = 'LISTA_LOTTI'
      SET @Blocco = 'NON_VISIBILE'

  -- il folder dei criteri serve solo per Economicamente vantaggiosa 
  IF @CriterioAggiudicazioneGara <> '15532'
    AND @CriterioAggiudicazioneGara <> '25532'
  BEGIN
    --****************
    -- solamente se il documento non è in lavorazione e non è stato definito un criterio di valutazione economico
    -- i vecchi documenti per le gare al prezzo non applicavano i criteri di valutazione economici e quindi per uniformità continuano a nascondere il tab
    IF @SectionName = 'CRITERI'
    BEGIN
      IF EXISTS (
          SELECT id
          FROM ctl_doc with(nolock)
          WHERE id = @IdDoc
            AND statofunzionale <> 'InLavorazione'
          )
        AND NOT EXISTS (
          SELECT idrow
          FROM Document_Microlotto_Valutazione_ECO with(nolock)
          WHERE idheader = @idDoc
            AND TipoDoc IN ('BANDO_GARA', 'TEMPLATE_GARA')
          )
      BEGIN
        SET @Blocco = 'NON_VISIBILE'
      END
    END
  END

  -- in caso di gara ad affidamento diretto i criteri non si devono vedere !!!
  IF @pg = '15583'
    AND @SectionName = 'CRITERI'
    SET @Blocco = 'NON_VISIBILE'

  -- il foder dei desinatari è presente solo se il bando li prevede
  -- per nasconderlo non devo stare su un affidamento diretto avviso con destinatari
  IF @tb <> '3'
    AND @tipoDoc <> 'BANDO_SEMPLIFICATO'
    AND NOT (
      @tb = '5'
      AND @pg = '15583'
      )
    IF @SectionName = 'DESTINATARI'
      SET @Blocco = 'NON_VISIBILE'

  IF @TipoSceltaContraente <> 'ACCORDOQUADRO'
  BEGIN
    IF @SectionName = 'PLANT'
    BEGIN
      SET @Blocco = 'NON_VISIBILE'
    END
  END

  --cambio caption al folder "criteri di valutazione" se è visibile
  IF @SectionName = 'CRITERI'
    AND @Divisione_lotti <> 0
    IF @Blocco <> 'NON_VISIBILE'
      SET @Blocco = 'CAPTION:criteri di valutazione prevalenti'

  -- reupero il RUP
  SELECT @Rup = value
  FROM CTL_DOC_Value WITH (NOLOCK)
  WHERE idheader = @IdDoc
    AND DSE_ID = 'InfoTec_comune'
    AND dzt_name = 'UserRUP'

  -- se l'utente collegato ha il profilo URP all'ora l'accesso alle sezioni è limitato alla testa
  IF EXISTS (
      SELECT idpfu
      FROM profiliutenteattrib WITH (NOLOCK)
      WHERE idpfu = @IdUser
        AND dztnome = 'Profilo'
        AND attvalue = 'URP'
      )
    --se utente collegato è il compilatore deve vedere
    AND (@Compilatore <> @IdUser)
    --se utente rup devo vedere lo stesso
    AND (@Rup <> @IdUser) AND @tipoDoc <> 'TEMPLATE_GARA'
  BEGIN
    SET @Blocco = 'NON_VISIBILE'
  END

  -- se non sono un avviso-negoziato non mostro la sezione manifestazioni di interesse
  -- oppure non devo vedere la sezione se non sono su un affidamento diretto - avviso/avviso con destinatari
  IF @SectionName = 'LISTA_MANIF_INTERES'
  BEGIN
    IF NOT (
        @tb = '1'
        AND @pg = '15478'
        )
      AND NOT (
        @tb IN (
          '4'
          , '5'
          )
        AND @pg = '15583'
        )
    BEGIN
      SET @Blocco = 'NON_VISIBILE'
    END
    ELSE
    BEGIN
      --If 	@VisualizzaNotifiche = '0'  --1 significa=si 0 significa=no
      --BEGIN
      --	IF getdate() < @DataScadenzaOfferta
      --		set @Blocco = 'La visualizzazione delle manifestazioni di interesse è disponibile al superamento della data "Termine Presentazione Documenti"'
      --END
      --ELSE
      BEGIN
        SET @Blocco = ''
      END
    END
  END

  IF @SectionName IN ('REQUISITI')
    AND (
      dbo.attivoSimog() = 0
      OR @richiestoSimog = 'no'
      OR @richiestoSimog = ''
      OR EXISTS (
        SELECT id
        FROM ctl_doc WITH (NOLOCK)
        WHERE linkeddoc = @IdDoc
          AND tipodoc = 'RICHIESTA_SMART_CIG'
          AND statofunzionale = 'Inviato'
        )

		OR @attivo_INTEROP_Gara = 1
      )
	  
  BEGIN
    SET @Blocco = 'NON_VISIBILE'
  END

  IF @SectionName IN ('LISTA_COMUNICAZIONI')
  BEGIN
    SET @Blocco = 'NON_VISIBILE'

    --if  ( getdate() > @DataAperturaOfferte ) and @Comunicazione_Iniziativa = 'si'
    IF (getdate() > @DataScadenzaOfferta)
    BEGIN
      DECLARE @c INT

      SET @c = 0

      SELECT @c = count(id)
      FROM ctl_doc o WITH (NOLOCK)
      WHERE o.deleted = 0
        AND o.tipodoc IN ('COMUNICAZIONE_OE')
        AND StatoDoc = 'Sended'
        AND Linkeddoc = @IdDoc

      IF @Comunicazione_Iniziativa = 'si'
        OR isnull(@c, 0) > 0
      BEGIN
        SET @Blocco = ''
      END
    END
  END

  --select @TipoProceduraCaratteristica
  --SE AFFIDAMENTI DIRETTI SEMPLIFICATI NON MOSTRO I FOLDER ECONOMICA RIFERIMENTI NOTE
  IF @TipoProceduraCaratteristica = 'AffidamentoSemplificato'
    AND @SectionName IN (
      'ECONOMICA'
      , 'RIFERIMENTI'
      , 'NOTE'
      , 'REQUISITI'
      --, 'TECH_INFO'
      , 'DESTINATARI'
      , 'LISTA_OFFERTE'
      , 'ALLEGATI_RETTIFICA'
      )
  BEGIN
    SET @Blocco = 'NON_VISIBILE'
  END

  --per la sezione LISTA MANIFESTAZIONI DI INTERESSE
  --nel caso affidamento diretto a 2 fasi cambiamo etichetta
	IF @SectionName IN ('LISTA_MANIF_INTERES')
    AND @tb IN ('4','5') AND @pg = '15583'
	begin
		IF @Blocco = ''
		  SET @Blocco = 'CAPTION:Risposte all''Avviso'
	end


	-- SEZIONE INTEROPERABILITÀ e CRONOLOGIA
	IF @SectionName in ( 'INTEROP', 'PCP_CRONOLOGIA')
	BEGIN
		


		-- Non visualizzare la sezione "interoperabilità" per : 
		--	le gare con ( Tipo di procedura = Richiesta preventivo. cioè ProceduraGara = 15479 )
		--	le consultazioni preliminari di mercato ( già esclusa essendo tipo doc BANDO_CONSULTAZIONE )
		--	prima fase di una negoziata con avviso ( TipoBandoGara = '1' AND ProceduraGara = '15478' )
		--	RDO ( @TipoProceduraCaratteristica = 'RDO' )
		--	Affidamento diretto ( @pg = '15583' )
		--  Se diverso da in lavorazione e non ho un dato obbligatorio di cn16. serve per nascondere la sezione per le gare precedenti all'attivazione dell'attività del contract notice

		--declare @datoSentinellaCN16 varchar(100) = ''

		--select @datoSentinellaCN16 = cn16_AuctionConstraintIndicator from Document_E_FORM_CONTRACT_NOTICE with(nolock) where idHeader = @IdDoc

		--IF ( 
		--		( @pg = '15479' ) --Richiesta preventivo
		--			OR
		--		( @tb = '1' AND @pg = '15478' ) --negoziata con avviso 
		--		    OR
		--		( @TipoProceduraCaratteristica = 'RDO' ) -- RDO
		--		--	OR
		--		--( @pg = '15583' ) --Affidamento diretto 
		--			OR
		--		( @statoFunzionale <> 'InLavorazione' and isnull(@datoSentinellaCN16,'') = '' ) --se diverso da in lavorazione e non ho un dato obbligatorio di cn16
					
		--)
		
		
		if @attivo_INTEROP_Gara = 0
		BEGIN
			SET @Blocco = 'NON_VISIBILE'
		END

	END


  SELECT @Blocco AS Blocco
END
GO
