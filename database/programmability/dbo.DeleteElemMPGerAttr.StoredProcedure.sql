USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[DeleteElemMPGerAttr]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
/*
Autore:  Alfano Antonio
Scopo: Delete elemento logica MpGerarchiaAttributi
Data: 27/6/2001
*/
CREATE PROCEDURE [dbo].[DeleteElemMPGerAttr] (@mpgaIdMp INT,@IdMpga INT) AS
begin
begin tran
DECLARE @mpgaIdDzt INT --IdDzt del nodo selezionato
DECLARE @mpgaContesto VARCHAR(50)  --contesto del nodo selezionato
DECLARE @iCstr INT --contatore
DECLARE @mpgaPath VARCHAR(100) --path del nodo
DECLARE @mpgaDescr VARCHAR(101)  --chiave ML
DECLARE @mpgaIdMpNodo INT 
--Esistenza nodo!!!!!
IF not exists (SELECT * FROM MPGerarchiaAttributi WHERE IdMpga=@IdMpga AND mpgaDeleted=0)      BEGIN
                                                 raiserror ('Errore nodo inesistente  (DeleteElemMPGerAttr) ', 16, 1) 
                                                rollback tran
                                                return 99
                                                                              END
--Assiomi
IF @mpgaIdMp=0        begin
      IF  not exists (SELECT * FROM MPGerarchiaAttributi WHERE IdMpga=@IdMpga AND mpgaIdMp=0 AND mpgaDeleted=0)      BEGIN
                                    raiserror ('Errore MP inconsistenti  (DeleteElemMPGerAttr) ', 16, 1) 
                                                rollback tran
                                                return 99
                                                                                          END
            
                              END
ELSE       begin
      IF  not exists (SELECT * FROM MPGerarchiaAttributi WHERE IdMpga=@IdMpga AND mpgaIdMp=@mpgaIdMp AND mpgaDeleted=0) AND not exists (SELECT * FROM MPGerarchiaAttributi WHERE IdMpga=@IdMpga AND mpgaIdMp=0 AND mpgaDeleted=0)      BEGIN
                                    raiserror ('Errore MP inconsistenti  (DeleteElemMPGerAttr) ', 16, 1) 
                                                rollback tran
                                                return 99
                                                                                          END
                              END
--seleziona dati del nodo
SELECT @mpgaIdDzt=mpgaIdDzt,@mpgaContesto=mpgaContesto ,@mpgaPath=mpgaPath,@mpgaIdMpNodo=mpgaIdMp  FROM MPGerarchiaAttributi
WHERE IdMpGa=@IdMpga AND mpgaDeleted=0
--albero gia esistente
IF @mpgaIdMpNodo=0 AND exists(SELECT * FROM MPGerarchiaAttributi
WHERE  mpgaIdMp=@mpgaIdMp AND mpgaContesto=@mpgaContesto AND  @mpgaIdMp<>0 AND mpgaDeleted=0)        begin
                                    raiserror ('Errore MP gia esistente  (DeleteElemMPGerAttr) ', 16, 1) 
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
                                                raiserror ('Errore insert MPGerarchiaAttributi  (DeleteElemMPGerAttr) ', 16, 1) 
                                                rollback tran
                                                return 99
                                                 END
--cambio padre
SELECT @IdMpga=IdMpGa FROM MPGerarchiaAttributi
WHERE mpgaContesto=@mpgaContesto AND mpgaIdMp=@mpgaIdMp AND mpgaPath=@mpgaPath AND mpgaDeleted=0
--fai delete 
--delete del nodo con tutto il suo albero
delete FROM MPGerarchiaAttributi
WHERE IdMpga in ( SELECT b.IdMpga FROM MPGerarchiaAttributi b,MPGerarchiaAttributi a
WHERE  a.IdMpga=@IdMpga AND b.mpgaPath like a.mpgaPath+'%' AND a.mpgaIdMp=@mpgaIdMp AND b.mpgaIdMp=@mpgaIdMp  AND a.mpgaContesto=@mpgaContesto AND b.mpgaContesto=@mpgaContesto)
                      IF @@error <> 0
                                           begin
                                                raiserror ('Errore delete MPGerarchiaAttributi  (DeleteElemMPGerAttr) ', 16, 1) 
                                                rollback tran
                                                return 99
                                                 END
end --ifi
ELSE --ifi
begin --ifi
--delete logico del nodo con tutto il suo albero
update MPGerarchiaAttributi
set mpgaDeleted=1
WHERE IdMpga in ( SELECT b.IdMpga FROM MPGerarchiaAttributi b,MPGerarchiaAttributi a
WHERE  a.IdMpga=@IdMpga AND b.mpgaPath like a.mpgaPath+'%' AND a.mpgaIdMp=@mpgaIdMp AND b.mpgaIdMp=@mpgaIdMp  AND a.mpgaContesto=@mpgaContesto AND b.mpgaContesto=@mpgaContesto)            
                      IF @@error <> 0
                                           begin
                                                raiserror ('Errore update MPGerarchiaAttributi  (DeleteElemMPGerAttr) ', 16, 1) 
                                                rollback tran
                                                return 99
                                                 END
end --ifi
--aggiornamento padre
IF not exists ( SELECT * FROM MPGerarchiaAttributi
WHERE mpgaContesto=@mpgaContesto AND mpgaIdMp=@mpgaIdMp 
and mpgaPath like substring(@mpgaPath,1,len(@mpgaPath)-4)+'%' AND mpgaDeleted=0 AND mpgaPath<>substring(@mpgaPath,1,len(@mpgaPath)-4) )      BEGIN
update MPGerarchiaAttributi
set mpgaFoglia=1
WHERE mpgaContesto=@mpgaContesto AND mpgaIdMp=@mpgaIdMp 
and mpgaPath=substring(@mpgaPath,1,len(@mpgaPath)-4)+'%' 
                      IF @@error <> 0
                                           begin
                                                raiserror ('Errore update MPGerarchiaAttributi  (DeleteElemMPGerAttr) ', 16, 1) 
                                                rollback tran
                                                return 99
                                                 END
                                                            END
commit tran
end
GO
