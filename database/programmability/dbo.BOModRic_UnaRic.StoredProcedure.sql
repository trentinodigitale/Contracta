USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[BOModRic_UnaRic]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[BOModRic_UnaRic](@IdRic INT) AS
 SELECT * FROM Ricerche
  WHERE IdRic = @IdRic
GO
