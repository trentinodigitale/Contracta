USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[Get_Figli_Lng4]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[Get_Figli_Lng4](
@Codice AS VARCHAR (50), 
@IdMp   AS INTEGER, 
@IdTid  AS INTEGER) 
AS
DECLARE @Livello     INT
DECLARE @RdDefValue  VARCHAR(8000)
DECLARE @SQLCommand  VARCHAR(8000)
IF @IdTid = 21
   BEGIN
        GOTO L_StructAz
   END
IF @IdTid = -21
   BEGIN
        GOTO L_Deleghe
   END
IF @IdMp = -1
   BEGIN
        GOTO L_All
   END
IF NOT EXISTS (SELECT * FROM MPDominiGerarchici WHERE mpdgTipo = @IdTid AND mpdgIdMp = @IdMp)
   BEGIN
          SET @IdMp = 0
          SELECT @IdMp = IdMp FROM MarketPlace WHERE substring (mpOpzioni, 1, 1) = '1'
          IF @IdMp = 0
             BEGIN
                    RAISERROR ('MetaMarketplace non trovato', 16, 1) 
                    RETURN  99
             END
   END
IF  @Codice = '-1'
   BEGIN
        SELECT a1.dgCodiceInterno   AS CodiceInterno,
               a1.dgCodiceEsterno   AS CodiceEsterno,
               b.dscTesto           AS Descrizione,
               a1.dgLivello         AS Livello, 
               a1.dgFoglia          AS Foglia
          FROM DominiGerarchici a1, DescsLng4 b
         WHERE a1.dgIdDsc = b.IdDsc
           AND a1.dgTipoGerarchia = @IdTid
           AND a1.dgLivello = 0
           AND a1.dgDeleted = 0
        GOTO ExitStored
   END
IF  @Codice = '0'
   BEGIN
        SELECT @Livello = min (dgLivello)
          FROM DominiGerarchici
         WHERE dgTipoGerarchia = @IDTid 
           AND IdDg in (SELECT mpdgIdDg FROM MPDominiGerarchici WHERE mpdgIdMp = @IdMp AND mpdgDeleted = 0)
        SELECT a1.dgCodiceInterno  AS CodiceInterno,
               a1.dgCodiceEsterno  AS CodiceEsterno,
               b.dscTesto          AS Descrizione,
               a1.dgLivello        AS Livello, 
               a1.dgFoglia         AS Foglia
          FROM DominiGerarchici a1, DescsLng4 b
         WHERE a1.dgIdDsc = b.IdDsc
           AND a1.dgTipoGerarchia = @IdTid
           AND (a1.dgLivello = @Livello or a1.dgLivello = 0)
           AND a1.IdDg in (SELECT b1.IdDg 
                             FROM DominiGerarchici b, DominiGerarchici b1, MPDominiGerarchici c
                            WHERE b.IdDg = c.mpdgIdDg
                              AND b.dgPath like b1.dgPath + '%'
                              AND b.dgTIpoGerarchia = @IDTid
                              AND b1.dgTIpoGerarchia = @IDTid
                              AND c.mpdgDeleted = 0
                              AND c.mpdgIdMp = @IdMp)
           AND a1.dgDeleted = 0
        ORDER BY a1.dgPath
        GOTO ExitStored
   END
SELECT a1.dgCodiceInterno  AS CodiceInterno,
       a1.dgCodiceEsterno  AS CodiceEsterno,
       b.dscTesto          AS Descrizione,
       a1.dgLivello        AS Livello, 
       a1.dgFoglia         AS Foglia
  FROM DominiGerarchici a, DominiGerarchici a1, DescsLng4 b
 WHERE a1.dgIdDsc = b.IdDsc
   AND a.IdDg in (SELECT b1.IdDg 
                    FROM DominiGerarchici b, DominiGerarchici b1, MPDominiGerarchici c
                   WHERE b.IdDg = c.mpdgIdDg
                     AND b1.dgPath like b.dgPath + '%'
                     AND c.mpdgDeleted = 0
                     AND c.mpdgIdMp = @IdMp)
   AND a.dgTipoGerarchia = @IdTid
   AND a1.dgTipoGerarchia = @IdTid
   AND a.dgCodiceInterno = @Codice
   AND a1.dgPath like a.dgPath + '%'
   AND (a1.dgLivello = a.dgLivello + 1 or a1.dgLivello = a.dgLivello)
   AND a1.dgDeleted = 0
ORDER BY a1.dgPath
 GOTO ExitStored
L_All:
IF  @Codice = '-1'
   BEGIN
        SELECT a1.dgCodiceInterno  AS CodiceInterno,
               a1.dgCodiceEsterno  AS CodiceEsterno,
               b.dscTesto          AS Descrizione,
               a1.dgLivello        AS Livello, 
               a1.dgFoglia         AS Foglia
          FROM DominiGerarchici a1, DescsLng4 b
         WHERE a1.dgIdDsc = b.IdDsc
           AND a1.dgTipoGerarchia = @IdTid
           AND a1.dgLivello = 0
           AND a1.dgDeleted = 0
        GOTO ExitStored
   END
IF  @Codice = '0'
   BEGIN
        SELECT a1.dgCodiceInterno  AS CodiceInterno,
               a1.dgCodiceEsterno  AS CodiceEsterno,
               b.dscTesto          AS Descrizione,
               a1.dgLivello        AS Livello, 
               a1.dgFoglia         AS Foglia
          FROM DominiGerarchici a1, DescsLng4 b
         WHERE a1.dgIdDsc = b.IdDsc
           AND a1.dgTipoGerarchia = @IdTid
           AND (a1.dgLivello = 1 OR a1.dgLivello = 0)
           AND a1.dgDeleted = 0
        ORDER BY a1.dgPath
        GOTO ExitStored
   END
SELECT a1.dgCodiceInterno  AS CodiceInterno,
       a1.dgCodiceEsterno  AS CodiceEsterno,
       b.dscTesto          AS Descrizione,
       a1.dgLivello        AS Livello, 
       a1.dgFoglia         AS Foglia
  FROM DominiGerarchici a, DominiGerarchici a1, DescsLng4 b
 WHERE a1.dgIdDsc = b.IdDsc
   AND a.dgTipoGerarchia = @IdTid
   AND a1.dgTipoGerarchia = @IdTid
   AND a.dgCodiceInterno = @Codice
   AND a1.dgPath like a.dgPath + '%'
   AND (a1.dgLivello = a.dgLivello + 1 or a1.dgLivello = a.dgLivello)
   AND a1.dgDeleted = 0
ORDER BY a1.dgPath
 GOTO ExitStored
L_StructAz:
SELECT @RdDefValue = rdDefValue 
  FROM RegDefault
 WHERE rdKey = 'SediDest'
   AND rdIdMp = @IdMp
   AND rdDeleted = 0
IF @rdDefValue IS NULL
BEGIN
        SELECT @RdDefValue = rdDefValue 
          FROM RegDefault
         WHERE rdKey = 'SediDest'
           AND rdIdMp = 0
           AND rdDeleted = 0
END
IF @rdDefValue IS NULL
    BEGIN
      SET @rdDefValue = ''
    END
ELSE
    BEGIN
         SET @rdDefValue = REPLACE (@rdDefValue, ';', '+'' ''+')
    END
/* Se il codice _ senza '-' allora restituisco tutta la struttura aziendale per l'IdAzi passato in @Codice */
IF CHARINDEX('-', @Codice) = 0
BEGIN
      IF @rdDefValue = ''
         BEGIN
                 SET @SQLCommand = 'SELECT CAST(IdAz AS VARCHAR) + ''-'' + Path AS CodiceInterno,
                                             Descrizione                       AS CodiceEsterno,  
                                             Descrizione                       AS Descrizione,  
                                             (LEN(Path) / 5) - 1               AS Livello,
                                             0                                 AS Foglia
                                        FROM AZ_STRUTTURA
                                       WHERE IdAz = ' + @Codice + 
                                       ' AND ((LEN(Path) / 5) - 1) IN (0, 1)  AND Deleted = 0
                                       ORDER BY IdAz, Path'
         END
      ELSE
         BEGIN
                 SET @SQLCommand = 'SELECT CAST(a.IdAz AS VARCHAR) + ''-'' + a.Path AS CodiceInterno,
                                             Descrizione                           AS CodiceEsterno, ' +
                                             @rdDefValue                   + '     AS Descrizione,
                                             (LEN(a.Path) / 5) - 1                 AS Livello,
                                             0                                     AS Foglia
                                        FROM AZ_STRUTTURA a, v_AttrStrAz b
                                       WHERE a.IdAz = ' + @Codice +
                                       ' AND a.IdAz = b.IdAz
                                         AND ((LEN(a.Path) / 5) - 1) IN (0, 1)
                                         AND a.IdStrutt = b.IdStrutt  AND a.Deleted = 0
                                       ORDER BY a.IdAz, a.Path'
         END
    EXEC (@SQLCommand)
    GOTO ExitStored
END
SELECT @Livello = ((LEN(Path) / 5) - 1)
  FROM AZ_STRUTTURA 
 WHERE CAST(IdAz AS VARCHAR) + '-' + Path = @Codice
   AND Deleted = 0
IF @Livello IS NULL
   SET @Livello = 0
IF @rdDefValue = ''
 BEGIN
         SET @SQLCommand = 'SELECT CAST(IdAz AS VARCHAR) + ''-'' + Path AS CodiceInterno,
                                     Descrizione                       AS CodiceEsterno,  
                                     Descrizione                       AS Descrizione,  
                                     (LEN(Path) / 5) - 1               AS Livello,
                                     0                                 AS Foglia
                                FROM AZ_STRUTTURA
                               WHERE CAST(IdAz AS VARCHAR) + ''-'' + Path LIKE ''' + @Codice + '''+ ''%''' +
                               ' AND ((LEN(Path) / 5) - 1) IN (' + CAST(@Livello AS VARCHAR) + ',' + CAST (@Livello + 1 AS VARCHAR) + ')' + 
                               ' AND Deleted = 0 ' + 
                               ' ORDER BY IdAz, Path'
 END
ELSE
 BEGIN
         SET @SQLCommand = 'SELECT CAST(a.IdAz AS VARCHAR) + ''-'' + a.Path AS CodiceInterno,
                                     Descrizione                           AS CodiceEsterno, ' +
                                     @rdDefValue                   + '     AS Descrizione,
                                     (LEN(a.Path) / 5) - 1                 AS Livello,
                                     0                                     AS Foglia
                                FROM AZ_STRUTTURA a, v_AttrStrAz b
                               WHERE CAST(a.IdAz AS VARCHAR) + ''-'' + a.Path LIKE ''' + @Codice + '''+ ''%''' +
                               ' AND a.IdAz = b.IdAz ' +
                               ' AND ((LEN(Path) / 5) - 1) IN (' + CAST(@Livello AS VARCHAR) + ',' + CAST (@Livello + 1 AS VARCHAR) + ')' + 
                               ' AND a.IdStrutt = b.IdStrutt  AND a.Deleted = 0
                               ORDER BY a.IdAz, a.Path'
 END
EXEC (@SQLCommand)
GOTO ExitStored
L_Deleghe:
/* Se il codice _ senza '-' allora restituisco tutta la struttura aziendale per l'IdAzi passato in @Codice */
IF CHARINDEX('-', @Codice) = 0
BEGIN
     SELECT CAST(IdAz AS VARCHAR) + '-' + Path AS CodiceInterno,
            Descrizione                       AS CodiceEsterno,  
            Descrizione                       AS Descrizione,  
            (LEN(Path) / 5) - 1               AS Livello,
            0                                 AS Foglia
       FROM AZ_DELEGHE
      WHERE IdAz = @Codice
        AND ((LEN(Path) / 5) - 1) IN (0, 1) AND Deleted = 0
        ORDER BY IdAz, Path
      GOTO ExitStored
END
SELECT @Livello = ((LEN(Path) / 5) - 1)
  FROM AZ_DELEGHE
 WHERE CAST(IdAz AS VARCHAR) + '-' + Path = @Codice
   AND Deleted = 0
IF @Livello IS NULL
   SET @Livello = 0
SELECT CAST(IdAz AS VARCHAR) + '-' + Path AS CodiceInterno,
       Descrizione                       AS CodiceEsterno,  
       Descrizione                       AS Descrizione,  
       (LEN(Path) / 5) - 1               AS Livello,
       0                                 AS Foglia
  FROM AZ_DELEGHE
 WHERE CAST(IdAz AS VARCHAR) + '-' + Path LIKE @Codice + '%'
   AND ((LEN(Path) / 5) - 1) IN (@Livello, @Livello + 1)
   AND Deleted = 0 
ORDER BY IdAz, Path
ExitStored:
GO
