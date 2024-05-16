USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[mpc_Aggiorna]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[mpc_Aggiorna](@lastDate DATETIME = NULL OUTPUT) 
AS
DECLARE @ConfDate DATETIME
SELECT @ConfDate = umdUltimaMod FROM srv_UltimaMod WHERE umdNome = 'MPCommands'
IF (@ConfDate IS NULL) /* Non Accade */
   BEGIN
         SELECT @lastDate = GETDATE()
         SELECT IdMpc           AS IdTab, 
                mpcIdGroup      AS IdGroup,
                mpcIType        AS iType,
                mpcISubType     AS iSubType,
                mpcName         AS Name,
                mpcTypeCommand  AS Command,
                mpcSystem       AS System,
                mpcUserFunz     AS UserFunz,
                mpcIcon         AS Icon,
                mpcParam1       AS Param1,
                mpcParam2       AS Param2,
                mpcOrdine       AS Ordine,
                mpcDeleted      AS flagDeleted,
                mpcUltimaMod    AS UltimaMod
           FROM MPCommands
         ORDER BY IdMpc
   END 
ELSE 
   BEGIN
        IF (@lastDate IS NULL)
            SELECT IdMpc           AS IdTab, 
                   mpcIdGroup      AS IdGroup,
                   mpcIType        AS iType,
                   mpcISubType     AS iSubType,
                   mpcName         AS Name,
                   mpcTypeCommand  AS Command,
                   mpcSystem       AS System,
                   mpcUserFunz     AS UserFunz,
                   mpcIcon         AS Icon,
                   mpcParam1       AS Param1,
                   mpcParam2       AS Param2,
                   mpcOrdine       AS Ordine,
                   mpcDeleted      AS flagDeleted,
                   mpcUltimaMod    AS UltimaMod
              FROM MPCommands
              ORDER BY IdMpc
        ELSE
        IF (@lastDate < @ConfDate)
            SELECT IdMpc           AS IdTab, 
                   mpcIdGroup      AS IdGroup,
                   mpcIType        AS iType,
                   mpcISubType     AS iSubType,
                   mpcName         AS Name,
                   mpcTypeCommand  AS Command,
                   mpcSystem       AS System,
                   mpcUserFunz     AS UserFunz,
                   mpcIcon         AS Icon,
                   mpcParam1       AS Param1,
                   mpcParam2       AS Param2,
                   mpcOrdine       AS Ordine,
                   mpcDeleted      AS flagDeleted,
                   mpcUltimaMod    AS UltimaMod
              FROM MPCommands
             WHERE mpcUltimaMod > @lastDate
             ORDER BY IdMpc
        SELECT @lastDate = @ConfDate
   END
GO
