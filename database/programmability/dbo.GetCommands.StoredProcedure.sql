USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[GetCommands]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [dbo].[GetCommands]
(
   @IdGrp           INTeger,
   @vcLng           VARCHAR(5),
   @vcFunzionalita  VARCHAR(400) 
)
AS
DECLARE @vcSQL  VARCHAR (8000)
set @vcSQL = 
'SELECT distinct cast(dbo.CNV_ESTESA(mlngDesc_' + @vcLng + ', ''' + @vcLng + ''') AS NVARCHAR(200)) AS DescCommand, mpcName, mpcItype, mpcISubType, mpcIcon, mpcOrdine, mpcLink,mpcSelection
   FROM Multilinguismo, MPCommands
  WHERE IdMultilng = mpcName
    AND mpcTypeCommand = 0
    AND mpcIdGroup = ' + cast(@IdGrp AS VARCHAR(5)) + 
   ' AND mpcDeleted = 0
    AND IdMpc not in (
                      SELECT IdMpc
                        FROM Multilinguismo, MPCommands, MPMultilinguismo, MPGroups
                        WHERE mpmlngMPKey = mpcName
                          AND IdMultilng = mpmlngMlngKey AND mpcIdGroup = mpgIdGroup AND mpgIdMp = mpmlngIdMp)
    AND (mpcUserfunz = -1 or substring (''' + @vcFunzionalita + ''', mpcUserfunz, 1) = ''1'')
 union 
 SELECT distinct cast(dbo.CNV_ESTESA(mlngDesc_' + @vcLng + ', ''' + @vcLng + ''') AS NVARCHAR(200)) AS DescCommand, mpcName, mpcItype, mpcISubType, mpcIcon, mpcOrdine, mpcLink,mpcSelection
   FROM Multilinguismo, MPCommands, MPMultilinguismo, MPGroups
  WHERE mpmlngMPKey = mpcName
    AND IdMultilng = mpmlngMlngKey
    AND mpcTypeCommand = 0
    AND mpcIdGroup = ' + cast(@IdGrp AS VARCHAR(5)) + 
   ' AND mpcDeleted = 0
    AND (mpcUserfunz = -1 or substring (''' + @vcFunzionalita + ''', mpcUserfunz, 1) = ''1'')
    AND mpcIdGroup = mpgIdGroup AND mpgIdMp = mpmlngIdMp
 ORDER BY mpcOrdine'

exec (@vcSQL)

GO
