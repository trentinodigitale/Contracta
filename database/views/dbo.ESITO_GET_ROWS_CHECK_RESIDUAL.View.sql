USE [AFLink_TND]
GO
/****** Object:  View [dbo].[ESITO_GET_ROWS_CHECK_RESIDUAL]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[ESITO_GET_ROWS_CHECK_RESIDUAL]
AS
SELECT      d.idheader,
d.idrow,d.residualbudget,
--d.keyente,d.keyarea,d.keycdr,d.keypegcdc,d.keycapitolo,d.keycodintervento,d.rdp_dataprevcons,
'35152001' as KeyEnte,
'01' AS KeyArea,'10' AS KeyCDR, '10' AS KeyUAC ,'10' AS KeyPegCDC, '1326' AS Keycapitolo, 
'1001' AS KeyProgetto, 
 '03' AS KeyCodintervento,
Importo , ResidualBudget AS Residuo
FROM         dbo.Document_Esito_PREVQUOT d

GO
