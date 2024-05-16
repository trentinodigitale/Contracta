USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[spIsLocked]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[spIsLocked]
/*-1:errore 0:tabella non bloccata 1:tabella bloccata e timeout non scaduto 2:tabella bloccata e timeout scaduto */
/*3:tabella bloccata dallo stesso operatore e timeout non scaduto 4:tabella bloccata dallo stesso operatore e timeout scaduto */
 (
  @IdAz INT,
  @Tabella VARCHAR(20) ,
  @LockDelta INT ,
  @LockUser INT ,
  @returnValue INT OUTPUT
 )
As
DECLARE @currLock   INT
DECLARE @currLockInit   DATETIME
DECLARE @currLockEnd    DATETIME
DECLARE @currLockUser   INT
 /*  */
 IF (@IdAz IS NULL)  
      BEGIN   
         set @returnValue = -1
         return
      END   
 IF (@Tabella IS NULL) or (@Tabella = '')
   BEGIN
         set @returnValue = -1
         return
      END   
 IF (@LockUser IS NULL) 
      BEGIN
         set @returnValue = -1
         return
      END   
 set @currLock = (SELECT LockValue FROM AZ_LOCK WHERE IdAz = @IdAz AND TABELLA = @Tabella)
 set @currLockInit = (SELECT LockInit FROM AZ_LOCK WHERE IdAz = @IdAz AND TABELLA = @Tabella)
 set @currLockUser = (SELECT LockUser FROM AZ_LOCK WHERE IdAz = @IdAz AND TABELLA = @Tabella)
 IF (@currLock IS NULL) or (@currLockInit IS NULL) or (@currLockUser IS NULL) 
        set @returnValue = -1
 ELSE
         BEGIN
           set @currLockEnd = DATEADD(mi, @LockDelta, @currLockInit)
           IF (@currLock=0)
             BEGIN
             set @returnValue = 0
             return 
             END
           IF ((@currLock=1) AND (@LockUser <> @currLockUser) AND (@currLockEnd >= GETDATE()) )
             BEGIN
             set @returnValue = 1
             return 
             END
           IF ((@currLock=1) AND (@LockUser <> @currLockUser) AND ( @currLockEnd < GETDATE()) )
             BEGIN
             set @returnValue = 2
             return 
             END
           IF ((@currLock=1) AND (@LockUser = @currLockUser) AND (@currLockEnd < GETDATE()) )
             BEGIN
             set @returnValue = 3
             return 
             END
           IF ((@currLock=1) AND (@LockUser = @currLockUser) AND (@currLockEnd >= GETDATE()) )
             BEGIN
             set @returnValue = 4
             return 
             END
         END
GO
