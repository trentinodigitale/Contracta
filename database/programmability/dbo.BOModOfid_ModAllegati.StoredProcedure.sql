USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[BOModOfid_ModAllegati]    Script Date: 5/16/2024 2:38:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[BOModOfid_ModAllegati](@IdMdl INT) AS
  SELECT * FROM ModelliAllegati
    WHERE magIdMdl = @IdMdl
    ORDER BY magIdMgr
GO
