USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[BOAziende_GeoRegion]    Script Date: 5/16/2024 2:38:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[BOAziende_GeoRegion](@IdAzi INT)
AS
SELECT AziGph.* 
  FROM AziGph
 WHERE AziGph.GphIdAzi = @IdAzi
ORDER BY AziGph.gphValue
GO
