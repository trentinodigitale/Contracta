USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[GetPadriDaConAziende_I]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [dbo].[GetPadriDaConAziende_I](@Codice AS VARCHAR (50), @IdMp AS INTeger, @IdTid AS INTeger, @Profilo AS char(1) = 'S') AS
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
IF @IdTid <> 16 AND @IdTid <> 18
   begin
         raiserror ('Tipo Dato [%d] non gestito (CreateSP_GetPadriDaConAziende)', 16, 1, @IdTid) 
         return (99)
   end
IF @IdTid = 16 
    goto ClCSP
IF @Codice = '-1'
   begin
       /* Restituisce sempre un rowset vuoto */
       SELECT top 0 a.dgCodiceInterno  AS CodiceInterno,
                    a.dgCodiceEsterno  AS CodiceEsterno,
                    b.dscTesto         AS Descrizione,
                    a.dgLivello        AS Livello,
                    f.Conta            AS Conta,
		    a.dgFoglia         AS Foglia
         FROM DominiGerarchici a, DescsI b, ConAziende f
        WHERE a.dgIdDsc = b.IdDsc
          AND a.dgTipoGerarchia = @IdTid
          AND a.dgCodiceInterno = f.atvAtecord
          AND f.conIdMp = @IdMp
          AND f.ConProfilo = @Profilo
       goto ExitStored
   end
 
SELECT  a1.dgCodiceInterno  AS CodiceInterno,
        a1.dgCodiceEsterno  AS CodiceEsterno,
        b.dscTesto          AS Descrizione,
        a1.dgLivello        AS Livello,
        f.Conta             AS Conta,
	a1.dgFoglia         AS Foglia
  FROM DominiGerarchici a, DominiGerarchici a1, DescsI b, ConAziende f
 WHERE a1.dgIdDsc = b.IdDsc
   AND (a.IdDg in (SELECT b1.IdDg 
                    FROM DominiGerarchici b, DominiGerarchici b1, MPDominiGerarchici c
                   WHERE b.IdDg = c.mpdgIdDg
                     AND b1.dgPath like b.dgPath + '%'
                     AND b1.dgTipoGErarchia = @IDTid
                     AND b.dgTipoGErarchia = @IDTid
                     AND c.mpdgDeleted = 0
                     AND c.mpdgIdMp = @IdMp) or a.dgLivello = 0)
   AND a.dgTipoGerarchia  = @IdTid
   AND a1.dgTipoGerarchia = @IdTid
   AND a.dgCodiceInterno  = @Codice
   AND a1.dgCodiceInterno = f.atvAtecord
   AND (a.dgPath like a1.dgPath + '%')
   AND a1.dgDeleted = 0
   AND a.dgDeleted = 0
   AND f.conIdMp = @IdMp
   AND f.ConProfilo = @Profilo
ORDER BY a1.dgPath
goto ExitStored
ClCSP:
IF @Codice = '-1'
   begin
       /* Restituisce sempre un rowset vuoto */
       SELECT top 0 a.dgCodiceInterno  AS CodiceInterno,
                    a.dgCodiceEsterno  AS CodiceEsterno,
                    b.dscTesto         AS Descrizione,
                    a.dgLivello        AS Livello,
                    f.Conta            AS Conta,
		    a.dgFoglia         AS Foglia
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
        f.Conta             AS Conta,
	a1.dgFoglia         AS Foglia
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
ExitStored:

GO
