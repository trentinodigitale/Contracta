USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[CambiDaStoricoDivise]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[CambiDaStoricoDivise] (@DataCambio DATETIME) AS
SELECT     sdvIdUms, sdvData, sdvCambio 
  FROM     StoricoDivise 
WHERE      sdvData <= @DataCambio
ORDER BY   sdvData DESC
GO
