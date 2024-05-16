USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[SP_NUOVO_TEMPLATE_GARA_SAVE]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SP_NUOVO_TEMPLATE_GARA_SAVE] (@idDoc INT, @idUser INT)
AS
BEGIN
  -- *** INIZIO cambio jumpcheck per aprire il bando	
  DECLARE @tb VARCHAR(50)
  DECLARE @pg VARCHAR(50)
  DECLARE @richiestaCIG VARCHAR(10)
  DECLARE @idAzi INT
  DECLARE @Lista_Enti_abilitati_RCig AS VARCHAR(4000)
  DECLARE @EvidenzaPubblica_Parametro AS VARCHAR(10)
  declare @TipoProceduraCaratteristica as varchar(10)
  SET @richiestaCIG = 'si'

  SELECT @idazi = pfuidazi
  FROM profiliutente WITH (NOLOCK)
  WHERE idpfu = @idUser

  SELECT @pg = ProceduraGara
    , @tb = TipoBandoGara
	, @TipoProceduraCaratteristica = isnull(TipoProceduraCaratteristica,'')
  FROM document_bando WITH (NOLOCK)
  WHERE idheader = @IdDoc

  UPDATE ctl_doc
  SET jumpCheck = 'OK', deleted = 0
  WHERE id = @IdDoc

  --IF (@tb = '1'AND @pg = '15478') -- SE ( Avviso - Negoziata ) 
  --  OR (@tb = '2'AND @pg = '15477') --  SE  ( Bando - Ristretta )
  --  OR (@tb IN ('4', '5') AND @pg = '15583') -- avviso di un affidamento a 2 fasi
  --  OR (dbo.attivoSimog() = 0) --SE NON ATTIVO IL SIMOG
  --BEGIN
  --  SET @richiestaCIG = 'no'
  --END

  ----se azienda corrente non è tra gli enti abilitati setto @richiestaCIG a no
  --SELECT @Lista_Enti_abilitati_RCig = dbo.PARAMETRI('GROUP_SIMOG', 'ENTI_ABILITATI', 'DefaultValue', '', - 1)

  --IF @Lista_Enti_abilitati_RCig <> '' AND CHARINDEX(',' + cast(@idazi AS VARCHAR(20)) + ',', ',' + @Lista_Enti_abilitati_RCig + ',') = 0
  --  SET @richiestaCIG = 'no'

  --UPDATE document_bando
  --SET GeneraConvenzione = '0', RichiestaCigSimog = @richiestaCIG
  --WHERE idheader = @IdDoc AND ISNULL(CIG, '') = ''
  -- *** FINE cambio jumpcheck per aprire il bando	

  ---- *** INIZIO se RDO allora setto ListaAlbi con unico bando istitutivo me
  --	declare @ListaAlbi as varchar(500)
  --	if exists(select * from document_bando WITH (NOLOCK) where idheader = @IdDoc and TipoProceduraCaratteristica='RDO')
  --	begin
  --		select top 1 @ListaAlbi=cast(id as varchar(50)) from ctl_doc WITH (NOLOCK) where tipodoc='BANDO' and StatoFunzionale = 'Pubblicato' and StatoDoc = 'Sended' and deleted=0 and isnull(jumpcheck,'')='' order by id desc
  --		update document_bando set ListaAlbi = '###' + @ListaAlbi + '###'
  --			where idheader = @IdDoc
  --	end
  --	if exists(select * from document_bando WITH (NOLOCK) where idheader = @IdDoc and TipoProceduraCaratteristica='Cottimo')
  --	begin
  --		select top 1 @ListaAlbi=cast(id as varchar(50)) from ctl_doc WITH (NOLOCK) where tipodoc='BANDO' and StatoFunzionale = 'Pubblicato' and StatoDoc = 'Sended' and deleted=0 and isnull(jumpcheck,'')='BANDO_ALBO_LAVORI' order by id desc
  --		update document_bando set ListaAlbi = '###' + @ListaAlbi + '###'
  --			where idheader = @IdDoc
  --	end
  ---- *** FINE se RDO allora setto ListaAlbi con unico bando istitutivo me

  ---- *** INIZIO Se non presente aggiungo il record nella Document_dati_protocollo 
  	--if not exists(select * from Document_dati_protocollo WITH (NOLOCK) where idheader = @IdDoc)
  	--begin
  	--		 insert into Document_dati_protocollo ( idHeader)
  	--			values (  @IdDoc )
  	--end
  ---- ***FINE Se non presente aggiungo il record nella Document_dati_protocollo

  --se si tratta di RDO setto GEneraConvenzione=0 (che è il default nel modello dinamico relativo)
  if @TipoProceduraCaratteristica='RDO'
  begin
	update document_bando set GeneraConvenzione = '0'  WHERE idheader = @idDoc
  end

  -- *** INIZIO Sostituisco il modello per la testa per utilizzare quello più adeguato per il tipo di procedura
  EXEC TEMPLATE_GARA_DEFINIZIONE_STRUTTURA @idDoc, - 1, @idazi

  -- *** FINE Sostituisco il modello per la testa per utilizzare quello più adeguato per il tipo di procedura

  -- *** INIZIO Porto la versione del documento a 2 per gestire le formule economiche multiple
  UPDATE ctl_doc
  SET Versione = '2'
  WHERE id = @idDoc
  -- *** FINE Porto la versione del documento a 2 per gestire le formule economiche multiple

  -- *** INIZIO se criterio aggiudicazione gara è Offerta Economicamente più vantaggiosa setta la conformità a no
  --se criterio aggiudicazione gara è Offerta Economicamente più vantaggiosa o COSTO FISSO setta la conformità a no
  UPDATE document_bando
  SET Conformita = 'No'
  WHERE idheader = @idDoc AND CriterioAggiudicazioneGara IN ('15532', '25532')

  -- *** FINE se criterio aggiudicazione gara è Offerta Economicamente più vantaggiosa setta la conformità a no

  -- ** INIZIO Se l'utente collegato non fa parte dell'azimaster, setto un default per l'IdentificativoIniziativa
  IF NOT EXISTS (SELECT idpfu
                 FROM profiliutente WITH (NOLOCK)
                 WHERE idpfu = @idUser AND pfuIdAzi = 35152001)
  BEGIN
    UPDATE document_bando
    SET IdentificativoIniziativa = '9999'
    WHERE idheader = @idDoc
  END
  -- *** FINE Se l'utente collegato non fa parte dell'azimaster, setto un default per l'IdentificativoIniziativa

  -- *** INIZO Setta EnteProponente e RUPProponente	
  DECLARE @enteprop NVARCHAR(MAX)
  SET @enteprop = ''

  SELECT @enteprop = cast(pfuidazi AS VARCHAR(50))
  FROM ProfiliUtente WITH (NOLOCK)
  WHERE IdPfu = @idUser

  --valorizzo @idUser se posso essere RupProponente altrimenti vuoto
  IF NOT EXISTS (
      SELECT DMV_COD
      FROM ELENCO_RESPONSABILI_AZI WITH (NOLOCK)
      WHERE RUOLO IN ('RUP', 'RUP_PDG')
            AND idpfu = (SELECT TOP 1 idpfu
                         FROM ProfiliUtente WITH (NOLOCK)
                         WHERE pfuIdAzi = @enteprop)
            AND DMV_Cod = @idUser)
  BEGIN
    SET @idUser = 0
  END

  UPDATE document_bando
  SET EnteProponente = @enteprop + '#\0000\0000'
      , RupProponente = @idUser
  WHERE idheader = @idDoc
  -- *** FINE Setta EnteProponente e RUPProponente

  --recupero @EvidenzaPubblica_Parametro dai parametri
  --se si tratta di un invito (TipoBandoGara=3)
  SELECT @EvidenzaPubblica_Parametro = dbo.PARAMETRI('NUOVA_PROCEDURA-SAVE:INVITO', 'EvidenzaPubblica', 'DefaultValue', 'NULL', - 1)

  IF @EvidenzaPubblica_Parametro <> 'NULL' AND @tb = '3'
  BEGIN
    UPDATE Document_Bando
    SET EvidenzaPubblica = @EvidenzaPubblica_Parametro
    WHERE idheader = @idDoc
  END
END
GO
