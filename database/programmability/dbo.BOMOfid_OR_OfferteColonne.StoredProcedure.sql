USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[BOMOfid_OR_OfferteColonne]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[BOMOfid_OR_OfferteColonne] (@IdMdl INT) AS
 SELECT ModelliColonne.*
 FROM ModelliColonne
 WHERE ModelliColonne.mclIdMdl = @IdMdl
GO
