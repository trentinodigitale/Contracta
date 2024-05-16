USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[BOMOfid_OR_OffArt]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[BOMOfid_OR_OffArt] (@IdMdl INT) AS
 SELECT OfferteArticoli.*
 FROM OfferteArticoli
 WHERE OfferteArticoli.oarIdOff IN
  (SELECT Offerte.IdOff FROM Offerte WHERE offIdMdl = @IdMdl AND offStato = 3)
GO
