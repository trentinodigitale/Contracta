USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[BOModOff_EleOff]    Script Date: 5/16/2024 2:38:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[BOModOff_EleOff] (@IdPfu INT) AS
 SELECT Offerte.*
 FROM Offerte
 WHERE offIdPfu = @IdPfu
 ORDER BY IdOff
GO
