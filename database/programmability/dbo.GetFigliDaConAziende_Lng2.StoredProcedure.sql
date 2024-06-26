USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[GetFigliDaConAziende_Lng2]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[GetFigliDaConAziende_Lng2](@Codice AS VARCHAR (50), @IdMp AS INTeger, @IdTid AS INTeger, @Profilo AS char(1) = 'S') AS
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
DECLARE @Livello AS  INT
IF @IdTid <> 16 AND @IdTid <> 18
   begin
         raiserror ('Tipo Dato [%d] non gestito (CreateSP_GetFigliDaConAziende)', 16, 1, @IdTid) 
         return (99)
   end
IF @IdTid = 16
   goto clCSP
IF  @Codice = '-1'
   begin
        SELECT a1.dgCodiceInterno  AS CodiceInterno,
               a1.dgCodiceEsterno  AS CodiceEsterno,
               b.dscTesto          AS Descrizione,
               a1.dgLivello        AS Livello,
               f.Conta             AS Conta
          FROM DominiGerarchici a1, DescsLng2 b, ConAziende f
         WHERE a1.dgIdDsc = b.IdDsc
           AND a1.dgTipoGerarchia = @IdTid
           AND a1.dgCodiceInterno = f.atvatecord
           AND a1.dgLivello = 0
           AND a1.dgDeleted = 0
           AND f.conIdMp = @IdMp
           AND f.ConProfilo = @Profilo
        goto ExitStored
   end
IF  @Codice = '0'
   begin
        SELECT @Livello = min (dgLivello)
          FROM DominiGerarchici
         WHERE dgTipoGerarchia = @IDTid 
           AND IdDg in (SELECT mpdgIdDg FROM MPDominiGerarchici WHERE mpdgIdMp = @IdMp AND mpdgDeleted = 0)
        SELECT a1.dgCodiceInterno  AS CodiceInterno,
               a1.dgCodiceEsterno  AS CodiceEsterno,
               b.dscTesto          AS Descrizione,
               a1.dgLivello        AS Livello,
               f.Conta             AS Conta
          FROM DominiGerarchici a1, DescsLng2 b, ConAziende f
         WHERE a1.dgIdDsc = b.IdDsc
           AND a1.dgTipoGerarchia = @IdTid
           AND a1.dgCodiceInterno = f.atvatecord
           AND (a1.dgLivello = @Livello or a1.dgLivello = 0)
           AND a1.IdDg in (SELECT b1.IdDg 
                             FROM DominiGerarchici b, DominiGerarchici b1, MPDominiGerarchici c
                            WHERE b.IdDg = c.mpdgIdDg
                              AND b.dgPath like b1.dgPath + '%'
                              AND b.dgTIpoGerarchia = @IDTid
                              AND b1.dgTIpoGerarchia = @IDTid
                              AND c.mpdgTIpo = @IDTid
                              AND c.mpdgDeleted = 0
                              AND c.mpdgIdMp = @IdMp)
           AND a1.dgDeleted = 0
           AND f.conIdMp = @IdMp
           AND f.ConProfilo = @Profilo
        ORDER BY a1.dgPath
        goto ExitStored
   end
SELECT a1.dgCodiceInterno  AS CodiceInterno,
       a1.dgCodiceEsterno  AS CodiceEsterno,
       b.dscTesto          AS Descrizione,
       a1.dgLivello        AS Livello,
       f.Conta             AS Conta
  FROM DominiGerarchici a, DominiGerarchici a1, DescsLng2 b, ConAziende f
 WHERE a1.dgIdDsc = b.IdDsc
   AND a.IdDg in (SELECT b1.IdDg 
                    FROM DominiGerarchici b, DominiGerarchici b1, MPDominiGerarchici c
                   WHERE b.IdDg = c.mpdgIdDg
                     AND b1.dgPath like b.dgPath + '%'
                     AND c.mpdgDeleted = 0
                     AND c.mpdgTIpo = @IDTid
                     AND c.mpdgIdMp = @IdMp)
   AND a1.dgCodiceInterno = f.atvatecord
   AND a.dgTipoGerarchia = @IdTid
   AND a1.dgTipoGerarchia = @IdTid
   AND a.dgCodiceInterno = @Codice
   AND a1.dgPath like a.dgPath + '%'
   AND (a1.dgLivello = a.dgLivello + 1 or a1.dgLivello = a.dgLivello)
   AND a1.dgDeleted = 0
   AND f.conIdMp = @IdMp
   AND f.ConProfilo = @Profilo
ORDER BY a1.dgPath
goto ExitStored
ClCSP:
IF  @Codice = '-1'
   begin
        SELECT a1.dgCodiceInterno  AS CodiceInterno,
               a1.dgCodiceEsterno  AS CodiceEsterno,
               b.dscTesto          AS Descrizione,
               a1.dgLivello        AS Livello,
               f.Conta             AS Conta
          FROM DominiGerarchici a1, DescsLng2 b, ConCSP f
         WHERE a1.dgIdDsc = b.IdDsc
           AND a1.dgTipoGerarchia = @IdTid
           AND a1.dgCodiceInterno = f.concspcode
           AND a1.dgLivello = 0
           AND a1.dgDeleted = 0
           AND f.conIdMp = @IdMp
        goto ExitStored
   end
IF  @Codice = '0'
   begin
        SELECT @Livello = min (dgLivello)
          FROM DominiGerarchici
         WHERE dgTipoGerarchia = @IDTid 
           AND IdDg in (SELECT mpdgIdDg FROM MPDominiGerarchici WHERE mpdgIdMp = @IdMp AND mpdgDeleted = 0)
        SELECT a1.dgCodiceInterno  AS CodiceInterno,
               a1.dgCodiceEsterno  AS CodiceEsterno,
               b.dscTesto          AS Descrizione,
               a1.dgLivello        AS Livello,
               f.Conta             AS Conta
          FROM DominiGerarchici a1, DescsLng2 b, ConCSP f
         WHERE a1.dgIdDsc = b.IdDsc
           AND a1.dgTipoGerarchia = @IdTid
           AND a1.dgCodiceInterno = f.concspcode
           AND (a1.dgLivello = 1 or a1.dgLivello = 0)
           AND a1.IdDg in (SELECT b1.IdDg 
                             FROM DominiGerarchici b, DominiGerarchici b1, MPDominiGerarchici c
                            WHERE b.IdDg = c.mpdgIdDg
                              AND b.dgPath like b1.dgPath + '%'
                              AND b.dgPath like b1.dgPath + '%'
                              AND b.dgTIpoGerarchia = @IDTid
                              AND c.mpdgTipo = @IdTid
                              AND c.mpdgDeleted = 0
                              AND c.mpdgIdMp = @IdMp)
           AND a1.dgDeleted = 0
           AND f.conIdMp = @IdMp
        ORDER BY a1.dgPath
        goto ExitStored
   end
SELECT a1.dgCodiceInterno  AS CodiceInterno,
       a1.dgCodiceEsterno  AS CodiceEsterno,
       b.dscTesto          AS Descrizione,
       a1.dgLivello        AS Livello,
       f.Conta             AS Conta
  FROM DominiGerarchici a, DominiGerarchici a1, DescsLng2 b, ConCSP f
 WHERE a1.dgIdDsc = b.IdDsc
   AND a.IdDg in (SELECT b1.IdDg 
                    FROM DominiGerarchici b, DominiGerarchici b1, MPDominiGerarchici c
                   WHERE b.IdDg = c.mpdgIdDg
                     AND b1.dgPath like b.dgPath + '%'
                     AND c.mpdgDeleted = 0
                     AND c.mpdgTipo = @IdTid
                     AND c.mpdgIdMp = @IdMp)
   AND a1.dgCodiceInterno = f.concspcode
   AND a.dgTipoGerarchia = @IdTid
   AND a1.dgTipoGerarchia = @IdTid
   AND a.dgCodiceInterno = @Codice
   AND a1.dgPath like a.dgPath + '%'
   AND (a1.dgLivello = a.dgLivello + 1 or a1.dgLivello = a.dgLivello)
   AND a1.dgDeleted = 0
   AND f.conIdMp = @IdMp
ORDER BY a1.dgPath
ExitStored:
GO
