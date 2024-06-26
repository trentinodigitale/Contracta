USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[MoveMpModAttr]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Autore: Alfano Antonio
Scopo: Ordinamento MpModelliAttributi
Data:   7/9/2001
*/
CREATE PROCEDURE [dbo].[MoveMpModAttr] (@IdDoc INT,@IdMp INT, @IdMpMod INT, @strmpmaIddzt VARCHAR(500),@idMpModNew  INT  OUTPUT,@IdDocNew INT OUTPUT)
AS
begin
DECLARE @isDone bit
DECLARE @DocIdMpMod INT
DECLARE @subMpmaIddzt VARCHAR(10) --IdMdlAtt corrente in formato VARCHAR
DECLARE @mpmaIdDzt INT --IdMdlAtt corrente
DECLARE @pos INT --posizione pathindex
DECLARE @iOrder INT --nuovo ordine IdMdlAtt
DECLARE @mpmIdMp INT --Idmp corrente
--DECLARE @IdMpMod INT --IdMpMod corrente
DECLARE @mpmaIdMpModNew INT --IdMpMod nuovo
--valori cursore
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
set @isDone=0
begin tran
set @iOrder=0
SELECT @DocIdMpMod=DocIdMpMod FROM Mpdocumenti
WHERE IdDoc=@IdDoc AND docDeleted=0
IF @DocIdMpMod IS NULL       BEGIN
                                          raiserror ('Errore record inesistente(MoveMpModAttr) ', 16, 1) 
                                                rollback tran
                                                return 99
                        END
--selezione  IdMp  
SELECT @mpmIdMp=mpmIdMp FROM MpModelli
WHERE IdMpMod=@IdMpMod AND mpmDeleted=0 
set @idMpModNew=@IdMpMod
IF @mpmIdMp IS NULL      BEGIN
                                                raiserror ('Errore modello non esistente (MoveMpModAttr) ', 16, 1) 
                                                rollback tran
                                                return 99
                  END
--consistenza del modello
IF @DocIdMpMod<>@IdMpMod      BEGIN
                                          raiserror ('Errore modello inconsistente(MoveMpModAttr) ', 16, 1) 
                                                rollback tran
                                                return 99
                        END
--Assiomi
IF @IdMp=0            BEGIN
      IF @mpmIdMp<>0                        BEGIN
                                          raiserror ('Errore MP  inconsistenti  (MoveMpModAttr) ', 16, 1) 
                                                rollback tran
                                                return 99
                                          END
                  END
            ELSE      BEGIN
      IF @IdMp<>@mpmIdMp AND not @mpmIdMp=0      BEGIN
                                          raiserror ('Errore MP  inconsistenti  (MoveMpModAttr) ', 16, 1) 
                                                rollback tran
                                                return 99                  
                                          END
                  END
--Criterio di copia (tabelle MPModelli e MpDocumenti)
IF @mpmIdMp=0 AND @mpmIdMp<>@IdMp      BEGIN
--copia record MPModelli
insert INTo MPModelli(mpmIdMp,mpmDesc,mpmTipo)
SELECT @IdMp,mpmDesc,mpmTipo FROM MPModelli
WHERE IdMpMod=@IdMpMod
IF @@error <> 0
                                           begin
                                                raiserror ('Errore insert MPModelli (MoveMpModAttr) ', 16, 1) 
                                                rollback tran
                                                return 99
                                                 END
set @mpmaIdMpModNew=@@identity
set @idMpModNew=@mpmaIdMpModNew
/* cursore per la costruzione degli idMdlatt e relativa copia dei controlli associati*/
--cursore per la copia degli attributicontrolli 
--copia record MPModelliAttributi
DECLARE crsMpModAtt cursor static for       SELECT IdMdlAtt,mpmaIdMpMod,mpmaIdDzt,mpmaRegObblig,mpmaOrdine,mpmaValoreDef,mpmaPesoDef,mpmaIdFva,mpmaIdUmsDef,mpmaLocked,mpmaShadow,mpmaOpzioni,mpmaOper FROM MPModelliAttributi
                        WHERE mpmaIdMpMod=@IdMpMod AND mpmaDeleted=0
           
open crsMpModAtt
fetch next FROM crsMpModAtt INTo @IdMdlAttOld,@mpmaIdMpMod_c,@mpmaIdDzt_c,@mpmaRegObblig_c,@mpmaOrdine_c,@mpmaValoreDef_c,@mpmaPesoDef_c,@mpmaIdFva_c,@mpmaIdUmsDef_c,@mpmaLocked_c,@mpmaShadow_c,@mpmaOpzioni_c,@mpmaOper_c
while @@fetch_status = 0  --Whileb
begin
insert INTo MPModelliAttributi(mpmaIdMpMod,mpmaIdDzt,mpmaRegObblig,mpmaOrdine,mpmaValoreDef,mpmaPesoDef,mpmaIdFva,mpmaIdUmsDef,mpmaLocked,mpmaShadow,mpmaOpzioni,mpmaOper)
values(@mpmaIdMpModNew,@mpmaIdDzt_c,@mpmaRegObblig_c,@mpmaOrdine_c,@mpmaValoreDef_c,@mpmaPesoDef_c,@mpmaIdFva_c,@mpmaIdUmsDef_c,@mpmaLocked_c,@mpmaShadow_c,@mpmaOpzioni_c,@mpmaOper_c)
IF @@error <> 0
                                           begin
                                                raiserror ('Errore insert MPModelliAttributi  (MoveMpModAttr) ', 16, 1) 
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
                                                raiserror ('Errore insert MpAttributiControlli (MoveMpModAttr) ', 16, 1) 
                                                rollback tran
                                    close crsMpModAtt
                                    deallocate crsMpModAtt
                                                return 99
                                                 END
fetch next FROM crsMpModAtt INTo @IdMdlAttOld,@mpmaIdMpMod_c,@mpmaIdDzt_c,@mpmaRegObblig_c,@mpmaOrdine_c,@mpmaValoreDef_c,@mpmaPesoDef_c,@mpmaIdFva_c,@mpmaIdUmsDef_c,@mpmaLocked_c,@mpmaShadow_c,@mpmaOpzioni_c,@mpmaOper_c
end--Whileb
close crsMpModAtt
deallocate crsMpModAtt
set @isDone=1
--copia record MpDocumenti
insert INTo MpDocumenti(docIdMp,docItype,docPath,docIdMpMod,docISubType,docIsReplicable)
SELECT @IdMp,docItype,docPath,@mpmaIdMpModNew,docISubType,docIsReplicable FROM MpDocumenti
WHERE IdDoc=@IdDoc --docIdMpMod=@IdMpMod AND docDeleted=0 --and docIdMp=@IdMpCorr1 
IF @@error <> 0
                                           begin
                                                raiserror ('Errore insert MpDocumenti  (MoveMpModAttr) ', 16, 1) 
                                                rollback tran
                                                return 99
                                                 END
set @IdDocNew=@@identity
--cambio IdMpMod con l'ultimo generato
set @IdMpMod=@mpmaIdMpModNew
                              END
/******************************************/
--ciclo di scompattamento e aggiornamento(o inserimento) dei IdMdlAtt
while  @strmpmaIddzt<>''   begin
      set @Pos = PATINDEX('%#~%', @strmpmaIddzt)
            set @subMpmaIddzt = left (@strmpmaIddzt, @Pos - 1) -- Estrazione della IdMdlAtt
            set @strmpmaIddzt = substring(@strmpmaIddzt, @Pos + 2, len(@strmpmaIddzt)- @Pos)  --riduzione della string dei IdMdlAtt
      set @iOrder=@iOrder+1 --aggiornamento ordine
--controllo valore numerico
IF isnumeric(@subMpmaIddzt)=0     begin 
                                                raiserror ('Errore valore MpmaIddzt non numerico (MoveMpModAttr) ', 16, 1) 
                                                rollback tran
                                                return 99
                              END
set @mpmaIdDzt = cast (@subMpmaIddzt AS INT) --cast IdMdlAtt
--controllo
IF not exists(SELECT * FROM MPModelliAttributi WHERE  mpmaIdDzt=@mpmaIdDzt AND mpmaIdMpMod=@IdMpMod AND mpmadeleted=0)            BEGIN
                                                raiserror ('Errore valore Iddzt non esistente nel modello (MoveMpModAttr) ', 16, 1) 
                                                rollback tran
                                                return 99
                                                                                    END
--Criterio di copia
IF @mpmIdMp=0 AND @mpmIdMp<>@IdMp AND @isDone=0      BEGIN
--copia record MPModelliAttributi
insert INTo MPModelliAttributi(mpmaIdMpMod,mpmaIdDzt,mpmaRegObblig,mpmaOrdine,mpmaValoreDef,mpmaPesoDef,mpmaIdFva,mpmaIdUmsDef,mpmaLocked,mpmaShadow,mpmaOpzioni,mpmaOper)
SELECT @IdMpMod,mpmaIdDzt,mpmaRegObblig,@iOrder,mpmaValoreDef,mpmaPesoDef,mpmaIdFva,mpmaIdUmsDef,mpmaLocked,mpmaShadow,mpmaOpzioni,mpmaOper FROM MPModelliAttributi
WHERE  mpmaIdDzt=@mpmaIdDzt AND mpmaIdMpMod=@IdMpMod AND mpmaDeleted=0
IF @@error <> 0
                                           begin
                                                raiserror ('Errore insert MPModelliAttributi  (MoveMpModAttr) ', 16, 1) 
                                                rollback tran
                                                return 99
                                                 END
                              END
                              ELSE
                              BEGIN
--aggiornamento record MPModelliAttributi
update MpModelliAttributi 
set mpmaOrdine=@iOrder
WHERE  mpmaIdDzt=@mpmaIdDzt AND mpmaIdMpMod=@IdMpMod AND mpmaDeleted=0
IF @@error<>0      BEGIN 
                                                raiserror ('Errore: "update" MpModelliAttributi (MoveMpModAttr) ', 16, 1) 
                                                rollback tran
                                                return 99
            END  
                              END 
end --while
commit tran
end


GO
