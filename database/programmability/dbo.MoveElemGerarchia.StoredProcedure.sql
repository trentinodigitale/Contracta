USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[MoveElemGerarchia]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
/*
Autore: Alfano Antonio
Scopo: Spostamento di un nodo
Data:   7/6/2001
*/
CREATE PROCEDURE [dbo].[MoveElemGerarchia](@IdTid INT,  @CodiceInterno VARCHAR(20),@CodiceInternoNuovoPadre VARCHAR(20))       
AS
begin
DECLARE @dgLivelloNew smallint  --Livello del nuovo padre
DECLARE @dgLivelloOld smallint  --vecchio livello del nodo da spostare 
DECLARE @dgPathOld VARCHAR(100)  --path del nodo da spostare
DECLARE @dgPathNew VARCHAR(100) --path nuova
DECLARE @pathLastChild VARCHAR(100) --path di appoggio
begin tran --Inizio della transazione 
--Seleziona  vecchie path e livello del nodo da trasferire
SELECT @dgPathOld=dgPath, @dgLivelloOld=dgLivello
FROM dominiGerarchici
WHERE dgCodiceInterno=@CodiceInterno AND dgTipoGerarchia=@IdTid 
IF @dgPathOld IS NULL  or @dgPathOld=''      BEGIN
                                              raiserror ('Errore: Input Nodo Move  (MoveElemGerarchia) ', 16, 1) 
                                                      rollback tran
                                                            return 99
                  END
--Controllo che il nodo padre non stia nel sottoalbero del nodo da spostare
IF exists(SELECT * FROM dominiGerarchici
WHERE dgCodiceInterno=@CodiceInternoNuovoPadre AND dgTipoGerarchia=@IdTid 
and  dgpath in (SELECT  b.dgpath
FROM dominiGerarchici b, dominiGerarchici a 
WHERE b.dgpath like a.dgpath+'%'   AND a.dgCodiceInterno=@CodiceInterno AND 
a.dgTipoGerarchia=@IdTid  AND b.dgTipoGerarchia=@IdTid))                           BEGIN
                                        raiserror ('Errore: Nodo padre presente nel sottoalbero del nodo da spostare (MoveElemGerarchia) ', 16, 1) 
                                                rollback tran
                                                return 99                                    
                                                            END
--Controllo primo nodo della gerarchia
IF exists( SELECT * FROM Dominigerarchici WHERE dgCodiceInterno=@CodiceInternoNuovoPadre AND (dgPath='' or dgPath IS NULL) AND dgTipoGerarchia=@IdTid) begin --primo Codice INTerno  --ifp
--Controllo che il vecchio padre non sia anche il nuovo
IF @dgLivelloOld=1       BEGIN
                                                commit tran
                                                return 0                              
                  END
 
--Massimo tra le path del primo livello
SELECT  @pathLastChild=max(substring(dgpath,1,4))  
FROM dominigerarchici 
WHERE dgLivello =1 AND  dgTipoGerarchia=@IdTid
set @dgLivelloNew=0 --Livello primo nodo
--Caso in cui non ci sono nodi a quel livello (non si verifica mai--si pu_ anche togliere)
IF @pathLastChild IS NULL begin
                  set @pathLastChild='000.'
                  END
--possibilita di inserire un nuovo nodo(superato il max)
IF cast(substring(right(@pathLastChild,4),1,3) AS INT)=999 begin
                              /*errore nodi non disponobili */
                                        raiserror ('Errore: Impossibile inserire nodo (MoveElemGerarchia) ', 16, 1) 
                                                rollback tran
                                                return 99
                              END
--costruzione nuova path
set @pathLastChild=cast(cast(substring(right(@pathLastChild,4),1,3) AS INT)+1 AS VARCHAR(100))  
set @dgPathNew=left('000',3-len(@pathLastChild))+@pathLastChild+ '.' 
end  --ifp
ELSE  --ifp 
begin --ifp
--da fare quando non si tratta il primo nodo
--Seleziona la path e livello del nuovo padre padre
SELECT @dgPathNew=dgPath, @dgLivelloNew=dgLivello
FROM dominiGerarchici
WHERE dgCodiceInterno=@CodiceInternoNuovoPadre AND dgTipoGerarchia=@IdTid 
IF @dgPathNew IS NULL      BEGIN
                                        raiserror ('Errore: Input Nodo Nuovo Padre (MoveElemGerarchia) ', 16, 1) 
                                                rollback tran
                                                return 99
                  END
--Controllo che il vecchio padre non sia anche il nuovo
IF left(@dgPathOld,len(@dgPathOld)-4)=@dgPathNew       BEGIN
                                                            commit tran
                                                            return 0                              
                                          END
--Massimo tra le path del livello in cui spostare il nodo
SELECT  @pathLastChild=max(substring(b.dgpath,1,len(@dgPathNew)+4))  
FROM dominigerarchici b,dominigerarchici a 
WHERE b.dgPath like a.dgPath+'%' AND a.dgCodiceInterno=@CodiceInternoNuovoPadre  
and a.dgTipoGerarchia=@IdTid AND b.dgTipoGerarchia=@IdTid  
and b.dgLivello = a.dgLivello + 1 
--Caso in cui non ci sono nodi in quel livello
IF @pathLastChild IS NULL begin
                  set @pathLastChild='000.'
                  END
--possibilita di inserire un nuovo nodo(superato il max)
IF cast(substring(right(@pathLastChild,4),1,3) AS INT)=999 begin
                              /*errore nodi non disponobili */
                                        raiserror ('Errore: Impossibile inserire nodo (MoveElemGerarchia) ', 16, 1) 
                                                rollback tran
                                                return 99
                              END
--costruzione nuova path
set @pathLastChild=cast(cast(substring(right(@pathLastChild,4),1,3) AS INT)+1 AS VARCHAR(100))  
set @dgPathNew=@dgPathNew+left('000',3-len(@pathLastChild))+@pathLastChild+ '.' 
end --ifp
--Aggiornamento del vecchio padre nel caso non abbia pi" figli
--caso in cui il vecchio padre non sia il primo nodo (--a che serve?)
IF left(@dgPathOld,len(@dgPathOld)-4)<>''  begin --if
--Caso in cui il vecchio padre diventa foglia (non ha figli)
IF not exists (SELECT  *
FROM dominiGerarchici 
WHERE dgpath like left(@dgPathOld,len(@dgPathOld)-4)+'%'  
and dglivello=@dgLivelloOld AND dgTipoGerarchia=@IdTid AND dgpath<>@dgPathOld AND dgDeleted=0)        BEGIN  --iff
update dominiGerarchici    --Aggiornamento del vecchio padre (dgfoglia=1)
set dgfoglia=1
WHERE  dgpath=left(@dgPathOld,len(@dgPathOld)-4) AND dgTipoGerarchia=@IdTid AND dgDeleted=0 
IF @@error <> 0
                                           begin
                                                raiserror ('Errore Update DominiGerarchici (MoveElemGerarchia) ', 16, 1) 
                                                rollback tran
                                                return 99
                                                 END
                                                            END --iff
            END --if
--Aggiornamento del nuovo padre nel caso in cui sia foglia
update DominiGerarchici
set      dgFoglia=0 
WHERE dgCodiceInterno=@CodiceInternoNuovoPadre AND dgTipoGerarchia=@IdTid 
IF @@error <> 0
                                           begin
                                                raiserror ('Errore Update DominiGerarchici (MoveElemGerarchia) ', 16, 1) 
                                                rollback tran
                                                return 99
                                                 END
--Aggiornamento del nodo con la nuova path 
update DominiGerarchici
set      dgPath=@dgPathNew, 
      dgLenPathPadre=len(@dgPathNew)-4,
      dgLivello=@dgLivelloNew+1      
WHERE dgCodiceInterno=@CodiceInterno AND dgTipoGerarchia=@IdTid 
IF @@error <> 0
                                           begin
                                                raiserror ('Errore Update DominiGerarchici (MoveElemGerarchia) ', 16, 1) 
                                                rollback tran
                                                return 99
                                                 END
--Aggiornamento dei figli del nodo con la nuove path 
update DominiGerarchici
set      dgPath=@dgPathNew+ substring(dgPath,len(@dgPathOld)+1,len(dgPath)-len(@dgPathOld)) ,
      dgLenPathPadre=len(@dgPathNew+ substring(dgPath,len(@dgPathOld)+1,len(dgPath)-len(@dgPathOld)))-4,
      dgLivello=@dgLivelloNew+dgLivello-@dgLivelloOld+1
WHERE dgPath in (SELECT  dgpath  
FROM dominigerarchici 
WHERE dgPath like @dgPathOld+'%' AND dgTipoGerarchia=@IdTid)
IF @@error <> 0
                                           begin
                                                raiserror ('Errore Update DominiGerarchici (MoveElemGerarchia) ', 16, 1) 
                                                rollback tran
                                                return 99
                                                 END
commit tran  --chiusura della transazione
end
GO
