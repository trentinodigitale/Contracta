USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[mpg_Aggiorna]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[mpg_Aggiorna](@lastDate DATETIME = NULL OUTPUT) 
AS
DECLARE @ConfDate DATETIME
SELECT @ConfDate = umdUltimaMod FROM srv_UltimaMod WHERE umdNome = 'MPGroups'
IF (@ConfDate IS NULL) /* Non Accade */
   BEGIN
         SELECT @lastDate = GETDATE()
         SELECT IdMpg           AS IdTab, 
                mpgIdMp         AS IdMp, 
                mpgIdGroup      AS IdGroup,
                mpgGroupKey     AS GroupKey,
                mpgGroupName    AS GroupName,
                mpgUserProfile  AS UserProfile,
                mpgGroupType    AS GroupType,
                mpgOrdine       AS Ordine,
                mpgDeleted      AS flagDeleted,
                mpgUltimaMod    AS UltimaMod
           FROM MPGroups
         ORDER BY IdMpg
   END 
ELSE 
   BEGIN
        IF (@lastDate IS NULL)
            SELECT IdMpg           AS IdTab, 
                   mpgIdMp         AS IdMp, 
                   mpgIdGroup      AS IdGroup,
                   mpgGroupKey     AS GroupKey,
                   mpgGroupName    AS GroupName,
                   mpgUserProfile  AS UserProfile,
                   mpgGroupType    AS GroupType,
                   mpgOrdine       AS Ordine,
                   mpgDeleted      AS flagDeleted,
                   mpgUltimaMod    AS UltimaMod
              FROM MPGroups
            ORDER BY IdMpg
        ELSE
        IF (@lastDate < @ConfDate)
            SELECT IdMpg           AS IdTab, 
                   mpgIdMp         AS IdMp, 
                   mpgIdGroup      AS IdGroup,
                   mpgGroupKey     AS GroupKey,
                   mpgGroupName    AS GroupName,
                   mpgUserProfile  AS UserProfile,
                   mpgGroupType    AS GroupType,
                   mpgOrdine       AS Ordine,
                   mpgDeleted      AS flagDeleted,
                   mpgUltimaMod    AS UltimaMod
              FROM MPGroups
             WHERE mpgUltimaMod > @lastDate
             ORDER BY IdMpg
        SELECT @lastDate = @ConfDate
   END
GO
