USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[CaricaTabMultilingue]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[CaricaTabMultilingue] (@lastDate DATETIME = NULL OUTPUT) AS
 DECLARE @ConfDate DATETIME
 SELECT @ConfDate = umdUltimaMod FROM srv_UltimaMod WHERE umdNome = 'MultiLinguismo'
 IF (@ConfDate IS NULL) /* Non accade */
 BEGIN
  SELECT @lastDate = GETDATE()
  SELECT IdMultiLng AS IdMultiLng,mlngDesc_I AS mlngDesc_I,mlngDesc_UK AS mlngDesc_UK,mlngUltimaMod,mlngDesc_E AS mlngDesc_E,mlngCancellato AS flagDeleted,mlngDesc_FRA AS mlngDesc_FRA,mlngDesc_Lng1 AS mlngDesc_Lng1,mlngDesc_Lng2 AS mlngDesc_Lng2,mlngDesc_Lng3 AS mlngDesc_Lng3,mlngDesc_Lng4 AS mlngDesc_Lng4 
  FROM MultiLinguismo
  ORDER BY IdMultiLng
 END ELSE BEGIN
  IF (@lastDate IS NULL)
   SELECT IdMultiLng AS IdMultiLng,mlngDesc_I AS mlngDesc_I,mlngDesc_UK AS mlngDesc_UK,mlngUltimaMod,mlngDesc_E AS mlngDesc_E,mlngCancellato AS flagDeleted,mlngDesc_FRA AS mlngDesc_FRA,mlngDesc_Lng1 AS mlngDesc_Lng1,mlngDesc_Lng2 AS mlngDesc_Lng2,mlngDesc_Lng3 AS mlngDesc_Lng3,mlngDesc_Lng4 AS mlngDesc_Lng4  
   FROM MultiLinguismo
   ORDER BY IdMultiLng
  ELSE
   IF (@lastDate < @ConfDate)
    SELECT IdMultiLng AS IdMultiLng,mlngDesc_I AS mlngDesc_I,mlngDesc_UK AS mlngDesc_UK,mlngUltimaMod,mlngDesc_E AS mlngDesc_E,mlngCancellato AS flagDeleted ,mlngDesc_FRA AS mlngDesc_FRA,mlngDesc_Lng1 AS mlngDesc_Lng1,mlngDesc_Lng2 AS mlngDesc_Lng2,mlngDesc_Lng3 AS mlngDesc_Lng3,mlngDesc_Lng4 AS mlngDesc_Lng4  
    FROM MultiLinguismo
    WHERE mlngUltimaMod > @lastDate
    ORDER BY IdMultiLng
  SELECT @lastDate = @ConfDate
 END
GO
