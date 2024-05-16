USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[sp_DeleteMSG]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_DeleteMSG] (@Security CHAR (8))
AS
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
IF @Security <> 'XXXXXXXX'
   BEGIN
        RAISERROR ('Parametro non valido', 16, 1)
        RETURN 99
   END
BEGIN TRANSACTION
IF exists (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[FK_MSGValoriAttributi_DizionarioAttributi]') AND OBJECTPROPERTY(id, N'IsForeignKey') = 1)
     ALTER TABLE [dbo].[MSGValoriAttributi] 
                 DROP CONSTRAINT FK_MSGValoriAttributi_DizionarioAttributi
IF exists (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[FK_MSGValoriAttributi_Datetime_MSGValoriAttributi]') AND OBJECTPROPERTY(id, N'IsForeignKey') = 1)
     ALTER TABLE [dbo].[MSGValoriAttributi_Datetime] 
            DROP CONSTRAINT FK_MSGValoriAttributi_Datetime_MSGValoriAttributi
IF exists (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[FK_MSGValoriAttributi_Descrizioni_MSGValoriAttributi]') AND OBJECTPROPERTY(id, N'IsForeignKey') = 1)
     ALTER TABLE [dbo].[MSGValoriAttributi_Descrizioni] 
            DROP CONSTRAINT FK_MSGValoriAttributi_Descrizioni_MSGValoriAttributi
IF exists (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[FK_MSGValoriAttributi_Float_MSGValoriAttributi]') AND OBJECTPROPERTY(id, N'IsForeignKey') = 1)
     ALTER TABLE [dbo].[MSGValoriAttributi_Float] 
            DROP CONSTRAINT FK_MSGValoriAttributi_Float_MSGValoriAttributi
IF exists (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[FK_MSGValoriAttributi_Image_MSGValoriAttributi]') AND OBJECTPROPERTY(id, N'IsForeignKey') = 1)
     ALTER TABLE [dbo].[MSGValoriAttributi_Image] 
            DROP CONSTRAINT FK_MSGValoriAttributi_Image_MSGValoriAttributi
IF exists (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[FK_MSGValoriAttributi_Int_MSGValoriAttributi]') AND OBJECTPROPERTY(id, N'IsForeignKey') = 1)
     ALTER TABLE [dbo].[MSGValoriAttributi_Int] 
            DROP CONSTRAINT FK_MSGValoriAttributi_Int_MSGValoriAttributi
IF exists (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[FK_MSGValoriAttributi_Keys_MSGValoriAttributi]') AND OBJECTPROPERTY(id, N'IsForeignKey') = 1)
     ALTER TABLE [dbo].[MSGValoriAttributi_Keys] 
            DROP CONSTRAINT FK_MSGValoriAttributi_Keys_MSGValoriAttributi
IF exists (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[FK_MSGValoriAttributi_Money_MSGValoriAttributi]') AND OBJECTPROPERTY(id, N'IsForeignKey') = 1)
     ALTER TABLE [dbo].[MSGValoriAttributi_Money] 
            DROP CONSTRAINT FK_MSGValoriAttributi_Money_MSGValoriAttributi
IF exists (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[FK_MSGValoriAttributi_Nvarchar_MSGValoriAttributi]') AND OBJECTPROPERTY(id, N'IsForeignKey') = 1)
     ALTER TABLE [dbo].[MSGValoriAttributi_Nvarchar] 
            DROP CONSTRAINT FK_MSGValoriAttributi_Nvarchar_MSGValoriAttributi
IF exists (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[FK_MSGVatArt_MSGValoriAttributi]') AND OBJECTPROPERTY(id, N'IsForeignKey') = 1)
     ALTER TABLE [dbo].[MSGVatArt] 
            DROP CONSTRAINT FK_MSGVatArt_MSGValoriAttributi
IF exists (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[FK_MSGVatMsg_MSGValoriAttributi]') AND OBJECTPROPERTY(id, N'IsForeignKey') = 1)
     ALTER TABLE [dbo].[MSGVatMsg] 
           DROP CONSTRAINT FK_MSGVatMsg_MSGValoriAttributi
IF exists (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[FK_MessaggiAgent_Messaggi]') AND OBJECTPROPERTY(id, N'IsForeignKey') = 1)
     ALTER TABLE [dbo].[MessaggiAgent] 
           DROP CONSTRAINT FK_MessaggiAgent_Messaggi
IF exists (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[FK_MessaggiArticoli_Messaggi]') AND OBJECTPROPERTY(id, N'IsForeignKey') = 1)
     ALTER TABLE [dbo].[MessaggiArticoli] 
           DROP CONSTRAINT FK_MessaggiArticoli_Messaggi
IF exists (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[FK_MessaggiUtenti_Messaggi]') AND OBJECTPROPERTY(id, N'IsForeignKey') = 1)
     ALTER TABLE [dbo].[MessaggiUtenti] 
           DROP CONSTRAINT FK_MessaggiUtenti_Messaggi
   
IF exists (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[FK_MSGVatArt_Messaggi]') AND OBJECTPROPERTY(id, N'IsForeignKey') = 1)
     ALTER TABLE [dbo].[MSGVatArt] 
          DROP CONSTRAINT FK_MSGVatArt_Messaggi
IF exists (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[FK_MSGValoriAttributi_UnitaMisura]') AND OBJECTPROPERTY(id, N'IsForeignKey') = 1)
     ALTER TABLE [dbo].[MSGValoriAttributi] 
          DROP CONSTRAINT FK_MSGValoriAttributi_UnitaMisura
IF exists (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[FK_MessaggiArticoli_Articoli]') AND OBJECTPROPERTY(id, N'IsForeignKey') = 1)
     ALTER TABLE [dbo].[MessaggiArticoli] 
          DROP CONSTRAINT FK_MessaggiArticoli_Articoli
IF exists (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[FK_MSGVatArt_Articoli]') AND OBJECTPROPERTY(id, N'IsForeignKey') = 1)
     ALTER TABLE [dbo].[MSGVatArt] 
          DROP CONSTRAINT FK_MSGVatArt_Articoli
IF exists (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[FK_MessaggiUtenti_Aziende]') AND OBJECTPROPERTY(id, N'IsForeignKey') = 1)
     ALTER TABLE [dbo].[MessaggiUtenti] 
          DROP CONSTRAINT FK_MessaggiUtenti_Aziende
IF exists (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[FK_MessaggiUtenti_Aziende1]') AND OBJECTPROPERTY(id, N'IsForeignKey') = 1)
     ALTER TABLE [dbo].[MessaggiUtenti] 
          DROP CONSTRAINT FK_MessaggiUtenti_Aziende1
IF exists (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[FK_MessaggiUtenti_ProfiliUtente]') AND OBJECTPROPERTY(id, N'IsForeignKey') = 1)
     ALTER TABLE [dbo].[MessaggiUtenti] 
          DROP CONSTRAINT FK_MessaggiUtenti_ProfiliUtente
IF exists (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[FK_MessaggiUtenti_ProfiliUtente1]') AND OBJECTPROPERTY(id, N'IsForeignKey') = 1)
     ALTER TABLE [dbo].[MessaggiUtenti] 
          DROP CONSTRAINT FK_MessaggiUtenti_ProfiliUtente1
IF exists (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[FK_MSGPermissions_ProfiliUtente]') AND OBJECTPROPERTY(id, N'IsForeignKey') = 1)
     ALTER TABLE [dbo].[MSGPermissions] 
          DROP CONSTRAINT FK_MSGPermissions_ProfiliUtente
IF exists (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[FK_Messaggi_Document]') AND OBJECTPROPERTY(id, N'IsForeignKey') = 1)
     ALTER TABLE [dbo].[Messaggi] 
          DROP CONSTRAINT FK_Messaggi_Document
IF exists (SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[FK_TAB_ATTACH_TAB_OBJ]') AND OBJECTPROPERTY(id, N'IsForeignKey') = 1)
     ALTER TABLE dbo.TAB_ATTACH
              DROP CONSTRAINT FK_TAB_ATTACH_TAB_OBJ
IF exists (SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[FK_TAB_BLACK_LIST_TAB_MESSAGGI]') AND OBJECTPROPERTY(id, N'IsForeignKey') = 1)
        ALTER TABLE dbo.TAB_BLACK_LIST
              DROP CONSTRAINT FK_TAB_BLACK_LIST_TAB_MESSAGGI
IF exists (SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[FK_TAB_ATTACH_TAB_MESSAGGI]') AND OBJECTPROPERTY(id, N'IsForeignKey') = 1)
        ALTER TABLE dbo.TAB_ATTACH
              DROP CONSTRAINT FK_TAB_ATTACH_TAB_MESSAGGI
IF exists (SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[FK_TAB_TENDER_TAB_MESSAGGI]') AND OBJECTPROPERTY(id, N'IsForeignKey') = 1)
        ALTER TABLE dbo.TAB_TENDER
              DROP CONSTRAINT FK_TAB_TENDER_TAB_MESSAGGI
IF exists (SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[FK_TAB_UTENTI_MESSAGGI_TAB_MESSAGGI]') AND OBJECTPROPERTY(id, N'IsForeignKey') = 1)
        ALTER TABLE dbo.TAB_UTENTI_MESSAGGI
              DROP CONSTRAINT FK_TAB_UTENTI_MESSAGGI_TAB_MESSAGGI
IF exists (SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[FK_MSGPermissions_TAB_MESSAGGI]') AND OBJECTPROPERTY(id, N'IsForeignKey') = 1)
        ALTER TABLE dbo.MSGPermissions
              DROP CONSTRAINT FK_MSGPermissions_TAB_MESSAGGI
IF exists (SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[FK_FolderDocuments_TAB_MESSAGGI]') AND OBJECTPROPERTY(id, N'IsForeignKey') = 1)
        ALTER TABLE dbo.FolderDocuments
              DROP CONSTRAINT FK_FolderDocuments_TAB_MESSAGGI
IF exists (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[FK_TAB_ATTACH_TAB_OBJ]') AND OBJECTPROPERTY(id, N'IsForeignKey') = 1)
        ALTER TABLE [dbo].[TAB_ATTACH] 
                DROP CONSTRAINT FK_TAB_ATTACH_TAB_OBJ
IF exists (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[FK_Messaggi_TAB_MESSAGGI]') AND OBJECTPROPERTY(id, N'IsForeignKey') = 1)
        ALTER TABLE [dbo].[Messaggi] 
                DROP CONSTRAINT FK_Messaggi_TAB_MESSAGGI
IF exists (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[FK_MessageFields_TAB_MESSAGGI]') AND OBJECTPROPERTY(id, N'IsForeignKey') = 1)
        ALTER TABLE [dbo].[MessageFields] 
                DROP CONSTRAINT FK_MessageFields_TAB_MESSAGGI
truncate table dbo.MSGValoriAttributi_Nvarchar  --senza fk
truncate table dbo.MSGValoriAttributi_int
truncate table dbo.MSGValoriAttributi_Datetime
truncate table dbo.MSGValoriAttributi_Money --senza fk
truncate table dbo.MSGValoriAttributi_float
truncate table dbo.MSGValoriAttributi_Descrizioni
truncate table dbo.MSGValoriAttributi_keys
truncate table dbo.MSGVatArt --da ragionarci!!!
truncate table dbo.MSGVatMsg
truncate table dbo.MSGValoriAttributi
truncate table dbo.MessaggiUtenti
truncate table dbo.MessaggiArticoli
truncate table dbo.MessaggiAgent
truncate table dbo.Messaggi
truncate table dbo.MessageFields
truncate table dbo.TAB_ATTACH
truncate table dbo.TAB_OBJ
truncate table dbo.TAB_UTENTI_MESSAGGI
truncate table dbo.TAB_TENDER
truncate table dbo.TAB_BLACK_LIST
truncate table dbo.TAB_MESSAGGI
truncate table dbo.TAB_AUCTION
truncate table dbo.TAB_AUCTION_OFFER
truncate table dbo.MSGPermissions
truncate table dbo.FolderDocuments
--per i messaggi
ALTER TABLE [dbo].[MSGValoriAttributi_Datetime] ADD 
      CONSTRAINT [FK_MSGValoriAttributi_Datetime_MSGValoriAttributi] FOREIGN KEY 
      (
            [IdVat]
      ) REFERENCES [dbo].[MSGValoriAttributi] (
            [IdVat]
      )
ALTER TABLE [dbo].[MSGValoriAttributi_Descrizioni] ADD 
      CONSTRAINT [FK_MSGValoriAttributi_Descrizioni_MSGValoriAttributi] FOREIGN KEY 
      (
            [IdVat]
      ) REFERENCES [dbo].[MSGValoriAttributi] (
            [IdVat]
      )
ALTER TABLE [dbo].[MSGValoriAttributi_Float] ADD 
      CONSTRAINT [FK_MSGValoriAttributi_Float_MSGValoriAttributi] FOREIGN KEY 
      (
            [IdVat]
      ) REFERENCES [dbo].[MSGValoriAttributi] (
            [IdVat]
      )
ALTER TABLE [dbo].[MSGValoriAttributi_Image] ADD 
      CONSTRAINT [FK_MSGValoriAttributi_Image_MSGValoriAttributi] FOREIGN KEY 
      (
            [IdVat]
      ) REFERENCES [dbo].[MSGValoriAttributi] (
            [IdVat]
      )
ALTER TABLE [dbo].[MSGValoriAttributi_Int] ADD 
      CONSTRAINT [FK_MSGValoriAttributi_Int_MSGValoriAttributi] FOREIGN KEY 
      (
            [IdVat]
      ) REFERENCES [dbo].[MSGValoriAttributi] (
            [IdVat]
      )
ALTER TABLE [dbo].[MSGValoriAttributi_Keys] ADD 
      CONSTRAINT [FK_MSGValoriAttributi_Keys_MSGValoriAttributi] FOREIGN KEY 
      (
            [IdVat]
      ) REFERENCES [dbo].[MSGValoriAttributi] (
            [IdVat]
      )
ALTER TABLE [dbo].[MSGValoriAttributi_Money] ADD 
      CONSTRAINT [FK_MSGValoriAttributi_Money_MSGValoriAttributi] FOREIGN KEY 
      (
            [IdVat]
      ) REFERENCES [dbo].[MSGValoriAttributi] (
            [IdVat]
      )
ALTER TABLE [dbo].[MSGValoriAttributi_Nvarchar] ADD 
      CONSTRAINT [FK_MSGValoriAttributi_Nvarchar_MSGValoriAttributi] FOREIGN KEY 
      (
            [IdVat]
      ) REFERENCES [dbo].[MSGValoriAttributi] (
            [IdVat]
      )
ALTER TABLE [dbo].[MSGVatArt] ADD 
      CONSTRAINT [FK_MSGVatArt_Messaggi] FOREIGN KEY 
      (
            [IdMsg]
      ) REFERENCES [dbo].[Messaggi] (
            [IdMsg]
      ),
      CONSTRAINT [FK_MSGVatArt_MSGValoriAttributi] FOREIGN KEY 
      (
            [IdVat]
      ) REFERENCES [dbo].[MSGValoriAttributi] (
            [IdVat]
      )
ALTER TABLE [dbo].[MSGVatMsg] ADD 
      CONSTRAINT [FK_MSGVatMsg_MSGValoriAttributi] FOREIGN KEY 
      (
            [IdVat]
      ) REFERENCES [dbo].[MSGValoriAttributi] (
            [IdVat]
      )
--messaggi
ALTER TABLE [dbo].[MessaggiArticoli] ADD 
      CONSTRAINT [FK_MessaggiArticoli_Messaggi] FOREIGN KEY 
      (
            [maIdMsg]
      ) REFERENCES [dbo].[Messaggi] (
            [IdMsg]
      )
ALTER TABLE [dbo].[MessaggiUtenti] ADD 
      CONSTRAINT [FK_MessaggiUtenti_Aziende] FOREIGN KEY 
      (
            [muIdAziMitt]
      ) REFERENCES [dbo].[Aziende] (
            [IdAzi]
      ),
      CONSTRAINT [FK_MessaggiUtenti_Messaggi] FOREIGN KEY 
      (
            [muIdMsg]
      ) REFERENCES [dbo].[Messaggi] (
            [IdMsg]
      ),
      CONSTRAINT [FK_MessaggiUtenti_ProfiliUtente] FOREIGN KEY 
      (
            [muIdPfuMitt]
      ) REFERENCES [dbo].[ProfiliUtente] (
            [IdPfu]
      ),
      CONSTRAINT [FK_MessaggiUtenti_ProfiliUtente1] FOREIGN KEY 
      (
            [muIdPfuDest]
      ) REFERENCES [dbo].[ProfiliUtente] (
            [IdPfu]
      )
--UnitaMisura
ALTER TABLE [dbo].[MSGValoriAttributi] ADD 
      CONSTRAINT [FK_MSGValoriAttributi_DizionarioAttributi] FOREIGN KEY 
      (
            [vatIdDzt]
      ) REFERENCES [dbo].[DizionarioAttributi] (
            [IdDzt]
      ),
      CONSTRAINT [FK_MSGValoriAttributi_UnitaMisura] FOREIGN KEY 
      (
            [vatIdUms]
      ) REFERENCES [dbo].[UnitaMisura] (
            [IdUms]
      )
ALTER TABLE [dbo].[MSGPermissions] ADD 
      CONSTRAINT [FK_MSGPermissions_ProfiliUtente] FOREIGN KEY 
      (
            [mpIdPfu]
      ) REFERENCES [dbo].[ProfiliUtente] (
            [IdPfu]
      ),
      CONSTRAINT [FK_MSGPermissions_TAB_MESSAGGI] FOREIGN KEY 
      (
            [mpIdMsg]
      ) REFERENCES [dbo].[TAB_MESSAGGI] (
            [IdMsg]
      )
ALTER TABLE [dbo].[Messaggi] ADD 
      CONSTRAINT [FK_Messaggi_Document] FOREIGN KEY 
      (
            [msgIdDcm]
      ) REFERENCES [dbo].[Document] (
            [IdDcm]
      ),
      CONSTRAINT [FK_Messaggi_TAB_MESSAGGI] FOREIGN KEY 
      (
            [IdMsg]
      ) REFERENCES [dbo].[TAB_MESSAGGI] (
            [IdMsg]
      )
--TAB_ATTACH
ALTER TABLE dbo.TAB_TENDER ADD CONSTRAINT
      FK_TAB_TENDER_TAB_MESSAGGI FOREIGN KEY
      (
      tndIdMsg
      ) REFERENCES dbo.TAB_MESSAGGI
      (
      IdMsg
      )
ALTER TABLE dbo.FolderDocuments ADD CONSTRAINT
      FK_FolderDocuments_TAB_MESSAGGI FOREIGN KEY
      (
      fdIdMsg
      ) REFERENCES dbo.TAB_MESSAGGI
      (
      IdMsg
      )
ALTER TABLE dbo.TAB_UTENTI_MESSAGGI ADD CONSTRAINT
      FK_TAB_UTENTI_MESSAGGI_TAB_MESSAGGI FOREIGN KEY
      (
      umIdMsg
      ) REFERENCES dbo.TAB_MESSAGGI
      (
      IdMsg
      )
ALTER TABLE dbo.TAB_BLACK_LIST ADD CONSTRAINT
      FK_TAB_BLACK_LIST_TAB_MESSAGGI FOREIGN KEY
      (
      blIdMsg
      ) REFERENCES dbo.TAB_MESSAGGI
      (
      IdMsg
      )
ALTER TABLE dbo.TAB_ATTACH ADD CONSTRAINT
      FK_TAB_ATTACH_TAB_MESSAGGI FOREIGN KEY
      (
      attIdMsg
      ) REFERENCES dbo.TAB_MESSAGGI
      (
      IdMsg
      )
ALTER TABLE dbo.MessageFields ADD CONSTRAINT
      FK_MessageFields_TAB_MESSAGGI FOREIGN KEY
      (
      mfIdMsg
      ) REFERENCES dbo.TAB_MESSAGGI
      (
      IdMSG
      )
ALTER TABLE dbo.TAB_ATTACH ADD CONSTRAINT
      FK_TAB_ATTACH_TAB_OBJ FOREIGN KEY
      (
      attIdObj
      ) REFERENCES dbo.TAB_OBJ
      (
      IdObj
      )
commit transaction

GO
