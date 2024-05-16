USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[BOVersione_VerComp]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[BOVersione_VerComp] (@varSO VARCHAR(50), @varObject VARCHAR(50))  AS
SELECT * 
FROM VersioneComponenti 
WHERE VersioneComponenti.vcSO = @varSO AND VersioneComponenti.vcObject = @varObject
ORDER BY VersioneComponenti.vcVersion
GO
