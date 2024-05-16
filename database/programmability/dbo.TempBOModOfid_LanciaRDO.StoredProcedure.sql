USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[TempBOModOfid_LanciaRDO]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[TempBOModOfid_LanciaRDO] (@IdMdl INT) AS
 
 CREATE TABLE #RdoToLaunch (
  [mazProg] smallint IDENTITY (1, 1) NOT NULL 
   CONSTRAINT [PK_RdoToLaunch] PRIMARY KEY  NONCLUSTERED ,
  [mazIdMdl] INT NULL ,
  [mazIdAzi] INT NULL ,
  [mazProtocollo] NVARCHAR(12) NULL ,
  [mazDataInvio] DATETIME,
  [mazIdOff] INT NULL)
 DECLARE @NumeroRdo INT
 DECLARE @CurIdPfu INT
 DECLARE @CurIdAzi INT
 DECLARE @CurProt INT
 DECLARE @CurProg INT
 DECLARE @CurStrProt NVARCHAR(12)
 DECLARE @TotRdo INT
 DECLARE @SedeOpLw INT
 DECLARE @SedeOpUp INT
 DECLARE @IdPfuSel INT
 DECLARE @CurIdAziSel INT
 DECLARE @CurIdOff INT
 DECLARE @CurIdOar INT
 DECLARE @CurIdVat INT
 DECLARE @O_IdMar INT
 DECLARE @O_marIdArt INT
 DECLARE @I_macIdMcl INT
 DECLARE @I_mclShadow bit
 DECLARE @I_vatIdDzt INT
 DECLARE @I_vatTipoMem tinyint
 DECLARE @I_vatIdUms INT
 DECLARE @I_vatV1 INT
 DECLARE @I_vatV2 money
 DECLARE @I_vatV2_IdSdv INT
 DECLARE @I_vatV3 float
 DECLARE @I_vatV4 NVARCHAR(4000)
 DECLARE @I_vatV5 DATETIME
 DECLARE @I_vatV6_IdDsc INT
 DECLARE @I_vatV7 INT
 --Id Temporanei
 DECLARE @TIdOff INT
 DECLARE @TIdOar INT
 DECLARE @TIdVat INT
 SET @TIdOff = 1
 SET @TIdOar = 1
 SELECT @CurIdPfu = mdlIdPfu FROM TempModelli WHERE IdMdl = @IdMdl
 IF @CurIdPfu IS NULL
 BEGIN
  RAISERROR('Modello non elaborabile',16,-1)
  GOTO lblEnd
 END
 SELECT @CurIdAzi = pfuIdAzi, @CurStrProt = pfuPrefissoProt FROM ProfiliUtente WHERE IdPfu = @CurIdPfu
 SELECT @CurProt = aziProssimoProtRDO, @SedeOpLw = aziGphValueOper FROM Aziende WHERE IdAzi = @CurIdAzi
 SELECT @CurStrProt = @CurStrProt + ' ' + RIGHT('0000' + CAST( @CurProt AS NVARCHAR),4) + '/'
--Inserisce nella tabella temporanea tutte le aziende coinvolte nella ofid 
 INSERT #RdoToLaunch(mazProtocollo, mazIdAzi)
  SELECT DISTINCT @CurStrProt AS mazProtocollo, Articoli.artIdAzi AS mazIdAzi FROM Articoli
   INNER JOIN TempModelliArticoli ON TempModelliArticoli.marIdArt = Articoli.IdArt
   INNER JOIN TempModelliGruppi ON TempModelliGruppi.IdMgr = TempModelliArticoli.marIdMgr
   WHERE TempModelliGruppi.mgrIdMdl = @IdMdl
 SELECT @TotRdo = @@ROWCOUNT --Numero di RDO Lanciate
 IF @TotRdo = 0
 BEGIN
  RAISERROR('Nessun Articolo nella Ofid',16,-1)
  GOTO lblEnd
 END
--completa le informazioni dell'RDO con la data di lancioe il numero di protocollo (ABC 000X/00Y) 
 UPDATE #RdoToLaunch SET
  mazDataInvio = GETDATE(),
  mazProtocollo = mazProtocollo + RIGHT('000' + CAST( mazProg AS NVARCHAR), 3),
  mazIdMdl = @IdMdl
  
 SELECT @CurProg = 1
 BEGIN TRAN
 UPDATE Aziende SET aziProssimoProtRDO = aziProssimoProtRDO + 1 WHERE idAzi = @CurIdAzi
 UPDATE TempModelli SET mdlStato = 2 WHERE IdMdl = @IdMdl -- Ofid diventa non modificabile
 
--GOTO lblAllOk --Momentanea
 EXEC UpperRange @SedeOpLw, @SedeOpUp OUTPUT
 SET ANSI_WARNINGS OFF
 
 WHILE @CurProg <= @TotRdo
 BEGIN
  --Genera un'offerta per ogni RDO
  SELECT @CurIdAziSel = mazIdAzi FROM #RdoToLaunch WHERE mazProg = @CurProg --Azienda destinataria
  --Individua il seller che copre l'area geografica del buyer 
  SELECT @IdPfuSel = NULL
  SELECT DISTINCT TOP 1 @IdPfuSel = DfSPfuGph.IdPfu
   FROM DfSPfuGph 
   INNER JOIN ProfiliUtente ON ProfiliUtente.IdPfu = DfSPfuGph.IdPfu
   WHERE (DfSPfuGph.gphValue BETWEEN @SedeOpLw AND @SedeOpUp) AND
    ProfiliUtente.pfuIdAzi = @CurIdAziSel AND
    ProfiliUtente.pfuVenditore = 1 AND ProfiliUtente.pfuDeleted = 0
  IF @IdPfuSel IS NULL
  BEGIN
   -- In questo caso non vi sono venditori sull'area geografica selezionata
   -- oppure il venditore non ha selezionato un'area geografica
   -- L'offerta viene mandata al venditore pi" scarico
   SELECT TOP 1 @IdPfuSel = ProfiliUtente.IdPfu
   FROM ProfiliUtente
   LEFT OUTER JOIN RdoElaborate ON ProfiliUtente.IdPfu = RdoElaborate.IdPfu
   WHERE pfuIdAzi = @CurIdAziSel AND pfuVenditore = 1 AND pfuDeleted = 0
   ORDER BY RdoElaborate.NumeroRdo
   -- L'offerta viene mandata all'amministratore dell'azienda destinataria
   IF @IdPfuSel IS NULL
   BEGIN
     SELECT TOP 1 @IdPfuSel = IdPfu 
     FROM ProfiliUtente WHERE pfuIdAzi = @CurIdAziSel AND pfuAdmin = 1 AND pfuDeleted = 0
   END   
  END
  
  SELECT @TIdVat = MAX(IdVat) FROM TempValoriAttributi
  SET @TIdVat = @TIdVat + 1
  IF NOT (@IdPfuSel IS NULL)
  BEGIN
    --incrementa di uno il numero di Rdo Elaborate
    SELECT @NumeroRdo = NULL
    SELECT @NumeroRdo = RdoElaborate.NumeroRdo
    FROM RdoElaborate WHERE RdoElaborate.IdPfu = @IdPfuSel
    IF @NumeroRdo IS NULL
    BEGIN
      INSERT RdoElaborate(IdPfu,NumeroRdo) VALUES (@IdPfuSel,1)
    END
    IF NOT (@NumeroRdo IS NULL)
    BEGIN
      UPDATE RdoElaborate SET NumeroRdo = NumeroRdo + 1 
      WHERE IdPfu = @IdPfuSel 
    END
   INSERT TempOfferte(IdOff,offIdPfu, offIdMdl) VALUES (@TIdOff,@IdPfuSel,@IdMdl)
   SET @CurIdOff = @TIdOff
   SET @TIdOff = @TIdOff + 1
   --PRINT 'TIdOff: ' + CAST(@TIdOff AS NVARCHAR)
   
   UPDATE #RdoToLaunch SET mazIdOff = @CurIdOff WHERE mazProg = @CurProg
   -- Ora deve inserire il resto del modello
   --Apre un cursore con tutti gli articoli associati all'azienda corrente
   DECLARE MyCur_Outer CURSOR LOCAL FORWARD_ONLY STATIC READ_ONLY FOR
    SELECT TempModelliArticoli.IdMar,
     TempModelliArticoli.marIdArt
     FROM  TempModelliArticoli
      INNER JOIN TempModelliGruppi ON TempModelliGruppi.IdMgr = TempModelliArticoli.marIdMgr
      INNER JOIN Articoli ON Articoli.IdArt = TempModelliArticoli.marIdArt
     WHERE  (TempModelliGruppi.mgrIdMdl = @IdMdl) AND
      artIdAzi = @CurIdAziSel
     ORDER BY IdMar
   OPEN MyCur_Outer
   
   FETCH NEXT FROM MyCur_Outer INTO @O_IdMar, @O_marIdArt
   
   WHILE @@FETCH_STATUS = 0
   BEGIN
    -- Operazioni ciclo Outer (articoli)
    -- Inserisce in OfferteArticoli
    INSERT TempOfferteArticoli(IdOar,oarIdOff,oarIdArt) VALUES(@TIdOar,@CurIdOff,@O_marIdArt)
    SELECT @CurIdOar = @TIdOar
    SET @TIdOar = @TIdOar + 1
    --PRINT 'TIdOar: ' + CAST(@TIdOar AS NVARCHAR)
    -- Fine cilo Outer
    --Ora prendiamo gli attributi (una riga di attributi)
    DECLARE MyCur_Inner CURSOR LOCAL FORWARD_ONLY STATIC READ_ONLY FOR
    SELECT TempModelliArticoliXColonne.macIdMcl,
      TempModelliColonne.mclShadow,
      TempValoriAttributi.vatIdDzt,
      TempValoriAttributi.vatTipoMem,
      TempValoriAttributi.vatIdUms,
      TempValoriAttributi_Int.vatValore AS vatV1, 
      TempValoriAttributi_Money.vatValore AS vatV2, 
      TempValoriAttributi_Money.vatIdSdv AS vatV2_IdSdv,
      TempValoriAttributi_Float.vatValore AS vatV3, 
      TempValoriAttributi_Nvarchar.vatValore AS vatV4, 
      TempValoriAttributi_Datetime.vatValore AS vatV5, 
      TempValoriAttributi_Descr.vatIdDsc AS vatV6_IdDsc, 
      TempValoriAttributi_Keys.vatValore AS vatV7
     FROM TempModelliArticoliXColonne
      INNER JOIN TempModelliColonne ON TempModelliColonne.IdMcl = TempModelliArticoliXColonne.macIdMcl
      INNER JOIN TempValoriAttributi ON TempValoriAttributi.IdVat = TempModelliArticoliXColonne.macIdVat
      LEFT OUTER JOIN TempValoriAttributi_Datetime ON TempValoriAttributi.IdVat = TempValoriAttributi_Datetime.IdVat
      LEFT OUTER JOIN TempValoriAttributi_Descr ON TempValoriAttributi.IdVat = TempValoriAttributi_Descr.IdVat
      LEFT OUTER JOIN TempValoriAttributi_Keys ON TempValoriAttributi.IdVat = TempValoriAttributi_Keys.IdVat
      LEFT OUTER JOIN TempValoriAttributi_Money ON TempValoriAttributi.IdVat = TempValoriAttributi_Money.IdVat
      LEFT OUTER JOIN TempValoriAttributi_Nvarchar ON TempValoriAttributi.IdVat = TempValoriAttributi_Nvarchar.IdVat
      LEFT OUTER JOIN TempValoriAttributi_Float ON TempValoriAttributi.IdVat = TempValoriAttributi_Float.IdVat
      LEFT OUTER JOIN TempValoriAttributi_Int ON TempValoriAttributi.IdVat = TempValoriAttributi_Int.IdVat
     WHERE (TempModelliArticoliXColonne.macIdMar = @O_IdMar)
     ORDER BY macIdMcl
    OPEN MyCur_Inner
    FETCH NEXT FROM MyCur_Inner INTO @I_macIdMcl, @I_mclShadow, @I_vatIdDzt, @I_vatTipoMem, @I_vatIdUms,
     @I_vatV1, @I_vatV2, @I_vatV2_IdSdv, @I_vatV3, @I_vatV4, @I_vatV5, @I_vatV6_IdDsc, @I_vatV7
    --PRINT 'Entering Inner: ' + CAST(@@FETCH_STATUS AS NVARCHAR)
    WHILE @@FETCH_STATUS = 0
    BEGIN
     -- Operazioni ciclo Inner (per ogni singolo attributo casella della griglia)
     -- Inserisce in ValoriAttributi
     -- PRINT 'Ciclo Inner @I_macIdMcl:' + CAST(@I_macIdMcl AS NVARCHAR)
     INSERT TempValoriAttributi(IdVat,vatTipoMem,vatIdUms,vatIdDzt) VALUES(@TIdVat,@I_vatTipoMem,@I_vatIdUms,@I_vatIdDzt)
     SELECT @CurIdVat = @TIdVat
     SET @TIdVat = @TIdVat + 1
     IF @I_mclShadow = 1
     --dovrebbe mettere a NULL tutti i valori, per il momento li mettiamo a 0
     --non possiamo mascherare date, divise (non importi), e domini (descrizioni e keys)
     BEGIN
      SELECT @I_vatV1 = 0
      SELECT @I_vatV2 = 0
      SELECT @I_vatV3 = 0
      SELECT @I_vatV4 = ''
     END
     --Inserisce le valorizzazioni
     IF @I_vatTipoMem = 1
      INSERT TempValoriAttributi_Int VALUES(@CurIdVat,@I_vatV1)
     ELSE IF @I_vatTipoMem = 2
      INSERT TempValoriAttributi_Money VALUES(@CurIdVat,@I_vatV2,@I_vatV2_IdSdv)
     ELSE IF @I_vatTipoMem = 3
      INSERT TempValoriAttributi_Float VALUES(@CurIdVat,@I_vatV3)
     ELSE IF @I_vatTipoMem = 4
      INSERT TempValoriAttributi_Nvarchar VALUES(@CurIdVat,@I_vatV4)
     ELSE IF @I_vatTipoMem = 5
      INSERT TempValoriAttributi_Datetime VALUES(@CurIdVat,@I_vatV5)
     ELSE IF @I_vatTipoMem = 6
      INSERT TempValoriAttributi_Descr VALUES(@CurIdVat,@I_vatV6_IdDsc)
     ELSE IF @I_vatTipoMem = 7
      INSERT TempValoriAttributi_Keys VALUES(@CurIdVat,@I_vatV7,DEFAULT)
     --Inserisce in OfferteArticoliXColonne
     INSERT TempOfferteArticoliXColonne(oacIdOar,oacIdMcl,oacIdVat,oacWarning)  VALUES(@CurIdOar,@I_macIdMcl,@CurIdVat,0)
    
     -- Fine ciclo Inner
     FETCH NEXT FROM MyCur_Inner INTO @I_macIdMcl, @I_mclShadow, @I_vatIdDzt, @I_vatTipoMem, @I_vatIdUms,
      @I_vatV1, @I_vatV2, @I_vatV2_IdSdv, @I_vatV3, @I_vatV4, @I_vatV5, @I_vatV6_IdDsc, @I_vatV7
    END
    CLOSE MyCur_Inner
    DEALLOCATE MyCur_Inner
    FETCH NEXT FROM MyCur_Outer INTO @O_IdMar, @O_marIdArt
   END
   CLOSE MyCur_Outer
   DEALLOCATE MyCur_Outer
  END
  -- Passa alla prossima RDO 
  SELECT @CurProg = @CurProg + 1
 END
 SET ANSI_WARNINGS ON
 --Ora trasferisce le righe in ModelliAziende
 INSERT TempModelliAziende(mazProg,mazIdMdl,mazIdAzi,mazProtocollo,mazDataInvio,mazIdOff)
  SELECT * FROM #RdoToLaunch
 --Restituisce il recordset (per prova)
 /* 
 SELECT * FROM ModelliAziende WHERE mazIdMdl = @IdMdl ORDER BY mazProg
 SELECT * FROM Offerte WHERE offIdMdl = @IdMdl ORDER BY IdOff
 SELECT OfferteArticoli.* 
  FROM OfferteArticoli
  INNER JOIN Offerte ON Offerte.IdOff = OfferteArticoli.oarIdOff
  WHERE offIdMdl = @IdMdl
 SELECT OfferteArticoliXColonne.* FROM OfferteArticoliXColonne
  INNER JOIN OfferteArticoli ON OfferteArticoli.IdOar = OfferteArticoliXColonne.oacIdOar
  INNER JOIN Offerte ON Offerte.IdOff = OfferteArticoli.oarIdOff
  WHERE Offerte.offIdMdl= @IdMdl
 SELECT * FROM ValoriAttributi WHERE IdVat IN (
  SELECT OfferteArticoliXColonne.oacIdVat FROM OfferteArticoliXColonne
   INNER JOIN OfferteArticoli ON OfferteArticoli.IdOar = OfferteArticoliXColonne.oacIdOar
   INNER JOIN Offerte ON Offerte.IdOff = OfferteArticoli.oarIdOff
   WHERE Offerte.offIdMdl= @IdMdl)
 SELECT * FROM ValoriAttributi_Int WHERE IdVat IN (
  SELECT OfferteArticoliXColonne.oacIdVat FROM OfferteArticoliXColonne
   INNER JOIN OfferteArticoli ON OfferteArticoli.IdOar = OfferteArticoliXColonne.oacIdOar
   INNER JOIN Offerte ON Offerte.IdOff = OfferteArticoli.oarIdOff
   WHERE Offerte.offIdMdl= @IdMdl)
 SELECT * FROM ValoriAttributi_Money WHERE IdVat IN (
  SELECT OfferteArticoliXColonne.oacIdVat FROM OfferteArticoliXColonne
   INNER JOIN OfferteArticoli ON OfferteArticoli.IdOar = OfferteArticoliXColonne.oacIdOar
   INNER JOIN Offerte ON Offerte.IdOff = OfferteArticoli.oarIdOff
   WHERE Offerte.offIdMdl= @IdMdl)
 SELECT * FROM ValoriAttributi_Float WHERE IdVat IN (
  SELECT OfferteArticoliXColonne.oacIdVat FROM OfferteArticoliXColonne
   INNER JOIN OfferteArticoli ON OfferteArticoli.IdOar = OfferteArticoliXColonne.oacIdOar
   INNER JOIN Offerte ON Offerte.IdOff = OfferteArticoli.oarIdOff
   WHERE Offerte.offIdMdl= @IdMdl)
 SELECT * FROM ValoriAttributi_Nvarchar WHERE IdVat IN (
  SELECT OfferteArticoliXColonne.oacIdVat FROM OfferteArticoliXColonne
   INNER JOIN OfferteArticoli ON OfferteArticoli.IdOar = OfferteArticoliXColonne.oacIdOar
   INNER JOIN Offerte ON Offerte.IdOff = OfferteArticoli.oarIdOff
   WHERE Offerte.offIdMdl= @IdMdl)
 SELECT * FROM ValoriAttributi_Datetime WHERE IdVat IN (
  SELECT OfferteArticoliXColonne.oacIdVat FROM OfferteArticoliXColonne
   INNER JOIN OfferteArticoli ON OfferteArticoli.IdOar = OfferteArticoliXColonne.oacIdOar
   INNER JOIN Offerte ON Offerte.IdOff = OfferteArticoli.oarIdOff
   WHERE Offerte.offIdMdl= @IdMdl)
 SELECT * FROM ValoriAttributi_Descrizioni WHERE IdVat IN (
  SELECT OfferteArticoliXColonne.oacIdVat FROM OfferteArticoliXColonne
   INNER JOIN OfferteArticoli ON OfferteArticoli.IdOar = OfferteArticoliXColonne.oacIdOar
   INNER JOIN Offerte ON Offerte.IdOff = OfferteArticoli.oarIdOff
   WHERE Offerte.offIdMdl= @IdMdl)
 SELECT * FROM ValoriAttributi_Keys WHERE IdVat IN (
  SELECT OfferteArticoliXColonne.oacIdVat FROM OfferteArticoliXColonne
   INNER JOIN OfferteArticoli ON OfferteArticoli.IdOar = OfferteArticoliXColonne.oacIdOar
   INNER JOIN Offerte ON Offerte.IdOff = OfferteArticoli.oarIdOff
   WHERE Offerte.offIdMdl= @IdMdl)
 GOTO lblWrong --Cosi' non modifichiamo niente
 */
lblAllOk:
 COMMIT TRAN
 GOTO lblEnd
lblWrong:
 ROLLBACK TRAN
lblEnd:
 SELECT TempModelliAziende.*,
 Aziende.aziRagioneSociale,
 Aziende.aziE_Mail,
 Aziende.aziTelefono1,
 Aziende.aziFax,
 Aziende.aziSitoWeb,
 Aziende.aziIndirizzoLeg,
 Aziende.aziProvinciaLeg,
 Aziende.aziStatoLeg
 FROM TempModelliAziende
  INNER JOIN Aziende ON TempModelliAziende.mazIdAzi = Aziende.IdAzi
 WHERE mazIdMdl = @IdMdl AND (mazIdOff IS NULL)
 ORDER BY IdMaz
GO
