USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[DeleteMpModAttr]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Autore: Alfano Antonio
Scopo: Delete MpModelliAttributi
Data: 05/09/2001
*/
CREATE PROCEDURE [dbo].[DeleteMpModAttr] (@IdDoc INT,@IdMp INT,@IdMdlAtt INT,@idMpModNew  INT  OUTPUT,@IdDocNew INT OUTPUT) AS
begin
DECLARE @IdMpCorr1 INT --IdMp corrente
DECLARE @mpmaIdMpModNew INT  --IdMpMod temporaneo
DECLARE @mpmaIddzt INT --IdDzt
DECLARE @IdMpMod INT --IdMpMod
DECLARE @DocIdMpMod INT
--var per il cursore
DECLARE @mpmaIdMpMod_c INT
DECLARE @mpmaIdDzt_c INT
DECLARE @mpmaRegObblig_c bit
DECLARE @mpmaOrdine_c INT
DECLARE @mpmaValoreDef_c VARCHAR(50)
DECLARE @mpmaPesoDef_c INT
DECLARE @mpmaIdFva_c INT
DECLARE @mpmaIdUmsDef_c INT
DECLARE @mpmaLocked_c bit
DECLARE @mpmaShadow_c bit
DECLARE @mpmaOpzioni_c VARCHAR(50)
DECLARE @mpmaOper_c VARCHAR(20)
DECLARE @IdMdlAttOld INT
DECLARE @IdMdlAttNew INT
set @IdDocNew=@IdDoc
begin tran
--Selezione relativo a  @IdMdlAtt
SELECT @IdMpMod=mpmaIdMpMod,@mpmaIddzt=mpmaIdDzt FROM MPModelliAttributi
WHERE IdMdlAtt=@IdMdlAtt AND mpmaDeleted=0
set  @idMpModNew=@IdMpMod
IF @IdMpMod  IS NULL       BEGIN
                                          raiserror ('Errore record inesistente(DeleteMpModAttr) ', 16, 1) 
                                                rollback tran
                                                return 99
                        END
SELECT @DocIdMpMod=DocIdMpMod FROM Mpdocumenti
WHERE IdDoc=@IdDoc AND docDeleted=0
IF @DocIdMpMod IS NULL       BEGIN
                                          raiserror ('Errore record inesistente(DeleteMpModAttr) ', 16, 1) 
                                                rollback tran
                                                return 99
                        END
--IdMp da MPModelli
SELECT @IdMpCorr1=mpmIdMp FROM MPModelli
WHERE IdMpMod=@IdMpMod 
IF @IdMpCorr1 IS NULL       BEGIN
                                          raiserror ('Errore record inesistente(DeleteMpModAttr) ', 16, 1) 
                                                rollback tran
                                                return 99
                        END
--consistenza del modello
IF @DocIdMpMod<>@IdMpMod      BEGIN
                                          raiserror ('Errore modello inconsistente(DeleteMpModAttr) ', 16, 1) 
                                                rollback tran
                                                return 99
                        END
--Assiomi
IF @IdMp=0            BEGIN
      IF @IdMpCorr1<>0                        BEGIN
                                          raiserror ('Errore MP  incosistenti  (DeleteMpModAttr) ', 16, 1) 
                                                      rollback tran
                                                      return 99
                                          END
                  END
            ELSE      BEGIN
      IF @IdMp<>@IdMpCorr1 AND not @IdMpCorr1=0      BEGIN
                                          raiserror ('Errore MP  incosistenti  (DeleteMpModAttr) ', 16, 1) 
                                                      rollback tran
                                                      return 99                  
                                          END
                  END
--Criterio di copia
IF @IdMpCorr1=0 AND @IdMpCorr1<>@IdMp      BEGIN
--copia record MPModelli
insert INTo MPModelli(mpmIdMp,mpmDesc,mpmTipo)
SELECT @IdMp,mpmDesc,mpmTipo FROM MPModelli
WHERE IdMpMod=@IdMpMod
IF @@error <> 0
                                           begin
                                                raiserror ('Errore insert MPModelli (DeleteMpModAttr) ', 16, 1) 
                                                rollback tran
                                                return 99
                                                 END
set @mpmaIdMpModNew=@@identity
set @idMpModNew=@mpmaIdMpModNew
--copia record MpDocumenti
insert INTo MpDocumenti(docIdMp,docItype,docPath,docIdMpMod,docISubType,docIsReplicable)
SELECT @IdMp,docItype,docPath,@mpmaIdMpModNew,docISubType,docIsReplicable FROM MpDocumenti
WHERE IdDoc=@IdDoc --docIdMpMod=@IdMpMod AND docDeleted=0 --and docIdMp=@IdMpCorr1 
IF @@error <> 0
                                           begin
                                                raiserror ('Errore insert MpDocumenti  (DeleteMpModAttr) ', 16, 1) 
                                                rollback tran
                                                return 99
                                                 END
set @IdDocNew=@@identity
/***********************/
--cursore per la copia degli attributicontrolli 
--copia record MPModelliAttributi
DECLARE crsMpModAtt cursor STATIC for       SELECT IdMdlAtt,mpmaIdMpMod,mpmaIdDzt,mpmaRegObblig,mpmaOrdine,mpmaValoreDef,mpmaPesoDef,mpmaIdFva,mpmaIdUmsDef,mpmaLocked,mpmaShadow,mpmaOpzioni,mpmaOper FROM MPModelliAttributi
                        WHERE mpmaIdMpMod=@IdMpMod AND mpmaDeleted=0 AND mpmaIddzt<>@mpmaIddzt 
           
open crsMpModAtt
fetch next FROM crsMpModAtt INTo @IdMdlAttOld,@mpmaIdMpMod_c,@mpmaIdDzt_c,@mpmaRegObblig_c,@mpmaOrdine_c,@mpmaValoreDef_c,@mpmaPesoDef_c,@mpmaIdFva_c,@mpmaIdUmsDef_c,@mpmaLocked_c,@mpmaShadow_c,@mpmaOpzioni_c,@mpmaOper_c
while @@fetch_status = 0  --Whileb
begin
insert INTo MPModelliAttributi(mpmaIdMpMod,mpmaIdDzt,mpmaRegObblig,mpmaOrdine,mpmaValoreDef,mpmaPesoDef,mpmaIdFva,mpmaIdUmsDef,mpmaLocked,mpmaShadow,mpmaOpzioni,mpmaOper)
values(@mpmaIdMpModNew,@mpmaIdDzt_c,@mpmaRegObblig_c,@mpmaOrdine_c,@mpmaValoreDef_c,@mpmaPesoDef_c,@mpmaIdFva_c,@mpmaIdUmsDef_c,@mpmaLocked_c,@mpmaShadow_c,@mpmaOpzioni_c,@mpmaOper_c)
IF @@error <> 0
                                           begin
                                                raiserror ('Errore insert MPModelliAttributi  (DeleteMpModAttr) ', 16, 1) 
                                                rollback tran
                                    close crsMpModAtt
                                    deallocate crsMpModAtt
                                                return 99
                                                 END
set  @IdMdlAttNew=@@identity
--MpAttributiControlli
insert INTo MpAttributiControlli(mpacIdMdlAtt,mpacIddzt,mpacValue) 
SELECT @IdMdlAttNew,mpacIddzt,mpacValue FROM MpAttributiControlli 
WHERE mpacIdMdlAtt=@IdMdlAttOld AND mpacDeleted=0
IF @@error <> 0
                                           begin
                                                raiserror ('Errore insert MpAttributiControlli  (DeleteMpModAttr) ', 16, 1) 
                                                rollback tran
                                                close crsMpModAtt
                                    deallocate crsMpModAtt
                                    return 99
                                                 END
fetch next FROM crsMpModAtt INTo @IdMdlAttOld,@mpmaIdMpMod_c,@mpmaIdDzt_c,@mpmaRegObblig_c,@mpmaOrdine_c,@mpmaValoreDef_c,@mpmaPesoDef_c,@mpmaIdFva_c,@mpmaIdUmsDef_c,@mpmaLocked_c,@mpmaShadow_c,@mpmaOpzioni_c,@mpmaOper_c
end--Whileb
close crsMpModAtt
deallocate crsMpModAtt
/***********************/
--cambio IdMpMod con l'ultimo generato
set @IdMpMod=@mpmaIdMpModNew
                              END
ELSE      BEGIN
--cancellazione logica
update MPAttributiControlli
set mpacDeleted=1
WHERE mpacIdMdlAtt in (SELECT IdMdlAtt FROM MPModelliAttributi
WHERE  mpmaIdMpMod=@IdMpMod AND mpmaIddzt=@mpmaIddzt)  
IF @@error <> 0
                                           begin
                                                raiserror ('Errore update MPAttributiControlli  (DeleteMpModAttr) ', 16, 1) 
                                                rollback tran
                                                return 99
                                                 END
--cancellazione logica
update MPModelliAttributi
set mpmaDeleted=1
WHERE mpmaIdMpMod=@IdMpMod AND mpmaIddzt=@mpmaIddzt  
IF @@error <> 0
                                           begin
                                                raiserror ('Errore update MPModelliAttributi  (DeleteMpModAttr) ', 16, 1) 
                                                rollback tran
                                                return 99
                                                 END
                              
end
      
commit tran
end


GO
