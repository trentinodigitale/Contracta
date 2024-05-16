USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[BOAziende_ValAtt_Keys]    Script Date: 5/16/2024 2:38:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[BOAziende_ValAtt_Keys] (@IdAzi INT)
AS
SELECT ValoriAttributi_Keys.* 
  FROM ValoriAttributi_Keys, DFVatAzi
 WHERE ValoriAttributi_Keys.IdVat = DFVatAzi.Idvat 
   AND IdAzi = @IdAzi
ORDER BY ValoriAttributi_Keys.IdVat
GO
