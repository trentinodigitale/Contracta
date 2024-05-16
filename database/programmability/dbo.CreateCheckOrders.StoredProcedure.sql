USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[CreateCheckOrders]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CreateCheckOrders]
as 
begin
      IF exists (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[CheckOrders]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
      drop table [dbo].[CheckOrders]
      CREATE TABLE [dbo].[CheckOrders] (
      [IdMsg] [int] ,
      [iType] [smallint] NULL ,
      [NumOrd] [varchar] (30) NULL ,
      [Stato] [smallint] NULL ,
      [StateOrder] [smallint] NULL ,
      [Datains] [DATETIME] NULL ,
      [FieldIdOrd] [varchar] (100),
      [FieldFindFieldValue] [varchar] (500) NULL,      
      [InDossier] [bit] NULL,
      [Err] [bit] NULL
) ON [PRIMARY]
  
  CREATE  UNIQUE  INDEX [IX_CheckOrders_Idmsg] ON [dbo].[CheckOrders]([IdMsg]) WITH  FILLFACTOR = 90 ON [PRIMARY]
  INSERT CheckOrders (IdMsg, iType, NumOrd, Stato, StateOrder, Datains,FieldIdOrd,FieldFindFieldValue,InDossier)
  SELECT TAB_MESSAGGI.IdMsg, msgIType, SUBSTRING (msgText, 
                                    PATINDEX ('%<biztoBFieldNumOrd>%', msgText) + 19, 
                                    PATINDEX ('%</biztoBFieldNumOrd>%', msgText) - 
                                    (PATINDEX ('%<biztoBFieldNumOrd>%', msgText) + 19)),
                        SUBSTRING (msgText, PATINDEX ('%<biztoBFieldStato>%', msgText) + 18, PATINDEX ('%</biztoBFieldStato>%', msgText) - (PATINDEX ('%<biztoBFieldStato>%', msgText) + 18)),
                        SUBSTRING (msgText, PATINDEX ('%<biztoBFieldStateOrder>%', msgText) + 23, PATINDEX ('%</biztoBFieldStateOrder>%', msgText) - (PATINDEX ('%<biztoBFieldStateOrder>%', msgText) + 23)),
                        msgDataIns, SUBSTRING (msgText, 
                        PATINDEX ('%<biztoBFieldIdOrd>%', msgText) + 18, 
                        PATINDEX ('%</biztoBFieldIdOrd>%', msgText) - 
                        (PATINDEX ('%<biztoBFieldIdOrd>%', msgText) + 18)
                       ) AS 'FieldIdOrd',
               SUBSTRING (msgText, 
                        PATINDEX ('%<biztoBFieldFindFieldValue>%', msgText) + 27 , 
                        case when (PATINDEX ('%</biztoBFieldFindFieldValue>%', msgText) - 
                                    (PATINDEX ('%<biztoBFieldFindFieldValue>%', msgText)+27)) > 0 then 
                              PATINDEX ('%</biztoBFieldFindFieldValue>%', msgText) - 
                        (PATINDEX ('%<biztoBFieldFindFieldValue>%', msgText) + 27)
                        END 
                       ) AS 'FieldFindFieldValue', 1
  FROM TAB_MESSAGGI
 WHERE msgIType IN (22,23) 
   AND msgISubType = -1
/*
     Err= 1 Numord senza / e FieldFindFieldValue <> NULL    
*/
   update checkorders
   set err = 1 
   WHERE idmsg in (
                  SELECT idmsg  
                  FROM checkorders
                  WHERE patindex ('%/%',numord) = 0 
                       AND FieldFindFieldValue is not NULL )
   IF @@error <> 0 
            BEGIN
                  raiserror ('Errore Update Checkorders 1',16,1)
                  rollback tran
                  return 
            END 
/*
     Metto a NULL FieldFindFieldValue
*/
  update checkorders
  set FieldFindFieldValue  = NULL
  WHERE err = 1 
  IF @@error <> 0 
            BEGIN
                  raiserror ('Errore Update Checkorders 2',16,1)
                  rollback tran
                  return 
            END 
end
GO
