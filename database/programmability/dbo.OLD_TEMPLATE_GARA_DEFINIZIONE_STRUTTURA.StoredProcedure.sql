USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_TEMPLATE_GARA_DEFINIZIONE_STRUTTURA]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[OLD_TEMPLATE_GARA_DEFINIZIONE_STRUTTURA] (@IdNewDoc INT, @idDoc INT = 0, @idAzi INT = 0)
AS
BEGIN
  DECLARE @tipodoc AS VARCHAR(200)
  DECLARE @TipoProceduraCaratteristica AS VARCHAR(200)
  DECLARE @TipoSceltaContraente AS VARCHAR(200)
  DECLARE @tipobandogara VARCHAR(500)
  DECLARE @proceduraGara VARCHAR(500)
  DECLARE @richiestaCIG VARCHAR(100)
  DECLARE @fascicoloGenerale VARCHAR(500)
  DECLARE @idPfuAOO INT

  SELECT @tipodoc = TipoDoc
         , @TipoProceduraCaratteristica = TipoProceduraCaratteristica
         , @tipobandogara = TipoBandoGara
         , @proceduraGara = DB.ProceduraGara
         , @TipoSceltaContraente = DB.TipoSceltaContraente
         , @richiestaCIG = db.RichiestaCigSimog
         , @fascicoloGenerale = fascicoloSecondario
         , @idPfuAOO = IdPfu
    FROM ctl_doc WITH (NOLOCK)
         INNER JOIN document_bando DB WITH (NOLOCK) ON id = DB.idheader
         LEFT JOIN Document_dati_protocollo b WITH (NOLOCK) ON b.idHeader = Id
    WHERE id = @IdNewDoc

  --RETTIFICO IL MODELLO DI TESTATA CON QUELLO DEFINITO 	
  IF @tipodoc = 'TEMPLATE_GARA' AND ISNULL(@TipoProceduraCaratteristica, '') = ''
  BEGIN
    DELETE FROM CTL_DOC_SECTION_MODEL
           WHERE DSE_ID = 'TESTATA' AND IdHeader = @IdNewDoc

    /* SE AVVISO O RISTRETTA-BANDO */
    IF @tipobandogara = '1'
        OR (@proceduraGara = '15477' AND @tipobandogara = '2')
        OR (@proceduraGara = '15583' AND (@tipobandogara = '4' OR @tipobandogara = '5'))
    BEGIN
      INSERT INTO CTL_DOC_SECTION_MODEL (IdHeader, DSE_ID, MOD_Name)
             VALUES (@IdNewDoc, 'TESTATA', 'TEMPLATE_GARA_TESTATA_AVVISO')
    END
  END

  --TEMPLATE_GARA-RDO
  IF @tipodoc = 'TEMPLATE_GARA' AND ISNULL(@TipoProceduraCaratteristica, '') = 'RDO'
  BEGIN
    DELETE FROM CTL_DOC_SECTION_MODEL
           WHERE DSE_ID = 'TESTATA' AND IdHeader = @IdNewDoc

    INSERT INTO CTL_DOC_SECTION_MODEL (IdHeader, DSE_ID, MOD_Name)
           VALUES (@IdNewDoc, 'TESTATA', 'TEMPLATE_GARA_TESTATA_RDO')
  END

  --recupero se ATTIVO Cottimo_Gara_Unificato
  declare @Cottimo_Gara_Unificato_Attivo as varchar(10)
  select @Cottimo_Gara_Unificato_Attivo = dbo.PARAMETRI('GROUP_Procedura','Cottimo_Gara_Unificato','ATTIVO','NO',-1 )
	

  --TEMPLATE_GARA-COTTIMO
  IF @tipodoc = 'TEMPLATE_GARA' AND ISNULL(@TipoProceduraCaratteristica, '') = 'Cottimo'
  BEGIN
	if @Cottimo_Gara_Unificato_Attivo <> 'YES'
	begin

  		delete from  CTL_DOC_SECTION_MODEL where DSE_ID='TESTATA' and IdHeader=@IdNewDoc
  		insert into CTL_DOC_SECTION_MODEL ( IdHeader, DSE_ID, MOD_Name ) 
  			values( @IdNewDoc , 'TESTATA' , 'TEMPLATE_GARA_TESTATA_COTTIMO' )
	end
	else
	begin
		--se è un avviso utilizzo lo stesso modello dell'avviso della negoziata
		IF  @tipobandogara = '1'
		begin
			delete from  CTL_DOC_SECTION_MODEL where DSE_ID='TESTATA' and IdHeader=@IdNewDoc
  			insert into CTL_DOC_SECTION_MODEL ( IdHeader, DSE_ID, MOD_Name ) 
  				values( @IdNewDoc , 'TESTATA' , 'TEMPLATE_GARA_TESTATA_AVVISO' )
		end
	end
  END

  --TEMPLATE_GARA-ACCORDOQUADRO
  IF @tipodoc = 'TEMPLATE_GARA' AND ISNULL(@TipoSceltaContraente, '') = 'ACCORDOQUADRO'
  BEGIN
    DELETE FROM CTL_DOC_SECTION_MODEL
           WHERE DSE_ID = 'TESTATA' AND IdHeader = @IdNewDoc

    INSERT INTO CTL_DOC_SECTION_MODEL (IdHeader, DSE_ID, MOD_Name)
           VALUES (@IdNewDoc, 'TESTATA', 'TEMPLATE_GARA_TESTATA_ACCORDOQUADRO')
  END

  --BANDO_ASTA
  IF @tipodoc = 'BANDO_ASTA' OR ISNULL(@TipoProceduraCaratteristica, '') = 'RilancioCompetitivo'
  BEGIN
    DELETE FROM CTL_DOC_SECTION_MODEL
           WHERE DSE_ID = 'TESTATA' AND IdHeader = @IdNewDoc
  END

  /*AFFIDAMENTO DIRETTO oppure RICHIESTA DI PREVENTIVO*/
  IF @tipodoc = 'TEMPLATE_GARA' AND @ProceduraGara IN ('15583', '15479') AND @tipobandogara = '3'
  BEGIN
    DELETE FROM CTL_DOC_SECTION_MODEL
           WHERE DSE_ID = 'TESTATA'AND IdHeader = @IdNewDoc

    INSERT INTO CTL_DOC_SECTION_MODEL (IdHeader, DSE_ID, MOD_Name)
           VALUES (@IdNewDoc, 'TESTATA', 'TEMPLATE_GARA_TESTATA_GAREINFORMALI')
  END

  /*SE SUL CLIENTE NON E' ATTIVO attestazione_di_partecipazione setto a no il campo ClausolaFideiussoria sulla document_bando*/
  IF (dbo.PARAMETRI('ATTIVA_MODULO', 'attestazione_di_partecipazione', 'ATTIVA', 'YES', - 1) <> 'YES')
  BEGIN
    UPDATE document_bando
      SET ClausolaFideiussoria = '0'
      WHERE idHeader = @IdNewDoc
  END

  DECLARE @richiestaTED AS VARCHAR(10) = 'no'

  IF dbo.IsTedActive(@idAzi) = 1 AND @richiestaCIG = 'si'
  BEGIN
    -- Nel caso dell'appalto specifico, richiesta di offerta, richiesta di preventivo ed affidamento diretto il campo Invio GUUE in Testata deve essere nascosto oppure non selezionabile e bloccato su no
    IF @tipodoc = 'TEMPLATE_GARA'
      AND ISNULL(@TipoProceduraCaratteristica, '') = ''
      AND isnull(@ProceduraGara, '') NOT IN ('15583', '15479')
    BEGIN
      SET @richiestaTED = 'si'
    END
  END

  --TEMPLATE_GARA-AFFIDAMENTO DIRETTO SEMPLIFICATO
  IF @tipodoc = 'TEMPLATE_GARA'
    AND ISNULL(@TipoProceduraCaratteristica, '') = 'AffidamentoSemplificato'
  BEGIN
    DELETE FROM CTL_DOC_SECTION_MODEL
           WHERE DSE_ID = 'TESTATA'AND IdHeader = @IdNewDoc

    INSERT INTO CTL_DOC_SECTION_MODEL (IdHeader, DSE_ID, MOD_Name)
           VALUES (@IdNewDoc, 'TESTATA', 'TEMPLATE_GARA_TESTATA_AFFIDAMENTISEMPLIFICATI')
  END

  UPDATE document_bando
    SET RichiestaTED = @richiestaTED
    WHERE idHeader = @IdNewDoc

  -- vede se deve rendere editabile il fascicolo
  -- è non editabile solo se è attivo il genera fascicolo per quel documento-AOO
  DECLARE @contesto VARCHAR(500)
  DECLARE @sottoTipo VARCHAR(500)
  DECLARE @noteditable VARCHAR(500)

  SET @noteditable = ''

  IF EXISTS (SELECT id
               FROM lib_dictionary WITH (NOLOCK)
               WHERE dzt_name = 'SYS_ATTIVA_PROTOCOLLO_GENERALE' AND dzt_valuedef = 'YES')
  BEGIN
    SET @contesto = dbo.GetContestoFascicolo(@tipoDoc, @IdNewDoc)

    IF isnull(@fascicoloGenerale, '') = ''
      AND EXISTS (SELECT id
                    FROM Document_protocollo_docER WITH (NOLOCK)
                    WHERE tipodoc = @tipoDoc
                          AND isnull(contesto, '') = @contesto /* and attivo = 1*/
                          AND deleted = 0
                          AND aoo = dbo.getAOO(@idPfuAOO)
                          AND generaFascicolo = 1
                 )
    BEGIN
      SET @noteditable = ' fascicoloSecondario '
    END
  END

  UPDATE Document_dati_protocollo
    SET noteditable = @noteditable
    WHERE idHeader = @IdNewDoc
END
GO
