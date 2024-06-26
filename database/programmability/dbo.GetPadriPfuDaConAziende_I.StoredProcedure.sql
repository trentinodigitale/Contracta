USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[GetPadriPfuDaConAziende_I]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GetPadriPfuDaConAziende_I](@Codice AS VARCHAR (50), @IdMp AS INTeger, @IdPfu AS INTeger, 
                                    @dztNomeB AS VARCHAR (50), @dztNomeS AS VARCHAR (50)) AS
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
IF @Codice = '-1'
   begin
       /* Restituisce sempre un rowset vuoto */
       SELECT top 0 a.dgCodiceInterno  AS CodiceInterno,
                    a.dgCodiceEsterno  AS CodiceEsterno,
                    b.dscTesto         AS Descrizione,
                    a.dgLivello        AS Livello,
                    f.Conta            AS Conta
         FROM DominiGerarchici a, DescsI b, ConCSP f
        WHERE a.dgIdDsc = b.IdDsc
          AND a.dgTipoGerarchia = @IdTid
          AND a.dgCodiceInterno = f.concspcode
          AND f.conIdMp = @IdMp
       goto ExitStored
   end
 
SELECT  a1.dgCodiceInterno  AS CodiceInterno,
        a1.dgCodiceEsterno  AS CodiceEsterno,
        b.dscTesto          AS Descrizione,
        a1.dgLivello        AS Livello,
        f.Conta             AS Conta
  FROM DominiGerarchici a, DominiGerarchici a1, DescsI b, ConCSP f
 WHERE a1.dgIdDsc = b.IdDsc
   AND (a.IdDg in (SELECT b1.IdDg 
                    FROM DominiGerarchici b, DominiGerarchici b1, MPDominiGerarchici c
                   WHERE b.IdDg = c.mpdgIdDg
                     AND b1.dgPath like b.dgPath + '%'
                     AND c.mpdgDeleted = 0
                     AND c.mpdgIdMp = @IdMp) or a.dgLivello = 0)
   AND a.dgTipoGerarchia  = @IdTid
   AND a1.dgTipoGerarchia = @IdTid
   AND a.dgCodiceInterno  = @Codice
   AND a.dgCodiceInterno = f.concspcode
   AND (a.dgPath like a1.dgPath + '%')
   AND a1.dgDeleted = 0
   AND a.dgDeleted = 0
   AND f.conIdMp = @IdMp
ORDER BY a1.dgPath
goto ExitStored
l_Filter:
IF @Codice = '-1'
   begin
       /* Restituisce sempre un rowset vuoto */
       SELECT top 0 a.dgCodiceInterno  AS CodiceInterno,
                    a.dgCodiceEsterno  AS CodiceEsterno,
                    b.dscTesto         AS Descrizione,
                    a.dgLivello        AS Livello,
                    f.Conta            AS Conta
         FROM DominiGerarchici a, DescsI b, ConCSP f
        WHERE a.dgIdDsc = b.IdDsc
          AND a.dgTipoGerarchia = @IdTid
          AND a.dgCodiceInterno = f.concspcode
          AND f.conIdMp = @IdMp
       goto ExitStored
   end
SELECT v.CodiceInterno, v.CodiceEsterno, v.Descrizione, v.Livello, v.Conta
 FROM (
SELECT  a1.dgCodiceInterno  AS CodiceInterno,
        a1.dgCodiceEsterno  AS CodiceEsterno,
        b.dscTesto          AS Descrizione,
        a1.dgLivello        AS Livello,
        f.Conta             AS Conta,
        a1.dgPath
  FROM DominiGerarchici a, DominiGerarchici a1, DescsI b, ConCSP f
 WHERE a1.dgIdDsc = b.IdDsc
   AND (a1.IdDg in (SELECT b1.IdDg 
                    FROM DominiGerarchici b, DominiGerarchici b1, v_DFPfu c
                   WHERE b.IdDg = c.vIdDg
                     AND b1.dgPath like b.dgPath + '%'
                     AND b1.dgTipoGErarchia = @IDTid
                     AND b.dgTipoGErarchia = @IDTid
                     AND c.vTipo = @Tipo
                     AND c.vIdPfu = @IdPfu))
   AND a.dgTipoGerarchia  = @IdTid
   AND a1.dgTipoGerarchia = @IdTid
   AND a.dgCodiceInterno  = @Codice
   AND a.dgCodiceInterno = f.concspcode
   AND (a.dgPath like a1.dgPath + '%')
   AND a1.dgDeleted = 0
   AND a.dgDeleted = 0
   AND f.conIdMp = @IdMp
UNION ALL
SELECT  a1.dgCodiceInterno  AS CodiceInterno,
        a1.dgCodiceEsterno  AS CodiceEsterno,
        b.dscTesto          AS Descrizione,
        a1.dgLivello        AS Livello,
        f.Conta             AS Conta,
        a1.dgPath
  FROM DominiGerarchici a, DominiGerarchici a1, DescsI b, ConCSP f
 WHERE a1.dgIdDsc = b.IdDsc
   AND (a1.dgLivello = 0)
   AND a.dgTipoGerarchia  = @IdTid
   AND a1.dgTipoGerarchia = @IdTid
   AND a.dgCodiceInterno  = @Codice
   AND a.dgCodiceInterno = f.concspcode
   AND (a.dgPath like a1.dgPath + '%')
   AND a1.dgDeleted = 0
   AND a.dgDeleted = 0
   AND f.conIdMp = @IdMp) v
ORDER BY v.dgPath
goto ExitStored
ExitStored:
GO
