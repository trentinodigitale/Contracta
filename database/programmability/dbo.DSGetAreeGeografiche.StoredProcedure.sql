USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[DSGetAreeGeografiche]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[DSGetAreeGeografiche] (@CodLingua VARCHAR(20) ,@DataUMod DATETIME )
 AS SELECT * FROM bizAreeGeografiche
GO
