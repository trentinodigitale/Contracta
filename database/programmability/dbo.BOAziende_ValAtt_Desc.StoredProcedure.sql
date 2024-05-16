USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[BOAziende_ValAtt_Desc]    Script Date: 5/16/2024 2:38:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[BOAziende_ValAtt_Desc] (@IdAzi INT)
AS
SELECT ValoriAttributi_Descrizioni.* 
  FROM ValoriAttributi_Descrizioni, DfVatAzi
  WHERE ValoriAttributi_Descrizioni.IdVat = DfVatAzi.IdVat
    AND IdAzi = @IdAzi
ORDER BY ValoriAttributi_Descrizioni.IdVat
GO
