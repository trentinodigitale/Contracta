USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[mpif_Aggiorna]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[mpif_Aggiorna](@lastDate DATETIME = NULL OUTPUT) 
AS
 DECLARE @ConfDate DATETIME
 SELECT @ConfDate = umdUltimaMod FROM srv_UltimaMod WHERE umdNome = 'MPInheritFields'
 IF (@ConfDate IS NULL) /* Non Accade */
    BEGIN
          SELECT @lastDate = GETDATE()
          SELECT   IdmpIF                AS  IdTab
                  ,mpifIdMp              AS  IdMp
                  ,mpifITypeSource       AS  ITypeSource
                  ,mpifISubTypeSource    AS  ISubTypeSource
                  ,mpifITypeDest         AS  ITypeDest
                  ,mpifISubTypeDest      AS  ISubTypeDest
                  ,mpifFieldNameSource   AS  FieldNameSource
                  ,mpifFieldNameDest     AS  FieldNameDest
                  ,mpifScript            AS  Script
                  ,mpifDeleted           AS  flagDeleted
                  ,mpifUltimaMod         AS  UltimaMod
             FROM MPInheritFields
           ORDER BY Idmpif
    END 
 ELSE 
    BEGIN
           IF (@lastDate IS NULL)
                SELECT   IdmpIF                AS  IdTab
                        ,mpifIdMp              AS  IdMp
                        ,mpifITypeSource       AS  ITypeSource
                        ,mpifISubTypeSource    AS  ISubTypeSource
                        ,mpifITypeDest         AS  ITypeDest
                        ,mpifISubTypeDest      AS  ISubTypeDest
                        ,mpifFieldNameSource   AS  FieldNameSource
                        ,mpifFieldNameDest     AS  FieldNameDest
                        ,mpifScript            AS  Script
                        ,mpifDeleted           AS  flagDeleted
                        ,mpifUltimaMod         AS  UltimaMod
                  FROM MPInheritFields
               ORDER BY Idmpif
           ELSE
               IF (@lastDate < @ConfDate)
                SELECT   IdmpIF                AS  IdTab
                        ,mpifIdMp              AS  IdMp
                        ,mpifITypeSource       AS  ITypeSource
                        ,mpifISubTypeSource    AS  ISubTypeSource
                        ,mpifITypeDest         AS  ITypeDest
                        ,mpifISubTypeDest      AS  ISubTypeDest
                        ,mpifFieldNameSource   AS  FieldNameSource
                        ,mpifFieldNameDest     AS  FieldNameDest
                        ,mpifScript            AS  Script
                        ,mpifDeleted           AS  flagDeleted
                        ,mpifUltimaMod         AS  UltimaMod
                      FROM MPInheritFields
                     WHERE mpifUltimaMod > @lastDate
                  ORDER BY Idmpif
      SELECT @lastDate = @ConfDate
 END
GO
