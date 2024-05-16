USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[InsertElemGerarchia]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Autore : Alfano Antonio
Scopo: Inserimento di un elemento nella DominiGerarchici
Data. 6/6/2001
*/
CREATE PROCEDURE [dbo].[InsertElemGerarchia] (@IdTid INT, @CodiceInternoPadre VARCHAR(20), @CodiceEsternoNew VARCHAR(20), @strLingue VARCHAR(100), @strDescs NVARCHAR(4000) ) AS
begin
--DECLARE @dgTipoGerarchia smallint   
--DECLARE @dgCodiceInterno VARCHAR(20)
--DECLARE @dgCodiceEsterno VARCHAR(20)
DECLARE @dgPath VARCHAR(100)  --Path temporanea
DECLARE @dgLivello smallint --Livello
DECLARE @dgFoglia bit  --proprieta del nodo
DECLARE @dgLenPathPadre smallint  --Lunghezza apdre
DECLARE @dgIdDsc INT  --Id delle descrittive
DECLARE @maxCodInt INT  --Codice INTerno del nuovo nodo
DECLARE @pathFirstChild VARCHAR(100) --path  nodo da riciclare 
DECLARE @pathLastChild VARCHAR(100) --stringa di elaborazione path nuovo elemento
--inserimento delle descrittive
/**** Variabili per scompattare le stringhe di input *********/
DECLARE @pos INT 
DECLARE @pos2 INT
DECLARE @substrDescs NVARCHAR(4000)   --destrittiva corrente
DECLARE @substrLingue VARCHAR(20) --lingua corrente
--per il ripristino delle stringhe.Si  utilizzano  nel secondo ciclo 
DECLARE @TempstrLingue VARCHAR(100)
DECLARE @TempstrDescs NVARCHAR(4000)
--Salvataggio input
set @TempstrLingue = @strLingue
set @TempstrDescs = @strDescs
--Controllo input valido
IF not exists (SELECT * FROM Dominigerarchici WHERE dgCodiceInterno=@CodiceInternoPadre AND dgTipoGerarchia=@IdTid)          BEGIN
                                                                                    raiserror ('Errore:Input errato  (InsertElemGerarchia) ', 16, 1) 
                                                                                                
                                                                                                return 99
                                                                                    END                        
--Ciclo di inserimento della descrittiva in Italiano-generazione IdDsc
while @strLingue <> '' AND @strDescs<>''   begin
      set @Pos = PATINDEX('%#~%', @strDescs)
      set @substrDescs = left (@strDescs, @Pos - 1) -- Estrazione della descrittive
      set @strDescs = substring(@strDescs, @Pos + 2, len(@strDescs)- @Pos)  --riduzione della string delle descrittive
      set @Pos2 = PATINDEX('%#~%', @strLingue)
      set @substrLingue = left (@strLingue, @Pos2 - 1) -- Estrazione della Lingua
      set @strLingue = substring(@strLingue, @Pos2 + 2, len(@strLingue)- @Pos2)  --riduzione della string delle Lingue
IF @substrLingue='I'      BEGIN
                  insert INTo DescsI(dscTesto) values(@substrDescs)
                      IF @@error <> 0
                                           begin
                                                 return 99
                                                 END
                  set @dgIdDsc=@@identity
                  END
 
end --while
--Un controllo sulla validita della formattazione delle stringhe
IF @strLingue<>'' or @strDescs<>''      BEGIN --errore formattazione stringhe
                                                raiserror ('Errore formato stringhe descs o Lingua (InsertElemGerarchia) ', 16, 1)                                                 
                                                return 99
                        END  
--Ripristino delle string di input
set @strLingue=@TempstrLingue
set @strDescs=@TempstrDescs
--Inserimento delle altre descrittive
while @strLingue <> '' AND @strDescs<>''   begin
      set @Pos = PATINDEX('%#~%', @strDescs)
      set @substrDescs = left (@strDescs, @Pos - 1) -- Estrazione della descrizioni
      set @strDescs = substring(@strDescs, @Pos + 2, len(@strDescs)- @Pos)  --riduzione della string delle descrizioni
      set @Pos2 = PATINDEX('%#~%', @strLingue)
      set @substrLingue = left (@strLingue, @Pos2 - 1) -- Estrazione della Lingua
      set @strLingue = substring(@strLingue, @Pos2 + 2, len(@strLingue)- @Pos2)  --riduzione della string delle lingua
 
IF @substrLingue='UK'      BEGIN
                  insert INTo DescsUK(IdDsc,dscTesto) values(@dgIdDsc,@substrDescs)
                      IF @@error <> 0
                                           begin
                                                      return 99
                                                 END
                  END
IF @substrLingue='E'      BEGIN
                  insert INTo DescsE(IdDsc,dscTesto) values(@dgIdDsc,@substrDescs)
                      IF @@error <> 0
                                           begin
                                                return 99
                                                 END
                  END
 
IF @substrLingue='FRA'      BEGIN
                  insert INTo DescsFRA(IdDsc,dscTesto) values(@dgIdDsc,@substrDescs)
                      IF @@error <> 0
                                           begin
                                                return 99
                                                 END
                  END
IF @substrLingue='Lng1'      BEGIN
                  insert INTo DescsLng1(IdDsc,dscTesto) values(@dgIdDsc,@substrDescs)
                      IF @@error <> 0
                                           begin
                                                return 99
                                                 END
                  END
IF @substrLingue='Lng2'      BEGIN
                  insert INTo DescsLng2(IdDsc,dscTesto) values(@dgIdDsc,@substrDescs)
                      IF @@error <> 0
                                           begin
                                                return 99
                                                 END
                  END
IF @substrLingue='Lng3'      BEGIN
                  insert INTo DescsLng3(IdDsc,dscTesto) values(@dgIdDsc,@substrDescs)
                      IF @@error <> 0
                                           begin
                                                return 99
                                                 END
                  END
IF @substrLingue='Lng4'      BEGIN
                  insert INTo DescsLng4(IdDsc,dscTesto) values(@dgIdDsc,@substrDescs)
                      IF @@error <> 0
                                           begin
                                                return 99
                                                 END
                  END
end --while
--Controllo sulla formattazione
IF @strLingue<>'' or @strDescs<>''      BEGIN
                              /* Errore formattazione stringa*/
                                                raiserror ('Errore formato string descs or lingua (InsertElemGerarchia) ', 16, 1) 
                                                
                                                return 99
                              END  
--valori validi in ogni caso
SELECT @dgLivello=dgLivello,@dgLenPathPadre=dgLenPathPadre
FROM Dominigerarchici 
WHERE dgCodiceInterno=@CodiceInternoPadre AND dgTipoGerarchia=@IdTid
--max dei codiceinterno della gerarchia corrente
SELECT @maxCodInt=max(cast(dgCodiceInterno AS INT))
FROM dominigerarchici  
WHERE dgTipoGerarchia=@IdTid AND isnumeric(dgCodiceInterno)=1
--verifica valore numerico del codice INTerno e generazione del Codice INTerno
IF @maxCodInt IS NULL   begin
                  set @maxCodInt=1
            END
      ELSE
            BEGIN
                  set @maxCodInt=@maxCodInt+1
            END
--controllo sul primo nodo della gerarchia
IF exists( SELECT * FROM Dominigerarchici WHERE dgCodiceInterno=@CodiceInternoPadre AND (dgPath='' or dgPath IS NULL) AND dgTipoGerarchia=@IdTid) begin --primo Codice INTerno  --ifp
--selezione del nodo da riciclare
SELECT @pathFirstChild=min(dgpath)  
FROM dominigerarchici  
WHERE dgLivello = 1 
and dgTipoGerarchia=@IdTid AND dgDeleted=0 
and dgpath not in (SELECT dgpath  
FROM dominigerarchici  
WHERE dgLivello = 1 AND dgTipoGerarchia=@IdTid AND dgDeleted=0) 
IF  @pathFirstChild is not NULL  begin    --if1
--Riciclo del nodo
insert INTo dominigerarchici (dgTipoGerarchia,dgCodiceInterno,dgCodiceEsterno,dgPath,dgLivello,dgLenPathPadre,dgIdDsc,dgFoglia)
SELECT top 1 dgTipoGerarchia,@maxCodInt, @CodiceEsternoNew,dgPath,dgLivello,dgLenPathPadre,@dgIdDsc,1
FROM dominigerarchici
WHERE dgPath=@pathFirstChild AND dgTipoGerarchia=@IdTid  
                         IF @@error <> 0
                                           begin
                                                return 99
                                                 END
                  END  --if1
ELSE  --if1
                  BEGIN  --if1
--da fare nel caso in cui non ci sono nodi da riciclare
--massima path disponibile
SELECT @pathLastChild=max(dgpath)  
FROM dominigerarchici  
WHERE  dgTipoGerarchia=@IdTid  AND dgLivello=1 
and dgDeleted = 0
--nel caso in cui non ci sono nodi a quel livello
IF  @pathLastChild IS NULL begin
                  set @pathLastChild='000.'
                  END
--impossibilitO di inserire un nuovo nodo(superato il max)
IF cast(substring(right(@pathLastChild,4),1,3) AS INT)=999 begin
                              /*errore nodi non disponobili */
                                                raiserror ('Errore: Impossibile inserire nodo 1 (InsertElemGerarchia) ', 16, 1) 
                                                
                                                return 99
                              END
--costruzione nuova path
set @pathLastChild=cast(cast(substring(right(@pathLastChild,4),1,3) AS INT)+1 AS VARCHAR(100))  
set @pathLastChild=left('000',3-len(@pathLastChild))+@pathLastChild+ '.' 
--inserimento del nuovo nodo nella dominigerarchici
insert INTo dominigerarchici (dgTipoGerarchia,dgCodiceInterno,dgCodiceEsterno,dgPath,dgLivello,dgLenPathPadre,dgIdDsc,dgFoglia) values(@IdTid,@maxCodInt,@CodiceEsternoNew,@pathLastChild,@dgLivello+1, @dgLenPathPadre,@dgIdDsc,1)
                      IF @@error <> 0
                                           begin
                                                raiserror ('Errore Insert DominiGerarchici (InsertElemGerarchia) ', 16, 1) 
                                                
                                                return 99
                                                 END
                  END --if1
                                                                                    END --ifp
ELSE --ifp 
                                                                                          BEGIN --ifp
--valori legati al padre
SELECT @dgPath=dgPath, @dgFoglia=dgFoglia,@dgLivello=dgLivello,@dgLenPathPadre=dgLenPathPadre 
FROM dominigerarchici
WHERE dgCodiceInterno=@CodiceInternoPadre AND dgTipoGerarchia=@IdTid
--perdita della proprietO foglia del padre
IF @dgFoglia=1 begin
                  update dominigerarchici
                  set        dgFoglia=0
                  WHERE  dgCodiceInterno=@CodiceInternoPadre AND dgTipoGerarchia=@IdTid 
                      IF @@error <> 0
                                           begin
                                                return 99
                                                 END
            END
--selezione del figlio da riciclare
SELECT @pathFirstChild=min(dgpath)  
FROM dominigerarchici  
WHERE dgPath like @dgPath+'%'  AND dgTipoGerarchia=@IdTid   
and dgLivello = (SELECT dgLivello + 1 
FROM dominigerarchici 
WHERE dgCodiceInterno=@CodiceInternoPadre AND dgTipoGerarchia=@IdTid ) AND dgdeleted=1  
and dgpath not in  (SELECT dgpath FROM dominigerarchici 
WHERE dgPath like @dgPath+'%'  AND dgTipoGerarchia=@IdTid AND dgLivello = (SELECT dgLivello + 1 
FROM dominigerarchici 
WHERE dgCodiceInterno=@CodiceInternoPadre AND dgTipoGerarchia=@IdTid ) AND dgdeleted=0) 
IF  @pathFirstChild is not NULL begin    --if1
--Riciclo del nodo
insert INTo dominigerarchici (dgTipoGerarchia,dgCodiceInterno,dgCodiceEsterno,dgPath,dgLivello,dgLenPathPadre,dgIdDsc,dgFoglia)
SELECT top 1 dgTipoGerarchia,@maxCodInt, @CodiceEsternoNew,dgPath,dgLivello,dgLenPathPadre,@dgIdDsc,1
FROM dominigerarchici
WHERE dgPath=@pathFirstChild AND dgTipoGerarchia=@IdTid  
                      IF @@error <> 0
                                           begin
                                                return 99
                                                 END
                  END  --if1
ELSE  --if1
                  BEGIN  --if1
--da fare nel caso in cui non ci sono nodi da riciclare
--Massimi tra le path 
SELECT  @pathLastChild=max(dgpath)  
FROM dominigerarchici  
WHERE dgPath like @dgPath+'%'  AND dgTipoGerarchia=@IdTid   AND dgLivello = (SELECT dgLivello + 1 FROM dominigerarchici 
                                                              WHERE dgPath=@dgPath AND  dgTipoGerarchia=@IdTid AND dgDeleted=0 )  
--Caso in cui non ci sono nodi a quel livello
IF @pathLastChild IS NULL begin
                  set @pathLastChild='000.'
                  END
--possibilita di inserire un nuovo nodo(superato il max)
IF cast(substring(right(@pathLastChild,4),1,3) AS INT)=999 begin
                              /*errore nodi non disponobili */
                                        raiserror ('Errore: Impossibile inserire nodo (InsertElemGerarchia) 2', 16, 1) 
                                                
                                                return 99
                              END
--costruzione nuova path
set @pathLastChild=cast(cast(substring(right(@pathLastChild,4),1,3) AS INT)+1 AS VARCHAR(100))  
set @pathLastChild=@dgpath+left('000',3-len(@pathLastChild))+@pathLastChild+ '.' 
--inserimento del nuovo nodo nella dominigerarchici
insert INTo dominigerarchici (dgTipoGerarchia,dgCodiceInterno,dgCodiceEsterno,dgPath,dgLivello,dgLenPathPadre,dgIdDsc,dgFoglia) values(@IdTid,@maxCodInt,@CodiceEsternoNew,@pathLastChild, @dgLivello+1,@dgLenPathPadre+4 ,@dgIdDsc,1)
                      IF @@error <> 0
                                           begin
                                                return 99
                                                 END
                  END --if1
end --ifp
end
GO
