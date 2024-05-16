USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[GetDBVersion]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GetDBVersion] (@vcModule VARCHAR (50))
AS
SELECT dbvRelease, dbvFatRelease, dbvLastUpdate
  FROM DBVersion
 WHERE dbvModule = @vcModule
GO
