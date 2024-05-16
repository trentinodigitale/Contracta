USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[BOAziende_ValAtt]    Script Date: 5/16/2024 2:38:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[BOAziende_ValAtt](@IdAzi INT)
AS
SELECT ValoriAttributi.* 
  FROM ValoriAttributi, DfVatAzi 
 WHERE ValoriAttributi.IdVat = DfVatAzi.IdVat
   AND IdAzi = @IdAzi
ORDER BY ValoriAttributi.IdVat
GO
