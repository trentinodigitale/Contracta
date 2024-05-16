USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[InsertMpModAttr]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Autore: Alfano Antonio
Scopo: Inserimento MpModelliAttributi
Data: 05/09/2001
*/
CREATE PROCEDURE [dbo].[InsertMpModAttr] (@IdDoc INT,@IdMp INT,@IdMpMod INT,@mpmaIdDzt INT, @mpmaRegObblig bit, @mpmaValoreDef VARCHAR(50) , @mpmaPesoDef INT, @mpmaIdFva INT, @mpmaIdUmsDef INT, @mpmaLocked bit, @mpmaShadow bit,@mpmaOpzioni VARCHAR(20),@mpmaOper VARCHAR(20),@strMpacIddzt VARCHAR(500), @strMpacValue VARCHAR(500),@idMpModNew  INT OUTPUT,@IdDocNew INT OUTPUT) AS  
begin 
DECLARE @RC INT
DECLARE @IdMpCorr1 INT --idMp corrente
DECLARE @mpmaOrdine INT --Ordine
DECLARE @mpmaIdMpModNew INT --IdMpMod temporaneo
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
DECLARE @IdMdlAtt INT
DECLARE @DocIdMpMod INT
--per MpacIddzt 
DECLARE @pos INT
DECLARE @MpacIddzt INT
DECLARE @subMpacIddzt VARCHAR(10)
--per MpacValue 
DECLARE @pos2 INT
DECLARE @MpacValue VARCHAR(30)
set @IdDocNew=@IdDoc
begin tran
--Controllo stringhe controlli --not (entrambe vuote o entrambe piene)
/*IF @strMpacIddzt<>'' or  @strMpacValue  <>''      BEGIN
                                                raiserror ('Errore formattazione stringhe  (InsertMpModAttr) ', 16, 1) 
                                                rollback tran
                                                return 99
                                    END
*/
 -- not (entrambe vuote o entrambe piene)
IF not ((@strMpacIddzt<>'' AND  @strMpacValue  <>'') or ( @strMpacIddzt='' AND  @strMpacValue=''))      BEGIN
                                                raiserror ('Errore formattazione stringhe  (InsertMpModAttr) ', 16, 1) 
                                                rollback tran
                                                return 99
                                    END 
SELECT @DocIdMpMod=DocIdMpMod FROM Mpdocumenti
WHERE IdDoc=@IdDoc AND docDeleted=0
IF @DocIdMpMod IS NULL       BEGIN
                                          raiserror ('Errore record inesistente(InsertMpModAttr) ', 16, 1) 
                                                rollback tran
                                                return 99
                        END
--IdMpMod da MPModelli
SELECT @IdMpCorr1=mpmIdMp FROM MPModelli
WHERE IdMpMod=@IdMpMod AND mpmDeleted=0
set @idMpModNew=@IdMpMod
IF @IdMpCorr1 IS NULL       BEGIN
                                    raiserror ('Errore record inesistente(InsertMpModAttr) ', 16, 1) 
                                                rollback tran
                                                return 99
                        END
--consistenza del modello
IF @DocIdMpMod<>@IdMpMod      BEGIN
                                          raiserror ('Errore modello inconsistente(InsertMpModAttr) ', 16, 1) 
                                                rollback tran
                                                return 99
                        END
--Assiomi
IF @IdMp=0            BEGIN
      IF @IdMpCorr1<>0                        BEGIN
                                          raiserror ('Errore MP  inconsistenti  (InsertMpModAttr) ', 16, 1) 
                                                      rollback tran
                                                      return 99
                                          END
                  END
            ELSE      BEGIN
      IF @IdMp<>@IdMpCorr1 AND not @IdMpCorr1=0      BEGIN
                                          raiserror ('Errore MP  inconsistenti  (InsertMpModAttr) ', 16, 1) 
                                                      rollback tran
                                                      return 99                  
                                          END
                  END
--Controllo esistenza IdDzt
IF not exists(SELECT * FROM DizionarioAttributi 
            WHERE IdDzt=@mpmaIdDzt       AND dztDeleted=0       )      BEGIN
                                    raiserror ('Errore record DizionarioAttributi inesistente(InsertMpModAttr) ', 16, 1) 
                                                rollback tran
                                                return 99
                                          END
--Controllo esistenza IdDzt-IdMpMod
IF exists( SELECT * FROM MpModelliAttributi
         WHERE mpmaIdDzt=@mpmaIdDzt AND mpmaIdMpMod=@IdMpMod AND mpmaDeleted=0) AND  (@IdMpCorr1<>0 or @IdMpCorr1=@IdMp)        BEGIN
                              
                                    raiserror ('Errore record gia esistente(InsertMpModAttr) ', 16, 1) 
                                                rollback tran
                                                return 99
                                                                  END 
--riciclo attributo gia esistente!!!!
SELECT @IdMdlAtt=IdMdlAtt  FROM MpModelliAttributi,MpModelli
WHERE mpmaIdDzt=@mpmaIdDzt AND mpmaIdMpMod=@IdMpMod AND mpmaDeleted=1 AND mpmaIdMpMod=IdMpMod AND mpmIdMp=@IdMp 
IF @IdMdlAtt is not NULL            BEGIN
update MpModelliAttributi
set mpmaDeleted=0
WHERE @IdMdlAtt=IdMdlAtt
IF @@error <> 0
                                                 BEGIN
                                                raiserror ('Errore update MPModelliAttributi  (InsertMpModAttr) ', 16, 1) 
                                                rollback tran
                                                return 99
                                                  END
EXEC @RC = [dbo].[UpdateMpModAttr] @IdDoc,@IdMp, @IdMdlAtt, @mpmaRegObblig, @mpmaValoreDef, @mpmaPesoDef, @mpmaIdFva, @mpmaIdUmsDef, @mpmaLocked, @mpmaShadow, @mpmaOpzioni,@mpmaOper, @strMpacIddzt, @strMpacValue, @idMpModNew OUTPUT, @IdDocNew OUTPUT  
IF @RC =99      BEGIN
                                    raiserror ('Errore "Exec" stored UpdateMpModAttr (InsertMpModAttr) ', 16, 1) 
                                                rollback tran
                                                return 99
            END
commit tran
return 0
                        END
--Criterio di copia
IF @IdMpCorr1=0 AND @IdMpCorr1<>@IdMp      BEGIN --ifc
--copia record MPModelli
insert INTo MPModelli(mpmIdMp,mpmDesc,mpmTipo)
SELECT @IdMp,mpmDesc,mpmTipo FROM MPModelli
WHERE IdMpMod=@IdMpMod
IF @@error <> 0
                                           begin
                                                raiserror ('Errore insert MPModelli (InsertMpModAttr) ', 16, 1) 
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
                                                raiserror ('Errore insert MpDocumenti  (InsertMpModAttr) ', 16, 1) 
                                                rollback tran
                                                return 99
                                                 END
set @IdDocNew=@@identity
/********/
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
                                                raiserror ('Errore insert MPModelliAttributi  (InsertMpModAttr) ', 16, 1) 
                                                rollback tran
                                    close crsMpModAtt
                                    deallocate crsMpModAtt
                                                return 99
                                                 END
set  @IdMdlAtt=@@identity
--MpAttributiControlli
insert INTo MpAttributiControlli(mpacIdMdlAtt,mpacIddzt,mpacValue) 
SELECT @IdMdlAtt,mpacIddzt,mpacValue FROM MpAttributiControlli 
WHERE mpacIdMdlAtt=@IdMdlAttOld AND mpacDeleted=0
IF @@error <> 0
                                           begin
                                                raiserror ('Errore insert MpAttributiControlli (InsertMpModAttr) ', 16, 1) 
                                                rollback tran
                                    close crsMpModAtt
                                    deallocate crsMpModAtt
                                                return 99
                                                 END
fetch next FROM crsMpModAtt INTo @IdMdlAttOld,@mpmaIdMpMod_c,@mpmaIdDzt_c,@mpmaRegObblig_c,@mpmaOrdine_c,@mpmaValoreDef_c,@mpmaPesoDef_c,@mpmaIdFva_c,@mpmaIdUmsDef_c,@mpmaLocked_c,@mpmaShadow_c,@mpmaOpzioni_c,@mpmaOper_c
end--Whileb
close crsMpModAtt
deallocate crsMpModAtt
/*******/
--cambio IdMpMod con l'ultimo generato
set @IdMpMod=@mpmaIdMpModNew
                              END  --ifc
--massimo ordine 
SELECT @mpmaOrdine=max(mpmaOrdine) FROM MPModelliAttributi
WHERE mpmaIdMpMod=@IdMpMod
IF @mpmaOrdine IS NULL       BEGIN
set @mpmaOrdine=0
                  END
set @mpmaOrdine=@mpmaOrdine+1
 
/*
IF @mpmaValoreDef=''
   begin
      @mpmaValoreDef=NULL
  end
*/
DECLARE @a VARCHAR(51)
set  @a=@mpmaValoreDef+'.'
IF len(@a)=1
   begin
          set  @mpmaValoreDef=NULL
  end
--Inserimento MpModelliAttributi
insert INTo MPModelliAttributi(mpmaIdMpMod,mpmaIdDzt,mpmaRegObblig,mpmaValoreDef,mpmaPesoDef,mpmaIdFva,mpmaIdUmsDef,mpmaLocked,mpmaShadow,mpmaOpzioni,mpmaOrdine,mpmaOper)  
values(@IdMpMod,@mpmaIdDzt, @mpmaRegObblig,@mpmaValoreDef ,NULLIF(@mpmaPesoDef,-1), NULLIF(@mpmaIdFva,-1), NULLIF(@mpmaIdUmsDef,-1) , @mpmaLocked, @mpmaShadow,@mpmaOpzioni,@mpmaOrdine,NULLIF(@mpmaOper,-1))
IF @@error <> 0
                                                 BEGIN
                                                raiserror ('Errore insert MPModelliAttributi  (InsertMpModAttr) ', 16, 1) 
                                                rollback tran
                                                return 99
                                                  END
set  @IdMdlAtt=@@identity
/* scompattamento delle stringa @strMpacIddzt e @strMpacValue  e inserimento nella MpAttributiControlli */
while @strMpacIddzt <> ''   begin
      set @Pos = PATINDEX('%#~%', @strMpacIddzt)
      set @subMpacIddzt = left (@strMpacIddzt, @Pos - 1) -- Estrazione della funzionalita
      set @strMpacIddzt = substring(@strMpacIddzt, @Pos + 2, len(@strMpacIddzt)- @Pos)  --riduzione della string delle funzionalita
      set @Pos2 = PATINDEX('%#~%', @strMpacValue)
      set @MpacValue = left (@strMpacValue, @Pos2 - 1) -- Estrazione della funzionalita
      set @strMpacValue = substring(@strMpacValue, @Pos2 + 2, len(@strMpacValue)- @Pos2)  --riduzione della string delle funzionalita
--Controllo valore numerico, mentre "ELSE" segnala l'errore  
  IF isnumeric(@subMpacIddzt)=1     begin --ifi
   
   set @MpacIddzt = cast (@subMpacIddzt AS INT)
IF exists(SELECT * FROM DizionarioAttributi WHERE Iddzt=@MpacIddzt )                        BEGIN--ife
--Inserimento in MpAttributiControlli
insert INTo MpAttributiControlli(mpacIdMdlAtt,mpacIddzt,mpacValue) values(@IdMdlAtt,@mpacIddzt,@mpacValue)
IF @@error <> 0
                                                 BEGIN
                                                raiserror ('Errore insert MpAttributiControlli  (InsertMpModAttr) ', 16, 1) 
                                                rollback tran
                                                return 99
                                                  END
                              END--ife
                              ELSE--ife
                              BEGIN--ife
                                                raiserror ('Errore valore mpacIdDzt non presente nel DizionarioAttributi  (InsertMpModAttr) ', 16, 1) 
                                                rollback tran
                                                return 99
                              END--ife
   
     end --ifi
      ELSE --ifi   
                                                 BEGIN --ifi
                                                raiserror ('Errore valore mpacIdDzt non numerico  (InsertMpModAttr) ', 16, 1) 
                                                rollback tran
                                                return 99
                                                  END --ifi
end --while
IF @strMpacIddzt<>'' or  @strMpacValue  <>''      BEGIN
                                                raiserror ('Errore formattazione stringhe  (InsertMpModAttr) ', 16, 1) 
                                                rollback tran
                                                return 99
                                    END
commit tran
end


GO
