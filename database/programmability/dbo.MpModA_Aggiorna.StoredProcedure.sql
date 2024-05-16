USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[MpModA_Aggiorna]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[MpModA_Aggiorna] 
  (@lastDate DATETIME = NULL OUTPUT) 
as
DECLARE @ConfDate DATETIME
SELECT @ConfDate = umdUltimaMod FROM srv_UltimaMod WHERE umdnome='MPModelliAttributi' --da cambiare
IF (@ConfDate IS NULL) --Non Accade 
      begin
       SELECT @lastDate = GETDATE()
         SELECT idmdlatt AS IdTab, mpmaIdMpMod AS IdMod,mpmaIdDzt AS IdDzt, mpmaRegObblig AS Obblig,mpmaOrdine AS Ordine,
                mpmaValoreDef AS ValoreDef, mpmaPesoDef AS PesoDef, mpmaIdFva AS FvaDef, mpmaIdUmsDef AS UmsDef,
                mpmaDeleted AS flagDeleted,mpmaDataUltimaMod AS DataUltimaMod, dztNome AS Nome, mpmaLocked AS Locked, mpmaShadow AS Shadow
         FROM MpModelliAttributi, DizionarioAttributi, MPModelli
         WHERE mpmaIdDzt = IdDzt
           AND mpmaIdMpMod = IdMpMod
           AND (mpmTipo = 0 OR mpmTipo = 8)
       ORDER BY 1
      end      
      ELSE 
         begin
             IF (@lastDate IS NULL) 
             SELECT idmdlatt AS IdTab, mpmaIdMpMod AS IdMod,mpmaIdDzt AS IdDzt, mpmaRegObblig AS Obblig,mpmaOrdine AS Ordine,
                mpmaValoreDef AS ValoreDef, mpmaPesoDef AS PesoDef, mpmaIdFva AS FvaDef, mpmaIdUmsDef AS UmsDef,
                mpmaDeleted AS flagDeleted,mpmaDataUltimaMod AS DataUltimaMod, dztNome AS Nome, mpmaLocked AS Locked, mpmaShadow AS Shadow
         FROM MpModelliAttributi, DizionarioAttributi, MPModelli
         WHERE mpmaIdDzt = IdDzt
           AND mpmaIdMpMod = IdMpMod
           AND (mpmTipo = 0 OR mpmTipo = 8)
       ORDER BY 1
          ELSE
            IF (@lastDate < @ConfDate)
                
               SELECT idmdlatt AS IdTab, mpmaIdMpMod AS IdMod,mpmaIdDzt AS IdDzt, mpmaRegObblig AS Obblig,mpmaOrdine AS Ordine,
                mpmaValoreDef AS ValoreDef, mpmaPesoDef AS PesoDef, mpmaIdFva AS FvaDef, mpmaIdUmsDef AS UmsDef,
                mpmaDeleted AS flagDeleted,mpmaDataUltimaMod AS DataUltimaMod, dztNome AS Nome, mpmaLocked AS Locked, mpmaShadow AS Shadow
                FROM MpModelliAttributi, DizionarioAttributi, MPModelli
               WHERE mpmaIdDzt = IdDzt
                AND mpmaIdMpMod = IdMpMod
            AND (mpmTipo = 0 OR mpmTipo = 8)
            AND mpmaDataUltimaMod > @lastDate
             ORDER BY 1    
               SELECT @lastDate = @ConfDate
         end
GO
