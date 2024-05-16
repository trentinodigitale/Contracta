USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[BOAziende_ValAtt_Money]    Script Date: 5/16/2024 2:38:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[BOAziende_ValAtt_Money] (@IdAzi INT)
AS
SELECT ValoriAttributi_Money.* 
  FROM ValoriAttributi_Money, DFVatAzi
 WHERE ValoriAttributi_Money.IdVat = DFVatAzi.IdVat 
   AND IdAzi = @IdAzi
ORDER BY ValoriAttributi_Money.IdVat
GO
