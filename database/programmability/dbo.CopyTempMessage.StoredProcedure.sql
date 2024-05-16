USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[CopyTempMessage]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[CopyTempMessage] AS

SET TRANSACTION ISOLATION LEVEL READ COMMITTED
SET NOCOUNT ON

DECLARE @IdMsg      INTEGER
DECLARE @NewIdMsg   INTEGER
DECLARE @IdObj      INTEGER
DECLARE @NewIdObj   INTEGER

CREATE TABLE #TempIdMsg (IdMsg INT)


DECLARE crs CURSOR STATIC FOR SELECT IdMsg 
                                FROM WORK_TAB_MESSAGGI WITH (NOLOCK) 
                               WHERE msgElabWithSuccess <> -5

OPEN crs

FETCH NEXT FROM crs INTO @IdMsg

WHILE @@FETCH_STATUS = 0
BEGIN
     INSERT INTO TAB_MESSAGGI (msgText, msgDataIns, msgElabWithSuccess, msgiType, msgPriorita, msgIdMp, msgIdCDO, msgiSubType)     
     SELECT msgText, msgDataIns, msgElabWithSuccess, msgiType, msgPriorita, msgIdMp, msgIdCDO, msgiSubType
       FROM WORK_TAB_MESSAGGI WITH (NOLOCK)
      WHERE IdMsg = @IdMsg

     IF @@ERROR <> 0
     BEGIN 
          RAISERROR ('Errore "INSERT" TAB_MESSAGGI', 16, 1)
          CLOSE crs
          DEALLOCATE crs
	  RETURN (99)
     END

     SET @NewIdMsg = @@IDENTITY

     INSERT INTO #TempIdMsg (IdMsg) VALUES (@NewIdMsg) 

     IF @@ERROR <> 0
     BEGIN 
          RAISERROR ('Errore "INSERT" #TempIdMsg', 16, 1)
          CLOSE crs
          DEALLOCATE crs
	  RETURN (99)
     END

     INSERT INTO TAB_UTENTI_MESSAGGI (umIdMsg, umIdPfu, umInput, umIsProspect, umIdMsgOrigine, umStato, umDataLastMail, umNumMail)
     SELECT @NewIdMsg, umIdPfu, umInput, umIsProspect, umIdMsgOrigine, umStato, umDataLastMail, umNumMail
       FROM WORK_TAB_UTENTI_MESSAGGI WITH (NOLOCK)
      WHERE umIdMsg = @IdMsg
      
     IF @@ERROR <> 0
     BEGIN 
          RAISERROR ('Errore "INSERT" TAB_UTENTI_MESSAGGI', 16, 1)
          CLOSE crs
          DEALLOCATE crs
	  RETURN (99)
     END

     DELETE FROM WORK_TAB_UTENTI_MESSAGGI WHERE umIdMsg = @IdMsg

     IF @@ERROR <> 0
     BEGIN 
          RAISERROR ('Errore "DELETE" WORK_TAB_UTENTI_MESSAGGI', 16, 1)
          CLOSE crs
          DEALLOCATE crs
	  RETURN (99)
     END

     DECLARE crs1 CURSOR STATIC FOR SELECT attIdObj 
                                      FROM WORK_TAB_ATTACH WITH (NOLOCK) 
                                     WHERE attIdmsg = @IdMsg 
                                    ORDER BY 1

     OPEN crs1

     FETCH NEXT FROM crs1 INTO @IdObj

     WHILE @@FETCH_STATUS = 0
     BEGIN

          INSERT INTO TAB_OBJ (objFile, objName, objAttachInfo)
          SELECT objFile, objName, objAttachInfo
            FROM WORK_TAB_OBJ WITH (NOLOCK)
           WHERE IdObj = @IdObj

          IF @@ERROR <> 0
          BEGIN 
                RAISERROR ('Errore "INSERT" TAB_OBJ', 16, 1)
                CLOSE crs
                DEALLOCATE crs
                CLOSE crs1
                DEALLOCATE crs1
	        RETURN (99)
          END
 
          SET @NewIdObj = @@IDENTITY

          DELETE FROM WORK_TAB_OBJ WHERE IdObj = @IdObj

          IF @@ERROR <> 0
          BEGIN 
                RAISERROR ('Errore "DELETE" WORK_TAB_OBJ', 16, 1)
                CLOSE crs
                DEALLOCATE crs
                CLOSE crs1
                DEALLOCATE crs1
	        RETURN (99)
          END

          INSERT INTO TAB_ATTACH (attIdMsg, attIdObj, attOrderFile)
          SELECT @NewIdMsg, @NewIdObj, attOrderFile
            FROM WORK_TAB_ATTACH
           WHERE attIdObj = @IdObj
             AND attIdMsg = @IdMsg

          IF @@ERROR <> 0
          BEGIN 
                RAISERROR ('Errore "INSERT" TAB_ATTACH', 16, 1)
                CLOSE crs
                DEALLOCATE crs
                CLOSE crs1
                DEALLOCATE crs1
	        RETURN (99)
          END

          DELETE FROM WORK_TAB_ATTACH WHERE attIdObj = @IdObj AND attIdMsg = @IdMsg

          IF @@ERROR <> 0
          BEGIN 
                RAISERROR ('Errore "DELETE" WORK_TAB_ATTACH', 16, 1)
                CLOSE crs
                DEALLOCATE crs
                CLOSE crs1
                DEALLOCATE crs1
	        RETURN (99)
          END

          FETCH NEXT FROM crs1 INTO @IdObj
     END
   
     CLOSE crs1
     DEALLOCATE crs1


     DELETE FROM WORK_TAB_MESSAGGI WHERE IdMsg = @IdMsg

     IF @@ERROR <> 0
     BEGIN 
	   RAISERROR ('Errore "DELETE" WORK_TAB_MESSAGGI', 16, 1)
	   CLOSE crs
	   DEALLOCATE crs
	   RETURN (99)
     END

     FETCH NEXT FROM crs INTO @IdMsg
END


CLOSE crs
DEALLOCATE crs

SELECT a.IdMsg, b.msgText 
  FROM #TempIdMsg a, TAB_MESSAGGI b
 WHERE a.IdMsg = b.IdMsg
 ORDER BY 1




GO
