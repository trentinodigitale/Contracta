USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[BOAzienda_ValoriInd]    Script Date: 5/16/2024 2:38:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[BOAzienda_ValoriInd](@idAzi INT)
AS
  SELECT ValoriIndicatori.IdVind,
         ValoriIndicatori.vindIdAzi,
         ValoriIndicatori.vindIdDsc,
         ValoriIndicatori.vindValore,
         ValoriIndicatori.vindDI,
         ValoriIndicatori.vindDF       
    FROM ValoriIndicatori
   WHERE vindIdAzi = @idAzi
GO
