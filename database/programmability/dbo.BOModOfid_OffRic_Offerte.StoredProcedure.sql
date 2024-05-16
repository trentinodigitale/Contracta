USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[BOModOfid_OffRic_Offerte]    Script Date: 5/16/2024 2:38:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[BOModOfid_OffRic_Offerte] (@IdMdl INT) AS
 SELECT Offerte.*
 FROM Offerte
 WHERE offIdMdl = @IdMdl
  AND offStato = 3
 ORDER BY IdOff
GO
