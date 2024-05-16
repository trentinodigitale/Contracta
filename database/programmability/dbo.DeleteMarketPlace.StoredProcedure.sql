USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[DeleteMarketPlace]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
/*
Autore modifiche: Alfano Antonio
Data: 29/11/2001
Scopo modifiche: Flag M in aziProfili e mpProfili
*/
CREATE PROCEDURE [dbo].[DeleteMarketPlace] 
(
  @mpLog AS NVARCHAR (12)
) 
AS
DECLARE @mpIdAziMaster AS INTeger
DECLARE @IdMp       AS INTeger
DECLARE @mpOpzioni  AS char (20)
set @IdMp = NULL
SELECT @IdMp = IdMp, @mpOpzioni = mpOpzioni, @mpIdAziMaster=mpIdAziMaster FROM MarketPlace WHERE mpLog = @mpLog 
IF @IdMp IS NULL
   begin
        raiserror ('Marketplace [%s] non trovato in tabella MarketPlace (DeleteMarketPlace)', 16, 1, @mpLog) 
        return(99)
   end
IF substring (@mpOpzioni, 1, 1) = '1'
   begin
        raiserror ('Impossibile eliminare il MetaMarketplace [%s] (DeleteMarketPlace)', 16, 1, @mpLog) 
        return(99)
   end
begin tran trn001
delete FROM MPMailCensimento WHERE mpmcIdMp = @IdMp
IF @@error <> 0
   begin 
         raiserror ('Errore "Delete" MPMailCensimento (DeleteMarketPlace)', 16, 1) 
         rollback tran trn001
         return (99)
   end
/* modifiche */
delete FROM MpMailAttach
WHERE mpmaIdMpm in (SELECT IdMpm FROM MPMail WHERE mpmIdMp = @IdMp)
IF @@error <> 0
   begin 
         raiserror ('Errore "Delete" MpMailAttach (DeleteMarketPlace)', 16, 1) 
         rollback tran trn001
         return (99)
   end
delete FROM MPMail WHERE mpmIdMp = @IdMp
IF @@error <> 0
   begin 
         raiserror ('Errore "Delete" MPMail (DeleteMarketPlace)', 16, 1) 
         rollback tran trn001
         return (99)
   end
/* fine modifiche */
delete FROM MPCampiReg WHERE mpcrIdMp = @IdMp
IF @@error <> 0
   begin 
         raiserror ('Errore "Delete" MPCampiReg (DeleteMarketPlace)', 16, 1) 
         rollback tran trn001
         return (99)
   end
delete FROM MPMultilinguismo WHERE mpmlngIdMp = @IdMp
IF @@error <> 0
   begin 
         raiserror ('Errore "Delete" MPMultilinguismo (DeleteMarketPlace)', 16, 1) 
         rollback tran trn001
         return (99)
   end
delete FROM MPDominiGerarchici  WHERE mpdgIdMp   = @IdMp
IF @@error <> 0
   begin 
         raiserror ('Errore "Delete" MPDominiGerarchici (DeleteMarketPlace)', 16, 1) 
         rollback tran trn001
         return (99)
   end
delete FROM MPFolder WHERE mpfIdMp    = @IdMp
IF @@error <> 0
   begin 
         raiserror ('Errore "Delete" MPFolder (DeleteMarketPlace)', 16, 1) 
         rollback tran trn001
         return (99)
   end
delete FROM MPGroups WHERE mpgIdMp = @IdMp
IF @@error <> 0
   begin 
         raiserror ('Errore "Delete" MPGroups (DeleteMarketPlace)', 16, 1) 
         rollback tran trn001
         return (99)
   end
delete FROM MPAziende WHERE mpaIdMp = @IdMp
IF @@error <> 0
   begin 
         raiserror ('Errore "Delete" MPAziende (DeleteMarketPlace)', 16, 1) 
         rollback tran trn001
         return (99)
   end
/*
delete FROM MpAttributiControlli
*/
delete FROM MpAttributiControlli
WHERE mpacIdmdlAtt in (SELECT IdmdlAtt FROM MpModelliAttributi
WHERE MpmaIdMpMod in (SELECT IdMpMod FROM MpModelli
WHERE mpmIdMp=@IdMp))
IF @@error <> 0
   begin 
         raiserror ('Errore "Delete" MpAttributiControlli (DeleteMarketPlace)', 16, 1) 
         rollback tran trn001
         return (99)
   end
delete FROM Modelli_Prodotti
WHERE IdMdl in  (SELECT IdMpMod FROM MpModelli
WHERE mpmIdMp=@IdMp)
IF @@error <> 0
   begin 
         raiserror ('Errore "Delete" Modelli_Prodotti (DeleteMarketPlace)', 16, 1) 
         rollback tran trn001
         return (99)
   end
delete FROM MpModelliAttributi
WHERE MpmaIdMpMod in (SELECT IdMpMod FROM MpModelli
WHERE mpmIdMp=@IdMp)
IF @@error <> 0
   begin 
         raiserror ('Errore "Delete" MpModelliAttributi (DeleteMarketPlace)', 16, 1) 
         rollback tran trn001
         return (99)
   end
delete FROM Mpdocumenti
WHERE  docIdMp=@IdMp
IF @@error <> 0
   begin 
         raiserror ('Errore "Delete" MPDocumenti (DeleteMarketPlace)', 16, 1) 
         rollback tran trn001
         return (99)
   end
delete FROM MpModelli
WHERE  mpmIdMp=@IdMp
IF @@error <> 0
   begin 
         raiserror ('Errore "Delete" MPModelli (DeleteMarketPlace)', 16, 1) 
         rollback tran trn001
         return (99)
   end
delete FROM MPProdotti WHERE mppIdMp = @IdMp
IF @@error <> 0
   begin 
         raiserror ('Errore "Delete" MPProdotti (DeleteMarketPlace)', 16, 1) 
         rollback tran trn001
         return (99)
   end
delete FROM MarketPlace WHERE IdMp = @IdMp
IF @@error <> 0
   begin 
         raiserror ('Errore "Delete" MarketPlace (DeleteMarketPlace)', 16, 1) 
         rollback tran trn001
         return (99)
   end
update aziende
set aziProfili=REPLACE(aziProfili,'M','')
WHERE IdAzi=@mpIdAziMaster AND IdAzi not in (SELECT mpIdAziMaster FROM MarketPlace)
IF @@error <> 0
   begin 
         raiserror ('Errore "Update" Aziende (DeleteMarketPlace)', 16, 1) 
         rollback tran trn001
         return (99)
   end
 
commit tran trn001
GO
