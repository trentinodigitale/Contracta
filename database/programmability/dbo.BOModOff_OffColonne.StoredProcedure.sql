USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[BOModOff_OffColonne]    Script Date: 5/16/2024 2:38:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[BOModOff_OffColonne](@IdOff INT) AS
  SELECT ModelliColonne.* FROM ModelliColonne
    WHERE (ModelliColonne.mclIdMdl = (SELECT offIdMdl FROM Offerte WHERE IdOff = @IdOff))
GO
