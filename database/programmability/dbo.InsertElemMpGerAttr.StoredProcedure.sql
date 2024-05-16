USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[InsertElemMpGerAttr]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
/*
Autore: Alfano Antonio
Scopo: Inserimento elemento MPGerarchiaAttributi
Data: 25/ 6 /2001
*/
CREATE PROCEDURE [dbo].[InsertElemMpGerAttr] (@mpgaIdMp INT,@mpgaContesto VARCHAR(50),@mpgaIdDzt INT, @mpgaProfili VARCHAR(20), @mpgaMultiSel bit, @strLingue VARCHAR(100),@strDescs NVARCHAR(4000), @IdMpgaPadre INT )AS
begin
begin tran
DECLARE @iCstr INT --contatore descrittive
DECLARE @mpgaIdMpPadre INT --IdMp padre
DECLARE @mpgaLenPathPadre smallint --len padre
DECLARE @mpgaLivello smallint --livello padre
DECLARE @mpgaPath VARCHAR(100) --path
DECLARE @pathLastChild VARCHAR(100)  --path di appoggio
DECLARE @mpgaPathPadre VARCHAR(100)  --path padre
DECLARE @mpgaDescr VARCHAR(101) --FK multilinguismo
/*var per lo scompattamento */
DECLARE @pos INT 
DECLARE @substrDescs NVARCHAR(4000)
DECLARE @mpgaFoglia bit
DECLARE @Pos2 INT
DECLARE @substrLingue VARCHAR(5)
DECLARE @LinguaI NVARCHAR(4000)
DECLARE @LinguaUK NVARCHAR(4000)
DECLARE @LinguaE NVARCHAR(4000)
DECLARE @LinguaFRA NVARCHAR(4000) 
DECLARE @LinguaLng1 NVARCHAR(4000)
DECLARE @LinguaLng2 NVARCHAR(4000)
DECLARE @LinguaLng3 NVARCHAR(4000)
DECLARE @LinguaLng4 NVARCHAR(4000)
DECLARE @mpgaIdDztPadre INT --IdDzt Padre
set @mpgaFoglia=1
IF @mpgaIdMp=0 AND  @IdMpgaPadre<>0       begin
      IF  not exists (SELECT * FROM MPGerarchiaAttributi WHERE IdMpga=@IdMpgaPadre AND mpgaIdMp=0 AND mpgaDeleted=0)      BEGIN
                                    raiserror ('Errore MP inconsistenti  (InsertElemMpGerAttr) ', 16, 1) 
                                                rollback tran
                                                return 99
                                                                                          END
            
                              END
IF @mpgaIdMp<>0 AND  @IdMpgaPadre<>0       begin
      IF  not exists (SELECT * FROM MPGerarchiaAttributi WHERE IdMpga=@IdMpgaPadre AND mpgaIdMp=@mpgaIdMp AND mpgaDeleted=0) AND not exists (SELECT * FROM MPGerarchiaAttributi WHERE IdMpga=@IdMpgaPadre AND mpgaIdMp=0 AND mpgaDeleted=0)      BEGIN
                                    raiserror ('Errore MP inconsistenti  (InsertElemMpGerAttr) ', 16, 1) 
                                                rollback tran
                                                return 99
                                                                                          END
                              END
--Esistenza padre!!!!!
IF not exists (SELECT * FROM MPGerarchiaAttributi WHERE IdMpga=@IdMpgaPadre AND mpgaDeleted=0) AND @IdMpgaPadre<>0       BEGIN
                                                 raiserror ('Errore padre inesistente  (InsertElemMpGerAttr) ', 16, 1) 
                                                rollback tran
                                                return 99
                                                                              END
--CASO NODO VIRTUALE*********************************************************** =0
IF @IdMpgaPadre=0      BEGIN --ifpv
set @mpgaPathPadre=''                  
set @mpgaLivello=0
set @mpgaLenPathPadre=0
                  END --ifpv
ELSE --ifpv
                  BEGIN --ifpv  
--seleziona dati del padre
SELECT @mpgaIdDztPadre=mpgaIdDzt,@mpgaContesto=mpgaContesto,@mpgaIdMpPadre=mpgaIdMp,@mpgaPathPadre=mpgaPath,@mpgaLivello=mpgaLivello,@mpgaLenPathPadre=mpgaLenPathPadre FROM MPGerarchiaAttributi
WHERE IdMpGa=@IdMpgaPadre 
--il padre deve essere un nodo con mpgaIdDzt=-1
IF @mpgaIdDztPadre<>-1       BEGIN
                                                 raiserror ('Errore il nodo selezionato non pu= essere padre   (InsertElemMpGerAttr) ', 16, 1) 
                                                rollback tran
                                                return 99
                  END
                  END --ifpv
/***********  QUA E' AGGIUNTA LINEA 200 **************/
--Controllo albero gia esistente
IF @mpgaIdMpPadre=0 AND exists(SELECT * FROM MPGerarchiaAttributi
WHERE  mpgaIdMp=@mpgaIdMp AND mpgaContesto=@mpgaContesto AND  @mpgaIdMp<>0 AND mpgaDeleted=0 )        begin
                                    raiserror ('Errore MP gia esistente  (InsertElemMpGerAttr) ', 16, 1) 
                                                rollback tran
                                                return 99
                                          END
/********************************/
--@mpgaIdDzt=-1 F un nodo INTerno!!!
IF @mpgaIdDzt=-1       BEGIN   --if2
--set @mpgaFoglia=0
set @iCstr=0 
set @mpgaProfili=NULL
set @mpgaMultiSel=1
--Selezione delle descrittive
while @strLingue <> '' AND @strDescs<>''   begin
      set @Pos = PATINDEX('%#~%', @strDescs)
      set @substrDescs = left (@strDescs, @Pos - 1) -- Estrazione della descrizioni
      set @strDescs = substring(@strDescs, @Pos + 2, len(@strDescs)- @Pos)  --riduzione della string delle descrizioni
      set @Pos2 = PATINDEX('%#~%', @strLingue)
      set @substrLingue = left (@strLingue, @Pos2 - 1) -- Estrazione della Lingua
      set @strLingue = substring(@strLingue, @Pos2 + 2, len(@strLingue)- @Pos2)  --riduzione della string delle lingua
 
IF @substrLingue='I'      BEGIN
                  set @iCstr=@iCstr+1
                  set @LinguaI=@substrDescs                  
                         END
IF @substrLingue='UK'      BEGIN
                  set @iCstr=@iCstr+1
                  set @LinguaUK=@substrDescs                  
                  END
IF @substrLingue='E'      BEGIN
                  set @iCstr=@iCstr+1
                  set @LinguaE=@substrDescs                  
                  END
 
IF @substrLingue='FRA'      BEGIN
                  set @iCstr=@iCstr+1
                  set @LinguaFRA=@substrDescs                  
                  END
IF @substrLingue='Lng1'      BEGIN
                  set @iCstr=@iCstr+1
                  set @LinguaLng1=@substrDescs                  
                  END
IF @substrLingue='Lng2'      BEGIN
                  set @iCstr=@iCstr+1
                  set @LinguaLng2=@substrDescs                  
                  END
IF @substrLingue='Lng3'      BEGIN
                  set @iCstr=@iCstr+1
                  set @LinguaLng3=@substrDescs                  
                  END
IF @substrLingue='Lng4'      BEGIN
                  set @iCstr=@iCstr+1
                  set @LinguaLng4=@substrDescs                  
                  END
end --while
--Controllo sulla formattazione
IF @strLingue<>'' or @strDescs<>'' begin  -- or @iCstr=4      
                              /* Errore formattazione stringa*/
                                                raiserror ('Errore formato string descs or lingua (InsertElemMpGerAttr) ', 16, 1) 
                                                rollback tran
                                                return 99
                              END  
set @iCstr=0
--creazione chiave del ML e inserimento nel multilinguismo
while 1=1            BEGIN
set @iCstr=@iCstr+1
set @mpgaDescr=substring(@LinguaI,1,80)+cast(@iCstr AS VARCHAR(10))
IF not exists (SELECT * FROM Multilinguismo
WHERE IdMultiLng=@mpgaDescr)  begin
insert INTo Multilinguismo(IdMultiLng, mlngDesc_I, mlngDesc_UK, mlngDesc_FRA, mlngDesc_E,mlngDesc_Lng1,mlngDesc_Lng2,mlngDesc_Lng3,mlngDesc_Lng4) 
values(@mpgaDescr,@LinguaI,@LinguaUK,@LinguaFRA,@LinguaE,@LinguaLng1,@LinguaLng2,@LinguaLng3,@LinguaLng4)
                      IF @@error <> 0
                                           begin
                                                raiserror ('Errore insert Multilinguismo  (InsertElemMpGerAttr) ', 16, 1) 
                                                rollback tran
                                                return 99
                                                 END
break
                  END
end  --while
                  END  --if2
ELSE begin      --if2
--Controllare esistenza IdDzt
IF not exists( SELECT * FROM DizionarioAttributi
            WHERE  IdDzt=@mpgaIdDzt)      BEGIN
                                                raiserror ('Errore mpgaIdDzt non esistente  (InsertElemMpGerAttr) ', 16, 1) 
                                                rollback tran
                                                return 99
                                    END
set @mpgaDescr=NULL
--set @mpgaFoglia=1
                  END      --if2
IF not exists(SELECT * FROM MPGerarchiaAttributi WHERE mpgaIdMp=@mpgaidmp AND mpgaContesto=@mpgaContesto AND mpgaDeleted=0) AND @mpgaidmp<>0   begin --ifi
--copia albero padre  
insert INTo MPGerarchiaAttributi(mpgaIdMp,mpgaContesto,mpgaDescr,mpgaIdDzt,mpgaPath,mpgaLivello,mpgaFoglia,mpgaLenPathPadre,mpgaProfili,mpgaMultiSel) 
SELECT @mpgaIdMp,mpgaContesto,mpgaDescr,mpgaIdDzt,mpgaPath,mpgaLivello,mpgaFoglia,mpgaLenPathPadre,mpgaProfili,mpgaMultiSel FROM MPGerarchiaAttributi
WHERE mpgaContesto=@mpgaContesto AND mpgaIdMp=0 AND mpgaDeleted=0
                      IF @@error <> 0
                                           begin
                                                raiserror ('Errore insert MPGerarchiaAttributi  (InsertElemMpGerAttr) ', 16, 1) 
                                                rollback tran
                                                return 99
                                                 END
IF @mpgaLivello>0      BEGIN
--cambio padre
SELECT @IdMpgaPadre=IdMpGa FROM MPGerarchiaAttributi
WHERE mpgaContesto=@mpgaContesto AND mpgaIdMp=@mpgaIdMp AND mpgaPath=@mpgaPathPadre AND mpgaDeleted=0
                  END
end --ifi
/********** CASO IN CUI NON CI SONO NODI ********/ 
--Inserimento di una nuova root
IF @mpgaLivello=0      BEGIN   --ifli
SELECT  @pathLastChild=max(mpgaPath)  
FROM MPGerarchiaAttributi  
WHERE mpgaContesto=@mpgaContesto AND mpgaIdMp=@mpgaIdMp AND mpgaLivello=1  AND mpgaDeleted=0  
                  END   --ifli
ELSE --ifli
                  BEGIN  --ifli 
--Massimi tra le path 
SELECT  @pathLastChild=max(mpgaPath)  
FROM MPGerarchiaAttributi  
WHERE mpgaPath like @mpgaPathPadre+'%' AND mpgaContesto=@mpgaContesto  AND mpgaIdMp=@mpgaIdMp AND mpgaLivello=@mpgaLivello+1  AND mpgaDeleted=0  
--Aggiornamento del padre mpgaFoglia=0
update MPGerarchiaAttributi
set mpgaFoglia=0
WHERE IdMpGa=@IdMpgaPadre  
                      IF @@error <> 0
                                           begin
                                                raiserror ('Errore update MPGerarchiaAttributi  (InsertElemMpGerAttr) ', 16, 1) 
                                                rollback tran
                                                return 99
                                                 END
                  
                  END --ifli
--costuzione nuova path
--Caso in cui non ci sono nodi a quel livello
IF @pathLastChild IS NULL begin
                  set @pathLastChild='000.'
                  END
--possibilita di inserire un nuovo nodo(superato il max)
IF cast(substring(right(@pathLastChild,4),1,3) AS INT)=999 begin
                              /*errore nodi non disponobili */
                                        raiserror ('Errore: Impossibile inserire nodo (InsertElemMpGerAttr) ', 16, 1) 
                                                rollback tran
                                                return 99
                              END
--costruzione nuova path
set @pathLastChild=cast(cast(substring(right(@pathLastChild,4),1,3) AS INT)+1 AS VARCHAR(100))  
set @pathLastChild=@mpgaPathPadre+left('000',3-len(@pathLastChild))+@pathLastChild+ '.' 
/*
--Controllo albero gia esistente
IF @mpgaIdMpPadre=0 AND exists(SELECT * FROM MPGerarchiaAttributi
WHERE  mpgaIdMp=@mpgaIdMp AND mpgaContesto=@mpgaContesto AND  @mpgaIdMp<>0)        begin
                                    raiserror ('Errore MP gia esistente  (InsertElemMpGerAttr) ', 16, 1) 
                                                rollback tran
                                                return 99
                                          END
*/
--inserimento del nuovo nodo
insert INTo MPGerarchiaAttributi(mpgaIdMp,mpgaContesto,mpgaDescr,mpgaIdDzt,mpgaPath,mpgaLivello,mpgaFoglia,mpgaLenPathPadre,mpgaProfili,mpgaMultiSel) 
values(@mpgaIdMp,@mpgaContesto,@mpgaDescr,@mpgaIdDzt,@pathLastChild,@mpgaLivello+1,@mpgaFoglia,len(@mpgaPathPadre),NULLIF(@mpgaProfili,''),@mpgaMultiSel)
                      IF @@error <> 0
                                           begin
                                                raiserror ('Errore insert MPGerarchiaAttributi  (InsertElemMpGerAttr) ', 16, 1) 
                                                rollback tran
                                                return 99
                                                 END
commit tran
end
GO
