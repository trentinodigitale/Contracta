USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[DSGetRangeTipologiaAzienda]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[DSGetRangeTipologiaAzienda] (@CodLingua VARCHAR(20) ,@DataUMod DATETIME )
 AS SELECT * FROM bizTipologiaAzienda
GO
