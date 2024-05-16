USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[GetPath_I]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GetPath_I](@Filtro AS NVARCHAR (500), @IdMp AS INT, @IdTid AS INT)
AS

DECLARE @Livello AS INT

IF @IdMp = -1
   GOTO L_All
   
IF NOT EXISTS (SELECT * FROM MPDominiGerarchici WHERE mpdgTipo = @IdTid AND mpdgIdMp = @IdMp)
BEGIN
        SET @IdMp = 0
        
        SELECT @IdMp = IdMp 
          FROM MarketPlace 
         WHERE SUBSTRING (mpOpzioni, 1, 1) = '1'

        IF @IdMp = 0
        BEGIN
                RAISERROR ('MetaMarketplace non trovato', 16, 1) 
                RETURN  99
        END
END


SELECT @Livello = MIN (dgLivello)
  FROM DominiGerarchici
 WHERE dgTipoGerarchia = @IDTid 
   AND IdDg in (SELECT mpdgIdDg FROM MPDominiGerarchici WHERE mpdgIdMp = @IdMp AND mpdgDeleted = 0)
   
SELECT vv.IdDg, vv.CodiceInterno, vv.CodiceEsterno,  vv.Descrizione, vv.Path, vv.Livello, vv.Foglia
  FROM
(
SELECT a1.IdDg
     , a1.dgCodiceInterno                                       AS CodiceInterno
     , a1.dgCodiceEsterno                                       AS CodiceEsterno
     , CAST(b1.dsctesto AS NVARCHAR(200))                       AS Descrizione
     , CASE @Livello 
            WHEN 1 THEN
                         CAST(b6.dscTesto AS NVARCHAR(200)) + '/' +
                         CAST(b5.dscTesto AS NVARCHAR(200)) + '/' +
                         CAST(b4.dscTesto AS NVARCHAR(200)) + '/' +
                         CAST(b3.dscTesto AS NVARCHAR(200)) + '/' +
                         CAST(b2.dscTesto AS NVARCHAR(200)) + '/' +
                         CAST(b1.dscTesto AS NVARCHAR(200)) 
            WHEN 2 THEN
                         CAST(b5.dscTesto AS NVARCHAR(200)) + '/' +
                         CAST(b4.dscTesto AS NVARCHAR(200)) + '/' +
                         CAST(b3.dscTesto AS NVARCHAR(200)) + '/' +
                         CAST(b2.dscTesto AS NVARCHAR(200)) + '/' +
                         CAST(b1.dscTesto AS NVARCHAR(200)) 
            WHEN 3 THEN
                         CAST(b4.dscTesto AS NVARCHAR(200)) + '/' +
                         CAST(b3.dscTesto AS NVARCHAR(200)) + '/' +
                         CAST(b2.dscTesto AS NVARCHAR(200)) + '/' +
                         CAST(b1.dscTesto AS NVARCHAR(200)) 
            WHEN 4 THEN
                         CAST(b3.dscTesto AS NVARCHAR(200)) + '/' +
                         CAST(b2.dscTesto AS NVARCHAR(200)) + '/' +
                         CAST(b1.dscTesto AS NVARCHAR(200)) 
            WHEN 5 THEN
                         CAST(b2.dscTesto AS NVARCHAR(200)) + '/' +
                         CAST(b1.dscTesto AS NVARCHAR(200)) 
            WHEN 6 THEN
                         CAST(b1.dscTesto AS NVARCHAR(200)) 
       END                                                      AS Path
     , a1.dgLivello                                             AS Livello
     , a1.dgfoglia                                              AS Foglia
  FROM DominiGerarchici a1
     , DominiGerarchici a2
     , DominiGerarchici a3
     , DominiGerarchici a4
     , DominiGerarchici a5
     , DominiGerarchici a6
     , DescsI b1
     , DescsI b2
     , DescsI b3
     , DescsI b4
     , DescsI b5
     , DescsI b6
 WHERE a1.dgIdDsc = b1.iddsc 
   AND a2.dgIdDsc = b2.iddsc
   AND a3.dgIdDsc = b3.iddsc
   AND a4.dgIdDsc = b4.iddsc
   AND a5.dgIdDsc = b5.iddsc
   AND a6.dgIdDsc = b6.iddsc
   AND a1.dgLivello = 6
   AND a2.dgLivello = 5
   AND a3.dgLivello = 4
   AND a4.dgLivello = 3
   AND a5.dgLivello = 2
   AND a6.dgLivello = 1
   AND a1.dgPath LIKE a6.dgPath + '%'
   AND a1.dgPath LIKE a5.dgPath + '%'
   AND a1.dgPath LIKE a4.dgPath + '%'
   AND a1.dgPath LIKE a3.dgPath + '%'
   AND a1.dgPath LIKE a2.dgPath + '%'
   AND a1.dgTipoGerarchia = @IdTid
   AND a2.dgTipoGerarchia = @IdTid
   AND a3.dgTipoGerarchia = @IdTid
   AND a4.dgTipoGerarchia = @IdTid
   AND a5.dgTipoGerarchia = @IdTid
   AND a6.dgTipoGerarchia = @IdTid
   AND a1.dgDeleted = 0
   AND a2.dgDeleted = 0
   AND a3.dgDeleted = 0
   AND a4.dgDeleted = 0
   AND a5.dgDeleted = 0
   AND a6.dgDeleted = 0
   AND b1.dsctesto LIKE @filtro
   
UNION

SELECT a1.IdDg
     , a1.dgCodiceInterno                                       AS CodiceInterno
     , a1.dgCodiceEsterno                                       AS CodiceEsterno
     , CAST(b1.dsctesto AS NVARCHAR(200))                       AS Descrizione
     , CASE @Livello 
            WHEN 1 THEN
                         CAST(b5.dscTesto AS NVARCHAR(200)) + '/' +
                         CAST(b4.dscTesto AS NVARCHAR(200)) + '/' +
                         CAST(b3.dscTesto AS NVARCHAR(200)) + '/' +
                         CAST(b2.dscTesto AS NVARCHAR(200)) + '/' +
                         CAST(b1.dscTesto AS NVARCHAR(200)) 
            WHEN 2 THEN
                         CAST(b4.dscTesto AS NVARCHAR(200)) + '/' +
                         CAST(b3.dscTesto AS NVARCHAR(200)) + '/' +
                         CAST(b2.dscTesto AS NVARCHAR(200)) + '/' +
                         CAST(b1.dscTesto AS NVARCHAR(200)) 
            WHEN 3 THEN
                         CAST(b3.dscTesto AS NVARCHAR(200)) + '/' +
                         CAST(b2.dscTesto AS NVARCHAR(200)) + '/' +
                         CAST(b1.dscTesto AS NVARCHAR(200)) 
            WHEN 4 THEN
                         CAST(b2.dscTesto AS NVARCHAR(200)) + '/' +
                         CAST(b1.dscTesto AS NVARCHAR(200)) 
            WHEN 5 THEN
                         CAST(b1.dscTesto AS NVARCHAR(200)) 
       END                                                      AS Path
     , a1.dgLivello                                             AS Livello
     , a1.dgfoglia                                              AS Foglia
  FROM DominiGerarchici a1
     , DominiGerarchici a2
     , DominiGerarchici a3
     , DominiGerarchici a4
     , DominiGerarchici a5
     , DescsI b1
     , DescsI b2
     , DescsI b3
     , DescsI b4
     , DescsI b5
 WHERE a1.dgIdDsc = b1.iddsc 
   AND a2.dgIdDsc = b2.iddsc
   AND a3.dgIdDsc = b3.iddsc
   AND a4.dgIdDsc = b4.iddsc
   AND a5.dgIdDsc = b5.iddsc
   AND a1.dgLivello = 5
   AND a2.dgLivello = 4
   AND a3.dgLivello = 3
   AND a4.dgLivello = 2
   AND a5.dgLivello = 1
   AND a1.dgPath LIKE a5.dgPath + '%'
   AND a1.dgPath LIKE a4.dgPath + '%'
   AND a1.dgPath LIKE a3.dgPath + '%'
   AND a1.dgPath LIKE a2.dgPath + '%'
   AND a1.dgTipoGerarchia = @IdTid
   AND a2.dgTipoGerarchia = @IdTid
   AND a3.dgTipoGerarchia = @IdTid
   AND a4.dgTipoGerarchia = @IdTid
   AND a5.dgTipoGerarchia = @IdTid
   AND a1.dgDeleted = 0
   AND a2.dgDeleted = 0
   AND a3.dgDeleted = 0
   AND a4.dgDeleted = 0
   AND a5.dgDeleted = 0
   AND b1.dsctesto LIKE @filtro
   
UNION

SELECT a1.IdDg
     , a1.dgCodiceInterno                                       AS CodiceInterno
     , a1.dgCodiceEsterno                                       AS CodiceEsterno
     , CAST(b1.dsctesto AS NVARCHAR(200))                       AS Descrizione
     , CASE @Livello 
            WHEN 1 THEN
                         CAST(b4.dscTesto AS NVARCHAR(200)) + '/' +
                         CAST(b3.dscTesto AS NVARCHAR(200)) + '/' +
                         CAST(b2.dscTesto AS NVARCHAR(200)) + '/' +
                         CAST(b1.dscTesto AS NVARCHAR(200)) 
            WHEN 2 THEN
                         CAST(b3.dscTesto AS NVARCHAR(200)) + '/' +
                         CAST(b2.dscTesto AS NVARCHAR(200)) + '/' +
                         CAST(b1.dscTesto AS NVARCHAR(200)) 
            WHEN 3 THEN
                         CAST(b2.dscTesto AS NVARCHAR(200)) + '/' +
                         CAST(b1.dscTesto AS NVARCHAR(200)) 
            WHEN 4 THEN
                         CAST(b1.dscTesto AS NVARCHAR(200)) 
       END                                                      AS Path
     , a1.dgLivello                                             AS Livello
     , a1.dgfoglia                                              AS Foglia
  FROM DominiGerarchici a1
     , DominiGerarchici a2
     , DominiGerarchici a3
     , DominiGerarchici a4
     , DescsI b1
     , DescsI b2
     , DescsI b3
     , DescsI b4
 WHERE a1.dgIdDsc = b1.iddsc 
   AND a2.dgIdDsc = b2.iddsc
   AND a3.dgIdDsc = b3.iddsc
   AND a4.dgIdDsc = b4.iddsc
   AND a1.dgLivello = 4
   AND a2.dgLivello = 3
   AND a3.dgLivello = 2
   AND a4.dgLivello = 1
   AND a1.dgPath LIKE a4.dgPath + '%'
   AND a1.dgPath LIKE a3.dgPath + '%'
   AND a1.dgPath LIKE a2.dgPath + '%'
   AND a1.dgTipoGerarchia = @IdTid
   AND a2.dgTipoGerarchia = @IdTid
   AND a3.dgTipoGerarchia = @IdTid
   AND a4.dgTipoGerarchia = @IdTid
   AND a1.dgDeleted = 0
   AND a2.dgDeleted = 0
   AND a3.dgDeleted = 0
   AND a4.dgDeleted = 0
   AND b1.dsctesto LIKE @filtro
   
UNION

SELECT a1.IdDg
     , a1.dgCodiceInterno                                       AS CodiceInterno
     , a1.dgCodiceEsterno                                       AS CodiceEsterno
     , CAST(b1.dsctesto AS NVARCHAR(200))                       AS Descrizione
     , CASE (@livello)
            WHEN 1 THEN
                    CAST(b3.dscTesto AS NVARCHAR(200)) + '/' +
                    CAST(b2.dscTesto AS NVARCHAR(200)) + '/' +
                    CAST(b1.dscTesto AS NVARCHAR(200)) 
            WHEN 2 THEN
                    CAST(b2.dscTesto AS NVARCHAR(200)) + '/' +
                    CAST(b1.dscTesto AS NVARCHAR(200)) 
            WHEN 3 THEN
                    CAST(b2.dscTesto AS NVARCHAR(200)) + '/' +
                    CAST(b1.dscTesto AS NVARCHAR(200)) 
            ELSE  ''
       END                                                      AS Path
     , a1.dgLivello                                             AS Livello
     , a1.dgfoglia                                              AS Foglia
  FROM DominiGerarchici a1
     , DominiGerarchici a2
     , DominiGerarchici a3
     , DescsI b1
     , DescsI b2
     , DescsI b3
 WHERE a1.dgIdDsc = b1.iddsc 
   AND a2.dgIdDsc = b2.iddsc
   AND a3.dgIdDsc = b3.iddsc
   AND a1.dgLivello = 3
   AND a2.dgLivello = 2
   AND a3.dgLivello = 1
   AND a1.dgPath LIKE a3.dgPath + '%'
   AND a1.dgPath LIKE a2.dgPath + '%'
   AND a1.dgTipoGerarchia = @IdTid
   AND a2.dgTipoGerarchia = @IdTid
   AND a3.dgTipoGerarchia = @IdTid
   AND a1.dgDeleted = 0
   AND a2.dgDeleted = 0
   AND a3.dgDeleted = 0
   AND b1.dsctesto LIKE @filtro
   
UNION

SELECT a1.IdDg
     , a1.dgCodiceInterno                                       AS CodiceInterno
     , a1.dgCodiceEsterno                                       AS CodiceEsterno
     , CAST(b1.dsctesto AS NVARCHAR(200))                       AS Descrizione
     , CASE @Livello
            WHEN 1 THEN
                       CAST(b2.dscTesto AS NVARCHAR(200)) + '/' +
                       CAST(b1.dscTesto AS NVARCHAR(200)) 
            WHEN 2 THEN
                       CAST(b1.dscTesto AS NVARCHAR(200)) 
            ELSE ''
       END                                                      AS Path
       , a1.dgLivello                                           AS Livello
       , a1.dgfoglia                                            AS Foglia
  FROM DominiGerarchici a1
     , DominiGerarchici a2
     , DescsI b1
     , DescsI b2
 WHERE a1.dgIdDsc = b1.iddsc 
   AND a2.dgIdDsc = b2.iddsc
   AND a1.dgLivello = 2
   AND a2.dgLivello = 1
   AND a1.dgPath LIKE a2.dgPath + '%'
   AND a1.dgTipoGerarchia = @IdTid
   AND a2.dgTipoGerarchia = @IdTid
   AND a1.dgDeleted = 0
   AND a2.dgDeleted = 0
   AND b1.dsctesto LIKE @filtro
   
UNION

SELECT a1.IdDg
     , a1.dgCodiceInterno                                       AS CodiceInterno
     , a1.dgCodiceEsterno                                       AS CodiceEsterno
     , CAST(b1.dsctesto AS NVARCHAR(200))                       AS Descrizione
     , CAST(b1.dscTesto AS NVARCHAR(200))                       AS Path
     , a1.dgLivello                                             AS Livello
     , a1.dgfoglia                                              AS Foglia
  FROM DominiGerarchici a1
     , DescsI b1
 WHERE a1.dgIdDsc = b1.iddsc 
   AND a1.dgLivello = 1
   AND a1.dgTipoGerarchia = @IdTid
   AND a1.dgDeleted = 0
   AND b1.dsctesto LIKE @filtro
) vv ,

(SELECT DISTINCT b1.IdDg 
   FROM DominiGerarchici b
      , DominiGerarchici b1
      , MPDominiGerarchici c
  WHERE b.IdDg = c.mpdgIdDg
    AND b1.dgPath LIKE b.dgPath + '%'
    AND b1.dgTipoGerarchia = @IdTid
    AND b.dgTipoGerarchia = @IdTid
    AND c.mpdgDeleted = 0
    AND c.mpdgIdMp = @IdMp) vv1
  WHERE vv.iddg = vv1.IdDg 
ORDER BY vv.Path
 GOTO ExitStored

L_All:

SELECT vv.IdDg, vv.CodiceInterno, vv.CodiceEsterno,  vv.Descrizione, vv.Path, vv.Livello, vv.Foglia
  FROM
(

SELECT a1.IdDg
     , a1.dgCodiceInterno                                       AS CodiceInterno
     , a1.dgCodiceEsterno                                       AS CodiceEsterno
     , CAST(b1.dsctesto AS NVARCHAR(200))                       AS Descrizione
     , CAST(b6.dscTesto AS NVARCHAR(200)) + '/' +
       CAST(b5.dscTesto AS NVARCHAR(200)) + '/' +
       CAST(b4.dscTesto AS NVARCHAR(200)) + '/' +
       CAST(b3.dscTesto AS NVARCHAR(200)) + '/' +
       CAST(b2.dscTesto AS NVARCHAR(200)) + '/' +
       CAST(b1.dscTesto AS NVARCHAR(200))                       AS Path
     , a1.dgLivello                                             AS Livello
     , a1.dgfoglia                                              AS Foglia
  FROM DominiGerarchici a1
     , DominiGerarchici a2
     , DominiGerarchici a3
     , DominiGerarchici a4
     , DominiGerarchici a5
     , DominiGerarchici a6
     , DescsI b1
     , DescsI b2
     , DescsI b3
     , DescsI b4
     , DescsI b5
     , DescsI b6
 WHERE a1.dgIdDsc = b1.iddsc 
   AND a2.dgIdDsc = b2.iddsc
   AND a3.dgIdDsc = b3.iddsc
   AND a4.dgIdDsc = b4.iddsc
   AND a5.dgIdDsc = b5.iddsc
   AND a6.dgIdDsc = b6.iddsc
   AND a1.dgLivello = 6
   AND a2.dgLivello = 5
   AND a3.dgLivello = 4
   AND a4.dgLivello = 3
   AND a5.dgLivello = 2
   AND a6.dgLivello = 1
   AND a1.dgPath LIKE a6.dgPath + '%'
   AND a1.dgPath LIKE a5.dgPath + '%'
   AND a1.dgPath LIKE a4.dgPath + '%'
   AND a1.dgPath LIKE a3.dgPath + '%'
   AND a1.dgPath LIKE a2.dgPath + '%'
   AND a1.dgTipoGerarchia = @IdTid
   AND a2.dgTipoGerarchia = @IdTid
   AND a3.dgTipoGerarchia = @IdTid
   AND a4.dgTipoGerarchia = @IdTid
   AND a5.dgTipoGerarchia = @IdTid
   AND a6.dgTipoGerarchia = @IdTid
   AND a1.dgDeleted = 0
   AND a2.dgDeleted = 0
   AND a3.dgDeleted = 0
   AND a4.dgDeleted = 0
   AND a5.dgDeleted = 0
   AND a6.dgDeleted = 0
   AND b1.dsctesto LIKE @filtro

UNION

SELECT a1.IdDg
     , a1.dgCodiceInterno                                       AS CodiceInterno
     , a1.dgCodiceEsterno                                       AS CodiceEsterno
     , CAST(b1.dsctesto AS NVARCHAR(200))                       AS Descrizione
     , CAST(b5.dscTesto AS NVARCHAR(200)) + '/' +
       CAST(b4.dscTesto AS NVARCHAR(200)) + '/' +
       CAST(b3.dscTesto AS NVARCHAR(200)) + '/' +
       CAST(b2.dscTesto AS NVARCHAR(200)) + '/' +
       CAST(b1.dscTesto AS NVARCHAR(200))                       AS Path
     , a1.dgLivello                                             AS Livello
     , a1.dgfoglia                                              AS Foglia
  FROM DominiGerarchici a1
     , DominiGerarchici a2
     , DominiGerarchici a3
     , DominiGerarchici a4
     , DominiGerarchici a5
     , DescsI b1
     , DescsI b2
     , DescsI b3
     , DescsI b4
     , DescsI b5
 WHERE a1.dgIdDsc = b1.iddsc 
   AND a2.dgIdDsc = b2.iddsc
   AND a3.dgIdDsc = b3.iddsc
   AND a4.dgIdDsc = b4.iddsc
   AND a5.dgIdDsc = b5.iddsc
   AND a1.dgLivello = 5
   AND a2.dgLivello = 4
   AND a3.dgLivello = 3
   AND a4.dgLivello = 2
   AND a5.dgLivello = 1
   AND a1.dgPath LIKE a5.dgPath + '%'
   AND a1.dgPath LIKE a4.dgPath + '%'
   AND a1.dgPath LIKE a3.dgPath + '%'
   AND a1.dgPath LIKE a2.dgPath + '%'
   AND a1.dgTipoGerarchia = @IdTid
   AND a2.dgTipoGerarchia = @IdTid
   AND a3.dgTipoGerarchia = @IdTid
   AND a4.dgTipoGerarchia = @IdTid
   AND a5.dgTipoGerarchia = @IdTid
   AND a1.dgDeleted = 0
   AND a2.dgDeleted = 0
   AND a3.dgDeleted = 0
   AND a4.dgDeleted = 0
   AND a5.dgDeleted = 0
   AND b1.dsctesto LIKE @filtro

UNION

SELECT a1.IdDg
     , a1.dgCodiceInterno                                       AS CodiceInterno
     , a1.dgCodiceEsterno                                       AS CodiceEsterno
     , CAST(b1.dsctesto AS NVARCHAR(200))                       AS Descrizione
     , CAST(b4.dscTesto AS NVARCHAR(200)) + '/' +
       CAST(b3.dscTesto AS NVARCHAR(200)) + '/' +
       CAST(b2.dscTesto AS NVARCHAR(200)) + '/' +
       CAST(b1.dscTesto AS NVARCHAR(200))                       AS Path
     , a1.dgLivello                                             AS Livello
     , a1.dgfoglia                                              AS Foglia
  FROM DominiGerarchici a1
     , DominiGerarchici a2
     , DominiGerarchici a3
     , DominiGerarchici a4
     , DescsI b1
     , DescsI b2
     , DescsI b3
     , DescsI b4
 WHERE a1.dgIdDsc = b1.iddsc 
   AND a2.dgIdDsc = b2.iddsc
   AND a3.dgIdDsc = b3.iddsc
   AND a4.dgIdDsc = b4.iddsc
   AND a1.dgLivello = 4
   AND a2.dgLivello = 3
   AND a3.dgLivello = 2
   AND a4.dgLivello = 1
   AND a1.dgPath LIKE a4.dgPath + '%'
   AND a1.dgPath LIKE a3.dgPath + '%'
   AND a1.dgPath LIKE a2.dgPath + '%'
   AND a1.dgTipoGerarchia = @IdTid
   AND a2.dgTipoGerarchia = @IdTid
   AND a3.dgTipoGerarchia = @IdTid
   AND a4.dgTipoGerarchia = @IdTid
   AND a1.dgDeleted = 0
   AND a2.dgDeleted = 0
   AND a3.dgDeleted = 0
   AND a4.dgDeleted = 0
   AND b1.dsctesto LIKE @filtro

UNION

SELECT a1.IdDg
     , a1.dgCodiceInterno                                       AS CodiceInterno
     , a1.dgCodiceEsterno                                       AS CodiceEsterno
     , CAST(b1.dsctesto AS NVARCHAR(200))                       AS Descrizione
     , CAST(b3.dscTesto AS NVARCHAR(200)) + '/' +
       CAST(b2.dscTesto AS NVARCHAR(200)) + '/' +
       CAST(b1.dscTesto AS NVARCHAR(200))                       AS Path
     , a1.dgLivello                                             AS Livello
     , a1.dgfoglia                                              AS Foglia
  FROM DominiGerarchici a1
     , DominiGerarchici a2
     , DominiGerarchici a3
     , DescsI b1
     , DescsI b2
     , DescsI b3
 WHERE a1.dgIdDsc = b1.iddsc 
   AND a2.dgIdDsc = b2.iddsc
   AND a3.dgIdDsc = b3.iddsc
   AND a1.dgLivello = 3
   AND a2.dgLivello = 2
   AND a3.dgLivello = 1
   AND a1.dgPath LIKE a3.dgPath + '%'
   AND a1.dgPath LIKE a2.dgPath + '%'
   AND a1.dgTipoGerarchia = @IdTid
   AND a2.dgTipoGerarchia = @IdTid
   AND a3.dgTipoGerarchia = @IdTid
   AND a1.dgDeleted = 0
   AND a2.dgDeleted = 0
   AND a3.dgDeleted = 0
   AND b1.dsctesto LIKE @filtro

UNION

SELECT a1.IdDg
     , a1.dgCodiceInterno                                               AS CodiceInterno
     , a1.dgCodiceEsterno                                               AS CodiceEsterno
     , CAST(b1.dsctesto AS NVARCHAR(200))                               AS Descrizione
     , CAST(b2.dscTesto AS NVARCHAR(200)) + '/' +
       CAST(b1.dscTesto AS NVARCHAR(200))                               AS Path
     , a1.dgLivello                                                     AS Livello
     , a1.dgfoglia                                                      AS Foglia
  FROM DominiGerarchici a1
     , DominiGerarchici a2
     , DescsI b1
     , DescsI b2
 WHERE a1.dgIdDsc = b1.iddsc 
   AND a2.dgIdDsc = b2.iddsc
   AND a1.dgLivello = 2
   AND a2.dgLivello = 1
   AND a1.dgPath LIKE a2.dgPath + '%'
   AND a1.dgTipoGerarchia = @IdTid
   AND a2.dgTipoGerarchia = @IdTid
   AND a1.dgDeleted = 0
   AND a2.dgDeleted = 0
   AND b1.dsctesto LIKE @filtro

UNION

SELECT a1.IdDg
     , a1.dgCodiceInterno                                               AS CodiceInterno
     , a1.dgCodiceEsterno                                               AS CodiceEsterno
     , CAST(b1.dsctesto AS NVARCHAR(200))                               AS Descrizione
     , CAST(b1.dscTesto AS NVARCHAR(200))                               AS Path
     , a1.dgLivello                                                     AS Livello
     , a1.dgfoglia                                                      AS Foglia
  FROM DominiGerarchici a1,
       DescsI b1
 WHERE a1.dgIdDsc = b1.iddsc 
   AND a1.dgLivello = 1
   AND a1.dgTipoGerarchia = @IdTid
   AND a1.dgDeleted = 0
   AND b1.dsctesto LIKE @filtro
) vv

ORDER BY vv.Path


ExitStored:


GO
