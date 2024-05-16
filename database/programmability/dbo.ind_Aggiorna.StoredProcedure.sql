USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[ind_Aggiorna]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ind_Aggiorna](@lastDate DATETIME = NULL OUTPUT) 
AS
DECLARE @ConfDate DATETIME
SELECT @ConfDate = umdUltimaMod FROM srv_UltimaMod WHERE umdNome = 'Indici'
IF (@ConfDate IS NULL) /* Non Accade */
   BEGIN
         SELECT @lastDate = GETDATE()
         SELECT IdInd           AS IdTab, 
                indTableName    AS TableName,
                indIndexName    AS IndexName,
                indFieldsName   AS FieldsName,
                indUnique       AS [Unique],
                indLanguage     AS Language,
                indDeleted      AS flagDeleted,
                indUltimaMod    AS UltimaMod
           FROM Indici
         ORDER BY IdInd
   END 
ELSE 
   BEGIN
        IF (@lastDate IS NULL)
            SELECT IdInd           AS IdTab, 
                   indTableName    AS TableName,
                   indIndexName    AS IndexName,
                   indFieldsName   AS FieldsName,
                   indUnique       AS [Unique],
                   indLanguage     AS Language,
                   indDeleted      AS flagDeleted,
                   indUltimaMod    AS UltimaMod
              FROM Indici
            ORDER BY IdInd
        ELSE
        IF (@lastDate < @ConfDate)
            SELECT IdInd           AS IdTab, 
                   indTableName    AS TableName,
                   indIndexName    AS IndexName,
                   indFieldsName   AS FieldsName,
                   indUnique       AS [Unique],
                   indLanguage     AS Language,
                   indDeleted      AS flagDeleted,
                   indUltimaMod    AS UltimaMod
              FROM Indici
             WHERE IndUltimaMod > @lastDate
            ORDER BY IdInd
        SELECT @lastDate = @ConfDate
   END
GO
