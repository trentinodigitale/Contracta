USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[BOModOfid_ModGruppi]    Script Date: 5/16/2024 2:38:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[BOModOfid_ModGruppi](@IdMdl INT) AS
  SELECT * FROM ModelliGruppi
    WHERE mgrIdMdl = @IdMdl
    ORDER BY IdMgr
GO
