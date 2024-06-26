USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[Get_Padri_Lng4]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[Get_Padri_Lng4](
@Codice AS VARCHAR (50), 
@IdMp   AS INTEGER, 
@IdTid  AS INTEGER) 
AS
DECLARE @RdDefValue  VARCHAR(8000)
DECLARE @SQLCommand  VARCHAR(8000)
IF @IdTid = 21
   BEGIN
        GOTO  L_StructAz
   END
IF @IdTid = -21
   BEGIN
        GOTO  L_Deleghe
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
IF @Codice = '-1'
   BEGIN
       /* Restituisce sempre un rowset vuoto */
       SELECT TOP 0 a.dgCodiceInterno  AS CodiceInterno,
                    a.dgCodiceEsterno  AS CodiceEsterno,
                    b.dscTesto         AS Descrizione,
                    a.dgLivello        AS Livello, 
                    a.dgFoglia         AS Foglia
         FROM DominiGerarchici a, DescsLng4 b
        WHERE a.dgIdDsc = b.IdDsc
          AND a.dgTipoGerarchia = @IdTid
       GOTO ExitStored
   END
 
SELECT  a1.dgCodiceInterno  AS CodiceInterno,
        a1.dgCodiceEsterno  AS CodiceEsterno,
        b.dscTesto          AS Descrizione,
        a1.dgLivello        AS Livello, 
      a1.dgFoglia           AS Foglia
  FROM DominiGerarchici a, DominiGerarchici a1, DescsLng4 b
 WHERE a1.dgIdDsc = b.IdDsc
   AND (a1.IdDg IN (SELECT b1.IdDg 
                    FROM DominiGerarchici b, DominiGerarchici b1, MPDominiGerarchici c
                   WHERE b.IdDg = c.mpdgIdDg
                     AND b1.dgPath like b.dgPath + '%'
                     AND b1.dgTipoGErarchia = @IDTid
                     AND b.dgTipoGErarchia = @IDTid
                     AND c.mpdgDeleted = 0
                     AND c.mpdgIdMp = @IdMp) or a1.dgLivello = 0)
   AND a.dgTipoGerarchia  = @IdTid
   AND a1.dgTipoGerarchia = @IdTid
   AND a.dgCodiceInterno  = @Codice
   AND (a.dgPath like a1.dgPath + '%')
   AND a1.dgDeleted = 0
   AND a.dgDeleted = 0
ORDER BY a1.dgPath
 GOTO ExitStored
l_All:
IF @Codice = '-1'
   BEGIN
       /* Restituisce sempre un rowSET vuoto */
       SELECT top 0 a.dgCodiceInterno  AS CodiceInterno,
                    a.dgCodiceEsterno  AS CodiceEsterno,
                    b.dscTesto         AS Descrizione,
                    a.dgLivello        AS Livello, 
                a.dgFoglia              AS Foglia
         FROM DominiGerarchici a, DescsLng4 b
        WHERE a.dgIdDsc = b.IdDsc
          AND a.dgTipoGerarchia = @IdTid
       GOTO ExitStored
   END
 
SELECT  a1.dgCodiceInterno  AS CodiceInterno,
        a1.dgCodiceEsterno  AS CodiceEsterno,
        b.dscTesto          AS Descrizione,
        a1.dgLivello        AS Livello,
      a1.dgFoglia           AS Foglia
  FROM DominiGerarchici a, DominiGerarchici a1, DescsLng4 b
 WHERE a1.dgIdDsc = b.IdDsc
   AND a.dgTipoGerarchia  = @IdTid
   AND a1.dgTipoGerarchia = @IdTid
   AND a.dgCodiceInterno  = @Codice
   AND (a.dgPath like a1.dgPath + '%')
   AND a1.dgDeleted = 0
   AND a.dgDeleted = 0
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
                                       ' AND ((LEN(Path) / 5) - 1) = 0  AND Deleted = 0
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
                                         AND ((LEN(a.Path) / 5) - 1) = 0
                                         AND a.IdStrutt = b.IdStrutt  AND a.Deleted = 0
                                       ORDER BY a.IdAz, a.Path'
         END
    EXEC (@SQLCommand)
    GOTO ExitStored
END
IF @rdDefValue = ''
 BEGIN
         SET @SQLCommand = 'SELECT CAST(IdAz AS VARCHAR) + ''-'' + Path AS CodiceInterno,
                                     Descrizione                       AS CodiceEsterno,  
                                     Descrizione                       AS Descrizione,  
                                     (LEN(Path) / 5) - 1               AS Livello,
                                     0                                 AS Foglia
                                FROM AZ_STRUTTURA
                               WHERE ''' + @Codice + ''' LIKE  CAST(IdAz AS VARCHAR) + ''-'' + Path + ''%''' +
                               '  AND Deleted = 0 ' + 
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
                               WHERE a.IdAz = b.IdAz ' +
                               ' AND ''' + @Codice + ''' LIKE  CAST(a.IdAz AS VARCHAR) + ''-'' + a.Path + ''%''' +
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
           AND ((LEN(Path) / 5) - 1) = 0  AND Deleted = 0
         ORDER BY IdAz, Path
 
        GOTO ExitStored
END
SELECT CAST(IdAz AS VARCHAR) + '-' + Path AS CodiceInterno,
       Descrizione                       AS CodiceEsterno,  
       Descrizione                       AS Descrizione,  
       (LEN(Path) / 5) - 1               AS Livello,
       0                                 AS Foglia
  FROM AZ_DELEGHE
 WHERE @Codice LIKE  CAST(IdAz AS VARCHAR) + '-' + Path + '%'
   AND Deleted = 0
   ORDER BY IdAz, Path
ExitStored:
GO
