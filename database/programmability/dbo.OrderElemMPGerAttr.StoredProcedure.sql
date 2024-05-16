USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OrderElemMPGerAttr]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
/*
Autore: Alfano Antonio
Scopo: Spostamento MpGerarchiaAttributi
Data: 16/11/2001
*/
CREATE PROCEDURE [dbo].[OrderElemMPGerAttr] (@mpgaIdMp INT,@IdMpga INT,@IdMpgaPrec INT) AS
begin
DECLARE @posPrec VARCHAR(5)
DECLARE @mpgaIdMpcurr INT --mpgaIdMp curr  
DECLARE @mpgaPath VARCHAR(100) --mpgaPath curr
DECLARE @mpgaPathPrec VARCHAR(100) --mpgaPath Prec
DECLARE @mpgaContesto VARCHAR(50) --mpgaContesto curr
DECLARE @mpgaContestoPrec VARCHAR(50) --mpgaContesto Prec
DECLARE @mpgaIdMpPrec INT --mpgaIdMp Prec
DECLARE @mpgaLivelloPrec INT --mpgaLivello Prec
DECLARE @mpgaLivellocurr INT --mpgaLivello curr
DECLARE @mpgaPathNew VARCHAR(100) --mpgaPath nuova
DECLARE @pathLastChild VARCHAR(100) --Path dell'ultimo curr del nuovo Prec 
begin tran
--esistenza nodo curr
SELECT @mpgaIdMpCurr=mpgaIdMp,@mpgaContesto=mpgaContesto,@mpgaPath=mpgaPath,@mpgaLivellocurr=mpgaLivello FROM MPGerarchiaAttributi 
WHERE IdMpga=@IdMpga AND mpgaDeleted=0
IF @mpgaPath IS NULL       BEGIN
                                                 raiserror ('Errore nodo inesistente  (OrderElemMPGerAttr) ', 16, 1) 
                                                rollback tran
                                                return 99
                  END
IF @IdMpgaPrec<>-1      BEGIN
--esistenza nodo Prec
SELECT @mpgaIdMpPrec=mpgaIdMp,@mpgaContestoPrec=mpgaContesto,@mpgaPathPrec=mpgaPath,@mpgaLivelloPrec=mpgaLivello FROM MPGerarchiaAttributi 
WHERE IdMpga=@IdMpgaPrec AND mpgaDeleted=0 
IF @mpgaPathPrec IS NULL       BEGIN
                                                 raiserror ('Errore nodo inesistente  (OrderElemMPGerAttr) ', 16, 1) 
                                                rollback tran
                                                return 99
                        END
                  END
                  ELSE
                  BEGIN
set @mpgaIdMpPrec=@mpgaIdMpcurr
set @mpgaContestoPrec=@mpgaContesto
set @mpgaPathPrec=substring(@mpgaPath,1,len(@mpgaPath)-4)+'000.'
set @mpgaLivelloPrec=@mpgaLivellocurr
                  END
--controllo di appartenenza dei nodi nella stessa gerarchia
IF not(@mpgaIdMpPrec=@mpgaIdMpcurr AND @mpgaContestoPrec=@mpgaContesto AND substring(@mpgaPath,1,len(@mpgaPath)-4)=substring(@mpgaPathPrec,1,len(@mpgaPathPrec)-4))      BEGIN
                                                 raiserror ('Errore: nodi non presenti nella stessa gerarchia o non fratelli   (OrderElemMPGerAttr) ', 16, 1) 
                                                rollback tran
                                                return 99
                                                            END
--Prec  uguale al corrente
IF @mpgaPathPrec=@mpgaPath                               BEGIN
                                                commit tran
                                                return 0
                                                END
--Assiomi (F inutile controllare il Prec!!)
IF @mpgaIdMp=0        begin
      IF  not exists (SELECT * FROM MPGerarchiaAttributi WHERE IdMpga=@IdMpga AND mpgaIdMp=0 AND mpgaDeleted=0)      BEGIN
                                          raiserror ('Errore MP inconsistenti  (OrderElemMPGerAttr) ', 16, 1) 
                                                rollback tran
                                                return 99
                                                                                          END
            
                              END
ELSE       begin
      IF  not exists (SELECT * FROM MPGerarchiaAttributi WHERE IdMpga=@IdMpga AND mpgaIdMp=@mpgaIdMp AND mpgaDeleted=0) AND not exists (SELECT * FROM MPGerarchiaAttributi WHERE IdMpga=@IdMpga AND mpgaIdMp=0 AND mpgaDeleted=0)      BEGIN
                                    raiserror ('Errore MP inconsistenti  (OrderElemMPGerAttr) ', 16, 1) 
                                                rollback tran
                                                return 99
                                                                                          END
                              END
--Esistenza della gerarchia( nuova eventualmente )
IF @mpgaIdMpcurr=0 AND exists(SELECT * FROM MPGerarchiaAttributi
WHERE  mpgaIdMp=@mpgaIdMp AND mpgaContesto=@mpgaContesto AND  @mpgaIdMp<>0  AND mpgaDeleted=0)        begin
                                          raiserror ('Errore MP gia esistente  (OrderElemMPGerAttr) ', 16, 1) 
                                                rollback tran
                                                return 99
                                          END
--eventuale personalizzazione
IF not exists(SELECT * FROM MPGerarchiaAttributi WHERE mpgaIdMp=@mpgaidmp AND mpgaContesto=@mpgaContesto AND mpgaDeleted=0) AND @mpgaidmp<>0  begin --ifi
--copia albero Prec-curr  
insert INTo MPGerarchiaAttributi(mpgaIdMp,mpgaContesto,mpgaDescr,mpgaIdDzt,mpgaPath,mpgaLivello,mpgaFoglia,mpgaLenPathPadre,mpgaProfili,mpgaMultiSel) 
SELECT @mpgaIdMp,mpgaContesto,mpgaDescr,mpgaIdDzt,mpgaPath,mpgaLivello,mpgaFoglia,mpgaLenPathPadre,mpgaProfili,mpgaMultiSel FROM MPGerarchiaAttributi
WHERE mpgaContesto=@mpgaContesto AND mpgaIdMp=0 AND mpgaDeleted=0
                      IF @@error <> 0
                                           begin
                                                raiserror ('Errore insert MPGerarchiaAttributi  (OrderElemMPGerAttr) ', 16, 1) 
                                                rollback tran
                                                return 99
                                                 END
--non serve!!!
IF @IdMpgaPrec<>-1      BEGIN
--cambio Prec
SELECT @IdMpgaPrec=IdMpGa FROM MPGerarchiaAttributi
WHERE mpgaContesto=@mpgaContesto AND mpgaIdMp=@mpgaIdMp AND mpgaPath=@mpgaPathPrec AND mpgaDeleted=0
                  END
--cambio curr
SELECT @IdMpga=IdMpGa FROM MPGerarchiaAttributi
WHERE mpgaContesto=@mpgaContesto AND mpgaIdMp=@mpgaIdMp AND mpgaPath=@mpgaPath AND mpgaDeleted=0
end --ifi
--ultimo fratello!!!!
--Massimi tra le path 
SELECT  @pathLastChild=max(mpgaPath)  
FROM MPGerarchiaAttributi  
WHERE mpgaPath like substring(@mpgaPathPrec,1,len(@mpgaPathPrec)-4)+'%' AND mpgaContesto=@mpgaContesto  AND mpgaIdMp=@mpgaIdMp AND mpgaLivello=@mpgaLivelloPrec  AND mpgaDeleted=0  AND IdMpga<>@IdMpga 
--possibilita di inserire un nuovo nodo(superato il max)
IF cast(substring(right(@pathLastChild,4),1,3) AS INT)=999 begin
                              /*errore nodi non disponobili */
                                        raiserror ('Errore: Impossibile inserire nodo (OrderElemMPGerAttr) ', 16, 1) 
                                                rollback tran
                                                return 99
                              END
update MPGerarchiaAttributi
set       mpgaPath = substring(@mpgaPath,1,len(@mpgaPath)-4) + '000.'+ substring(mpgaPath,len(@mpgaPath)+1,len(mpgaPath)-len(@mpgaPath)) 
WHERE  IdMpga in (SELECT IdMpga FROM MPGerarchiaAttributi WHERE  mpgaPath like @mpgaPath+'%' AND mpgaContesto=@mpgaContesto AND mpgaIdMp=@mpgaIdMp AND mpgaDeleted=0)
IF @@error <> 0
                                           begin
                                                raiserror ('Errore update MPGerarchiaAttributi  (OrderElemMPGerAttr) ', 16, 1) 
                                                rollback tran
                                                return 99
                                                 END
set @mpgaPath=substring(@mpgaPath,1,len(@mpgaPath)-4)+'000.'
--Aggiornamento dei nodi successivi con la nuova path 
update MPGerarchiaAttributi
set      mpgaPath=substring(mpgaPath,1,len(@mpgaPathPrec)-4) + left('000',3-len(cast((cast((substring(mpgaPath,len(@mpgaPathPrec)-3,3)) AS INT)+1) AS VARCHAR(3))))+cast((cast((substring(mpgaPath,len(@mpgaPathPrec)-3,3)) AS INT)+1) AS VARCHAR(3))+'.' + substring(mpgaPath,len(@mpgaPathPrec)+1,len(mpgaPath)-len(@mpgaPathPrec)) 
WHERE mpgaPath like substring(@mpgaPathPrec,1,len(@mpgaPathPrec)-4)+'%' AND mpgaContesto=@mpgaContesto AND mpgaIdMp=@mpgaIdMp AND mpgaDeleted=0 AND cast(substring(mpgaPath,len(@mpgaPathPrec)-3,3) AS INT)>cast(substring(right(@mpgaPathPrec,4),1,3) AS INT) AND IdMpga not in (SELECT IdMpga FROM MPGerarchiaAttributi WHERE  mpgaPath like @mpgaPath+'%' AND mpgaContesto=@mpgaContesto AND mpgaIdMp=@mpgaIdMp AND mpgaDeleted=0 ) AND mpgaLivello>=@mpgaLivelloPrec 
IF @@error <> 0
                                           begin
                                                raiserror ('Errore update MPGerarchiaAttributi  (OrderElemMPGerAttr) ', 16, 1) 
                                                rollback tran
                                                return 99
                                                 END
set @posPrec=cast(( cast ((substring(right(@mpgaPathPrec,4),1,3)) AS INT)+1) AS VARCHAR(5))
update MPGerarchiaAttributi
set       mpgaPath = substring(@mpgaPath,1,len(@mpgaPathPrec)-4) + left('000',3-len(@posPrec)) + @posPrec+ '.'+ substring(mpgaPath,len(@mpgaPath)+1,len(mpgaPath)-len(@mpgaPath)) 
WHERE  IdMpga in (SELECT IdMpga FROM MPGerarchiaAttributi WHERE  mpgaPath like @mpgaPath+'%' AND mpgaContesto=@mpgaContesto AND mpgaIdMp=@mpgaIdMp AND mpgaDeleted=0)
IF @@error <> 0
                                           begin
                                                raiserror ('Errore update MPGerarchiaAttributi  (OrderElemMPGerAttr) ', 16, 1) 
                                                rollback tran
                                                return 99
                                                 END
commit tran
end
GO
