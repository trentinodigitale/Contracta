USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[GetPathDaConAziende_E]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[GetPathDaConAziende_E](@Filtro AS NVARCHAR (500), @IdMp AS INTeger, @IdTid AS INTeger, @Profilo AS char(1) = 'S') as
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
DECLARE @Livello AS INT
SELECT @Livello = min (dgLivello)
  FROM DominiGerarchici
 WHERE dgTipoGerarchia = @IDTid 
   AND IdDg in (SELECT mpdgIdDg FROM MPDominiGerarchici WHERE mpdgIdMp = @IdMp AND mpdgDeleted = 0)
IF @IdTid <> 16 AND @IdTid <> 18
   begin
         raiserror ('Tipo Dato [%d] non gestito (CreateSP_GetPathDaConAziende)', 16, 1, @IdTid) 
         return (99)
   end
IF @IdTid = 16 
   goto ClCSP
SELECT vv.CodiceInterno, vv.CodiceEsterno,  vv.Descrizione, vv.Path, vv.Livello, vv.Conta
  from
(
SELECT a1.IdDg,
       a1.dgCodiceInterno                 AS CodiceInterno,
       a1.dgCodiceEsterno                 AS CodiceEsterno,
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
       a1.dgLivello                      AS Livello,
       f.Conta                           AS Conta
  FROM DominiGerarchici a1, DominiGerarchici a2, DominiGerarchici a3, DominiGerarchici a4, 
       DescsE b1, DescsE b2, DescsE b3, DescsE b4, ConAziende f
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
   AND a1.dgCodiceInterno = f.atvAtecord
   AND f.conIdMp = @IdMp
   AND f.ConProfilo = @Profilo
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
       a1.dgLivello                      AS Livello,
       f.Conta                           AS Conta
  FROM DominiGerarchici a1, DominiGerarchici a2, DominiGerarchici a3,
       DescsE b1, DescsE b2, DescsE b3, ConAziende f
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
   AND a1.dgCodiceInterno = f.atvAtecord
   AND f.conIdMp = @IdMp
   AND f.ConProfilo = @Profilo
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
       a1.dgLivello                      AS Livello,
       f.Conta                           AS Conta
  FROM DominiGerarchici a1, DominiGerarchici a2,
       DescsE b1, DescsE b2, ConAziende f
 WHERE a1.dgIdDsc = b1.iddsc 
   AND a2.dgIdDsc = b2.iddsc
   AND a1.dgLivello = 2
   AND a2.dgLivello = 1
   AND a1.dgPath like a2.dgPath + '%'
   AND a1.dgTipoGerarchia = @IdTid
   AND a2.dgTipoGerarchia = @IdTid
   AND a1.dgDeleted = 0
   AND b1.dsctesto like @filtro
   AND a1.dgCodiceInterno = f.atvAtecord
   AND f.conIdMp = @IdMp
   AND f.ConProfilo = @Profilo
union
SELECT a1.IdDg,
       a1.dgCodiceInterno AS CodiceInterno,
       a1.dgCodiceEsterno AS CodiceEsterno,
       cast(b1.dsctesto AS NVARCHAR(200)) AS Descrizione,
       cast(b1.dscTesto AS NVARCHAR(200)) AS Path,
       a1.dgLivello                       AS Livello,
       f.Conta                            AS Conta
  FROM DominiGerarchici a1,
       DescsE b1, ConAziende f
 WHERE a1.dgIdDsc = b1.iddsc 
   AND a1.dgLivello = 1
   AND a1.dgTipoGerarchia = @IdTid
   AND a1.dgDeleted = 0
   AND b1.dsctesto like @filtro
   AND a1.dgCodiceInterno = f.atvAtecord
   AND f.conIdMp = @IdMp
   AND f.ConProfilo = @Profilo
) vv, 
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
ClCSP:
SELECT vv.CodiceInterno, vv.CodiceEsterno,  vv.Descrizione, vv.Path, vv.Livello, vv.Conta
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
       a1.dgLivello                      AS Livello,
       f.Conta                           AS Conta
  FROM DominiGerarchici a1, DominiGerarchici a2, DominiGerarchici a3, DominiGerarchici a4, 
       DescsE b1, DescsE b2, DescsE b3, DescsE b4, ConCSP f
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
   AND a1.dgCodiceInterno = f.concspcode
   AND f.conIdMp = @IdMp
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
       a1.dgLivello                      AS Livello,
       f.Conta                           AS Conta
  FROM DominiGerarchici a1, DominiGerarchici a2, DominiGerarchici a3,
       DescsE b1, DescsE b2, DescsE b3, ConCSP f
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
   AND a1.dgCodiceInterno = f.concspcode
   AND f.conIdMp = @IdMp
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
       a1.dgLivello                      AS Livello,
       f.Conta                           AS Conta
  FROM DominiGerarchici a1, DominiGerarchici a2,
       DescsE b1, DescsE b2, ConCSP f
 WHERE a1.dgIdDsc = b1.iddsc 
   AND a2.dgIdDsc = b2.iddsc
   AND a1.dgLivello = 2
   AND a2.dgLivello = 1
   AND a1.dgPath like a2.dgPath + '%'
   AND a1.dgTipoGerarchia = @IdTid
   AND a2.dgTipoGerarchia = @IdTid
   AND a1.dgDeleted = 0
   AND b1.dsctesto like @filtro
   AND a1.dgCodiceInterno = f.concspcode
   AND f.conIdMp = @IdMp
union
SELECT a1.IdDg,
       a1.dgCodiceInterno AS CodiceInterno,
       a1.dgCodiceEsterno AS CodiceEsterno,
       cast(b1.dsctesto AS NVARCHAR(200)) AS Descrizione,
       cast(b1.dscTesto AS NVARCHAR(200)) AS Path,
       a1.dgLivello                       AS Livello,
       f.Conta                            AS Conta
  FROM DominiGerarchici a1,
       DescsE b1, ConCSP f
 WHERE a1.dgIdDsc = b1.iddsc 
   AND a1.dgLivello = 1
   AND a1.dgTipoGerarchia = @IdTid
   AND a1.dgDeleted = 0
   AND b1.dsctesto like @filtro
   AND a1.dgCodiceInterno = f.concspcode
   AND f.conIdMp = @IdMp
) vv, 
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
ExitStored:
GO
