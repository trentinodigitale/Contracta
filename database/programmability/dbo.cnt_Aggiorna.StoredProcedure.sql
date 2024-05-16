USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[cnt_Aggiorna]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[cnt_Aggiorna](@lastDate DATETIME = NULL OUTPUT) 
AS
DECLARE @ConfDate DATETIME
SELECT @ConfDate = umdUltimaMod FROM srv_UltimaMod WHERE umdNome = 'Counters'
IF (@ConfDate IS NULL) /* Non Accade */
   BEGIN
         SELECT @lastDate = GETDATE()
         SELECT IdCnt, 
                dztNome         AS dztNome,
                cntDeleted      AS flagDeleted,
                cntUltimaMod    AS UltimaMod
           FROM Counters, DizionarioAttributi
         WHERE cntIdDzt = IdDzt
         ORDER BY IdCnt
   END 
ELSE 
   BEGIN
        IF (@lastDate IS NULL)
         SELECT IdCnt, 
                dztNome         AS dztNome,
                cntDeleted      AS flagDeleted,
                cntUltimaMod    AS UltimaMod
           FROM Counters, DizionarioAttributi
         WHERE cntIdDzt = IdDzt
         ORDER BY IdCnt
        ELSE
        IF (@lastDate < @ConfDate)
         SELECT IdCnt, 
                dztNome         AS dztNome,
                cntDeleted      AS flagDeleted,
                cntUltimaMod    AS UltimaMod
           FROM Counters, DizionarioAttributi
         WHERE cntIdDzt = IdDzt 
           AND cntUltimaMod > @lastDate
         ORDER BY IdCnt
        SELECT @lastDate = @ConfDate
   END
GO
