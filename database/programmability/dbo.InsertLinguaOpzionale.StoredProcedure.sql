USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[InsertLinguaOpzionale]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Autore: Alfano - Albanese
Scopo: Attivazione lingua opzionale-caricamento massivo
Data: 12/11/2001
--prove
execute dbo.InsertLinguaOpzionale 'Lng1','Polacco','I'
SELECT * FROM Lingue
SELECT * FROM DescsLng2
WHERE IdDsc=143001
execute dbo.DeleteLinguaOpzionale 'Lng2'
*/
CREATE PROCEDURE [dbo].[InsertLinguaOpzionale]( @suffix VARCHAR(5), @descrizione NVARCHAR(4000), @suffixSession VARCHAR(5))
AS  
begin 
 
DECLARE @descrizioneI NVARCHAR(4000)
DECLARE @descrizioneUK NVARCHAR(4000)
DECLARE @IdDsc INT
DECLARE @lngSuffisso VARCHAR(5)
DECLARE @sql VARCHAR(4000)
DECLARE @sqlC VARCHAR(4000)
/*DECLARE @IsOld bit
set @IsOld=0
*/
begin tran
IF not exists (SELECT * FROM LingueAttivabili WHERE lasuffix=@suffix AND laDeleted=0)      BEGIN
                                                                  raiserror ('Errore suffisso NULLo o inesistente (InsertLinguaOpzionale)', 16, 1)
                                                                          rollback tran
                                                                          return 99
                                                                  END
--sp_help lingue
--Controllo lingua di sessione
IF @suffixSession not in ('I','UK')                                          BEGIN
                                                                  raiserror ('Errore suffisso NULLo o inesistente (InsertLinguaOpzionale)', 16, 1)
                                                                          rollback tran
                                                                          return 99 
                                                                  END
IF @suffixSession ='I'                                          BEGIN
                                                      set @descrizioneI=@descrizione
                                                      set @descrizioneUK='?'+@descrizione
                                                      END
                                                      ELSE
                                                      BEGIN
                                                      set @descrizioneUK=@descrizione
                                                      set @descrizioneI='?'+@descrizione
                                                      END
--se non esiste inserire inserire i nuovi record nelle descsX e la nuova lingua
IF not exists (SELECT * FROM Lingue WHERE lngSuffisso=@suffix AND lngDeleted=1)      BEGIN --b
                                                      
insert INTo DescsI(dscTesto) values(@descrizioneI)
IF @@error<>0                                                            BEGIN
                                                                  raiserror ('Errore "Insert" DescsX (InsertLinguaOpzionale)', 16, 1)
                                                                          rollback tran
                                                                          return 99
                                                                  END
set @IdDsc=@@identity
insert INTo DescsUK(IdDsc,dscTesto) values(@IdDsc,@descrizioneUK)
IF @@error<>0                                                            BEGIN
                                                                  raiserror ('Errore "Insert" DescsX (InsertLinguaOpzionale)', 16, 1)
                                                                          rollback tran
                                                                          return 99
                                                                  END
insert INTo DescsFRA(IdDsc,dscTesto) values(@IdDsc,'?'+ @descrizione)
IF @@error<>0                                                            BEGIN
                                                                  raiserror ('Errore "Insert" DescsX (InsertLinguaOpzionale)', 16, 1)
                                                                          rollback tran
                                                                          return 99
                                                                  END
insert INTo DescsE(IdDsc,dscTesto) values(@IdDsc,'?'+ @descrizione)
IF @@error<>0                                                            BEGIN
                                                                  raiserror ('Errore "Insert" DescsX (InsertLinguaOpzionale)', 16, 1)
                                                                          rollback tran
                                                                          return 99
                                                                  END
insert INTo Lingue(lngIdDsc,lngSuffisso) values(@IdDsc,@suffix)
IF @@error<>0                                                            BEGIN
                                                                  raiserror ('Errore "Insert" Lingue (InsertLinguaOpzionale)', 16, 1)
                                                                          rollback tran
                                                                          return 99
                                                                  END
end --b
ELSE --b
begin --b
--Seleziona rIF alla descsX
SELECT @IdDsc=lngIdDsc FROM Lingue WHERE lngSuffisso=@suffix AND lngDeleted=1
update Lingue
set lngDeleted=0
WHERE lngSuffisso=@suffix AND lngDeleted=1
IF @@error<>0                                                            BEGIN
                                                                  raiserror ('Errore "Update" Lingue (InsertLinguaOpzionale)', 16, 1)
                                                                          rollback tran
                                                                          return 99
                                                                  END
--Nel caso sia cambiata la lingua di sessione
update DescsI
set dscTesto=@descrizioneI
WHERE IdDsc=@IdDsc
IF @@error<>0                                                            BEGIN
                                                                  raiserror ('Errore "Update" DescsX (InsertLinguaOpzionale)', 16, 1)
                                                                          rollback tran
                                                                          return 99
                                                                  END
update DescsUK
set dscTesto=@descrizioneUK
WHERE IdDsc=@IdDsc
IF @@error<>0                                                            BEGIN
                                                                  raiserror ('Errore "Update" DescsX (InsertLinguaOpzionale)', 16, 1)
                                                                          rollback tran
                                                                          return 99
                                                                  END
update DescsFRA
set dscTesto='?'+@descrizione
WHERE IdDsc=@IdDsc
IF @@error<>0                                                            BEGIN
                                                                  raiserror ('Errore "Update" DescsX (InsertLinguaOpzionale)', 16, 1)
                                                                          rollback tran
                                                                          return 99
                                                                  END
update DescsE
set dscTesto='?'+@descrizione
WHERE IdDsc=@IdDsc
IF @@error<>0                                                            BEGIN
                                                                  raiserror ('Errore "Update" DescsX (InsertLinguaOpzionale)', 16, 1)
                                                                          rollback tran
                                                                          return 99
                                                                  END
end --b
--segnalazione di utilizzo lingua
update LingueAttivabili
set laDeleted=1
WHERE laSuffix=@suffix AND laDeleted=0
IF @@error<>0                                                            BEGIN
                                                                  raiserror ('Errore "Update" LingueAttivabili (InsertLinguaOpzionale)', 16, 1)
                                                                          rollback tran
                                                                          return 99
                                                                  END
--caricamento della descrittiva nelle lingue attivate
DECLARE crsLingue cursor static for SELECT distinct lngSuffisso FROM Lingue WHERE lngDeleted=0 AND lngSuffisso not in ('I','UK','E','FRA') 
open crsLingue
fetch next FROM crsLingue INTo @lngSuffisso
while @@fetch_status = 0  --Lingue
begin
set @sqlC='IF not exists( SELECT * FROM descs'+@lngSuffisso +' WHERE IdDsc='+ cast(@IdDsc AS VARCHAR(10))+' )      BEGIN '
-- exec  @sqlC ) begin
set @sql='insert INTo Descs'+@lngSuffisso +'(IdDsc,dscTesto) values('+cast(@IdDsc AS VARCHAR(10))+','+'''?'+@descrizione+''')' 
set @sqlC=@sqlC+@sql+' end ELSE begin '
set @sql=' update Descs'+@lngSuffisso+' set dscTesto='+'''?'+@descrizione+''' WHERE IdDsc='+ cast(@IdDsc AS VARCHAR(10))+'      END '
--set @sql=' update Descs'+@lngSuffisso+' set dscTesto='+'?'+@descrizione+' WHERE IdDsc='+ cast(@IdDsc AS VARCHAR(10))+' )      END '
set @sqlC=@sqlC+@sql
exec (@sqlC) 
IF @@error<>0                                                            BEGIN
                                                                  raiserror ('Errore "Insert dinamica" DescsX (InsertLinguaOpzionale)', 16, 1)
                                                                          rollback tran
                                                                  close crsLingue
                                                                  deallocate crsLingue
                                                                          return 99
                                                                  END
                  
fetch next FROM crsLingue INTo @lngSuffisso
end  --Lingue
close crsLingue
deallocate crsLingue
--Si poteva fare anche con sql dinamico...
IF @suffix='Lng1'            BEGIN
alter table descsLng1 disable trigger DescLng1_UltimaMod            
insert INTo DescsLng1(Iddsc,dscTesto,dscUltimaMod) 
SELECT Iddsc,'?'+dscTesto,GETDATE() FROM DescsI WHERE IdDsc not in (SELECT artIdDscDescrizione FROM Articoli) AND IdDsc<>@IdDsc
IF @@error<>0                                                            BEGIN
                                                                  raiserror ('Errore "Insert" DescsX (InsertLinguaOpzionale)', 16, 1)
                                                                          rollback tran
                                                                  alter table descsLng1 enable trigger DescLng1_UltimaMod            
                                                                          return 99
                                                                  END
--articoli
insert INTo DescsLng1(Iddsc,dscTesto,dscUltimaMod) 
SELECT Iddsc,dscTesto,GETDATE() FROM DescsI WHERE IdDsc in (SELECT artIdDscDescrizione FROM Articoli)
IF @@error<>0                                                            BEGIN
                                                                  raiserror ('Errore "Insert" DescsX (InsertLinguaOpzionale)', 16, 1)
                                                                          rollback tran
                                                                  alter table descsLng1 enable trigger DescLng1_UltimaMod            
                                                                          return 99
                                                                  END
alter table multilinguismo disable trigger MultiLinguismo_UltimaMod 
update Multilinguismo
set mlngDesc_Lng1='Lng1_'+ cast(mlngDesc_I AS NVARCHAR(4000)),
      mlngultimamod = GETDATE()
IF @@error<>0                                                            BEGIN
                                                                  raiserror ('Errore "Update" Multilinguismo (InsertLinguaOpzionale)', 16, 1)
                                                                          rollback tran
                                                                  alter table descsLng1 enable trigger DescLng1_UltimaMod
                                                                  alter table multilinguismo enable trigger MultiLinguismo_UltimaMod 
                                                                          return 99
                                                                  END
alter table descsLng1 enable trigger DescLng1_UltimaMod                                    
alter table multilinguismo enable trigger MultiLinguismo_UltimaMod 
                        END
--Lng2
IF @suffix='Lng2'            BEGIN
alter table descsLng2 disable trigger DescLng2_UltimaMod                                    
insert INTo DescsLng2(Iddsc,dscTesto,dscUltimaMod) 
SELECT Iddsc,'?'+dscTesto,GETDATE() FROM DescsI WHERE IdDsc not in (SELECT artIdDscDescrizione FROM Articoli) AND IdDsc<>@IdDsc
IF @@error<>0                                                            BEGIN
                                                                  raiserror ('Errore "Insert" DescsX (InsertLinguaOpzionale)', 16, 1)
                                                                          rollback tran
                                                                  alter table descsLng2 enable trigger DescLng2_UltimaMod                                                      
                                                                          return 99
                                                                  END
--articoli
insert INTo DescsLng2(Iddsc,dscTesto,dscUltimaMod) 
SELECT Iddsc,dscTesto,GETDATE() FROM DescsI WHERE IdDsc in (SELECT artIdDscDescrizione FROM Articoli)
IF @@error<>0                                                            BEGIN
                                                                  raiserror ('Errore "Insert" DescsX (InsertLinguaOpzionale)', 16, 1)
                                                                          rollback tran
                                                                  alter table descsLng2 enable trigger DescLng2_UltimaMod
                                                                          return 99
                                                                  END
alter table multilinguismo disable trigger MultiLinguismo_UltimaMod 
update Multilinguismo
set mlngDesc_Lng2='Lng2_'+cast(mlngDesc_I AS NVARCHAR(4000)),
      mlngultimamod = GETDATE()
IF @@error<>0                                                            BEGIN
                                                                  raiserror ('Errore "Update" Multilinguismo (InsertLinguaOpzionale)', 16, 1)
                                                                          rollback tran
                                                                  alter table descsLng2 enable trigger DescLng2_UltimaMod
                                                                  alter table multilinguismo enable trigger MultiLinguismo_UltimaMod       
                                                                          return 99
                                                                  END
alter table descsLng2 enable trigger DescLng2_UltimaMod                                                            
alter table multilinguismo enable trigger MultiLinguismo_UltimaMod 
                        END
--Lng3
IF @suffix='Lng3'            BEGIN
alter table descsLng3 disable trigger DescLng3_UltimaMod
insert INTo DescsLng3(Iddsc,dscTesto,dscUltimaMod) 
SELECT Iddsc,'?'+dscTesto,GETDATE() FROM DescsI WHERE IdDsc not in (SELECT artIdDscDescrizione FROM Articoli) AND IdDsc<>@IdDsc
IF @@error<>0                                                            BEGIN
                                                                  raiserror ('Errore "Insert" DescsX (InsertLinguaOpzionale)', 16, 1)
                                                                          rollback tran
                                                                  alter table descsLng3 enable trigger DescLng3_UltimaMod
                                                                          return 99
                                                                  END
--articoli
insert INTo DescsLng3(Iddsc,dscTesto,dscUltimaMod) 
SELECT Iddsc,dscTesto,GETDATE() FROM DescsI WHERE IdDsc in (SELECT artIdDscDescrizione FROM Articoli)
IF @@error<>0                                                            BEGIN
                                                                  raiserror ('Errore "Insert" DescsX (InsertLinguaOpzionale)', 16, 1)
                                                                          rollback tran
                                                                  alter table descsLng3 enable trigger DescLng3_UltimaMod
                                                                          return 99
                                                                  END
alter table multilinguismo disable trigger MultiLinguismo_UltimaMod 
update Multilinguismo
set mlngDesc_Lng3='Lng3_'+cast(mlngDesc_I AS NVARCHAR(4000)),
      mlngultimamod = GETDATE()
IF @@error<>0                                                            BEGIN
                                                                  raiserror ('Errore "Update" Multilinguismo (InsertLinguaOpzionale)', 16, 1)
                                                                          rollback tran
                                                                  alter table descsLng3 enable trigger DescLng3_UltimaMod
                                                                  alter table multilinguismo enable trigger MultiLinguismo_UltimaMod 
                                                                          return 99
                                                                  END
alter table descsLng3 enable trigger DescLng3_UltimaMod                        
alter table multilinguismo enable trigger MultiLinguismo_UltimaMod 
                        END
--Lng4
IF @suffix='Lng4'            BEGIN
alter table descsLng4 disable trigger DescLng4_UltimaMod                        
insert INTo DescsLng4(Iddsc,dscTesto,dscUltimaMod) 
SELECT Iddsc,'?'+dscTesto,GETDATE() FROM DescsI WHERE IdDsc not in (SELECT artIdDscDescrizione FROM Articoli) AND IdDsc<>@IdDsc
IF @@error<>0                                                            BEGIN
                                                                  raiserror ('Errore "Insert" DescsX (InsertLinguaOpzionale)', 16, 1)
                                                                          rollback tran
                                                                  alter table descsLng4 enable trigger DescLng4_UltimaMod
                                                
                                                                          return 99
                                                                  END
--articoli
insert INTo DescsLng4(Iddsc,dscTesto,dscUltimaMod) 
SELECT Iddsc,dscTesto,GETDATE() FROM DescsI WHERE IdDsc in (SELECT artIdDscDescrizione FROM Articoli)
IF @@error<>0                                                            BEGIN
                                                                  raiserror ('Errore "Insert" DescsX (InsertLinguaOpzionale)', 16, 1)
                                                                          rollback tran
                                                                  alter table descsLng4 enable trigger DescLng4_UltimaMod
                                                                          return 99
                                                                  END
alter table multilinguismo disable trigger MultiLinguismo_UltimaMod 
update Multilinguismo
set mlngDesc_Lng4='Lng4_'+cast(mlngDesc_I AS NVARCHAR(4000)),
      mlngultimamod = GETDATE()
      
IF @@error<>0                                                            BEGIN
                                                                  raiserror ('Errore "Update" Multilinguismo (InsertLinguaOpzionale)', 16, 1)
                                                                          rollback tran
                                                                  alter table descsLng4 enable trigger DescLng4_UltimaMod
                                                                  alter table multilinguismo enable trigger MultiLinguismo_UltimaMod 
                                                                          return 99
                                                                  END
alter table descsLng4 enable trigger DescLng4_UltimaMod                        
alter table multilinguismo enable trigger MultiLinguismo_UltimaMod 
                        END
commit tran
 
end


GO
