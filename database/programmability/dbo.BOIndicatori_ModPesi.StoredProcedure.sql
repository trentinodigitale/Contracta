USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[BOIndicatori_ModPesi]    Script Date: 5/16/2024 2:38:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
--fine001
CREATE PROCEDURE [dbo].[BOIndicatori_ModPesi](@idPfu INT)
AS
SELECT * 
  FROM ModPesiInd
 WHERE mpiIdPfu = @IdPfu
GO
