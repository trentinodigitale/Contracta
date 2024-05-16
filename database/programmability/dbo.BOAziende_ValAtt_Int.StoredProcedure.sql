USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[BOAziende_ValAtt_Int]    Script Date: 5/16/2024 2:38:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[BOAziende_ValAtt_Int] (@IdAzi INT)
AS
SELECT ValoriAttributi_Int.* 
  FROM ValoriAttributi_Int, DFVatAzi
 WHERE ValoriAttributi_Int.IdVat = DFVatAzi.IdVat 
   AND IdAzi = @IdAzi
ORDER BY ValoriAttributi_Int.IdVat
GO
