USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[mpac_Aggiorna]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[mpac_Aggiorna](@lastDate DATETIME = NULL OUTPUT) 
AS
DECLARE @ConfDate DATETIME
SELECT @ConfDate = umdUltimaMod FROM srv_UltimaMod WHERE umdNome = 'MPAttributiControlli'
IF (@ConfDate IS NULL) /* Non Accade */
   BEGIN
         SELECT @lastDate = GETDATE()
         SELECT IdMpAc          AS IdTab, 
                mpacIdMdlAtt    AS tabIdMdlAtt,
                dztNome         AS tabName,
                mpacValue       AS tabValue,
                mpacDeleted     AS flagDeleted,
                mpacUltimaMod   AS tabUltimaMod
           FROM MPAttributiControlli, DizionarioAttributi
          WHERE mpacIdDzt = IdDzt
         ORDER BY IdMpAc
   END 
ELSE 
   BEGIN
        IF (@lastDate IS NULL)
         SELECT IdMpAc          AS IdTab, 
                mpacIdMdlAtt    AS tabIdMdlAtt,
                dztNome         AS tabName,
                mpacValue       AS tabValue,
                mpacDeleted     AS flagDeleted,
                mpacUltimaMod   AS tabUltimaMod
           FROM MPAttributiControlli, DizionarioAttributi
          WHERE mpacIdDzt = IdDzt
         ORDER BY IdMpAc
        ELSE
        IF (@lastDate < @ConfDate)
         SELECT IdMpAc          AS IdTab, 
                mpacIdMdlAtt    AS tabIdMdlAtt,
                dztNome         AS tabName,
                mpacValue       AS tabValue,
                mpacDeleted     AS flagDeleted,
                mpacUltimaMod   AS tabUltimaMod
           FROM MPAttributiControlli, DizionarioAttributi
          WHERE mpacIdDzt = IdDzt AND mpacUltimaMod > @lastDate
         ORDER BY IdMpAc
        SELECT @lastDate = @ConfDate
   END
GO
