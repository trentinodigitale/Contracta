USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[TempOff_EleOff]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[TempOff_EleOff] (@IdOff INT)
with recompile
 AS
 SELECT TempOfferte.*
 FROM TempOfferte
 WHERE IdOff = @IdOff
GO
