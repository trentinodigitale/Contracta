USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[UpdateElemMpGerAttr]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
/*
Autore: Alfano Antonio
Scopo: Aggiornamento MpGerarchiaAttributi
Data: 26/6/2001
*/
CREATE PROCEDURE  [dbo].[UpdateElemMpGerAttr] (@mpgaIdMp INT, @mpgaProfili VARCHAR(20), @mpgaMultiSel bit, @strLingue VARCHAR(100),@strDescs NVARCHAR(4000), @IdMpga INT )AS
begin
begin tran
DECLARE @mpgaIdDzt INT --IdDzt del nodo selezionato
DECLARE @mpgaContesto VARCHAR(50)  --contesto del nodo selezionato
DECLARE @iCstr INT --contatore
DECLARE @mpgaIdMpSel INT  ----IdMp del nodo selezionato
DECLARE @mpgaPath VARCHAR(100) --path del nodo
DECLARE @mpgaDescr VARCHAR(101)  --chiave ML
/*var per lo scompattamento*/
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
--Esistenza nodo!!!!!
IF not exists (SELECT * FROM MPGerarchiaAttributi WHERE IdMpga=@IdMpga AND mpgaDeleted=0)      BEGIN
                                                 raiserror ('Errore nodo inesistente  (UpdateElemMpGerAttr) ', 16, 1) 
                                                rollback tran
                                                return 99
                                                                              END
--Assiomi
IF @mpgaIdMp=0        begin
      IF  not exists (SELECT * FROM MPGerarchiaAttributi WHERE IdMpga=@IdMpga AND mpgaIdMp=0 AND mpgaDeleted=0)      BEGIN
                                    raiserror ('Errore MP inconsistenti  (UpdateElemMpGerAttr) ', 16, 1) 
                                                rollback tran
                                                return 99
                                                                                          END
            
                              END
ELSE       begin
      IF  not exists (SELECT * FROM MPGerarchiaAttributi WHERE IdMpga=@IdMpga AND mpgaIdMp=@mpgaIdMp AND mpgaDeleted=0) AND not exists (SELECT * FROM MPGerarchiaAttributi WHERE IdMpga=@IdMpga AND mpgaIdMp=0 AND mpgaDeleted=0)      BEGIN
                                    raiserror ('Errore MP inconsistenti  (UpdateElemMpGerAttr) ', 16, 1) 
                                                rollback tran
                                                return 99
                                                                                          END
                              END
--seleziona dati del nodo
SELECT @mpgaIdDzt=mpgaIdDzt,@mpgaContesto=mpgaContesto,@mpgaIdMpSel=mpgaIdMp,@mpgaPath=mpgaPath,@mpgaIdMpSel=mpgaIdMp FROM MPGerarchiaAttributi
WHERE IdMpGa=@IdMpga AND mpgaDeleted=0
--@mpgaIdDzt=-1 F un nodo INTerno!!!
IF @mpgaIdDzt=-1       BEGIN   --if2
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
IF @strLingue<>'' or @strDescs<>''       BEGIN --or @iCstr<>4
                              /* Errore formattazione stringa*/
                                                raiserror ('Errore formato string descs or lingua (UpdateElemMpGerAttr) ', 16, 1) 
                                                rollback tran
                                                return 99
                              END  
set @iCstr=0
--creazione chiave del ML e inserimento nel multilinguismo
while 1=1            BEGIN   --while 2
set @iCstr=@iCstr+1
set @mpgaDescr=substring(@LinguaI,1,80)+cast(@iCstr AS VARCHAR(10))
IF not exists (SELECT * FROM Multilinguismo
WHERE IdMultiLng=@mpgaDescr)  begin
insert INTo Multilinguismo(IdMultiLng, mlngDesc_I, mlngDesc_UK, mlngDesc_FRA, mlngDesc_E, mlngDesc_Lng1, mlngDesc_Lng2, mlngDesc_Lng3, mlngDesc_Lng4) 
values(@mpgaDescr,@LinguaI,@LinguaUK,@LinguaFRA,@LinguaE,@LinguaLng1,@LinguaLng2,@LinguaLng3,@LinguaLng4)
                      IF @@error <> 0
                                           begin
                                                raiserror ('Errore insert Multilinguismo  (UpdateElemMpGerAttr) ', 16, 1) 
                                                rollback tran
                                                return 99
                                                 END
break
                  END
end  --while 2
end  --if2
ELSE             
begin      --if2
set @mpgaDescr=NULL
                  END      --if2
--Albero gia esistente 
IF @mpgaIdMpSel=0 AND exists(SELECT * FROM MPGerarchiaAttributi
WHERE  mpgaIdMp=@mpgaIdMp AND mpgaContesto=@mpgaContesto AND  @mpgaIdMp<>0 AND mpgaDeleted=0 )        begin
                                    raiserror ('Errore MP gia esistente  (UpdateElemMpGerAttr) ', 16, 1) 
                                                rollback tran
                                                return 99
                                          END
IF not exists(SELECT * FROM MPGerarchiaAttributi WHERE mpgaIdMp=@mpgaidmp AND mpgaContesto=@mpgaContesto AND mpgaDeleted=0) AND @mpgaidmp<>0  begin --ifi
--copia albero padre  
insert INTo MPGerarchiaAttributi(mpgaIdMp,mpgaContesto,mpgaDescr,mpgaIdDzt,mpgaPath,mpgaLivello,mpgaFoglia,mpgaLenPathPadre,mpgaProfili,mpgaMultiSel) 
SELECT @mpgaIdMp,mpgaContesto,mpgaDescr,mpgaIdDzt,mpgaPath,mpgaLivello,mpgaFoglia,mpgaLenPathPadre,mpgaProfili,mpgaMultiSel FROM MPGerarchiaAttributi
WHERE mpgaContesto=@mpgaContesto AND mpgaIdMp=0 AND mpgaDeleted=0
                      IF @@error <> 0
                                           begin
                                                raiserror ('Errore insert MPGerarchiaAttributi  (UpdateElemMpGerAttr) ', 16, 1) 
                                                rollback tran
                                                return 99
                                                 END
--cambio nodo
SELECT @IdMpga=IdMpGa FROM MPGerarchiaAttributi
WHERE mpgaContesto=@mpgaContesto AND mpgaIdMp=@mpgaIdMp AND mpgaPath=@mpgaPath AND mpgaDeleted=0
end --ifi
--update del nodo
update MPGerarchiaAttributi
set       mpgaIdMp=@mpgaIdMp,
      mpgaDescr=@mpgaDescr,
      mpgaMultiSel=@mpgaMultiSel,
      mpgaProfili=NULLIF(@mpgaProfili,'')
WHERE  IdMpga=@IdMpga 
                      IF @@error <> 0
                                           begin
                                                raiserror ('Errore update MPGerarchiaAttributi  (UpdateElemMpGerAttr) ', 16, 1) 
                                                rollback tran
                                                return 99
                                                 END
commit tran
end
GO
