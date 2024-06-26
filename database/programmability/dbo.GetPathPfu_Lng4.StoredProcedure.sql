USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[GetPathPfu_Lng4]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[GetPathPfu_Lng4](@Filtro AS NVARCHAR (500), @IdMp AS INTeger, @IdPfu AS INTeger, 
                                    @dztNomeB AS VARCHAR (50), @dztNomeS AS VARCHAR (50)) as
DECLARE @IdTid AS INTeger
DECLARE @Tipo  AS VARCHAR(50)
DECLARE @Livello AS INT
IF @dztNomeB not in ('AreaGeograficaOperativaUtenteBuyer', 'ArtClasMerceologicaUtenteBuyer', '')
   begin
          raiserror ('Tipo [%s] non valido', 16, 1, @dztNomeB) 
          return  99
         
   end
IF @dztNomeS not in ('AreaGeograficaOperativaUtenteSeller', 'ArtClasMerceologicaUtenteSeller', '')
   begin
          raiserror ('Tipo [%s] non valido', 16, 1, @dztNomeS) 
          return  99
         
   end
IF @dztNomeS <> '' AND @dztNomeB <> ''
   begin
         IF  @dztNomeS like 'AreaGeografica%'
                   set @Tipo = 'ALLGPH'
         ELSE
                   set @Tipo = 'ALLCSP'
         SELECT @IdTid = dztIdTid 
           FROM DizionarioAttributi 
          WHERE dztNome = @dztNomeS
   end
ELSE
IF @dztNomeS <> '' 
   begin
         set @Tipo = @dztNomeS
         SELECT @IdTid = dztIdTid 
           FROM DizionarioAttributi 
          WHERE dztNome = @dztNomeS
   end
ELSE
   begin
         set @Tipo = @dztNomeB
         SELECT @IdTid = dztIdTid 
           FROM DizionarioAttributi 
          WHERE dztNome = @dztNomeB
   end
IF exists (SELECT * FROM v_DFPfu, DominiGerarchici WHERE vIdPfu = @IdPfu AND vTipo = @Tipo and vIdDg = IdDg and dgCodiceInterno <> '0')
   begin
           goto l_Filter
   end
IF not exists (SELECT * FROM MPDominiGerarchici WHERE mpdgTipo = @IdTid AND mpdgIdMp = @IdMp)
   begin
          set @IdMp = 0
          SELECT @IdMp = IdMp FROM MarketPlace WHERE substring (mpOpzioni, 1, 1) = '1'
          IF @IdMp = 0
             begin
                    raiserror ('MetaMarketplace non trovato', 16, 1) 
                    return  99
             end
   end
SELECT @Livello = min (dgLivello)
  FROM DominiGerarchici
 WHERE dgTipoGerarchia = @IDTid 
   AND IdDg in (SELECT mpdgIdDg FROM MPDominiGerarchici WHERE mpdgIdMp = @IdMp AND mpdgDeleted = 0)
SELECT vv.IdDg, vv.CodiceInterno, vv.CodiceEsterno,  vv.Descrizione, vv.Path, vv.Livello
  from
(
SELECT a1.IdDg,
       a1.dgCodiceInterno                AS CodiceInterno,
       a1.dgCodiceEsterno                AS CodiceEsterno,
       cast(b1.dsctesto AS NVARCHAR(200)) AS Descrizione,
       case @Livello 
            when 1 then
                         cast(b4.dscTesto AS NVARCHAR(200)) + '/' +
                         cast(b3.dscTesto AS NVARCHAR(200)) + '/' +
                         cast(b2.dscTesto AS NVARCHAR(200)) + '/' +
                         cast(b1.dscTesto AS NVARCHAR(200)) 
            when 2 then
                         cast(b3.dscTesto AS NVARCHAR(200)) + '/' +
                         cast(b2.dscTesto AS NVARCHAR(200)) + '/' +
                         cast(b1.dscTesto AS NVARCHAR(200)) 
            when 3 then
                         cast(b2.dscTesto AS NVARCHAR(200)) + '/' +
                         cast(b1.dscTesto AS NVARCHAR(200)) 
            when 4 then
                         cast(b1.dscTesto AS NVARCHAR(200)) 
        end AS Path,
       a1.dgLivello                      AS Livello
  FROM DominiGerarchici a1, DominiGerarchici a2, DominiGerarchici a3, DominiGerarchici a4, 
       DescsLng4 b1, DescsLng4 b2, DescsLng4 b3, DescsLng4 b4
 WHERE a1.dgIdDsc = b1.iddsc 
   AND a2.dgIdDsc = b2.iddsc
   AND a3.dgIdDsc = b3.iddsc
   AND a4.dgIdDsc = b4.iddsc
   AND a1.dgLivello = 4
   AND a2.dgLivello = 3
   AND a3.dgLivello = 2
   AND a4.dgLivello = 1
   AND a1.dgPath like a4.dgPath + '%'
   AND a1.dgPath like a3.dgPath + '%'
   AND a1.dgPath like a2.dgPath + '%'
   AND a1.dgTipoGerarchia = @IdTid
   AND a2.dgTipoGerarchia = @IdTid
   AND a3.dgTipoGerarchia = @IdTid
   AND a4.dgTipoGerarchia = @IdTid
   AND a1.dgDeleted = 0
   AND b1.dsctesto like @filtro
union
SELECT a1.IdDg,
       a1.dgCodiceInterno AS CodiceInterno,
       a1.dgCodiceEsterno AS CodiceEsterno,
       cast(b1.dsctesto AS NVARCHAR(200)) AS Descrizione,
       case (@livello)
            when 1 then
                    cast(b3.dscTesto AS NVARCHAR(200)) + '/' +
                    cast(b2.dscTesto AS NVARCHAR(200)) + '/' +
                    cast(b1.dscTesto AS NVARCHAR(200)) 
            when 2 then
                    cast(b2.dscTesto AS NVARCHAR(200)) + '/' +
                    cast(b1.dscTesto AS NVARCHAR(200)) 
            when 3 then
                    cast(b2.dscTesto AS NVARCHAR(200)) + '/' +
                    cast(b1.dscTesto AS NVARCHAR(200)) 
            ELSE  ''
       end
       AS Path,
       a1.dgLivello                      AS Livello
  FROM DominiGerarchici a1, DominiGerarchici a2, DominiGerarchici a3,
       DescsLng4 b1, DescsLng4 b2, DescsLng4 b3
 WHERE a1.dgIdDsc = b1.iddsc 
   AND a2.dgIdDsc = b2.iddsc
   AND a3.dgIdDsc = b3.iddsc
   AND a1.dgLivello = 3
   AND a2.dgLivello = 2
   AND a3.dgLivello = 1
   AND a1.dgPath like a3.dgPath + '%'
   AND a1.dgPath like a2.dgPath + '%'
   AND a1.dgTipoGerarchia = @IdTid
   AND a2.dgTipoGerarchia = @IdTid
   AND a3.dgTipoGerarchia = @IdTid
   AND a1.dgDeleted = 0
   AND b1.dsctesto like @filtro
union
SELECT a1.IdDg,
       a1.dgCodiceInterno AS CodiceInterno,
       a1.dgCodiceEsterno AS CodiceEsterno,
       cast(b1.dsctesto AS NVARCHAR(200)) AS Descrizione,
       case @Livello
            when 1 then
                       cast(b2.dscTesto AS NVARCHAR(200)) + '/' +
                       cast(b1.dscTesto AS NVARCHAR(200)) 
            when 2 then
                       cast(b1.dscTesto AS NVARCHAR(200)) 
            ELSE ''
       end AS Path,
       a1.dgLivello                      AS Livello
  FROM DominiGerarchici a1, DominiGerarchici a2,
       DescsLng4 b1, DescsLng4 b2
 WHERE a1.dgIdDsc = b1.iddsc 
   AND a2.dgIdDsc = b2.iddsc
   AND a1.dgLivello = 2
   AND a2.dgLivello = 1
   AND a1.dgPath like a2.dgPath + '%'
   AND a1.dgTipoGerarchia = @IdTid
   AND a2.dgTipoGerarchia = @IdTid
   AND a1.dgDeleted = 0
   AND b1.dsctesto like @filtro
union
SELECT a1.IdDg,
       a1.dgCodiceInterno AS CodiceInterno,
       a1.dgCodiceEsterno AS CodiceEsterno,
       cast(b1.dsctesto AS NVARCHAR(200)) AS Descrizione,
       cast(b1.dscTesto AS NVARCHAR(200)) AS Path,
       a1.dgLivello                      AS Livello
  FROM DominiGerarchici a1,
       DescsLng4 b1
 WHERE a1.dgIdDsc = b1.iddsc 
   AND a1.dgLivello = 1
   AND a1.dgTipoGerarchia = @IdTid
   AND a1.dgDeleted = 0
   AND b1.dsctesto like @filtro
) vv ,
(SELECT b1.IdDg 
                    FROM DominiGerarchici b, DominiGerarchici b1, MPDominiGerarchici c
                   WHERE b.IdDg = c.mpdgIdDg
                     AND b1.dgPath like b.dgPath + '%'
                     AND b1.dgTipoGerarchia = @IdTid
                     AND b.dgTipoGerarchia = @IdTid
                     AND c.mpdgDeleted = 0
                     AND c.mpdgIdMp = @IdMp) vv1
WHERE vv.iddg = vv1.IdDg 
ORDER BY vv.Path
 goto ExitStored
l_Filter:
SELECT @Livello = min (dgLivello)
  FROM DominiGerarchici
 WHERE dgTipoGerarchia = @IDTid 
   AND IdDg in (SELECT vIdDg FROM v_DfPfu WHERE vIdPfu = @IdPfu AND vTipo = @Tipo)
SELECT vv.IdDg, vv.CodiceInterno, vv.CodiceEsterno,  vv.Descrizione, vv.Path, vv.Livello
  from
(
SELECT a1.IdDg,
       a1.dgCodiceInterno                AS CodiceInterno,
       a1.dgCodiceEsterno                AS CodiceEsterno,
       cast(b1.dsctesto AS NVARCHAR(200)) AS Descrizione,
       case @Livello 
            when 1 then
                         cast(b4.dscTesto AS NVARCHAR(200)) + '/' +
                         cast(b3.dscTesto AS NVARCHAR(200)) + '/' +
                         cast(b2.dscTesto AS NVARCHAR(200)) + '/' +
                         cast(b1.dscTesto AS NVARCHAR(200)) 
            when 2 then
                         cast(b3.dscTesto AS NVARCHAR(200)) + '/' +
                         cast(b2.dscTesto AS NVARCHAR(200)) + '/' +
                         cast(b1.dscTesto AS NVARCHAR(200)) 
            when 3 then
                         cast(b2.dscTesto AS NVARCHAR(200)) + '/' +
                         cast(b1.dscTesto AS NVARCHAR(200)) 
            when 4 then
                         cast(b1.dscTesto AS NVARCHAR(200)) 
        end AS Path,
       a1.dgLivello                      AS Livello
  FROM DominiGerarchici a1, DominiGerarchici a2, DominiGerarchici a3, DominiGerarchici a4, 
       DescsLng4 b1, DescsLng4 b2, DescsLng4 b3, DescsLng4 b4
 WHERE a1.dgIdDsc = b1.iddsc 
   AND a2.dgIdDsc = b2.iddsc
   AND a3.dgIdDsc = b3.iddsc
   AND a4.dgIdDsc = b4.iddsc
   AND a1.dgLivello = 4
   AND a2.dgLivello = 3
   AND a3.dgLivello = 2
   AND a4.dgLivello = 1
   AND a1.dgPath like a4.dgPath + '%'
   AND a1.dgPath like a3.dgPath + '%'
   AND a1.dgPath like a2.dgPath + '%'
   AND a1.dgTipoGerarchia = @IdTid
   AND a2.dgTipoGerarchia = @IdTid
   AND a3.dgTipoGerarchia = @IdTid
   AND a4.dgTipoGerarchia = @IdTid
   AND a1.dgDeleted = 0
   AND b1.dsctesto like @filtro
union
SELECT a1.IdDg,
       a1.dgCodiceInterno AS CodiceInterno,
       a1.dgCodiceEsterno AS CodiceEsterno,
       cast(b1.dsctesto AS NVARCHAR(200)) AS Descrizione,
       case (@livello)
            when 1 then
                    cast(b3.dscTesto AS NVARCHAR(200)) + '/' +
                    cast(b2.dscTesto AS NVARCHAR(200)) + '/' +
                    cast(b1.dscTesto AS NVARCHAR(200)) 
            when 2 then
                    cast(b2.dscTesto AS NVARCHAR(200)) + '/' +
                    cast(b1.dscTesto AS NVARCHAR(200)) 
            when 3 then
                    cast(b2.dscTesto AS NVARCHAR(200)) + '/' +
                    cast(b1.dscTesto AS NVARCHAR(200)) 
            ELSE  ''
       end
       AS Path,
       a1.dgLivello                      AS Livello
  FROM DominiGerarchici a1, DominiGerarchici a2, DominiGerarchici a3,
       DescsLng4 b1, DescsLng4 b2, DescsLng4 b3
 WHERE a1.dgIdDsc = b1.iddsc 
   AND a2.dgIdDsc = b2.iddsc
   AND a3.dgIdDsc = b3.iddsc
   AND a1.dgLivello = 3
   AND a2.dgLivello = 2
   AND a3.dgLivello = 1
   AND a1.dgPath like a3.dgPath + '%'
   AND a1.dgPath like a2.dgPath + '%'
   AND a1.dgTipoGerarchia = @IdTid
   AND a2.dgTipoGerarchia = @IdTid
   AND a3.dgTipoGerarchia = @IdTid
   AND a1.dgDeleted = 0
   AND b1.dsctesto like @filtro
union
SELECT a1.IdDg,
       a1.dgCodiceInterno AS CodiceInterno,
       a1.dgCodiceEsterno AS CodiceEsterno,
       cast(b1.dsctesto AS NVARCHAR(200)) AS Descrizione,
       case @Livello
            when 1 then
                       cast(b2.dscTesto AS NVARCHAR(200)) + '/' +
                       cast(b1.dscTesto AS NVARCHAR(200)) 
            when 2 then
                       cast(b1.dscTesto AS NVARCHAR(200)) 
            ELSE ''
       end AS Path,
       a1.dgLivello                      AS Livello
  FROM DominiGerarchici a1, DominiGerarchici a2,
       DescsLng4 b1, DescsLng4 b2
 WHERE a1.dgIdDsc = b1.iddsc 
   AND a2.dgIdDsc = b2.iddsc
   AND a1.dgLivello = 2
   AND a2.dgLivello = 1
   AND a1.dgPath like a2.dgPath + '%'
   AND a1.dgTipoGerarchia = @IdTid
   AND a2.dgTipoGerarchia = @IdTid
   AND a1.dgDeleted = 0
   AND b1.dsctesto like @filtro
union
SELECT a1.IdDg,
       a1.dgCodiceInterno AS CodiceInterno,
       a1.dgCodiceEsterno AS CodiceEsterno,
       cast(b1.dsctesto AS NVARCHAR(200)) AS Descrizione,
       cast(b1.dscTesto AS NVARCHAR(200)) AS Path,
       a1.dgLivello                      AS Livello
  FROM DominiGerarchici a1,
       DescsLng4 b1
 WHERE a1.dgIdDsc = b1.iddsc 
   AND a1.dgLivello = 1
   AND a1.dgTipoGerarchia = @IdTid
   AND a1.dgDeleted = 0
   AND b1.dsctesto like @filtro
) vv ,
(SELECT b1.IdDg 
                    FROM DominiGerarchici b, DominiGerarchici b1, v_DFPfu c
                   WHERE b.IdDg = c.vIdDg
                     AND b1.dgPath like b.dgPath + '%'
                     AND b1.dgTipoGerarchia = @IdTid
                     AND b.dgTipoGerarchia = @IdTid
                     AND c.vTipo = @Tipo
                     AND c.vIDPfu = @IdPfu) vv1
WHERE vv.iddg = vv1.IdDg 
ORDER BY vv.Path
 goto ExitStored
ExitStored:
GO
