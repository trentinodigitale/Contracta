USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_MAKE_MODULO_QUESTIONARIO_AMMINISTRATIVO]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[OLD_MAKE_MODULO_QUESTIONARIO_AMMINISTRATIVO] (@idDoc_QUESTIONARIO_AMMINISTRATIVO INT)
AS
BEGIN
  SET NOCOUNT ON;

  DECLARE @Template NVARCHAR(max)

  SET @Template = ''

  DECLARE @Descrizione NVARCHAR(max)
  DECLARE @DescrizioneEstesa NVARCHAR(max)
  DECLARE @JSonCampiObbligatori NVARCHAR(max)
  DECLARE @KeyRiga VARCHAR(500)
  DECLARE @KeyRigaSezione VARCHAR(500)
  DECLARE @Modello_Modulo VARCHAR(500)
  DECLARE @TipoRigaQuestionario VARCHAR(100)
  DECLARE @TipoParametroQuestionario VARCHAR(100)
  DECLARE @Tech_Info_Parametro NVARCHAR(max)
  DECLARE @DivSpiegazioneRelazione NVARCHAR(max)
  DECLARE @FlagSezioneAperta INT
  DECLARE @idx INT
  DECLARE @StrFilter_Domain AS VARCHAR(200)
  DECLARE @Sezionicondizionate AS NVARCHAR(max)
  DECLARE @JSon_Sezionicondizionate AS NVARCHAR(max)
  DECLARE @StrClassObblig AS VARCHAR(200)
  DECLARE @ChiaveUnivocaRiga AS VARCHAR(100)
  DECLARE @ChiaveSezione AS VARCHAR(100)
  DECLARE @FormatAllegato AS NVARCHAR(max)
  DECLARE @TipoFileAllegato AS NVARCHAR(max)
  DECLARE @StartTipoFile AS INT
  DECLARE @EndTipoFile AS INT
  DECLARE @Coda_Tech_Info_Parametro NVARCHAR(max)
  DECLARE @EsitoRiga AS NVARCHAR(max)
  DECLARE @TemplateScript AS NVARCHAR(max)
  DECLARE @TemplateCampiHidden AS NVARCHAR(max)
  DECLARE @crlf VARCHAR(10)

  SET @JSonCampiObbligatori = ''
  SET @JSon_Sezionicondizionate = ''
  SET @EsitoRiga = ''
  SET @TemplateScript = ''
  SET @TemplateCampiHidden = ''
  SET @crlf = '
'
  SET @Modello_Modulo = 'MODULO_QUESTIONARIO_AMMINISTRATIVO_' + cast(@idDoc_QUESTIONARIO_AMMINISTRATIVO AS VARCHAR(20))
  SET @FlagSezioneAperta = 0

  -------------------------------------------------------
  -- cancella una eventuale presenza prima di crearlo
  -------------------------------------------------------
  DELETE FROM CTL_Models WHERE [MOD_ID] = @Modello_Modulo

  DELETE FROM CTL_ModelAttributes WHERE [MA_MOD_ID] = @Modello_Modulo

  DELETE FROM CTL_ModelAttributeProperties WHERE [MAP_MA_MOD_ID] = @Modello_Modulo

  DELETE FROM CTL_Models WHERE [MOD_ID] = @Modello_Modulo + '_SAVE'

  DELETE FROM CTL_ModelAttributes WHERE [MA_MOD_ID] = @Modello_Modulo + '_SAVE'

  DELETE FROM CTL_ModelAttributeProperties WHERE [MAP_MA_MOD_ID] = @Modello_Modulo + '_SAVE'

  SET @Template = @Template + ''
  SET @idx = 0

  -------------------------------------------------------
  -- Ciclo sulle righe per la costruzione del modulo da compilare
  -------------------------------------------------------
  DECLARE CurSezioni CURSOR LOCAL STATIC
  FOR
  SELECT replace(P.KeyRiga, '.', '_'), P.TipoRigaQuestionario, P.Descrizione, P.DescrizioneEstesa, P.TipoParametroQuestionario, P.Tech_Info_Parametro, P.Sezionicondizionate
         , P.ChiaveUnivocaRiga, S.ChiaveUnivocaRiga AS ChiaveSezione, P.EsitoRiga
  FROM [dbo].[Document_Questionario_Amministrativo] P WITH (NOLOCK)
       INNER JOIN [dbo].[Document_Questionario_Amministrativo] S WITH (NOLOCK) ON S.idHeader = P.idHeader
         AND S.TipoRigaQuestionario = 'Sezione'
         AND S.KeyRiga = dbo.getPos(P.Keyriga, '.', 1)
  WHERE P.idHeader = @idDoc_QUESTIONARIO_AMMINISTRATIVO
  ORDER BY P.[idrow]

  OPEN CurSezioni

  FETCH NEXT
  FROM CurSezioni
  INTO @KeyRiga, @TipoRigaQuestionario, @Descrizione, @DescrizioneEstesa, @TipoParametroQuestionario, @Tech_Info_Parametro, @Sezionicondizionate, @ChiaveUnivocaRiga, @ChiaveSezione, @EsitoRiga

  WHILE @@FETCH_STATUS = 0
  BEGIN
    -------------------------------------------------------
    -- SEZIONE
    -------------------------------------------------------
    IF @TipoRigaQuestionario = 'Sezione'
    BEGIN
      -- se c'è una sezione precedente devo chiudere la DIV
      IF @FlagSezioneAperta = 1
        SET @Template = @Template + '</div>' + @crlf
      -- se è presente una relazione
      SET @DivSpiegazioneRelazione = ''

      IF isnull(@EsitoRiga, '') <> ''
      BEGIN
        --recupero il contenuto del tag title dell'immagine di info
        SET @DivSpiegazioneRelazione = isnull(@EsitoRiga, '')
        SET @DivSpiegazioneRelazione = replace(@DivSpiegazioneRelazione, '<br>', '')
        SET @DivSpiegazioneRelazione = dbo.GetPos(@DivSpiegazioneRelazione, '<img src="../images/Domain/state_info24x24.png" title="', 2)
        SET @DivSpiegazioneRelazione = replace(@DivSpiegazioneRelazione, '">', '')
      END

      -- Descrizione sintetica
      SET @Template = @Template + @crlf + '<!-- Apertura Sezione ' + @KeyRiga + ' -->' + @crlf + '<div class="col-md-12 ModuloQuestionarioSectionOpen">
            <div class="row ModuloQuestionarioSectionDescription_Print">
							<div class="col-md-1 ModuloQuestionarioSectionTitle" >Sezione ' + @KeyRiga + '</div>
              <div class="col-md-11"> 
                <hr class="ModuloQuestionarioHr">
              </div>
            </div>'
				--<div class="col-md-1 ModuloQuestionarioSectionTitle" >' + @Descrizione + '</div>


      IF @DivSpiegazioneRelazione != ''
      BEGIN
           SET @Template = @Template + '<div class="row col-md-11 ModuloQuestionarioConditionedSection" >' + @DivSpiegazioneRelazione + '</div>'
      END
           
      SET @Template = @Template + '</div>' -- Si chiude la prima <div> di apertura

      SET @FlagSezioneAperta = 1 -- segno che la sezione è aperta e dopo deve essere chiusa
      -- contenitore della sezione per consentire di nasconderla se relazionata
      SET @Template = @Template + '<div id="SEZIONE_' + @ChiaveUnivocaRiga + '" class="col-md-10 ModuloQuestionarioParameterNoteContainer">' + @crlf

      ---- descrizione estesa se presente
      --IF @DescrizioneEstesa <> ''
      --  SET @Template = @Template + '	<div class="DescrizioneEstesaSezione"> ' + replace(dbo.HTML_Encode(@DescrizioneEstesa), @crlf, '<br />') + '</div>' + @crlf

     SET @Template = @Template + '	<div class="DescrizioneEstesaSezione"> ' + replace(dbo.HTML_Encode(@Descrizione), @crlf, '<br />') + '</div>' + @crlf
    END

    -------------------------------------------------------
    -- NOTE
    -------------------------------------------------------
    IF @TipoRigaQuestionario = 'Nota'
    BEGIN
      SET @Template = @Template + '<div class="row rowParameterNote">' -- apre la div esterna

      -- Descrizione sintetica
      SET @Template = @Template + '<div class="ModuloQuestionarioNote">' + replace(@KeyRiga, '_', '.') + ' ' + @Descrizione + '</div>' + @crlf

      -- descrizione estesa se presente
      IF @DescrizioneEstesa <> ''
      BEGIN
        SET @Template = @Template + '	<div class="ModuloQuestionarioNoteDescription"> ' + replace(dbo.HTML_Encode(@DescrizioneEstesa), @crlf, '<br />') + '</div>'
      END

      SET @Template = @Template + '</div>' + @crlf -- chiude la div esterna

    END

    -------------------------------------------------------
    -- PARAMETRO
    -------------------------------------------------------
    IF @TipoRigaQuestionario = 'Parametro'
    BEGIN
      SET @StrClassObblig = ''

      -- se il parametro è obbligatorio
      IF charindex('"obbligatorio":true', @Tech_Info_Parametro) > 0
      BEGIN
        --insert into CTL_ModelAttributeProperties ( MAP_MA_MOD_ID, MAP_MA_DZT_Name, MAP_Propety, MAP_Value, MAP_Module ) 
        --	select @Modello_Modulo as MA_MOD_ID, 'PARAMETRO_' + @KeyRiga  as MA_DZT_Name, 'Obbligatory' as MAP_Propety , '1' as MAP_Value ,'TEMPLATE_GARA' as MA_Module
        -- elenco campi obbligatori
        SET @JSonCampiObbligatori = @JSonCampiObbligatori + 'PARAMETRO_' + @KeyRiga + '@@@' + @ChiaveSezione + ','
        SET @StrClassObblig = ' obb '
      END

      -- Descrizione sintetica
      SET @Template = @Template + '<div class="row rowParameterNote" ><div class="col-md-8" > <div class="col-md-12 Questionario_Parametro_Titolo' + @StrClassObblig + '">' + replace(@KeyRiga, '_', '.') + ' ' + @Descrizione + '</div>' + @crlf

      -- descrizione estesa se presente
      IF @DescrizioneEstesa <> ''
        SET @Template = @Template + '	<div class="col-md-12 Questionario_Parametro_Descrizione"> ' + replace(dbo.HTML_Encode(@DescrizioneEstesa), @crlf, '<br />') + '</div>' + @crlf
      SET @Template = @Template + '</div>' -- chiude la div interna
      SET @Template = @Template + '	<div class="col-md-4">(((PARAMETRO_' + @KeyRiga + ')))</div>' + @crlf
      SET @Template = @Template + '</div>' -- chiude la div esterna

      -------------------------------------------------------
      -- inserisce il record per la creazione del modello
      -------------------------------------------------------
      SET @idx = @idx + 1

      INSERT INTO CTL_ModelAttributes (MA_MOD_ID, MA_DZT_Name, MA_DescML, MA_Pos, MA_Len, MA_Order, DZT_Type, DZT_DM_ID, DZT_DM_ID_Um, DZT_Len, DZT_Dec, DZT_Format, DZT_Help
                                       , DZT_Multivalue, MA_Module)
      SELECT @Modello_Modulo AS MA_MOD_ID, 'PARAMETRO_' + @KeyRiga AS MA_DZT_Name, '' AS MA_DescML, @idx AS MA_Pos, /*dz.DZT_Len*/ 0 AS MA_Len, @idx AS MA_Order, dz.DZT_Type
             , dz.DZT_DM_ID, dz.DZT_DM_ID_Um, 0 AS /*dz.*/ DZT_Len, dz.DZT_Dec, dz.DZT_Format, dz.DZT_Help, dz.DZT_Multivalue, 'TEMPLATE_GARA' AS MA_Module
      FROM LIB_Dictionary dz WITH (NOLOCK)
      WHERE dz.DZT_Name = 'PARAMETRO_QUESTIONARIO_' + @TipoParametroQuestionario

      -- se parametro TESTO aggiungo il "massimo numero caratteri" sulla proprietà MaxLen della CTL_ModelAttributeProperties
      IF @TipoParametroQuestionario IN ('Testo')
      BEGIN
        DECLARE @StartMaxNumeroCaratteri AS INT = CHARINDEX('"MaxNumeroCaratteri":"', @Tech_Info_Parametro)

        -- aggiungo la Width di 100% per i campi testo
        INSERT INTO CTL_ModelAttributeProperties (MAP_MA_MOD_ID, MAP_MA_DZT_Name, MAP_Propety, MAP_Value, MAP_Module)
          SELECT @Modello_Modulo AS MA_MOD_ID, 'PARAMETRO_' + @KeyRiga AS MA_DZT_Name, 'Style' AS MAP_Propety, 'width_100_percent' AS MAP_Value, 'TEMPLATE_GARA' AS MA_Module

        IF @StartMaxNumeroCaratteri > 0
        BEGIN
          SET @StartMaxNumeroCaratteri = @StartMaxNumeroCaratteri + 22
          SET @Coda_Tech_Info_Parametro = SUBSTRING(@Tech_Info_Parametro, @StartMaxNumeroCaratteri, LEN(@Tech_Info_Parametro))

          DECLARE @EndMaxNumeroCaratteri AS INT = CHARINDEX('"', @Coda_Tech_Info_Parametro)
          DECLARE @MaxNumeroCaratteri AS VARCHAR(50)

          SET @MaxNumeroCaratteri = SUBSTRING(@Tech_Info_Parametro, @StartMaxNumeroCaratteri, @EndMaxNumeroCaratteri - 1)

          --UPDATE Document_Questionario_Amministrativo
          --SET Tech_Info_Parametro = '{"obbligatorio":true,"tipoParametro":"Testo","row":"0","MaxNumeroCaratteri":"00765"}'
          --WHERE idHeader = 470716 AND KeyRiga=4.1

          IF @MaxNumeroCaratteri <> ''
          BEGIN
            INSERT INTO CTL_ModelAttributeProperties (MAP_MA_MOD_ID, MAP_MA_DZT_Name, MAP_Propety, MAP_Value, MAP_Module)
              SELECT @Modello_Modulo AS MA_MOD_ID, 'PARAMETRO_' + @KeyRiga AS MA_DZT_Name, 'MaxLen' AS MAP_Propety, @MaxNumeroCaratteri AS MAP_Value, 'TEMPLATE_GARA' AS MA_Module

            --UPDATE Document_Questionario_Amministrativo
            --SET Tech_Info_Parametro = '{"obbligatorio":true,"tipoParametro":"Testo","row":"0","MaxNumeroCaratteri":"12890"}'
            --WHERE idHeader = 470716 AND KeyRiga=4.1
          END
        END
      END

      -- se parametro scelta singola/multipla aggiungo il filtro sul dominio
      IF @TipoParametroQuestionario IN ('sceltasingola', 'sceltamultipla')
      BEGIN
        SET @StrFilter_Domain = ''
        SET @StrFilter_Domain = 'SQL_WHERE= IdHeader = ' + cast(@idDoc_QUESTIONARIO_AMMINISTRATIVO AS VARCHAR(100)) + ' and DMV_Father =''' + replace(@KeyRiga, '_', '.') + ''''

        INSERT INTO CTL_ModelAttributeProperties (MAP_MA_MOD_ID, MAP_MA_DZT_Name, MAP_Propety, MAP_Value, MAP_Module)
        SELECT @Modello_Modulo AS MA_MOD_ID, 'PARAMETRO_' + @KeyRiga AS MA_DZT_Name, 'Filter' AS MAP_Propety, @StrFilter_Domain AS MAP_Value, 'TEMPLATE_GARA' AS MA_Module

        --per i paraemtri a scelta multipla inserisco la format OMA
        IF @TipoParametroQuestionario = 'sceltamultipla'
        BEGIN
          INSERT INTO CTL_ModelAttributeProperties (MAP_MA_MOD_ID, MAP_MA_DZT_Name, MAP_Propety, MAP_Value, MAP_Module)
          SELECT @Modello_Modulo AS MA_MOD_ID, 'PARAMETRO_' + @KeyRiga AS MA_DZT_Name, 'Format' AS MAP_Propety, 'OMAE99' AS MAP_Value, 'TEMPLATE_GARA' AS MA_Module
        END

        --per i paraemtri a scelta singola inserisco la format OA: questo cambia da una rapresentazione grafica come drop down in radio buttons
        --IF @TipoParametroQuestionario = 'sceltasingola'
        --BEGIN
        --  INSERT INTO CTL_ModelAttributeProperties (MAP_MA_MOD_ID, MAP_MA_DZT_Name, MAP_Propety, MAP_Value, MAP_Module)
        --  SELECT @Modello_Modulo AS MA_MOD_ID, 'PARAMETRO_' + @KeyRiga AS MA_DZT_Name, 'Format' AS MAP_Propety, 'OA' AS MAP_Value, 'TEMPLATE_GARA' AS MA_Module
        --END

        --se ci sono SezioniCondizionate sul parametro aggiorno la stringa che tiene elenco dei paraemtri che inflenzano
        --sezioni
        IF @Sezionicondizionate <> ''
        BEGIN
          SET @JSon_Sezionicondizionate = @JSon_Sezionicondizionate + 'PARAMETRO_' + @KeyRiga + ':' + @Sezionicondizionate + ','
        END
      END

      --per tutti i parametri aggiungo una funzione di onchange che serve a farmi capire che ho fatto un cambiamento
      --sul Modulo Questionario Amministrativo 
      INSERT INTO CTL_ModelAttributeProperties (MAP_MA_MOD_ID, MAP_MA_DZT_Name, MAP_Propety, MAP_Value, MAP_Module)
      SELECT @Modello_Modulo AS MA_MOD_ID, 'PARAMETRO_' + @KeyRiga AS MA_DZT_Name, 'OnChange' AS MAP_Propety, 'OnChangeFields_QUESTIONARIO(this);' AS MAP_Value, 'TEMPLATE_GARA' AS MA_Module

      --per i parametri di tipo allegato devo aggiungere la format con le estensioni ammesse
      IF @TipoParametroQuestionario IN ('Allegato', 'AllegatoFirmato')
      BEGIN
        --setto la format minima
        SET @FormatAllegato = 'INT'

        --se allegato firmato aggiungo la V
        IF @TipoParametroQuestionario = 'AllegatoFirmato'
        BEGIN
          SET @FormatAllegato = @FormatAllegato + 'V'
        END

        --se ci sono estensioni ammesse le accodo alla format
        SET @StartTipoFile = 0
        SET @EndTipoFile = 0
        SET @TipoFileAllegato = ''
        SET @StartTipoFile = CHARINDEX('"TipoFile_Value":', @Tech_Info_Parametro)

        IF @StartTipoFile > 0
        BEGIN
          SET @Coda_Tech_Info_Parametro = SUBSTRING(@Tech_Info_Parametro, @StartTipoFile, LEN(@Tech_Info_Parametro))
          SET @EndTipoFile = CHARINDEX(',', @Coda_Tech_Info_Parametro)

          IF @EndTipoFile > 0
          BEGIN
            SET @TipoFileAllegato = SUBSTRING(@Tech_Info_Parametro, @StartTipoFile + 18, @EndTipoFile - (18 + 2))

            --se ci sono estensioni ammesse
            IF @TipoFileAllegato <> ''
            BEGIN
              SET @FormatAllegato = @FormatAllegato + 'EXT:' + SUBSTRING(REPLACE(@TipoFileAllegato, '###', ','), 2, len(REPLACE(@TipoFileAllegato, '###', ',')) - 2) + '-'
            END
          END
        END

        --aggiungo la format per gli allegati
        INSERT INTO CTL_ModelAttributeProperties (MAP_MA_MOD_ID, MAP_MA_DZT_Name, MAP_Propety, MAP_Value, MAP_Module)
          SELECT @Modello_Modulo AS MA_MOD_ID, 'PARAMETRO_' + @KeyRiga AS MA_DZT_Name, 'Format' AS MAP_Propety, @FormatAllegato AS MAP_Value, 'TEMPLATE_GARA' AS MA_Module
        
        -- aggiungo la Width di 100% per i campi allegato
        INSERT INTO CTL_ModelAttributeProperties (MAP_MA_MOD_ID, MAP_MA_DZT_Name, MAP_Propety, MAP_Value, MAP_Module)
          SELECT @Modello_Modulo AS MA_MOD_ID, 'PARAMETRO_' + @KeyRiga AS MA_DZT_Name, 'Style' AS MAP_Propety, 'width_100_percent' AS MAP_Value, 'TEMPLATE_GARA' AS MA_Module
      END
    END

    FETCH NEXT
    FROM CurSezioni
    INTO @KeyRiga, @TipoRigaQuestionario, @Descrizione, @DescrizioneEstesa, @TipoParametroQuestionario, @Tech_Info_Parametro, @Sezionicondizionate, @ChiaveUnivocaRiga, @ChiaveSezione, @EsitoRiga
  END

  CLOSE CurSezioni

  DEALLOCATE CurSezioni

  -- chiudo l'html dell'ultima sezione
  IF @FlagSezioneAperta = 1
    SET @Template = @Template + '</div>' + @crlf
  SET @TemplateScript = @TemplateScript + '<script type="text/javascript">'

  --aggiungo in javascript le due variabili per gli obbligatori e per le sezioni condizionate
  IF @JSonCampiObbligatori <> ''
  BEGIN
    --tolgo ultima virgola
    SET @JSonCampiObbligatori = LEFT(@JSonCampiObbligatori, len(@JSonCampiObbligatori) - 1)
  END

  SET @TemplateScript = @TemplateScript + 'var JsonCampiObbligatori = ''' + @JSonCampiObbligatori + ''';' + @crlf
  SET @TemplateCampiHidden = @TemplateCampiHidden + '<input type="hidden" id="ModuloQuestionario_Obbligatori" name="ModuloQuestionario_Obbligatori" value="' + @JSonCampiObbligatori + '">'

  IF @JSon_Sezionicondizionate <> ''
  BEGIN
    --tolgo ultima virgola
    SET @JSon_Sezionicondizionate = LEFT(@JSon_Sezionicondizionate, len(@JSon_Sezionicondizionate) - 1)
  END

  SET @TemplateScript = @TemplateScript + 'var JSon_Sezionicondizionate = ''' + replace(@JSon_Sezionicondizionate, '''', '\''') + ''';'
  SET @TemplateCampiHidden = @TemplateCampiHidden + '<input type="hidden" id="ModuloQuestionario_SezioniCondizionate" name="ModuloQuestionario_SezioniCondizionate" value="' + replace(@JSon_Sezionicondizionate, '"', '""') + '">'
  SET @TemplateScript = @TemplateScript + '</script>'
  SET @Template = @TemplateScript + @TemplateCampiHidden + @Template

  -----------------------
  -- creo il modello agganciando il template appena creato
  -----------------------
  -- crea il modello di salvataggio e rappresentazione
  INSERT INTO CTL_Models (MOD_ID, MOD_Name, MOD_DescML, MOD_Type, MOD_Sys, MOD_help, MOD_Param, MOD_Module, MOD_Template)
  SELECT @Modello_Modulo AS MOD_ID, @Modello_Modulo AS MOD_Name, @Modello_Modulo AS MOD_DescML, 1 AS MOD_Type, 1 AS MOD_Sys, '' AS MOD_help
    , 'Type=posizionale&DrawMode=1&NumberColumn=2&Path=../../&PathImage=../../CTL_Library/images/Domain/' AS MOD_Param, 'TEMPLATE_GARA' AS MOD_Module, @Template AS MOD_Template

  ---- creare il campo del modello che contiene tutti i campi obbligatori
  --set @idx = @idx  + 1
  --insert into CTL_ModelAttributes ( MA_MOD_ID, MA_DZT_Name, MA_DescML, MA_Pos, MA_Len, MA_Order , DZT_Type, DZT_DM_ID, DZT_DM_ID_Um, DZT_Len, DZT_Dec, DZT_Format, DZT_Help, DZT_Multivalue, MA_Module ) 
  --	select @Modello_Modulo as MA_MOD_ID, 'PARAMETRO_' + @KeyRiga as MA_DZT_Name, '' as MA_DescML, @idx as MA_Pos,  0  as   MA_Len, @idx as MA_Order, 
  --				dz.DZT_Type, 
  --				dz.DZT_DM_ID, 
  --				dz.DZT_DM_ID_Um, 0 as /*dz.*/ DZT_Len,  dz.DZT_Dec,
  --				dz.DZT_Format,
  --				dz.DZT_Help, dz.DZT_Multivalue, 
  --				'TEMPLATE_GARA' as MA_Module
  --		from LIB_Dictionary dz with(nolock)  
  --		where dz.DZT_Name = 'PARAMETRO_QUESTIONARIO_' + @TipoParametroQuestionario
  --insert into CTL_ModelAttributeProperties ( MAP_MA_MOD_ID, MAP_MA_DZT_Name, MAP_Propety, MAP_Value, MAP_Module ) 
  --	select @Modello_Modulo as MA_MOD_ID, 'PARAMETRO_' + @KeyRiga  as MA_DZT_Name, 'Hide' as MAP_Propety , '1' as MAP_Value ,'TEMPLATE_GARA' as MA_Module

  
  ---------------------------------------------------------------------------------------------
  -- MODELLO PER IL SALVATAGGIO
  -- genero il modello per copia dalla visualizzazione togliendo tutti gli attributi non editabili
  ---------------------------------------------------------------------------------------------
  INSERT INTO CTL_Models (MOD_ID, MOD_Name, MOD_DescML, MOD_Type, MOD_Sys, MOD_help, MOD_Param, MOD_Module, MOD_Template)
    SELECT @Modello_Modulo + '_SAVE' AS MOD_ID, @Modello_Modulo + '_SAVE' AS MOD_Name, @Modello_Modulo + '_SAVE' AS MOD_DescML, 1 AS MOD_Type, 1 AS MOD_Sys, '' AS MOD_help
           , '' AS MOD_Param, 'TEMPLATE_GARA' AS MOD_Module, @Template AS MOD_Template

  INSERT INTO CTL_ModelAttributes (MA_MOD_ID, MA_DZT_Name, MA_DescML, MA_Pos, MA_Len, MA_Order, DZT_Type, DZT_DM_ID, DZT_DM_ID_Um, DZT_Len, DZT_Dec, DZT_Format, DZT_Help
                                   , DZT_Multivalue, MA_Module)
    SELECT MA_MOD_ID + '_SAVE', MA_DZT_Name, MA_DescML, MA_Pos, MA_Len, MA_Order, DZT_Type, DZT_DM_ID, DZT_DM_ID_Um, DZT_Len, DZT_Dec, DZT_Format, DZT_Help, DZT_Multivalue, MA_Module
    FROM CTL_ModelAttributes WITH (NOLOCK)
    WHERE MA_MOD_ID = @Modello_Modulo

  --aggiungo nei modelli i campi per gli attributi obbligatori e le sezioni condizionate 
  INSERT INTO CTL_ModelAttributes (MA_MOD_ID, MA_DZT_Name, MA_DescML, MA_Pos, MA_Len, MA_Order, DZT_Type, DZT_DM_ID, DZT_DM_ID_Um, DZT_Len, DZT_Dec, DZT_Format, DZT_Help
                                   , DZT_Multivalue, MA_Module)
    SELECT @Modello_Modulo + '_SAVE' AS MA_MOD_ID, DZT_Name, '' AS MA_DescML, 100 AS MA_Pos, /*dz.DZT_Len*/ 0 AS MA_Len, 100 AS MA_Order, dz.DZT_Type, dz.DZT_DM_ID, dz.DZT_DM_ID_Um
           , 0 AS /*dz.*/ DZT_Len, dz.DZT_Dec, dz.DZT_Format, dz.DZT_Help, dz.DZT_Multivalue, 'TEMPLATE_GARA' AS MA_Module
    FROM LIB_Dictionary dz WITH (NOLOCK)
    WHERE dz.DZT_Name IN ('ModuloQuestionario_Obbligatori', 'ModuloQuestionario_SezioniCondizionate')

  INSERT INTO CTL_ModelAttributes (MA_MOD_ID, MA_DZT_Name, MA_DescML, MA_Pos, MA_Len, MA_Order, DZT_Type, DZT_DM_ID, DZT_DM_ID_Um, DZT_Len, DZT_Dec, DZT_Format, DZT_Help
                                   , DZT_Multivalue, MA_Module)
    SELECT @Modello_Modulo AS MA_MOD_ID, DZT_Name, 'ModuloQuestionario_Obbligatori' AS MA_DescML, 100 AS MA_Pos, /*dz.DZT_Len*/ 0 AS MA_Len, 100 AS MA_Order, dz.DZT_Type
           , dz.DZT_DM_ID, dz.DZT_DM_ID_Um, 0 AS /*dz.*/ DZT_Len, dz.DZT_Dec, dz.DZT_Format, dz.DZT_Help, dz.DZT_Multivalue, 'TEMPLATE_GARA' AS MA_Module
    FROM LIB_Dictionary dz WITH (NOLOCK)
    WHERE dz.DZT_Name IN ('ModuloQuestionario_Obbligatori', 'ModuloQuestionario_SezioniCondizionate')
END
GO
