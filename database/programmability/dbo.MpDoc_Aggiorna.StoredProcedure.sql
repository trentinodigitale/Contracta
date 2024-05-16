USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[MpDoc_Aggiorna]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[MpDoc_Aggiorna] (@lastDate DATETIME = NULL OUTPUT)
as
DECLARE @ConfDate AS DATETIME
SELECT @ConfDate = umdUltimaMod FROM srv_UltimaMod WHERE umdnome='MPDocumenti'
IF (@ConfDate IS NULL)
    begin
        SELECT @lastDate = GETDATE()
         SELECT IdDoc            AS IdTab,
                docIdMp          AS IdMp,
                docItype         AS iType,
                docPath          AS KeyPath,
                docIdMpMod       AS IdMod,
                docDeleted       AS flagDeleted,
                docDataUltimamod AS DataUltimaMod, 
                docISubType      AS iSubType
           FROM mpdocumenti
         ORDER BY IdDoc
    end      
ELSE
    begin
         IF (@lastDate IS NULL) 
             SELECT IdDoc            AS IdTab,
                    docIdMp          AS IdMp,
                    docItype         AS iType,
                    docPath          AS KeyPath,
                    docIdMpMod       AS IdMod,
                    docDeleted       AS flagDeleted,
                    docDataUltimamod AS DataUltimaMod, 
                    docISubType      AS iSubType
                FROM mpdocumenti
              ORDER BY IdDoc
          ELSE
            IF (@lastDate < @ConfDate)                
                SELECT IdDoc            AS IdTab,
                       docIdMp          AS IdMp,
                       docItype         AS iType,
                       docPath          AS KeyPath,
                       docIdMpMod       AS IdMod,
                       docDeleted       AS flagDeleted,
                       docDataUltimamod AS DataUltimaMod, 
                       docISubType      AS iSubType
                  FROM mpdocumenti
                SELECT @lastDate = @ConfDate
   end
GO
