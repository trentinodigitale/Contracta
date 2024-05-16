USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[BORicerche_TempEsegue_I]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[BORicerche_TempEsegue_I] (@IdRic INT, @sTotArt INT = 0 OUTPUT) AS
 
 DECLARE @TotParamAzi INT
 DECLARE @TotParamArt INT
 DECLARE @IdAzi INT
 DECLARE @TotArt INT
 SELECT @IdAzi = pfuIdAzi 
  FROM TempRicerche
  INNER JOIN ProfiliUtente ON TempRicerche.ricIdPfu = ProfiliUtente.IdPfu
  WHERE TempRicerche.IdRic = @IdRic
 SELECT @TotParamAzi = COUNT(vatIdDzt) FROM (
  SELECT DISTINCT vatIdDzt
  FROM TempValoriAttributi
  INNER JOIN TempRicercheParametri ON TempRicercheParametri.rpmIdVat = TempValoriAttributi.IdVat
  INNER JOIN DizionarioAttributi ON DizionarioAttributi.IdDzt = TempValoriAttributi.vatIdDzt
  WHERE TempRicercheParametri.rpmIdRic = @IdRic AND
   DizionarioAttributi.dztFAziende = 1) AS X
 SELECT @TotParamArt = COUNT(vatIdDzt) FROM (
  SELECT DISTINCT TempValoriAttributi.vatIdDzt
  FROM TempValoriAttributi
  INNER JOIN TempRicercheParametri ON TempRicercheParametri.rpmIdVat = TempValoriAttributi.IdVat
  INNER JOIN DizionarioAttributi ON DizionarioAttributi.IdDzt = TempValoriAttributi.vatIdDzt
  WHERE TempRicercheParametri.rpmIdRic = @IdRic AND
   DizionarioAttributi.dztFArticoli = 1 AND DizionarioAttributi.dztFOfid = 0) AS X
 BEGIN TRAN
 -- Cancella eventuali TempRicerche precedenti
 DELETE TempRicercheArticoli WHERE racIdRic = @IdRic 
 IF @TotParamArt > 0
 BEGIN
  INSERT TempRicercheArticoli(racIdRic, racIdArt)
   SELECT @IdRic AS racIdRic, ricC AS ricIdArt FROM (
   SELECT ricC, COUNT(ricT) AS ricTimes FROM (
   SELECT DISTINCT rpmT AS ricT , Articoli.IdArt AS ricC
   FROM ( SELECT TempRicercheParametri.rpmIdVat AS rpmC,
     TempRicercheParametri.rpmFunzione AS rpmF, 
     ToS.vatIdDzt AS rpmT,
     ToS.vatTipoMem AS rpmM, 
     ToS_Int.vatValore AS rpmV_Int,
     ToS_Money.vatValore AS rpmV_Money,
     ToS_Float.vatValore AS rpmV_Float,
     ToS_Nvarchar.vatValore AS rpmV_Nvarchar,
     ToS_DATETIME.vatValore AS rpmV_DATETIME,
     ToS_Descrizioni.vatIdDsc AS rpmV_Descrizioni,
     ToS_Keys.vatValore AS rpmV_Keys_Low,
     ToS_Keys.vatValoreUp AS rpmV_Keys_Upp
    FROM TempRicercheParametri
     INNER JOIN TempValoriAttributi AS ToS ON ToS.IdVat = TempRicercheParametri.rpmIdVat
     LEFT OUTER JOIN TempValoriAttributi_Int AS ToS_Int ON ToS_Int.IdVat = TempRicercheParametri.rpmIdVat
     LEFT OUTER JOIN TempValoriAttributi_Money AS ToS_Money ON ToS_Money.IdVat = TempRicercheParametri.rpmIdVat
     LEFT OUTER JOIN TempValoriAttributi_Float AS ToS_Float ON ToS_Float.IdVat = TempRicercheParametri.rpmIdVat
     LEFT OUTER JOIN TempValoriAttributi_Nvarchar AS ToS_Nvarchar ON ToS_Nvarchar.IdVat = TempRicercheParametri.rpmIdVat
     LEFT OUTER JOIN TempValoriAttributi_Datetime AS ToS_DATETIME ON ToS_DATETIME.IdVat = TempRicercheParametri.rpmIdVat
     LEFT OUTER JOIN TempValoriAttributi_Descr AS ToS_Descrizioni ON ToS_Descrizioni.IdVat = TempRicercheParametri.rpmIdVat
     LEFT OUTER JOIN TempValoriAttributi_Keys AS ToS_Keys ON ToS_Keys.IdVat = TempRicercheParametri.rpmIdVat
    WHERE TempRicercheParametri.rpmIdRic = @IdRic AND
    ToS.vatIdDzt IN (SELECT IdDzt FROM DizionarioAttributi WHERE dztFArticoli = 1 AND dztFOfid = 0)
   ) AS Rpm
   CROSS JOIN Articoli
   LEFT OUTER JOIN (
    SELECT DfVatArt.IdArt AS vdcIdArt, ToC.vatIdDzt AS vdcT, ToC.vatTipoMem AS vdcM,
     ToC_Int.vatValore AS vdcV_Int,
     ToC_Money.vatValore AS vdcV_Money,
     ToC_Float.vatValore AS vdcV_Float,
     ToC_Nvarchar.vatValore AS vdcV_Nvarchar,
     ToC_DATETIME.vatValore AS vdcV_DATETIME,
     ToC_Descrizioni.vatIdDsc AS vdcV_Descrizioni,
     ToC_Keys.vatValore AS vdcV_Keys
    FROM DfVatArt
     INNER JOIN ValoriAttributi AS ToC ON (DfVatArt.IdVat = ToC.IdVat)
     LEFT OUTER JOIN ValoriAttributi_Int AS ToC_Int ON ToC_Int.IdVat = ToC.IdVat
     LEFT OUTER JOIN ValoriAttributi_Money AS ToC_Money ON ToC_Money.IdVat = ToC.IdVat
     LEFT OUTER JOIN ValoriAttributi_Float AS ToC_Float ON ToC_Float.IdVat = ToC.IdVat
     LEFT OUTER JOIN ValoriAttributi_Nvarchar AS ToC_Nvarchar ON ToC_Nvarchar.IdVat = ToC.IdVat
     LEFT OUTER JOIN ValoriAttributi_Datetime AS ToC_DATETIME ON ToC_DATETIME.IdVat = ToC.IdVat
     LEFT OUTER JOIN ValoriAttributi_Descrizioni AS ToC_Descrizioni ON ToC_Descrizioni.IdVat = ToC.IdVat
     LEFT OUTER JOIN ValoriAttributi_Keys AS ToC_Keys ON ToC_Keys.IdVat = ToC.IdVat
    ) AS Vdc ON (Articoli.IdArt = Vdc.vdcIdArt AND Vdc.vdcT = Rpm.rpmT)
   LEFT OUTER JOIN DescsI AS ToC_Descrizioni_I ON ToC_Descrizioni_I.IdDsc = Articoli.artIdDscDescrizione
   WHERE CASE WHEN ((@TotParamAzi = 0) AND (Articoli.artIdAzi <> @IdAzi)) THEN 1
     WHEN ((@TotParamAzi > 0) AND (Articoli.artIdAzi <> @IdAzi) AND Articoli.artIdAzi IN (
     -- Inizio TempRicerche Aziende
     SELECT ricIdAzi FROM (SELECT ricC AS ricIdAzi, COUNT(ricT) AS ricTimes FROM (
      SELECT DISTINCT rpmT AS ricT , Aziende.IdAzi AS ricC
      FROM ( SELECT TempRicercheParametri.rpmIdVat AS rpmC,
        TempRicercheParametri.rpmFunzione AS rpmF, 
        ToS.vatIdDzt AS rpmT,
        ToS.vatTipoMem AS rpmM, 
        ToS_Int.vatValore AS rpmV_Int,
        ToS_Money.vatValore AS rpmV_Money,
        ToS_Float.vatValore AS rpmV_Float,
        ToS_Nvarchar.vatValore AS rpmV_Nvarchar,
        ToS_DATETIME.vatValore AS rpmV_DATETIME,
        ToS_Descrizioni.vatIdDsc AS rpmV_Descrizioni,
        ToS_Keys.vatValore AS rpmV_Keys_Low,
        ToS_Keys.vatValoreUp AS rpmV_Keys_Upp
       FROM TempRicercheParametri
        INNER JOIN TempValoriAttributi AS ToS ON ToS.IdVat = TempRicercheParametri.rpmIdVat
        LEFT OUTER JOIN TempValoriAttributi_Int AS ToS_Int ON ToS_Int.IdVat = TempRicercheParametri.rpmIdVat
        LEFT OUTER JOIN TempValoriAttributi_Money AS ToS_Money ON ToS_Money.IdVat = TempRicercheParametri.rpmIdVat
        LEFT OUTER JOIN TempValoriAttributi_Float AS ToS_Float ON ToS_Float.IdVat = TempRicercheParametri.rpmIdVat
        LEFT OUTER JOIN TempValoriAttributi_Nvarchar AS ToS_Nvarchar ON ToS_Nvarchar.IdVat = TempRicercheParametri.rpmIdVat
        LEFT OUTER JOIN TempValoriAttributi_Datetime AS ToS_DATETIME ON ToS_DATETIME.IdVat = TempRicercheParametri.rpmIdVat
        LEFT OUTER JOIN TempValoriAttributi_Descr AS ToS_Descrizioni ON ToS_Descrizioni.IdVat = TempRicercheParametri.rpmIdVat
        LEFT OUTER JOIN TempValoriAttributi_Keys AS ToS_Keys ON ToS_Keys.IdVat = TempRicercheParametri.rpmIdVat
       WHERE TempRicercheParametri.rpmIdRic = @IdRic AND
        ToS.vatIdDzt IN (SELECT IdDzt FROM DizionarioAttributi WHERE dztFAziende = 1)
      ) AS Rpm
      CROSS JOIN Aziende
      LEFT OUTER JOIN (
       SELECT DfVatAzi.IdAzi AS vdcIdAzi, ToC.vatIdDzt AS vdcT, ToC.vatTipoMem AS vdcM,
        ToC_Int.vatValore AS vdcV_Int,
        ToC_Money.vatValore AS vdcV_Money,
        ToC_Float.vatValore AS vdcV_Float,
        ToC_Nvarchar.vatValore AS vdcV_Nvarchar,
        ToC_DATETIME.vatValore AS vdcV_DATETIME,
        ToC_Descrizioni.vatIdDsc AS vdcV_Descrizioni,
        ToC_Keys.vatValore AS vdcV_Keys
       FROM DfVatAzi
        INNER JOIN ValoriAttributi AS ToC ON (DfVatAzi.IdVat = ToC.IdVat)
        LEFT OUTER JOIN ValoriAttributi_Int AS ToC_Int ON ToC_Int.IdVat = ToC.IdVat
        LEFT OUTER JOIN ValoriAttributi_Money AS ToC_Money ON ToC_Money.IdVat = ToC.IdVat
        LEFT OUTER JOIN ValoriAttributi_Float AS ToC_Float ON ToC_Float.IdVat = ToC.IdVat
        LEFT OUTER JOIN ValoriAttributi_Nvarchar AS ToC_Nvarchar ON ToC_Nvarchar.IdVat = ToC.IdVat
        LEFT OUTER JOIN ValoriAttributi_Datetime AS ToC_DATETIME ON ToC_DATETIME.IdVat = ToC.IdVat
        LEFT OUTER JOIN ValoriAttributi_Descrizioni AS ToC_Descrizioni ON ToC_Descrizioni.IdVat = ToC.IdVat
        LEFT OUTER JOIN ValoriAttributi_Keys AS ToC_Keys ON ToC_Keys.IdVat = ToC.IdVat
       ) AS Vdc ON (Aziende.IdAzi = Vdc.vdcIdAzi AND Vdc.vdcT = Rpm.rpmT)
      WHERE CASE RpmT
       WHEN 78 THEN CASE
        WHEN (rpmF = 1) AND (Aziende.aziLocalitaLeg = rpmV_Nvarchar) THEN 1
        WHEN (rpmF = 2) AND (Aziende.aziLocalitaLeg Like rpmV_Nvarchar) AND (Aziende.aziLocalitaLeg <> '') THEN 1
        WHEN (rpmF = 3) AND (Aziende.aziLocalitaLeg <> rpmV_Nvarchar) THEN 1
        WHEN (rpmF = 4) AND (Aziende.aziLocalitaLeg < rpmV_Nvarchar) THEN 1
        WHEN (rpmF = 5) AND (Aziende.aziLocalitaLeg > rpmV_Nvarchar) THEN 1
        ELSE 0 END
       WHEN 77 THEN CASE
        WHEN (rpmF = 1) AND (Aziende.aziIndirizzoLeg = rpmV_Nvarchar) THEN 1
        WHEN (rpmF = 2) AND (Aziende.aziIndirizzoLeg Like rpmV_Nvarchar) AND (Aziende.aziIndirizzoLeg <> '') THEN 1
        WHEN (rpmF = 3) AND (Aziende.aziIndirizzoLeg <> rpmV_Nvarchar) THEN 1
        WHEN (rpmF = 4) AND (Aziende.aziIndirizzoLeg < rpmV_Nvarchar) THEN 1
        WHEN (rpmF = 5) AND (Aziende.aziIndirizzoLeg > rpmV_Nvarchar) THEN 1
        ELSE 0 END
       WHEN 95 THEN CASE
        WHEN (rpmF = 1) AND (Aziende.aziCAPLeg = rpmV_Nvarchar) THEN 1
        WHEN (rpmF = 2) AND (Aziende.aziCAPLeg Like rpmV_Nvarchar) AND (Aziende.aziCAPLeg <> '') THEN 1
        WHEN (rpmF = 3) AND (Aziende.aziCAPLeg <> rpmV_Nvarchar) THEN 1
        WHEN (rpmF = 4) AND (Aziende.aziCAPLeg < rpmV_Nvarchar) THEN 1
        WHEN (rpmF = 5) AND (Aziende.aziCAPLeg > rpmV_Nvarchar) THEN 1
        ELSE 0 END
       WHEN 79 THEN CASE
        WHEN (rpmF = 1) AND (Aziende.aziProvinciaLeg = rpmV_Nvarchar) THEN 1
        WHEN (rpmF = 2) AND (Aziende.aziProvinciaLeg Like rpmV_Nvarchar) AND (Aziende.aziProvinciaLeg <> '') THEN 1
        WHEN (rpmF = 3) AND (Aziende.aziProvinciaLeg <> rpmV_Nvarchar) THEN 1
        WHEN (rpmF = 4) AND (Aziende.aziProvinciaLeg < rpmV_Nvarchar) THEN 1
        WHEN (rpmF = 5) AND (Aziende.aziProvinciaLeg > rpmV_Nvarchar) THEN 1
        ELSE 0 END
       WHEN 81 THEN CASE
        WHEN (rpmF = 1) AND (Aziende.aziStatoLeg = rpmV_Nvarchar) THEN 1
        WHEN (rpmF = 2) AND (Aziende.aziStatoLeg Like rpmV_Nvarchar) AND (Aziende.aziStatoLeg <> '') THEN 1
        WHEN (rpmF = 3) AND (Aziende.aziStatoLeg <> rpmV_Nvarchar) THEN 1
        WHEN (rpmF = 4) AND (Aziende.aziStatoLeg < rpmV_Nvarchar) THEN 1
        WHEN (rpmF = 5) AND (Aziende.aziStatoLeg > rpmV_Nvarchar) THEN 1
        ELSE 0 END
       WHEN 90 THEN CASE
        WHEN (rpmF = 1) AND (Aziende.aziLocalitaOp = rpmV_Nvarchar) THEN 1
        WHEN (rpmF = 2) AND (Aziende.aziLocalitaOp Like rpmV_Nvarchar) AND (Aziende.aziLocalitaOp <> '') THEN 1
        WHEN (rpmF = 3) AND (Aziende.aziLocalitaOp <> rpmV_Nvarchar) THEN 1
        WHEN (rpmF = 4) AND (Aziende.aziLocalitaOp < rpmV_Nvarchar) THEN 1
        WHEN (rpmF = 5) AND (Aziende.aziLocalitaOp > rpmV_Nvarchar) THEN 1
        ELSE 0 END
       WHEN 89 THEN CASE
        WHEN (rpmF = 1) AND (Aziende.aziIndirizzoOp = rpmV_Nvarchar) THEN 1
        WHEN (rpmF = 2) AND (Aziende.aziIndirizzoOp Like rpmV_Nvarchar) AND (Aziende.aziIndirizzoOp <> '') THEN 1
        WHEN (rpmF = 3) AND (Aziende.aziIndirizzoOp <> rpmV_Nvarchar) THEN 1
        WHEN (rpmF = 4) AND (Aziende.aziIndirizzoOp < rpmV_Nvarchar) THEN 1
        WHEN (rpmF = 5) AND (Aziende.aziIndirizzoOp > rpmV_Nvarchar) THEN 1
        ELSE 0 END
       WHEN 96 THEN CASE
        WHEN (rpmF = 1) AND (Aziende.aziCAPOp = rpmV_Nvarchar) THEN 1
        WHEN (rpmF = 2) AND (Aziende.aziCAPOp Like rpmV_Nvarchar) AND (Aziende.aziCAPOp <> '') THEN 1
        WHEN (rpmF = 3) AND (Aziende.aziCAPOp <> rpmV_Nvarchar) THEN 1
        WHEN (rpmF = 4) AND (Aziende.aziCAPOp < rpmV_Nvarchar) THEN 1
        WHEN (rpmF = 5) AND (Aziende.aziCAPOp > rpmV_Nvarchar) THEN 1
        ELSE 0 END
       WHEN 91 THEN CASE
        WHEN (rpmF = 1) AND (Aziende.aziProvinciaOp = rpmV_Nvarchar) THEN 1
        WHEN (rpmF = 2) AND (Aziende.aziProvinciaOp Like rpmV_Nvarchar) AND (Aziende.aziProvinciaOp <> '') THEN 1
        WHEN (rpmF = 3) AND (Aziende.aziProvinciaOp <> rpmV_Nvarchar) THEN 1
        WHEN (rpmF = 4) AND (Aziende.aziProvinciaOp < rpmV_Nvarchar) THEN 1
        WHEN (rpmF = 5) AND (Aziende.aziProvinciaOp > rpmV_Nvarchar) THEN 1
        ELSE 0 END
       WHEN 93 THEN CASE
        WHEN (rpmF = 1) AND (Aziende.aziStatoOp = rpmV_Nvarchar) THEN 1
        WHEN (rpmF = 2) AND (Aziende.aziStatoOp Like rpmV_Nvarchar) AND (Aziende.aziStatoOp <> '') THEN 1
        WHEN (rpmF = 3) AND (Aziende.aziStatoOp <> rpmV_Nvarchar) THEN 1
        WHEN (rpmF = 4) AND (Aziende.aziStatoOp < rpmV_Nvarchar) THEN 1
        WHEN (rpmF = 5) AND (Aziende.aziStatoOp > rpmV_Nvarchar) THEN 1
        ELSE 0 END
       WHEN 75 THEN CASE
        WHEN (rpmF = 1) AND (Aziende.aziE_Mail = rpmV_Nvarchar) THEN 1
        WHEN (rpmF = 2) AND (Aziende.aziE_Mail Like rpmV_Nvarchar) AND (Aziende.aziE_Mail <> '') THEN 1
        WHEN (rpmF = 3) AND (Aziende.aziE_Mail <> rpmV_Nvarchar) THEN 1
        WHEN (rpmF = 4) AND (Aziende.aziE_Mail < rpmV_Nvarchar) THEN 1
        WHEN (rpmF = 5) AND (Aziende.aziE_Mail > rpmV_Nvarchar) THEN 1
        ELSE 0 END
       WHEN 83 THEN CASE
        WHEN (rpmF = 1) AND (Aziende.aziFAX = rpmV_Nvarchar) THEN 1
        WHEN (rpmF = 2) AND (Aziende.aziFAX Like rpmV_Nvarchar) AND (Aziende.aziFAX <> '') THEN 1
        WHEN (rpmF = 3) AND (Aziende.aziFAX <> rpmV_Nvarchar) THEN 1
        WHEN (rpmF = 4) AND (Aziende.aziFAX < rpmV_Nvarchar) THEN 1
        WHEN (rpmF = 5) AND (Aziende.aziFAX > rpmV_Nvarchar) THEN 1
        ELSE 0 END
       WHEN 74 THEN CASE
        WHEN (rpmF = 1) AND (Aziende.aziPartitaIVA = rpmV_Nvarchar) THEN 1
        WHEN (rpmF = 2) AND (Aziende.aziPartitaIVA Like rpmV_Nvarchar) AND (Aziende.aziPartitaIVA <> '') THEN 1
        WHEN (rpmF = 3) AND (Aziende.aziPartitaIVA <> rpmV_Nvarchar) THEN 1
        WHEN (rpmF = 4) AND (Aziende.aziPartitaIVA < rpmV_Nvarchar) THEN 1
        WHEN (rpmF = 5) AND (Aziende.aziPartitaIVA > rpmV_Nvarchar) THEN 1
        ELSE 0 END
       WHEN 72 THEN CASE
        WHEN (rpmF = 1) AND (Aziende.aziRagioneSociale = rpmV_Nvarchar) THEN 1
        WHEN (rpmF = 2) AND (Aziende.aziRagioneSociale Like rpmV_Nvarchar) AND (Aziende.aziRagioneSociale <> '') THEN 1
        WHEN (rpmF = 3) AND (Aziende.aziRagioneSociale <> rpmV_Nvarchar) THEN 1
        WHEN (rpmF = 4) AND (Aziende.aziRagioneSociale < rpmV_Nvarchar) THEN 1
        WHEN (rpmF = 5) AND (Aziende.aziRagioneSociale > rpmV_Nvarchar) THEN 1
        ELSE 0 END
       WHEN 82 THEN CASE
        WHEN (rpmF = 1) AND (Aziende.aziTelefono1 = rpmV_Nvarchar) THEN 1
        WHEN (rpmF = 2) AND (Aziende.aziTelefono1 Like rpmV_Nvarchar) AND (Aziende.aziTelefono1 <> '') THEN 1
        WHEN (rpmF = 3) AND (Aziende.aziTelefono1 <> rpmV_Nvarchar) THEN 1
        WHEN (rpmF = 4) AND (Aziende.aziTelefono1 < rpmV_Nvarchar) THEN 1
        WHEN (rpmF = 5) AND (Aziende.aziTelefono1 > rpmV_Nvarchar) THEN 1
        ELSE 0 END
       WHEN 73 THEN CASE
        WHEN (rpmF = 1) AND (Aziende.aziIdDscFormaSoc = rpmV_Descrizioni) THEN 1
        WHEN (rpmF = 3) AND (Aziende.aziIdDscFormaSoc <> rpmV_Descrizioni) THEN 1
        ELSE 0 END
       WHEN 71 THEN CASE
        WHEN (Aziende.aziAtvAtecord LIKE (rpmV_NVarChar + '%')) THEN 1
        ELSE 0 END
       WHEN 106 THEN CASE
        WHEN Aziende.aziGphValueOper BETWEEN rpmV_Keys_Low AND rpmV_Keys_Upp THEN 1
        ELSE 0 END
       ELSE CASE Vdc.vdcM
        WHEN 1 THEN CASE
         WHEN (rpmF = 1) AND (vdcV_Int = rpmV_Int) THEN 1
         WHEN (rpmF = 3) AND (vdcV_Int <> rpmV_Int) THEN 1
         WHEN (rpmF = 4) AND (vdcV_Int < rpmV_Int) THEN 1
         WHEN (rpmF = 5) AND (vdcV_Int > rpmV_Int) THEN 1
         ELSE 0 END
        WHEN 2 THEN CASE
         WHEN (rpmF = 1) AND (vdcV_Money = rpmV_Money) THEN 1
         WHEN (rpmF = 3) AND (vdcV_Money <> rpmV_Money) THEN 1
         WHEN (rpmF = 4) AND (vdcV_Money < rpmV_Money) THEN 1
         WHEN (rpmF = 5) AND (vdcV_Money > rpmV_Money) THEN 1
         ELSE 0 END
        WHEN 3 THEN CASE
         WHEN (rpmF = 1) AND (vdcV_Float = rpmV_Float) THEN 1
         WHEN (rpmF = 3) AND (vdcV_Float <> rpmV_Float) THEN 1
         WHEN (rpmF = 4) AND (vdcV_Float < rpmV_Float) THEN 1
         WHEN (rpmF = 5) AND (vdcV_Float > rpmV_Float) THEN 1
         ELSE 0 END
        WHEN 4 THEN CASE
         WHEN (rpmF = 1) AND (vdcV_Nvarchar = rpmV_Nvarchar) THEN 1
         WHEN (rpmF = 2) AND (vdcV_Nvarchar Like rpmV_Nvarchar) THEN 1
         WHEN (rpmF = 3) AND (vdcV_Nvarchar <> rpmV_Nvarchar) THEN 1
         WHEN (rpmF = 4) AND (vdcV_Nvarchar < rpmV_Nvarchar) THEN 1
         WHEN (rpmF = 5) AND (vdcV_Nvarchar > rpmV_Nvarchar) THEN 1
         ELSE 0 END
        WHEN 5 THEN CASE
         WHEN (rpmF = 1) AND (vdcV_DATETIME = rpmV_DATETIME) THEN 1
         WHEN (rpmF = 3) AND (vdcV_DATETIME <> rpmV_DATETIME) THEN 1
         WHEN (rpmF = 4) AND (vdcV_DATETIME < rpmV_DATETIME) THEN 1
         WHEN (rpmF = 5) AND (vdcV_DATETIME > rpmV_DATETIME) THEN 1
         ELSE 0 END
        WHEN 6 THEN CASE
         WHEN (rpmF = 1) AND (vdcV_Descrizioni = rpmV_Descrizioni) THEN 1
         WHEN (rpmF = 3) AND (vdcV_Descrizioni <> rpmV_Descrizioni) THEN 1
         ELSE 0 END
        WHEN 7 THEN CASE
         WHEN (rpmF = 1) AND (vdcV_Keys BETWEEN rpmV_Keys_Low AND rpmV_Keys_Upp) THEN 1
         ELSE 0 END
        ELSE 0 END
       END = 1
      ) AS ric GROUP BY ricC) AS Ric
      WHERE ricTimes = @TotParamAzi
     -- Fine TempRicerche Aziende
     )) THEN 1
     END = 1 AND
    CASE RpmT
    WHEN 70 THEN CASE
     WHEN (rpmF = 1) AND (ToC_Descrizioni_I.dscTesto = rpmV_Nvarchar) THEN 1
     WHEN (rpmF = 2) AND (ToC_Descrizioni_I.dscTesto Like rpmV_Nvarchar) AND (ToC_Descrizioni_I.dscTesto <> '') THEN 1
     WHEN (rpmF = 3) AND (ToC_Descrizioni_I.dscTesto <> rpmV_Nvarchar) THEN 1
     WHEN (rpmF = 4) AND (ToC_Descrizioni_I.dscTesto < rpmV_Nvarchar) THEN 1
     WHEN (rpmF = 5) AND (ToC_Descrizioni_I.dscTesto > rpmV_Nvarchar) THEN 1
     ELSE 0 END
    WHEN 69 THEN CASE
     WHEN (rpmF = 1) AND (Articoli.artCode = rpmV_Nvarchar) THEN 1
     WHEN (rpmF = 2) AND (Articoli.artCode Like rpmV_Nvarchar) AND (Articoli.artCode <> '') THEN 1
     WHEN (rpmF = 3) AND (Articoli.artCode <> rpmV_Nvarchar) THEN 1
     WHEN (rpmF = 4) AND (Articoli.artCode < rpmV_Nvarchar) THEN 1
     WHEN (rpmF = 5) AND (Articoli.artCode > rpmV_Nvarchar) THEN 1
     ELSE 0 END
    WHEN 107 THEN CASE
     WHEN Articoli.artCspValue BETWEEN rpmV_Keys_Low AND rpmV_Keys_Upp THEN 1
     ELSE 0 END
    ELSE CASE Vdc.vdcM
     WHEN 1 THEN CASE
      WHEN (rpmF = 1) AND (vdcV_Int = rpmV_Int) THEN 1
      WHEN (rpmF = 3) AND (vdcV_Int <> rpmV_Int) THEN 1
      WHEN (rpmF = 4) AND (vdcV_Int < rpmV_Int) THEN 1
      WHEN (rpmF = 5) AND (vdcV_Int > rpmV_Int) THEN 1
      ELSE 0 END
     WHEN 2 THEN CASE
      WHEN (rpmF = 1) AND (vdcV_Money = rpmV_Money) THEN 1
      WHEN (rpmF = 3) AND (vdcV_Money <> rpmV_Money) THEN 1
      WHEN (rpmF = 4) AND (vdcV_Money < rpmV_Money) THEN 1
      WHEN (rpmF = 5) AND (vdcV_Money > rpmV_Money) THEN 1
      ELSE 0 END
     WHEN 3 THEN CASE
      WHEN (rpmF = 1) AND (vdcV_Float = rpmV_Float) THEN 1
      WHEN (rpmF = 3) AND (vdcV_Float <> rpmV_Float) THEN 1
      WHEN (rpmF = 4) AND (vdcV_Float < rpmV_Float) THEN 1
      WHEN (rpmF = 5) AND (vdcV_Float > rpmV_Float) THEN 1
      ELSE 0 END
     WHEN 4 THEN CASE
      WHEN (rpmF = 1) AND (vdcV_Nvarchar = rpmV_Nvarchar) THEN 1
      WHEN (rpmF = 2) AND (vdcV_Nvarchar Like rpmV_Nvarchar) THEN 1
      WHEN (rpmF = 3) AND (vdcV_Nvarchar <> rpmV_Nvarchar) THEN 1
      WHEN (rpmF = 4) AND (vdcV_Nvarchar < rpmV_Nvarchar) THEN 1
      WHEN (rpmF = 5) AND (vdcV_Nvarchar > rpmV_Nvarchar) THEN 1
      ELSE 0 END
     WHEN 5 THEN CASE
      WHEN (rpmF = 1) AND (vdcV_DATETIME = rpmV_DATETIME) THEN 1
      WHEN (rpmF = 3) AND (vdcV_DATETIME <> rpmV_DATETIME) THEN 1
      WHEN (rpmF = 4) AND (vdcV_DATETIME < rpmV_DATETIME) THEN 1
      WHEN (rpmF = 5) AND (vdcV_DATETIME > rpmV_DATETIME) THEN 1
      ELSE 0 END
     WHEN 6 THEN CASE
      WHEN (rpmF = 1) AND (vdcV_Descrizioni = rpmV_Descrizioni) THEN 1
      WHEN (rpmF = 3) AND (vdcV_Descrizioni <> rpmV_Descrizioni) THEN 1
      ELSE 0 END
     WHEN 7 THEN CASE
      WHEN (rpmF = 1) AND (vdcV_Keys BETWEEN rpmV_Keys_Low AND rpmV_Keys_Upp) THEN 1
      ELSE 0 END
     ELSE 0 END
    END = 1)
   AS ric GROUP BY ricC) AS ric
   WHERE ricTimes = @TotParamArt
   ORDER BY ricC
  END ELSE BEGIN
  INSERT TempRicercheArticoli(racIdRic, racIdArt)
   SELECT @IdRic AS racIdRic, IdArt AS racIdArt FROM Articoli WHERE Articoli.artIdAzi IN (
     --Inizio ricerca Aziende
     SELECT ricIdAzi FROM (SELECT ricC AS ricIdAzi, COUNT(ricT) AS ricTimes FROM (
      SELECT DISTINCT rpmT AS ricT , Aziende.IdAzi AS ricC
      FROM ( SELECT TempRicercheParametri.rpmIdVat AS rpmC,
        TempRicercheParametri.rpmFunzione AS rpmF, 
        ToS.vatIdDzt AS rpmT,
        ToS.vatTipoMem AS rpmM, 
        ToS_Int.vatValore AS rpmV_Int,
        ToS_Money.vatValore AS rpmV_Money,
        ToS_Float.vatValore AS rpmV_Float,
        ToS_Nvarchar.vatValore AS rpmV_Nvarchar,
        ToS_DATETIME.vatValore AS rpmV_DATETIME,
        ToS_Descrizioni.vatIdDsc AS rpmV_Descrizioni,
        ToS_Keys.vatValore AS rpmV_Keys_Low,
        ToS_Keys.vatValoreUp AS rpmV_Keys_Upp
       FROM TempRicercheParametri
        INNER JOIN TempValoriAttributi AS ToS ON ToS.IdVat = TempRicercheParametri.rpmIdVat
        LEFT OUTER JOIN TempValoriAttributi_Int AS ToS_Int ON ToS_Int.IdVat = TempRicercheParametri.rpmIdVat
        LEFT OUTER JOIN TempValoriAttributi_Money AS ToS_Money ON ToS_Money.IdVat = TempRicercheParametri.rpmIdVat
        LEFT OUTER JOIN TempValoriAttributi_Float AS ToS_Float ON ToS_Float.IdVat = TempRicercheParametri.rpmIdVat
        LEFT OUTER JOIN TempValoriAttributi_Nvarchar AS ToS_Nvarchar ON ToS_Nvarchar.IdVat = TempRicercheParametri.rpmIdVat
        LEFT OUTER JOIN TempValoriAttributi_Datetime AS ToS_DATETIME ON ToS_DATETIME.IdVat = TempRicercheParametri.rpmIdVat
        LEFT OUTER JOIN TempValoriAttributi_Descr AS ToS_Descrizioni ON ToS_Descrizioni.IdVat = TempRicercheParametri.rpmIdVat
        LEFT OUTER JOIN TempValoriAttributi_Keys AS ToS_Keys ON ToS_Keys.IdVat = TempRicercheParametri.rpmIdVat
       WHERE TempRicercheParametri.rpmIdRic = @IdRic AND
        ToS.vatIdDzt IN (SELECT IdDzt FROM DizionarioAttributi WHERE dztFAziende = 1)
      ) AS Rpm
      CROSS JOIN Aziende
      LEFT OUTER JOIN (
       SELECT DfVatAzi.IdAzi AS vdcIdAzi, ToC.vatIdDzt AS vdcT, ToC.vatTipoMem AS vdcM,
        ToC_Int.vatValore AS vdcV_Int,
        ToC_Money.vatValore AS vdcV_Money,
        ToC_Float.vatValore AS vdcV_Float,
        ToC_Nvarchar.vatValore AS vdcV_Nvarchar,
        ToC_DATETIME.vatValore AS vdcV_DATETIME,
        ToC_Descrizioni.vatIdDsc AS vdcV_Descrizioni,
        ToC_Keys.vatValore AS vdcV_Keys
       FROM DfVatAzi
        INNER JOIN ValoriAttributi AS ToC ON (DfVatAzi.IdVat = ToC.IdVat)
        LEFT OUTER JOIN ValoriAttributi_Int AS ToC_Int ON ToC_Int.IdVat = ToC.IdVat
        LEFT OUTER JOIN ValoriAttributi_Money AS ToC_Money ON ToC_Money.IdVat = ToC.IdVat
        LEFT OUTER JOIN ValoriAttributi_Float AS ToC_Float ON ToC_Float.IdVat = ToC.IdVat
        LEFT OUTER JOIN ValoriAttributi_Nvarchar AS ToC_Nvarchar ON ToC_Nvarchar.IdVat = ToC.IdVat
        LEFT OUTER JOIN ValoriAttributi_Datetime AS ToC_DATETIME ON ToC_DATETIME.IdVat = ToC.IdVat
        LEFT OUTER JOIN ValoriAttributi_Descrizioni AS ToC_Descrizioni ON ToC_Descrizioni.IdVat = ToC.IdVat
        LEFT OUTER JOIN ValoriAttributi_Keys AS ToC_Keys ON ToC_Keys.IdVat = ToC.IdVat
       ) AS Vdc ON (Aziende.IdAzi = Vdc.vdcIdAzi AND Vdc.vdcT = Rpm.rpmT)
      WHERE CASE RpmT
       WHEN 78 THEN CASE
        WHEN (rpmF = 1) AND (Aziende.aziLocalitaLeg = rpmV_Nvarchar) THEN 1
        WHEN (rpmF = 2) AND (Aziende.aziLocalitaLeg Like rpmV_Nvarchar) AND (Aziende.aziLocalitaLeg <> '') THEN 1
        WHEN (rpmF = 3) AND (Aziende.aziLocalitaLeg <> rpmV_Nvarchar) THEN 1
        WHEN (rpmF = 4) AND (Aziende.aziLocalitaLeg < rpmV_Nvarchar) THEN 1
        WHEN (rpmF = 5) AND (Aziende.aziLocalitaLeg > rpmV_Nvarchar) THEN 1
        ELSE 0 END
       WHEN 77 THEN CASE
        WHEN (rpmF = 1) AND (Aziende.aziIndirizzoLeg = rpmV_Nvarchar) THEN 1
        WHEN (rpmF = 2) AND (Aziende.aziIndirizzoLeg Like rpmV_Nvarchar) AND (Aziende.aziIndirizzoLeg <> '') THEN 1
        WHEN (rpmF = 3) AND (Aziende.aziIndirizzoLeg <> rpmV_Nvarchar) THEN 1
        WHEN (rpmF = 4) AND (Aziende.aziIndirizzoLeg < rpmV_Nvarchar) THEN 1
        WHEN (rpmF = 5) AND (Aziende.aziIndirizzoLeg > rpmV_Nvarchar) THEN 1
        ELSE 0 END
       WHEN 95 THEN CASE
        WHEN (rpmF = 1) AND (Aziende.aziCAPLeg = rpmV_Nvarchar) THEN 1
        WHEN (rpmF = 2) AND (Aziende.aziCAPLeg Like rpmV_Nvarchar) AND (Aziende.aziCAPLeg <> '') THEN 1
        WHEN (rpmF = 3) AND (Aziende.aziCAPLeg <> rpmV_Nvarchar) THEN 1
        WHEN (rpmF = 4) AND (Aziende.aziCAPLeg < rpmV_Nvarchar) THEN 1
        WHEN (rpmF = 5) AND (Aziende.aziCAPLeg > rpmV_Nvarchar) THEN 1
        ELSE 0 END
       WHEN 79 THEN CASE
        WHEN (rpmF = 1) AND (Aziende.aziProvinciaLeg = rpmV_Nvarchar) THEN 1
        WHEN (rpmF = 2) AND (Aziende.aziProvinciaLeg Like rpmV_Nvarchar) AND (Aziende.aziProvinciaLeg <> '') THEN 1
        WHEN (rpmF = 3) AND (Aziende.aziProvinciaLeg <> rpmV_Nvarchar) THEN 1
        WHEN (rpmF = 4) AND (Aziende.aziProvinciaLeg < rpmV_Nvarchar) THEN 1
        WHEN (rpmF = 5) AND (Aziende.aziProvinciaLeg > rpmV_Nvarchar) THEN 1
        ELSE 0 END
       WHEN 81 THEN CASE
        WHEN (rpmF = 1) AND (Aziende.aziStatoLeg = rpmV_Nvarchar) THEN 1
        WHEN (rpmF = 2) AND (Aziende.aziStatoLeg Like rpmV_Nvarchar) AND (Aziende.aziStatoLeg <> '') THEN 1
        WHEN (rpmF = 3) AND (Aziende.aziStatoLeg <> rpmV_Nvarchar) THEN 1
        WHEN (rpmF = 4) AND (Aziende.aziStatoLeg < rpmV_Nvarchar) THEN 1
        WHEN (rpmF = 5) AND (Aziende.aziStatoLeg > rpmV_Nvarchar) THEN 1
        ELSE 0 END
       WHEN 90 THEN CASE
        WHEN (rpmF = 1) AND (Aziende.aziLocalitaOp = rpmV_Nvarchar) THEN 1
        WHEN (rpmF = 2) AND (Aziende.aziLocalitaOp Like rpmV_Nvarchar) AND (Aziende.aziLocalitaOp <> '') THEN 1
        WHEN (rpmF = 3) AND (Aziende.aziLocalitaOp <> rpmV_Nvarchar) THEN 1
        WHEN (rpmF = 4) AND (Aziende.aziLocalitaOp < rpmV_Nvarchar) THEN 1
        WHEN (rpmF = 5) AND (Aziende.aziLocalitaOp > rpmV_Nvarchar) THEN 1
        ELSE 0 END
       WHEN 89 THEN CASE
        WHEN (rpmF = 1) AND (Aziende.aziIndirizzoOp = rpmV_Nvarchar) THEN 1
        WHEN (rpmF = 2) AND (Aziende.aziIndirizzoOp Like rpmV_Nvarchar) AND (Aziende.aziIndirizzoOp <> '') THEN 1
        WHEN (rpmF = 3) AND (Aziende.aziIndirizzoOp <> rpmV_Nvarchar) THEN 1
        WHEN (rpmF = 4) AND (Aziende.aziIndirizzoOp < rpmV_Nvarchar) THEN 1
        WHEN (rpmF = 5) AND (Aziende.aziIndirizzoOp > rpmV_Nvarchar) THEN 1
        ELSE 0 END
       WHEN 96 THEN CASE
        WHEN (rpmF = 1) AND (Aziende.aziCAPOp = rpmV_Nvarchar) THEN 1
        WHEN (rpmF = 2) AND (Aziende.aziCAPOp Like rpmV_Nvarchar) AND (Aziende.aziCAPOp <> '') THEN 1
        WHEN (rpmF = 3) AND (Aziende.aziCAPOp <> rpmV_Nvarchar) THEN 1
        WHEN (rpmF = 4) AND (Aziende.aziCAPOp < rpmV_Nvarchar) THEN 1
        WHEN (rpmF = 5) AND (Aziende.aziCAPOp > rpmV_Nvarchar) THEN 1
        ELSE 0 END
       WHEN 91 THEN CASE
        WHEN (rpmF = 1) AND (Aziende.aziProvinciaOp = rpmV_Nvarchar) THEN 1
        WHEN (rpmF = 2) AND (Aziende.aziProvinciaOp Like rpmV_Nvarchar) AND (Aziende.aziProvinciaOp <> '') THEN 1
        WHEN (rpmF = 3) AND (Aziende.aziProvinciaOp <> rpmV_Nvarchar) THEN 1
        WHEN (rpmF = 4) AND (Aziende.aziProvinciaOp < rpmV_Nvarchar) THEN 1
        WHEN (rpmF = 5) AND (Aziende.aziProvinciaOp > rpmV_Nvarchar) THEN 1
        ELSE 0 END
       WHEN 93 THEN CASE
        WHEN (rpmF = 1) AND (Aziende.aziStatoOp = rpmV_Nvarchar) THEN 1
        WHEN (rpmF = 2) AND (Aziende.aziStatoOp Like rpmV_Nvarchar) AND (Aziende.aziStatoOp <> '') THEN 1
        WHEN (rpmF = 3) AND (Aziende.aziStatoOp <> rpmV_Nvarchar) THEN 1
        WHEN (rpmF = 4) AND (Aziende.aziStatoOp < rpmV_Nvarchar) THEN 1
        WHEN (rpmF = 5) AND (Aziende.aziStatoOp > rpmV_Nvarchar) THEN 1
        ELSE 0 END
       WHEN 75 THEN CASE
        WHEN (rpmF = 1) AND (Aziende.aziE_Mail = rpmV_Nvarchar) THEN 1
        WHEN (rpmF = 2) AND (Aziende.aziE_Mail Like rpmV_Nvarchar) AND (Aziende.aziE_Mail <> '') THEN 1
        WHEN (rpmF = 3) AND (Aziende.aziE_Mail <> rpmV_Nvarchar) THEN 1
        WHEN (rpmF = 4) AND (Aziende.aziE_Mail < rpmV_Nvarchar) THEN 1
        WHEN (rpmF = 5) AND (Aziende.aziE_Mail > rpmV_Nvarchar) THEN 1
        ELSE 0 END
       WHEN 83 THEN CASE
        WHEN (rpmF = 1) AND (Aziende.aziFAX = rpmV_Nvarchar) THEN 1
        WHEN (rpmF = 2) AND (Aziende.aziFAX Like rpmV_Nvarchar) AND (Aziende.aziFAX <> '') THEN 1
        WHEN (rpmF = 3) AND (Aziende.aziFAX <> rpmV_Nvarchar) THEN 1
        WHEN (rpmF = 4) AND (Aziende.aziFAX < rpmV_Nvarchar) THEN 1
        WHEN (rpmF = 5) AND (Aziende.aziFAX > rpmV_Nvarchar) THEN 1
        ELSE 0 END
       WHEN 74 THEN CASE
        WHEN (rpmF = 1) AND (Aziende.aziPartitaIVA = rpmV_Nvarchar) THEN 1
        WHEN (rpmF = 2) AND (Aziende.aziPartitaIVA Like rpmV_Nvarchar) AND (Aziende.aziPartitaIVA <> '') THEN 1
        WHEN (rpmF = 3) AND (Aziende.aziPartitaIVA <> rpmV_Nvarchar) THEN 1
        WHEN (rpmF = 4) AND (Aziende.aziPartitaIVA < rpmV_Nvarchar) THEN 1
        WHEN (rpmF = 5) AND (Aziende.aziPartitaIVA > rpmV_Nvarchar) THEN 1
        ELSE 0 END
       WHEN 72 THEN CASE
        WHEN (rpmF = 1) AND (Aziende.aziRagioneSociale = rpmV_Nvarchar) THEN 1
        WHEN (rpmF = 2) AND (Aziende.aziRagioneSociale Like rpmV_Nvarchar) AND (Aziende.aziRagioneSociale <> '') THEN 1
        WHEN (rpmF = 3) AND (Aziende.aziRagioneSociale <> rpmV_Nvarchar) THEN 1
        WHEN (rpmF = 4) AND (Aziende.aziRagioneSociale < rpmV_Nvarchar) THEN 1
        WHEN (rpmF = 5) AND (Aziende.aziRagioneSociale > rpmV_Nvarchar) THEN 1
        ELSE 0 END
       WHEN 82 THEN CASE
        WHEN (rpmF = 1) AND (Aziende.aziTelefono1 = rpmV_Nvarchar) THEN 1
        WHEN (rpmF = 2) AND (Aziende.aziTelefono1 Like rpmV_Nvarchar) AND (Aziende.aziTelefono1 <> '') THEN 1
        WHEN (rpmF = 3) AND (Aziende.aziTelefono1 <> rpmV_Nvarchar) THEN 1
        WHEN (rpmF = 4) AND (Aziende.aziTelefono1 < rpmV_Nvarchar) THEN 1
        WHEN (rpmF = 5) AND (Aziende.aziTelefono1 > rpmV_Nvarchar) THEN 1
        ELSE 0 END
       WHEN 73 THEN CASE
        WHEN (rpmF = 1) AND (Aziende.aziIdDscFormaSoc = rpmV_Descrizioni) THEN 1
        WHEN (rpmF = 3) AND (Aziende.aziIdDscFormaSoc <> rpmV_Descrizioni) THEN 1
        ELSE 0 END
       WHEN 71 THEN CASE
        WHEN (Aziende.aziAtvAtecord LIKE (rpmV_NVarChar + '%')) THEN 1
        ELSE 0 END
       WHEN 106 THEN CASE
        WHEN Aziende.aziGphValueOper BETWEEN rpmV_Keys_Low AND rpmV_Keys_Upp THEN 1
        ELSE 0 END
       ELSE CASE Vdc.vdcM
        WHEN 1 THEN CASE
         WHEN (rpmF = 1) AND (vdcV_Int = rpmV_Int) THEN 1
         WHEN (rpmF = 3) AND (vdcV_Int <> rpmV_Int) THEN 1
         WHEN (rpmF = 4) AND (vdcV_Int < rpmV_Int) THEN 1
         WHEN (rpmF = 5) AND (vdcV_Int > rpmV_Int) THEN 1
         ELSE 0 END
        WHEN 2 THEN CASE
         WHEN (rpmF = 1) AND (vdcV_Money = rpmV_Money) THEN 1
         WHEN (rpmF = 3) AND (vdcV_Money <> rpmV_Money) THEN 1
         WHEN (rpmF = 4) AND (vdcV_Money < rpmV_Money) THEN 1
         WHEN (rpmF = 5) AND (vdcV_Money > rpmV_Money) THEN 1
         ELSE 0 END
        WHEN 3 THEN CASE
         WHEN (rpmF = 1) AND (vdcV_Float = rpmV_Float) THEN 1
         WHEN (rpmF = 3) AND (vdcV_Float <> rpmV_Float) THEN 1
         WHEN (rpmF = 4) AND (vdcV_Float < rpmV_Float) THEN 1
         WHEN (rpmF = 5) AND (vdcV_Float > rpmV_Float) THEN 1
         ELSE 0 END
        WHEN 4 THEN CASE
         WHEN (rpmF = 1) AND (vdcV_Nvarchar = rpmV_Nvarchar) THEN 1
         WHEN (rpmF = 2) AND (vdcV_Nvarchar Like rpmV_Nvarchar) THEN 1
         WHEN (rpmF = 3) AND (vdcV_Nvarchar <> rpmV_Nvarchar) THEN 1
         WHEN (rpmF = 4) AND (vdcV_Nvarchar < rpmV_Nvarchar) THEN 1
         WHEN (rpmF = 5) AND (vdcV_Nvarchar > rpmV_Nvarchar) THEN 1
         ELSE 0 END
        WHEN 5 THEN CASE
         WHEN (rpmF = 1) AND (vdcV_DATETIME = rpmV_DATETIME) THEN 1
         WHEN (rpmF = 3) AND (vdcV_DATETIME <> rpmV_DATETIME) THEN 1
         WHEN (rpmF = 4) AND (vdcV_DATETIME < rpmV_DATETIME) THEN 1
         WHEN (rpmF = 5) AND (vdcV_DATETIME > rpmV_DATETIME) THEN 1
         ELSE 0 END
        WHEN 6 THEN CASE
         WHEN (rpmF = 1) AND (vdcV_Descrizioni = rpmV_Descrizioni) THEN 1
         WHEN (rpmF = 3) AND (vdcV_Descrizioni <> rpmV_Descrizioni) THEN 1
         ELSE 0 END
        WHEN 7 THEN CASE
         WHEN (rpmF = 1) AND (vdcV_Keys BETWEEN rpmV_Keys_Low AND rpmV_Keys_Upp) THEN 1
         ELSE 0 END
        ELSE 0 END
       END = 1
      ) AS ric GROUP BY ricC) AS Ric
      WHERE ricTimes = @TotParamAzi
     -- Fine TempRicerche Aziende
     )
  END
 SELECT @TotArt = @@ROWCOUNT
 UPDATE TempRicerche
  SET  ricTotArticoli = @TotArt,
   ricUltimoAgg = GETDATE()
  WHERE IdRic = @IdRic
 COMMIT TRAN
 PRINT 'Articoli Ricercati ' + CAST(@TotArt AS VARCHAR)
 SELECT @sTotArt = @TotArt
 
GO
