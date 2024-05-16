USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[UpdateRegDefault]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
/*
Autore: Alfano Antonio
Scopo: Update RegDefault
Data:  4/7/2001
*/
CREATE PROCEDURE [dbo].[UpdateRegDefault] (@IdMp INT, @IdRd INT,@rdPathSel VARCHAR(100), @rdDefValueSel VARCHAR(2000), @strLingue VARCHAR(100), @strDescs NVARCHAR(4000),@rdiType smallint,@rdiSubType smallint,@IdRdOUTPUT INT OUTPUT) AS
begin
--begin tran
DECLARE @rdIdMp INT  --IdMp associato al IdRd
DECLARE @IdUsc INT --IdUsc
DECLARE @usvIdDsc INT --IdDsc 
DECLARE @rdKey VARCHAR(50) --rdKey
DECLARE @rdPath VARCHAR(100) --rdPath
/*per lo scompattamento delle stringhe*/
DECLARE @pos INT 
DECLARE @pos2 INT
DECLARE @substrDescs NVARCHAR(4000)   --destrittiva corrente
DECLARE @substrLingue VARCHAR(20) --lingua corrente
--per il ripristino delle stringhe.Si  utilizzano  nel secondo ciclo 
DECLARE @TempstrLingue VARCHAR(100)
DECLARE @TempstrDescs NVARCHAR(4000)
/* restituzione valore vecchi nel caso di update*/
SET @IdRdOUTPUT=@IdRd
--Salvataggio input
set @TempstrLingue = @strLingue
set @TempstrDescs = @strDescs
--selezione valori RegDefault
SELECT @rdIdMp=rdIdMp,@rdPath=rdPath,@rdKey=rdKey FROM RegDefault
WHERE IdRd=@IdRd AND rdDeleted=0
--Esistenza record
IF @rdIdMp IS NULL       BEGIN
                                                raiserror ('Errore: record inesistente  (UpdateRegDefault) ', 16, 1) 
                                                --rollback tran
                                                return 99
                  END
--selezione IdUsc da USysColumns
SELECT @IdUsc=IdUsc  FROM USysColumns
WHERE uscTableName='RegDefault' AND  uscColumnName ='rdKey' 
--Esistenza record
IF @IdUsc IS NULL       BEGIN
                                                raiserror ('Errore: record in USysColumns inesistente  (UpdateRegDefault) ', 16, 1) 
                                                --rollback tran
                                                return 99
                  END
--Assiomi
IF @IdMp=0        begin
      IF  not exists (SELECT * FROM RegDefault WHERE rdKey=@rdKey AND rdIdMp=0 AND rdDeleted=0)      BEGIN
                                    raiserror ('Errore MP inconsistenti  (UpdateRegDefault) ', 16, 1) 
                                                --rollback tran
                                                return 99
                                                                                          END
            
                              END
ELSE       begin
      IF  not exists (SELECT * FROM RegDefault WHERE rdKey=@rdKey AND rdIdMp=@IdMp AND rdDeleted=0) AND not exists (SELECT * FROM RegDefault WHERE rdKey=@rdKey AND rdIdMp=0 AND rdDeleted=0)       BEGIN
                                            raiserror ('Errore MP inconsistenti  (UpdateRegDefault) ', 16, 1) 
                                                --rollback tran
                                                return 99
                                                                                          END
                              END
--Controllo esistenza @rdIdMp,@rdPathSel,@rdKey
IF exists (SELECT * FROM RegDefault WHERE rdIdMp=@IdMp AND  rdPath=@rdPathSel AND rdKey=@rdKey AND rdDeleted=0 AND IdRd<>@IdRd )      BEGIN
                                                raiserror ('999Errore esistenza rdIdMp,rdPathSel,rdKey  (UpdateRegDefault) ', 16, 1) 
                                                --rollback tran
                                                return 99
                                                 END
--Inserimento o aggiornamento dei nuovi valori 
IF @IdMp<>@rdIdMp      BEGIN
/********/
--controllo esistenza 
insert INTo RegDefault(rdIdMp,rdPath,rdKey,rdDefValue,rdiType,rdiSubType) values(@IdMp,@rdPathSel,@rdKey,@rdDefValueSel,@rdiType,@rdiSubType) 
IF @@error <> 0
                                           begin
                                                raiserror ('Errore insert  RegDefault  (UpdateRegDefault) ', 16, 1) 
                                                --rollback tran
                                                return 99
                                                 END
SET @IdRdOUTPUT=@@identity
                  END
ELSE
                  BEGIN
update RegDefault
set rdIdMp=@IdMp,
    rdPath=@rdPathSel,
    rdDefValue=@rdDefValueSel,
    rdiType=@rdiType,
    rdiSubType=@rdiSubType
WHERE IdRd=@IdRd
IF @@error <> 0
                                           begin
                                                raiserror ('Errore update RegDefault  (UpdateRegDefault) ', 16, 1) 
                                                --rollback tran
                                                return 99
                                                 END
                  END
IF @strLingue <> '' AND @strDescs<>''            BEGIN --ifstr
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
                                                raiserror ('Errore insert descs  (UpdateRegDefault) ', 16, 1) 
                                                --rollback tran
                                                return 99
                                                 END
                  set @usvIdDsc=@@identity
                  END
 
end --while
--Un controllo sulla validita della formattazione delle stringhe
IF @strLingue<>'' or @strDescs<>''      BEGIN --errore formattazione stringhe
                                                raiserror ('Errore formato stringhe descs o Lingua (UpdateRegDefault) ', 16, 1) 
                                                --rollback tran
                                                return 99
                        END  
--Aggiornamento della USysValues
update USysValues
set usvIdDsc=@usvIdDsc
WHERE usvValue=@rdKey AND usvIdUsc=@IdUsc
 IF @@error <> 0
                                           begin
                                                raiserror ('Errore "Update" USysValues  (UpdateRegDefault) ', 16, 1) 
                                                --rollback tran
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
                  insert INTo DescsUK(IdDsc,dscTesto) values(@usvIdDsc,@substrDescs)
                      IF @@error <> 0
                                           begin
                                                raiserror ('Errore insert descs  (UpdateRegDefault) ', 16, 1) 
                                                --rollback tran
                                                return 99
                                                 END
                  END
IF @substrLingue='E'      BEGIN
                  insert INTo DescsE(IdDsc,dscTesto) values(@usvIdDsc,@substrDescs)
                      IF @@error <> 0
                                           begin
                                                raiserror ('Errore insert descs  (UpdateRegDefault) ', 16, 1) 
                                                --rollback tran
                                                return 99
                                                 END
                  END
 
IF @substrLingue='FRA'      BEGIN
                  insert INTo DescsFRA(IdDsc,dscTesto) values(@usvIdDsc,@substrDescs)
                      IF @@error <> 0
                                           begin
                                                raiserror ('Errore insert descs  (UpdateRegDefault) ', 16, 1) 
                                                --rollback tran
                                                return 99
                                                 END
                  END
IF @substrLingue='Lng1'      BEGIN
                  insert INTo DescsLng1(IdDsc,dscTesto) values(@usvIdDsc,@substrDescs)
                      IF @@error <> 0
                                           begin
                                                raiserror ('Errore insert descs  (UpdateRegDefault) ', 16, 1) 
                                                --rollback tran
                                                return 99
                                                 END
                  END
IF @substrLingue='Lng2'      BEGIN
                  insert INTo DescsLng2(IdDsc,dscTesto) values(@usvIdDsc,@substrDescs)
                      IF @@error <> 0
                                           begin
                                                raiserror ('Errore insert descs  (UpdateRegDefault) ', 16, 1) 
                                                --rollback tran
                                                return 99
                                                 END
                  END
IF @substrLingue='Lng3'      BEGIN
                  insert INTo DescsLng3(IdDsc,dscTesto) values(@usvIdDsc,@substrDescs)
                      IF @@error <> 0
                                           begin
                                                raiserror ('Errore insert descs  (UpdateRegDefault) ', 16, 1) 
                                                --rollback tran
                                                return 99
                                                 END
                  END
IF @substrLingue='Lng4'      BEGIN
                  insert INTo DescsLng4(IdDsc,dscTesto) values(@usvIdDsc,@substrDescs)
                      IF @@error <> 0
                                           begin
                                                raiserror ('Errore insert descs  (UpdateRegDefault) ', 16, 1) 
                                                --rollback tran
                                                return 99
                                                 END
                  END
end --while
--Controllo sulla formattazione
IF @strLingue<>'' or @strDescs<>''      BEGIN
                              /* Errore formattazione stringa*/
                                                raiserror ('Errore formato string descs or lingua (UpdateRegDefault) ', 16, 1) 
                                                --rollback tran
                                                return 99
                              END  
end--ifstr
--commit tran
end
GO
