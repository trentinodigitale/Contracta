USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[sp_DeleteMsgDossier]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
/*
Autore: Alfano 
Scopo: Cancellazione dei messaggi dal dossier 
Data: 12/01/2002
*/
CREATE PROCEDURE [dbo].[sp_DeleteMsgDossier]( @IdMsg INT )
AS  
begin 
 
--controllo esistenza IdMsg
IF not exists(SELECT * FROM Messaggi WHERE IdMsg=@IdMsg)            BEGIN
                                                                          return 0
                                                END
create table #TempDelMsg (IdVat INT NULL)
insert INTo #TempDelMsg 
SELECT IdVat FROM MSGVatMsg WHERE IdMsg = @IDMsg
union all
SELECT IdVat FROM MSGVatArt WHERE IdMsg = @IDMsg
--MSGValoriAttributi_Nvarchar
delete FROM MSGValoriAttributi_Nvarchar WHERE IdVat in (SELECT IdVat FROM #TempDelMsg)
IF @@error<>0                                          BEGIN
                                                      raiserror ('Errore "delete" MSGValoriAttributi_Nvarchar (sp_DeleteMsgDossier)', 16, 1)
                                                                                        return 99
                                                END
--MSGValoriAttributi_int
delete FROM MSGValoriAttributi_int WHERE IdVat in (SELECT IdVat FROM #TempDelMsg)
IF @@error<>0                                          BEGIN
                                                      raiserror ('Errore "delete" MSGValoriAttributi_int (sp_DeleteMsgDossier)', 16, 1)
                                                                          return 99
                                                END
--MSGValoriAttributi_image
delete FROM MSGValoriAttributi_image WHERE IdVat in (SELECT IdVat FROM #TempDelMsg)
IF @@error<>0                                          BEGIN
                                                      raiserror ('Errore "delete" MSGValoriAttributi_image (sp_DeleteMsgDossier)', 16, 1)
                                                                          return 99
                                                END
--MSGValoriAttributi_Datetime
delete FROM MSGValoriAttributi_Datetime WHERE IdVat in (SELECT IdVat FROM #TempDelMsg)
IF @@error<>0                                          BEGIN
                                                      raiserror ('Errore "delete" MSGValoriAttributi_Datetime (sp_DeleteMsgDossier)', 16, 1)
                                                                          return 99
                                                END
--MSGValoriAttributi_Money
delete FROM MSGValoriAttributi_Money WHERE IdVat in (SELECT IdVat FROM #TempDelMsg)
IF @@error<>0                                          BEGIN
                                                      raiserror ('Errore "delete" MSGValoriAttributi_Money (sp_DeleteMsgDossier)', 16, 1)
                                                                          return 99
                                                END
--MSGValoriAttributi_float
delete FROM MSGValoriAttributi_float WHERE IdVat in (SELECT IdVat FROM #TempDelMsg)
IF @@error<>0                                          BEGIN
                                                      raiserror ('Errore "delete" MSGValoriAttributi_float (sp_DeleteMsgDossier)', 16, 1)
                                                                          return 99
                                                END
            
--MSGValoriAttributi_Descrizioni
delete FROM MSGValoriAttributi_Descrizioni WHERE IdVat in (SELECT IdVat FROM #TempDelMsg)
IF @@error<>0                                          BEGIN
                                                      raiserror ('Errore "delete" MSGValoriAttributi_Descrizioni (sp_DeleteMsgDossier)', 16, 1)
                                                                          return 99
                                                END
--MSGValoriAttributi_keys
delete FROM MSGValoriAttributi_keys WHERE IdVat in (SELECT IdVat FROM #TempDelMsg)
IF @@error<>0                                          BEGIN
                                                      raiserror ('Errore "delete" MSGValoriAttributi_keys (sp_DeleteMsgDossier)', 16, 1)
                                                                          return 99
                                                END
--MSGVatArt
delete FROM MSGVatArt WHERE IdMsg=@IdMsg
IF @@error<>0                                          BEGIN
                                                      raiserror ('Errore "delete" MSGVatArt (sp_DeleteMsgDossier)', 16, 1)
                                                                          return 99
                                                END
--MSGVatMsgdelete FROM MSGVatMsg WHERE IdMsg=@IdMsg
delete FROM MSGVatMSg WHERE IdMsg=@IdMsg
IF @@error<>0                                          BEGIN
                                                      raiserror ('Errore "delete" MSGVatMsg (sp_DeleteMsgDossier)', 16, 1)
                                                                          return 99
                                                END
--MSGValoriAttributi ( cancella tutti i record di questa tabella che non sono presenti ne nella MSGVatMsg e ne nella MSGVatArt) 
delete FROM MSGValoriAttributi WHERE idvat in (SELECT IdVat FROM #TempDelMsg)
IF @@error<>0                                          BEGIN
                                                      raiserror ('Errore "delete" MSGValoriAttributi (sp_DeleteMsgDossier)', 16, 1)
                                                                          return 99
                                                END
--MessaggiUtenti
delete FROM MessaggiUtenti WHERE muIdMsg=@IdMsg
IF @@error<>0                                          BEGIN
                                                      raiserror ('Errore "delete" MessaggiUtenti (sp_DeleteMsgDossier)', 16, 1)
                                                                          return 99
                                                END
--MessaggiArticoli
delete FROM MessaggiArticoli WHERE maIdMsg=@IdMsg
IF @@error<>0                                          BEGIN
                                                      raiserror ('Errore "delete" MessaggiArticoli (sp_DeleteMsgDossier)', 16, 1)
                                                                          return 99
                                                END
--Messaggi
delete FROM Messaggi WHERE IdMsg=@IdMsg
IF @@error<>0                                          BEGIN
                                                      raiserror ('Errore "delete" Messaggi (sp_DeleteMsgDossier)', 16, 1)
                                                                          return 99
                                                END
drop table #TempDelMsg
 
end
GO
