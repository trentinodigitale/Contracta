USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[BOAziende_Aziende]    Script Date: 5/16/2024 2:38:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[BOAziende_Aziende](@IdAzi INT) 
AS
SELECT * 
  FROM Aziende
 WHERE IdAzi = @IdAzi
GO
