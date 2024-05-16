USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[mpfc_Aggiorna]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[mpfc_Aggiorna](@lastDate DATETIME = NULL OUTPUT) 
AS
 DECLARE @ConfDate DATETIME
 SELECT @ConfDate = umdUltimaMod FROM srv_UltimaMod WHERE umdNome = 'MPFolderColumns'
 IF (@ConfDate IS NULL) /* Non Accade */
    BEGIN
          SELECT @lastDate = GETDATE()
          SELECT   Idmpfc                
                  ,mpfcIdMp              AS  IdMp
                  ,mpfcIType             AS  IType
                  ,mpfcISubType          AS  ISubType
                  ,mpfcCaption           AS  Caption
                  ,mpfcTypeCaption       AS  TypeCaption
                  ,mpfcTypeCol           AS  TypeCol
                  ,mpfcTypeEdit          AS  TypeEdit
                  ,mpfcFieldName         AS  FieldName
                  ,mpfcColWidth          AS  ColWidth
                  ,mpfcSortType          AS  SortType
                  ,mpfcKeyIcon           AS  KeyIcon
                  ,mpfcVisible           AS  Visible
                  ,mpfcOrder             AS  [Order]
                  ,mpfcContext           AS  Context
                  ,mpfcNULLBehaviour     AS  NULLBehaviour
                  ,mpfcDeleted           AS  flagDeleted
                  ,mpfcUltimaMod         AS  UltimaMod
                  ,mpfcUse
             FROM MPFolderColumns
           ORDER BY Idmpfc
    END 
 ELSE 
    BEGIN
           IF (@lastDate IS NULL)
               SELECT   Idmpfc                
                       ,mpfcIdMp              AS  IdMp
                       ,mpfcIType             AS  IType
                       ,mpfcISubType          AS  ISubType
                       ,mpfcCaption           AS  Caption
                       ,mpfcTypeCaption       AS  TypeCaption
                       ,mpfcTypeCol           AS  TypeCol
                       ,mpfcTypeEdit          AS  TypeEdit
                       ,mpfcFieldName         AS  FieldName
                       ,mpfcColWidth          AS  ColWidth
                       ,mpfcSortType          AS  SortType
                       ,mpfcKeyIcon           AS  KeyIcon
                       ,mpfcVisible           AS  Visible
                       ,mpfcOrder             AS  [Order]
                       ,mpfcContext           AS  Context
                       ,mpfcNULLBehaviour     AS  NULLBehaviour
                       ,mpfcDeleted           AS  flagDeleted
                       ,mpfcUltimaMod         AS  UltimaMod
                       ,mpfcUse
                   FROM MPFolderColumns
               ORDER BY Idmpfc
           ELSE
               IF (@lastDate < @ConfDate)
                   SELECT   Idmpfc                
                           ,mpfcIdMp              AS  IdMp
                           ,mpfcIType             AS  IType
                           ,mpfcISubType          AS  ISubType
                           ,mpfcCaption           AS  Caption
                           ,mpfcTypeCaption       AS  TypeCaption
                           ,mpfcTypeCol           AS  TypeCol
                           ,mpfcTypeEdit          AS  TypeEdit
                           ,mpfcFieldName         AS  FieldName
                           ,mpfcColWidth          AS  ColWidth
                           ,mpfcSortType          AS  SortType
                           ,mpfcKeyIcon           AS  KeyIcon
                           ,mpfcVisible           AS  Visible
                           ,mpfcOrder             AS  [Order]
                           ,mpfcContext           AS  Context
                           ,mpfcNULLBehaviour     AS  NULLBehaviour
                           ,mpfcDeleted           AS  flagDeleted
                           ,mpfcUltimaMod         AS  UltimaMod
                           ,mpfcUse
                      FROM MPFolderColumns
                     WHERE mpfcUltimaMod > @lastDate
                  ORDER BY Idmpfc
      SELECT @lastDate = @ConfDate
 END
GO
