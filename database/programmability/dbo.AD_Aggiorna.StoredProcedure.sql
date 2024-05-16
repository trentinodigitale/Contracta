USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[AD_Aggiorna]    Script Date: 5/16/2024 2:38:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[AD_Aggiorna] (@lastDate DATETIME = NULL OUTPUT)
AS
DECLARE @ConfDate DATETIME
SELECT @ConfDate = umdUltimaMod 
  FROM srv_UltimaMod 
 WHERE umdnome = 'Advising'
IF (@ConfDate IS NULL) 
            BEGIN
                  SELECT @lastDate = GETDATE()
                  SELECT  ai.IdAi AS ID,
                          ai.aiName                             AS Name,
                          ai.aiIdDi                             AS DocumentID,
                          ai.aiDescription                      AS AdviseDescription,
                          ai.aiFieldName                        AS AdviseFieldName,
                          ai.aiCommand                          AS Command,
                          ai.aiCommandParam                     AS CommandParam,
                          ai.aiPriority                         AS AdvisePriority,
                          ai.aiRegKey                           AS AdviseRegKey,
                          ai.aiContext                          AS Context,
                          ai.aiModifiable                       AS Modifiable,
                          ai.aiText                             AS AdviseText,
                          ai.aiStatusValue                      AS DocumentStatusValue,
                          ai.aiStatusDescription                AS DocumentStatusDescription,
                          ai.aiRequiredFromSender               AS RequiredFromSender,
                          ai.aiDeleted                          AS FlagDeleted,
                          ai.aiUltimaMod                        AS aiUltimaMod
                   FROM  AdviseInfo ai
                   ORDER BY ai.idai
            END
      ELSE
            BEGIN
                  IF (@lastDate IS NULL) 
                                    BEGIN
                                                SELECT  ai.IdAi AS ID,
                                                        ai.aiName                             AS Name,
                                                        ai.aiIdDi                             AS DocumentID,
                                                        ai.aiDescription                      AS AdviseDescription,
                                                        ai.aiFieldName                        AS AdviseFieldName,
                                                        ai.aiCommand                          AS Command,
                                                        ai.aiCommandParam                     AS CommandParam,
                                                        ai.aiPriority                         AS AdvisePriority,
                                                        ai.aiRegKey                           AS AdviseRegKey,
                                                        ai.aiContext                          AS Context,
                                                        ai.aiModifiable                       AS Modifiable,
                                                        ai.aiText                             AS AdviseText,
                                                        ai.aiStatusValue                      AS DocumentStatusValue,
                                                        ai.aiStatusDescription                AS DocumentStatusDescription,
                                                        ai.aiRequiredFromSender               AS RequiredFromSender,
                                                        ai.aiDeleted                          AS FlagDeleted,
                                                        ai.aiUltimaMod                        AS aiUltimaMod
                                                 FROM  AdviseInfo ai
                                                 ORDER BY ai.idai            
                                    END
                  ELSE
                                    BEGIN
                                                IF (@lastDate < @ConfDate)
                                                            BEGIN
                                                                  SELECT  ai.IdAi AS ID,
                                                                          ai.aiName                             AS Name,
                                                                          ai.aiIdDi                             AS DocumentID,
                                                                          ai.aiDescription                      AS AdviseDescription,
                                                                          ai.aiFieldName                        AS AdviseFieldName,
                                                                          ai.aiCommand                          AS Command,
                                                                          ai.aiCommandParam                     AS CommandParam,
                                                                          ai.aiPriority                         AS AdvisePriority,
                                                                          ai.aiRegKey                           AS AdviseRegKey,
                                                                          ai.aiContext                          AS Context,
                                                                          ai.aiModifiable                       AS Modifiable,
                                                                          ai.aiText                             AS AdviseText,
                                                                          ai.aiStatusValue                      AS DocumentStatusValue,
                                                                          ai.aiStatusDescription                AS DocumentStatusDescription,
                                                                          ai.aiRequiredFromSender               AS RequiredFromSender,
                                                                          ai.aiDeleted                          AS FlagDeleted,
                                                                          ai.aiUltimaMod                        AS aiUltimaMod
                                                                   FROM  AdviseInfo ai
                                                                   WHERE ai.aiUltimamod > @lastDate
                                                                   ORDER BY ai.idai      
                                                                   SELECT @lastDate = @ConfDate
                                                            END
                                    END
                  END
GO
