USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[MoveElemMPGerAttr]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
/*
Autore: Alfano Antonio
Scopo: Spostamento MpGerarchiaAttributi
Data: 19/11/2001
*/
CREATE PROCEDURE [dbo].[MoveElemMPGerAttr] (@mpgaIdMp INT,@IdMpga INT,@IdMpgaPadre INT) AS
begin
DECLARE @mpgaIdMpFiglio INT --mpgaIdMp figlio  
DECLARE @mpgaPath VARCHAR(100) --mpgaPath figlio
DECLARE @mpgaPathPadre VARCHAR(100) --mpgaPath Padre
DECLARE @mpgaContesto VARCHAR(50) --mpgaContesto figlio
DECLARE @mpgaContestoPadre VARCHAR(50) --mpgaContesto Padre
DECLARE @mpgaIdMpPadre INT --mpgaIdMp Padre
DECLARE @mpgaLivelloPadre INT --mpgaLivello Padre
DECLARE @mpgaLivelloFiglio INT --mpgaLivello Figlio
DECLARE @mpgaPathNew VARCHAR(100) --mpgaPath nuova
DECLARE @pathLastChild VARCHAR(100) --Path dell'ultimo figlio del nuovo padre 
DECLARE @mpgaIdDztPadre INT  --mpgaIdDzt Padre
begin tran
--esistenza nodo figlio
SELECT @mpgaIdMpFiglio=mpgaIdMp,@mpgaContesto=mpgaContesto,@mpgaPath=mpgaPath,@mpgaLivelloFiglio=mpgaLivello FROM MPGerarchiaAttributi 
WHERE IdMpga=@IdMpga AND mpgaDeleted=0
IF @mpgaPath IS NULL       BEGIN
                                                 raiserror ('Errore nodo inesistente  (MoveElemMPGerAttr) ', 16, 1) 
                                                rollback tran
                                                return 99
                  END
--nodo padre
IF @IdMpgaPadre<>0       BEGIN --ifp
--esistenza nodo padre
SELECT @mpgaIdDztPadre=mpgaIdDzt,@mpgaIdMpPadre=mpgaIdMp,@mpgaContestoPadre=mpgaContesto,@mpgaPathPadre=mpgaPath,@mpgaLivelloPadre=mpgaLivello FROM MPGerarchiaAttributi 
WHERE IdMpga=@IdMpgaPadre AND mpgaDeleted=0
IF @mpgaPathPadre IS NULL       BEGIN
                                                 raiserror ('Errore nodo inesistente  (MoveElemMPGerAttr) ', 16, 1) 
                                                rollback tran
                                                return 99
                        END
--il padre deve essere un nodo con mpgaIdDzt=-1
IF @mpgaIdDztPadre<>-1       BEGIN
                                                 raiserror ('Errore il nodo selezionato non pu= essere padre   (MoveElemMPGerAttr) ', 16, 1) 
                                                rollback tran
                                                return 99
                  END
                  END--ifp
ELSE --ifp
begin --ifp
--valori nel caso del nodo fittizio(padre)
set @mpgaIdMpPadre=@mpgaIdMpFiglio
set @mpgaContestoPadre=@mpgaContesto
set @mpgaPathPadre=''
set @mpgaLivelloPadre=0
end --ifp
--controllo di appartenenza dei nodi nella stessa gerarchia
IF not(@mpgaIdMpPadre=@mpgaIdMpFiglio AND @mpgaContestoPadre=@mpgaContesto)      BEGIN
                                                 raiserror ('Errore: nodi non presenti nella stessa gerarchia   (MoveElemMPGerAttr) ', 16, 1) 
                                                rollback tran
                                                return 99
                                                            END
--padre vecchio uguale al nuovo
IF @mpgaPathPadre=substring(@mpgaPath,1,len(@mpgaPath)-4)       BEGIN
                                                commit tran
                                                return 0
                                                END
--controllo presenza del padre nel sottoalbero del figlio
IF exists(SELECT * FROM MPGerarchiaAttributi
WHERE @IdMpgaPadre in (SELECT IdMpga FROM MPGerarchiaAttributi
WHERE mpgaPath like @mpgaPath+'%' AND mpgaContesto=@mpgaContesto 
and  mpgaIdMp=@mpgaIdMpFiglio AND mpgaPath<>@mpgaPath AND mpgaDeleted=0)) begin
                                                 raiserror ('Errore nodo inesistente  (MoveElemMPGerAttr) ', 16, 1) 
                                                rollback tran
                                                return 99
                                          END
--Assiomi (F inutile controllare il padre!!)
IF @mpgaIdMp=0        begin
      IF  not exists (SELECT * FROM MPGerarchiaAttributi WHERE IdMpga=@IdMpga AND mpgaIdMp=0 AND mpgaDeleted=0)      BEGIN
                                    raiserror ('Errore MP inconsistenti  (MoveElemMPGerAttr) ', 16, 1) 
                                                rollback tran
                                                return 99
                                                                                          END
            
                              END
ELSE       begin
      IF  not exists (SELECT * FROM MPGerarchiaAttributi WHERE IdMpga=@IdMpga AND mpgaIdMp=@mpgaIdMp AND mpgaDeleted=0) AND not exists (SELECT * FROM MPGerarchiaAttributi WHERE IdMpga=@IdMpga AND mpgaIdMp=0 AND mpgaDeleted=0)      BEGIN
                                    raiserror ('Errore MP inconsistenti  (MoveElemMPGerAttr) ', 16, 1) 
                                                rollback tran
                                                return 99
                                                                                          END
                              END
--Esistenza della gerarchia
IF @mpgaIdMpFiglio=0 AND exists(SELECT * FROM MPGerarchiaAttributi
WHERE  mpgaIdMp=@mpgaIdMp AND mpgaContesto=@mpgaContesto AND  @mpgaIdMp<>0 AND mpgaDeleted=0)        begin
                                    raiserror ('Errore MP gia esistente  (MoveElemMPGerAttr) ', 16, 1) 
                                                rollback tran
                                                return 99
                                          END
IF not exists(SELECT * FROM MPGerarchiaAttributi WHERE mpgaIdMp=@mpgaidmp AND mpgaContesto=@mpgaContesto AND mpgaDeleted=0) AND @mpgaidmp<>0  begin --ifi
--copia albero padre-figlio  
insert INTo MPGerarchiaAttributi(mpgaIdMp,mpgaContesto,mpgaDescr,mpgaIdDzt,mpgaPath,mpgaLivello,mpgaFoglia,mpgaLenPathPadre,mpgaProfili,mpgaMultiSel) 
SELECT @mpgaIdMp,mpgaContesto,mpgaDescr,mpgaIdDzt,mpgaPath,mpgaLivello,mpgaFoglia,mpgaLenPathPadre,mpgaProfili,mpgaMultiSel FROM MPGerarchiaAttributi
WHERE mpgaContesto=@mpgaContesto AND mpgaIdMp=0 AND mpgaDeleted=0
                      IF @@error <> 0
                                           begin
                                                raiserror ('Errore insert MPGerarchiaAttributi  (MoveElemMPGerAttr) ', 16, 1) 
                                                rollback tran
                                                return 99
                                                 END
--cambio padre
SELECT @IdMpga=IdMpGa FROM MPGerarchiaAttributi
WHERE mpgaContesto=@mpgaContesto AND mpgaIdMp=@mpgaIdMp AND mpgaPath=@mpgaPathPadre AND mpgaDeleted=0
--cambio figlio
SELECT @IdMpga=IdMpGa FROM MPGerarchiaAttributi
WHERE mpgaContesto=@mpgaContesto AND mpgaIdMp=@mpgaIdMp AND mpgaPath=@mpgaPath AND mpgaDeleted=0
end --ifi
--controllo nodo fittizio
IF @IdMpgaPadre=0       BEGIN --ifp
--Massimo tra le path del primo livello
SELECT  @pathLastChild=max(substring(mpgaPath,1,4))  
FROM MPGerarchiaAttributi 
WHERE mpgaLivello =1 AND mpgaContesto=@mpgaContesto AND mpgaIdMp=@mpgaIdMp AND  mpgaDeleted=0
 
set @mpgaLivelloPadre=0 --Livello primo nodo
--Caso in cui non ci sono nodi a quel livello (non si verifica mai--si pu= anche togliere)
IF @pathLastChild IS NULL begin
                  set @pathLastChild='000.'
                  END
--possibilita di inserire un nuovo nodo(superato il max)
IF cast(substring(right(@pathLastChild,4),1,3) AS INT)=999 begin
                              /*errore nodi non disponobili */
                                        raiserror ('Errore: Impossibile inserire nodo (MoveElemMPGerAttr) ', 16, 1) 
                                                rollback tran
                                                return 99
                              END
--costruzione nuova path
set @pathLastChild=cast(cast(substring(right(@pathLastChild,4),1,3) AS INT)+1 AS VARCHAR(100))  
set @mpgaPathNew=left('000',3-len(@pathLastChild))+@pathLastChild+ '.' 
end --ifp
ELSE --ifp
begin --ifp
--Massimi tra le path 
SELECT  @pathLastChild=max(mpgaPath)  
FROM MPGerarchiaAttributi  
WHERE mpgaPath like @mpgaPathPadre+'%' AND mpgaContesto=@mpgaContesto  AND mpgaIdMp=@mpgaIdMp AND mpgaLivello=@mpgaLivelloPadre+1  AND mpgaDeleted=0  
--Caso in cui non ci sono nodi in quel livello
IF @pathLastChild IS NULL begin
                  set @pathLastChild='000.'
                  END
--possibilita di inserire un nuovo nodo(superato il max)
IF cast(substring(right(@pathLastChild,4),1,3) AS INT)=999 begin
                              /*errore nodi non disponobili */
                                        raiserror ('Errore: Impossibile inserire nodo (MoveElemMPGerAttr) ', 16, 1) 
                                                rollback tran
                                                return 99
                              END
--costruzione nuova path
set @pathLastChild=cast(cast(substring(right(@pathLastChild,4),1,3) AS INT)+1 AS VARCHAR(100))  
set @mpgaPathNew=@mpgaPathPadre+left('000',3-len(@pathLastChild))+@pathLastChild+ '.' 
end --ifp
--aggiornamento del vecchio padre
IF not exists ( SELECT * FROM MPGerarchiaAttributi
WHERE mpgaContesto=@mpgaContesto AND mpgaIdMp=@mpgaIdMp 
and mpgaPath like substring(@mpgaPath,1,len(@mpgaPath)-4)+'%' AND mpgaDeleted=0 AND mpgaPath<>substring(@mpgaPath,1,len(@mpgaPath)-4) )      BEGIN
update MPGerarchiaAttributi
set mpgaFoglia=1
WHERE mpgaContesto=@mpgaContesto AND mpgaIdMp=@mpgaIdMp 
and mpgaPath=substring(@mpgaPath,1,len(@mpgaPath)-4)+'%' AND mpgaDeleted=0 
                      IF @@error <> 0
                                           begin
                                                raiserror ('Errore update MPGerarchiaAttributi  (MoveElemMPGerAttr) ', 16, 1) 
                                                rollback tran
                                                return 99
                                                 END
                              END
--Aggiornamento del padre nuovo mpgaFoglia=0
update MPGerarchiaAttributi
set mpgaFoglia=0
WHERE IdMpGa=@IdMpgaPadre  
                      IF @@error <> 0
                                           begin
                                                raiserror ('Errore update MPGerarchiaAttributi  (MoveElemMPGerAttr) ', 16, 1) 
                                                rollback tran
                                                return 99
                                                 END
--aggiornamento del nodo figlio con la nuova path
update MPGerarchiaAttributi
set       mpgaPath=@mpgaPathNew,
      mpgaLenPathPadre=len(@mpgaPathNew)-4,
      mpgaLivello=@mpgaLivelloPadre+1
WHERE IdMpGa=@IdMpga  
                      IF @@error <> 0
                                           begin
                                                raiserror ('Errore update MPGerarchiaAttributi  (MoveElemMPGerAttr) ', 16, 1) 
                                                rollback tran
                                                return 99
                                                 END
--Aggiornamento dei figli del nodo con la nuove path 
update MPGerarchiaAttributi
set      mpgaPath=@mpgaPathNew+ substring(mpgaPath,len(@mpgaPath)+1,len(mpgaPath)-len(@mpgaPath)) ,
      mpgaLenPathPadre=len(@mpgaPathNew+ substring(mpgaPath,len(@mpgaPath)+1,len(mpgaPath)-len(@mpgaPath)))-4,
      mpgaLivello=@mpgaLivelloPadre+mpgaLivello-@mpgaLivelloFiglio+1
WHERE Idmpga in (SELECT  Idmpga  
FROM MPGerarchiaAttributi 
WHERE mpgaPath like @mpgaPath+'%' AND mpgaContesto=@mpgaContesto AND mpgaIdMp=@mpgaIdMp AND mpgaDeleted=0)
IF @@error <> 0
                                           begin
                                                raiserror ('Errore Update MPGerarchiaAttributi (MoveElemMPGerAttr) ', 16, 1) 
                                                rollback tran
                                                return 99
                                                 END
commit tran
end
GO
