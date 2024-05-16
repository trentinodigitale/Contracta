USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[avp_Aggiorna]    Script Date: 5/16/2024 2:38:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[avp_Aggiorna](@lastDate DATETIME = NULL OUTPUT) 
AS
DECLARE @ConfDate DATETIME
SELECT @ConfDate = umdUltimaMod FROM srv_UltimaMod WHERE umdNome = 'avp_Aggiorna'
IF (@ConfDate IS NULL) /* Non Accade */
   BEGIN
        SELECT @lastDate = GETDATE()
        SELECT IdAvp        AS IdAvp,       
               avpIdMp      AS IdMp,
               avpContext   AS Context,      
               avpIdDzt     AS IdDzt,
               avpValue     AS Value,
               avpIdDztCrt  AS IdDztCrt,
               avpDeleted   AS flagDeleted,
               avpUltimaMod AS UltimaMod
          FROM AttrVisualProp 
        ORDER BY IdAvp
   END 
ELSE 
   BEGIN
        IF (@lastDate IS NULL)
                SELECT IdAvp        AS IdAvp,       
                       avpIdMp      AS IdMp,
                       avpContext   AS Context,      
                       avpIdDzt     AS IdDzt,
                       avpValue       AS Value,
                       avpIdDztCrt  AS IdDztCrt,
                       avpDeleted   AS flagDeleted,
                       avpUltimaMod AS UltimaMod
                  FROM AttrVisualProp 
                ORDER BY IdAvp
        ELSE
        IF (@lastDate < @ConfDate)
                SELECT IdAvp        AS IdAvp,       
                       avpIdMp      AS IdMp,
                       avpContext   AS Context,      
                       avpIdDzt     AS IdDzt,
                       avpValue       AS Value,
                       avpIdDztCrt  AS IdDztCrt,
                       avpDeleted   AS flagDeleted,
                       avpUltimaMod AS UltimaMod
                  FROM AttrVisualProp 
                 WHERE avpUltimaMod > @lastDate
                ORDER BY IdAvp
        SELECT @lastDate = @ConfDate
   END

GO
