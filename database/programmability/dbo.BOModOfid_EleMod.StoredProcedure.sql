USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[BOModOfid_EleMod]    Script Date: 5/16/2024 2:38:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[BOModOfid_EleMod](@IdPfu INT) AS
  SELECT * FROM Modelli
    WHERE mdlIdPfu = @IdPfu
    ORDER BY IdMdl
GO
