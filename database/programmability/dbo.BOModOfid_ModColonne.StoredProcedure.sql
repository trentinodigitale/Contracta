USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[BOModOfid_ModColonne]    Script Date: 5/16/2024 2:38:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[BOModOfid_ModColonne](@IdMdl INT) AS
  SELECT ModelliColonne.* FROM ModelliColonne
    WHERE (ModelliColonne.mclIdMdl = @IdMdl)
GO
