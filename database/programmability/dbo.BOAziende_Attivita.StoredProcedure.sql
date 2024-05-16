USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[BOAziende_Attivita]    Script Date: 5/16/2024 2:38:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[BOAziende_Attivita](@IdAzi INT)
AS
SELECT aziAteco.* 
  FROM AziAteco
 WHERE aziAteco.IdAzi = @IdAzi
ORDER BY aziAteco.atvAtecord
GO
