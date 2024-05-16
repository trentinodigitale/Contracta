USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[BOAziende_ValAtt_Float]    Script Date: 5/16/2024 2:38:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[BOAziende_ValAtt_Float] (@IdAzi INT)
AS
SELECT ValoriAttributi_Float.* 
  FROM ValoriAttributi_Float, DFVatAzi
 WHERE ValoriAttributi_Float.IdVat = DFVatAzi.IdVat 
   AND IdAzi = @IdAzi
ORDER BY ValoriAttributi_Float.IdVat
GO
