USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[DeleteLinguaOpzionale]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
/*
Autore: Alfano - Albanese
Scopo: disattivazione lingua opzionale-scaricamento massivo
Data: 12/11/2001
*/
CREATE PROCEDURE [dbo].[DeleteLinguaOpzionale]( @suffix VARCHAR(5))
AS  
begin 
 
DECLARE @updateMlng VARCHAR(4000)
DECLARE @deleteDescLngX VARCHAR(4000)
begin tran
--Controllo lingua di sessione
IF not exists (SELECT * FROM LingueAttivabili WHERE lasuffix=@suffix)                                          BEGIN
                                                                  raiserror ('Errore: lingua inesistente o non disattivabile (DeleteLinguaOpzionale)', 16, 1)
                                                                          rollback tran
                                                                          return 99
                                                                  END
IF exists (SELECT * FROM LingueAttivabili WHERE lasuffix=@suffix AND laDeleted=0)      BEGIN
                                                                  raiserror ('Errore: suffisso NULLo o lingua gia disattivata (DeleteLinguaOpzionale)', 16, 1)
                                                                          rollback tran
                                                                          return 99
                                                                  END
update LingueAttivabili
set laDeleted=0
WHERE laSuffix=@suffix
IF @@error<>0                                                            BEGIN
                                                                  raiserror ('Errore "update" LingueAttivabili(DeleteLinguaOpzionale)', 16, 1)
                                                                          rollback tran
                                                                          return 99
                                                                  END
update Lingue
set lngDeleted=1
WHERE lngSuffisso=@suffix
IF @@error<>0                                                            BEGIN
                                                                  raiserror ('Errore "update" Lingue (DeleteLinguaOpzionale)', 16, 1)
                                                                          rollback tran
                                                                          return 99
                                                                  END
set @updateMlng ='update Multilinguismo set mlngDesc_'+@suffix+'= NULL'+',mlngUltimaMod = GETDATE()' 
set @deleteDescLngX = 'delete descs'+@suffix
      
alter table multilinguismo disable trigger MultiLinguismo_UltimaMod
exec (@updateMlng)
IF @@error<>0                                                            BEGIN
                                                                  raiserror ('Errore "update dinamico" Multilinguismo (DeleteLinguaOpzionale)', 16, 1)
                                                                          rollback tran
                                                                  alter table multilinguismo enable trigger MultiLinguismo_UltimaMod
                                                                          return 99
                                                                  END
alter table multilinguismo enable trigger MultiLinguismo_UltimaMod
exec (@deleteDescLngX)
IF @@error<>0                                                            BEGIN
                                                                  raiserror ('Errore "update dinamico" DescsX (DeleteLinguaOpzionale)', 16, 1)
                                                                          rollback tran
                                                                          return 99
                                                                  END
commit tran
 
end
GO
