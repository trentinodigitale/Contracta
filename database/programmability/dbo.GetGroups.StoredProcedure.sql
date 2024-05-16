USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[GetGroups]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [dbo].[GetGroups]
(
   @IdMP        INT,
   @vcLng       VARCHAR(5),
   @vcUserProf  VARCHAR(5) 
)
AS
DECLARE @vcSQL         VARCHAR (8000)
DECLARE @vcProfFilter  VARCHAR (8000)
DECLARE @iCnt          INT
SET @vcProfFilter = 'AND ('
SET @iCnt = 0
WHILE @iCnt < LEN (@vcUserProf)
BEGIN
      SET @iCnt = @iCnt + 1
      IF @iCnt < LEN (@vcUserProf)
         SET @vcProfFilter = @vcProfFilter + 
                             'mpgUserProfile LIKE ' + '''%' +  
                             SUBSTRING (@vcUserProf, @iCnt, 1) +
                             '%''' + 
                             ' OR '
      ELSE
         SET @vcProfFilter = @vcProfFilter + 
                             'mpgUserProfile LIKE ' + '''%' +  
                             SUBSTRING (@vcUserProf, @iCnt, 1) +
                             '%''' + 
                             ' ) '
END
IF EXISTS (SELECT * FROM MPGroups WHERE mpgIdMp = @IdMp)
   BEGIN
        SET @vcSQL = 
        
        'SELECT DISTINCT CAST(dbo.CNV_ESTESA(mlngDesc_' + @vcLng + ', ''' + @vcLng + ''') AS NVARCHAR(200)) AS DescrGroup, mpgIDGroup, mpgGroupKey, mpgOrdine
           FROM Multilinguismo, MPGroups
          WHERE IdMultilng = mpgGroupName
            AND mpgGroupType = 0
            AND mpgIDMp = ' + CAST(@IdMp AS VARCHAR(5)) + 
           'AND mpgDeleted = 0
            AND (''' + @vcUserProf + '''LIKE ''%'' + mpgUserProfile + ''%'' OR mpgUserProfile LIKE ''%'' + ''' + @vcUserProf + ''' + ''%'')
            AND IdMpg NOT IN (
                              SELECT IdMpg
                                FROM Multilinguismo, MPGroups, MPMultilinguismo
                               WHERE mpmlngMPKey = mpgGroupName
                                 AND IdMultilng = mpmlngMlngKey)
         UNION 
         SELECT DISTINCT CAST(dbo.CNV_ESTESA(mlngDesc_' + @vcLng + ', ''' + @vcLng + ''') AS NVARCHAR(200)) AS DescrGroup, mpgIDGroup, mpgGroupKey, mpgOrdine
           FROM Multilinguismo, MPGroups, MPMultilinguismo
          WHERE mpmlngMPKey = mpgGroupName
            AND IdMultilng = mpmlngMlngKey
            AND mpgGroupType = 0
            AND mpgIDMp = ' + CAST(@IdMp AS VARCHAR(5)) + 
           'AND mpgIDMp = mpmlngIdMp 
            AND mpgDeleted = 0 ' + @vcProfFilter   +
         'ORDER BY mpgOrdine' 
  END
ELSE
  BEGIN
        SET @vcSQL = 
        
        'SELECT DISTINCT CAST(dbo.CNV_ESTESA(mlngDesc_' + @vcLng + ', ''' + @vcLng + ''') AS NVARCHAR(200)) AS DescrGroup, mpgIDGroup, mpgGroupKey, mpgOrdine
           FROM Multilinguismo, MPGroups
          WHERE IdMultilng = mpgGroupName
            AND mpgGroupType = 0
            AND mpgIDMp = 0
            AND mpgDeleted = 0 ' + @vcProfFilter    +  ' ORDER BY mpgOrdine' 
         
  END
EXEC (@vcSQL)

GO
