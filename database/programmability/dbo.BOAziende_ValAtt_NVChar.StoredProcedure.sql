USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[BOAziende_ValAtt_NVChar]    Script Date: 5/16/2024 2:38:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[BOAziende_ValAtt_NVChar] (@IdAzi INT)
AS
SELECT ValoriAttributi_Nvarchar.* 
  FROM ValoriAttributi_Nvarchar, DFVatAzi
 WHERE ValoriAttributi_Nvarchar.IdVat = DFVatAzi.IdVat
   AND IdAzi = @IdAzi
ORDER BY ValoriAttributi_Nvarchar.IdVat
GO
