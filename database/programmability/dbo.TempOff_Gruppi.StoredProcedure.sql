USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[TempOff_Gruppi]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[TempOff_Gruppi] (@IdOff int)
AS
SELECT mgIdProd, mgIdMdl, mgProdNome, mgProdPosizione
  FROM TempOfferteGruppi
 WHERE mgIdProd = -1
GO
