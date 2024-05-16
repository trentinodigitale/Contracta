USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[BOAziende_DfVatAzi]    Script Date: 5/16/2024 2:38:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[BOAziende_DfVatAzi](@IdAzi INT)
AS
SELECT DfVatAzi.* 
  FROM DfVatAzi
 WHERE DfVatAzi.IdAzi = @IdAzi
ORDER BY DfVatAzi.IdVat
GO
