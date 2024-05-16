USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[BOModOfid_ModGruppiXCol]    Script Date: 5/16/2024 2:38:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[BOModOfid_ModGruppiXCol](@IdMdl INT) AS
 SELECT *
 FROM ModelliGruppiXColonne
 WHERE mgcIdMcl IN (
  SELECT IdMcl 
  FROM ModelliColonne
  WHERE mclIdMdl = @IdMdl)
GO
