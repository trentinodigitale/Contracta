USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[GetMlng]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GetMlng]
AS
SELECT '0_I_' + LOWER (RTRIM (IdMultilng)) AS MKey, mlngDesc_I AS MValue
  FROM Multilinguismo 
 WHERE mlngCancellato = 0
   AND mlngDesc_I IS NOT NULL
UNION ALL
SELECT '0_UK_' + LOWER (RTRIM (IdMultilng)) AS MKey, mlngDesc_UK AS MValue
  FROM Multilinguismo 
 WHERE mlngCancellato = 0
   AND mlngDesc_UK IS NOT NULL
UNION ALL
SELECT '0_E_' + LOWER (RTRIM (IdMultilng)) AS MKey, mlngDesc_E AS MValue
  FROM Multilinguismo 
 WHERE mlngCancellato = 0
   AND mlngDesc_E IS NOT NULL
UNION ALL
SELECT '0_FRA_' + LOWER (RTRIM (IdMultilng)) AS MKey, mlngDesc_FRA AS MValue
  FROM Multilinguismo 
 WHERE mlngCancellato = 0
   AND mlngDesc_FRA IS NOT NULL
UNION ALL
SELECT '0_Lng1_' + LOWER (RTRIM (IdMultilng)) AS MKey, mlngDesc_Lng1 AS MValue
  FROM Multilinguismo 
 WHERE mlngCancellato = 0
   AND mlngDesc_Lng1 IS NOT NULL
UNION ALL
SELECT '0_Lng2_' + LOWER (RTRIM (IdMultilng)) AS MKey, mlngDesc_Lng2 AS MValue
  FROM Multilinguismo 
 WHERE mlngCancellato = 0
   AND mlngDesc_Lng2 IS NOT NULL
UNION ALL
SELECT '0_Lng3_' + LOWER (RTRIM (IdMultilng)) AS MKey, mlngDesc_Lng3 AS MValue
  FROM Multilinguismo 
 WHERE mlngCancellato = 0
   AND mlngDesc_Lng3 IS NOT NULL
UNION ALL
SELECT '0_Lng4_' + LOWER (RTRIM (IdMultilng)) AS MKey, mlngDesc_Lng4 AS MValue
  FROM Multilinguismo
 WHERE mlngCancellato = 0
   AND mlngDesc_Lng4 IS NOT NULL
UNION ALL
SELECT CAST (mpmlngIdMp AS VARCHAR (5)) + '_I_' + LOWER (RTRIM (mpmlngMPKey)) AS MKey, mlngDesc_I AS MValue
  FROM Multilinguismo, MPMultilinguismo
 WHERE mlngCancellato = 0
   AND mpmlngMlngKey = IdMultilng
   AND mpmlngDeleted = 0
   AND mlngDesc_I IS NOT NULL
UNION ALL
SELECT CAST (mpmlngIdMp AS VARCHAR (5)) + '_UK_' + LOWER (RTRIM (mpmlngMPKey)) AS MKey, mlngDesc_UK AS MValue
  FROM Multilinguismo, MPMultilinguismo
 WHERE mlngCancellato = 0
   AND mpmlngMlngKey = IdMultilng
   AND mpmlngDeleted = 0
   AND mlngDesc_UK IS NOT NULL
UNION ALL
SELECT CAST (mpmlngIdMp AS VARCHAR (5)) + '_E_' + LOWER (RTRIM (mpmlngMPKey)) AS MKey, mlngDesc_E AS MValue
  FROM Multilinguismo, MPMultilinguismo
 WHERE mlngCancellato = 0
   AND mpmlngMlngKey = IdMultilng
   AND mpmlngDeleted = 0
   AND mlngDesc_E IS NOT NULL
UNION ALL
SELECT CAST (mpmlngIdMp AS VARCHAR (5)) + '_FRA_' + LOWER (RTRIM (mpmlngMPKey)) AS MKey, mlngDesc_FRA AS MValue
  FROM Multilinguismo, MPMultilinguismo
 WHERE mlngCancellato = 0
   AND mpmlngMlngKey = IdMultilng
   AND mpmlngDeleted = 0
   AND mlngDesc_FRA IS NOT NULL
UNION ALL
SELECT CAST (mpmlngIdMp AS VARCHAR (5)) + '_Lng1_' + LOWER (RTRIM (mpmlngMPKey)) AS MKey, mlngDesc_Lng1 AS MValue
  FROM Multilinguismo, MPMultilinguismo
 WHERE mlngCancellato = 0
   AND mpmlngMlngKey = IdMultilng
   AND mpmlngDeleted = 0
   AND mlngDesc_Lng1 IS NOT NULL
UNION ALL
SELECT CAST (mpmlngIdMp AS VARCHAR (5)) + '_Lng2_' + LOWER (RTRIM (mpmlngMPKey)) AS MKey, mlngDesc_Lng2 AS MValue
  FROM Multilinguismo, MPMultilinguismo
 WHERE mlngCancellato = 0
   AND mpmlngMlngKey = IdMultilng
   AND mpmlngDeleted = 0
   AND mlngDesc_Lng2 IS NOT NULL
UNION ALL
SELECT CAST (mpmlngIdMp AS VARCHAR (5)) + '_Lng3_' + LOWER (RTRIM (mpmlngMPKey)) AS MKey, mlngDesc_Lng3 AS MValue
  FROM Multilinguismo, MPMultilinguismo
 WHERE mlngCancellato = 0
   AND mpmlngMlngKey = IdMultilng
   AND mpmlngDeleted = 0
   AND mlngDesc_Lng3 IS NOT NULL
UNION ALL
SELECT CAST (mpmlngIdMp AS VARCHAR (5)) + '_Lng4_' + LOWER (RTRIM (mpmlngMPKey)) AS MKey, mlngDesc_Lng4 AS MValue
  FROM Multilinguismo, MPMultilinguismo
 WHERE mlngCancellato = 0
   AND mpmlngMlngKey = IdMultilng
   AND mpmlngDeleted = 0
   AND mlngDesc_Lng4 IS NOT NULL
GO
