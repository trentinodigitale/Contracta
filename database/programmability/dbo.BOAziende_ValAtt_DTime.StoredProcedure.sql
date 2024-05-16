USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[BOAziende_ValAtt_DTime]    Script Date: 5/16/2024 2:38:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[BOAziende_ValAtt_DTime] (@IdAzi INT)
AS
SELECT ValoriAttributi_Datetime.* 
  FROM ValoriAttributi_Datetime, DfVatAzi
 WHERE ValoriAttributi_Datetime.IdVat = DfVatAzi.IdVat
    AND IdAzi = @IdAzi
ORDER BY ValoriAttributi_Datetime.IdVat
GO
