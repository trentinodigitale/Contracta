USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[BOIndicatori_Pesi]    Script Date: 5/16/2024 2:38:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[BOIndicatori_Pesi](@idPfu INT)
AS
SELECT * 
  FROM ModPesiRatingForn
 WHERE mprfIdPfu = @IdPfu
GO
