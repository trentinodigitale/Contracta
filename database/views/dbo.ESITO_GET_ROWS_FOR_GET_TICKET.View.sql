USE [AFLink_TND]
GO
/****** Object:  View [dbo].[ESITO_GET_ROWS_FOR_GET_TICKET]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[ESITO_GET_ROWS_FOR_GET_TICKET]
AS
SELECT     dbo.Document_Esito.ID, Document_Esito.Valuta AS Valuta, getdate() AS Periodo, 
                      dbo.Document_Esito_pubblicazioni.Importo  AS Importo, 
                      dbo.Document_Esito_pubblicazioni.idRow AS ID_RIGA_PROD, 
					    '35152001' as KeyEnte,
						'01' AS KeyArea,
						'10' AS KeyCDR, 
						'10' AS KeyUAC ,
						'10' AS KeyPegCDC, 
						'1326' AS Keycapitolo, 
						'1001' AS KeyProgetto, 
						'03' AS KeyCodintervento,
						Fornitore,
						 getdate() as RDP_DataPrevCons
FROM         dbo.Document_Esito INNER JOIN
             dbo.Document_Esito_pubblicazioni ON dbo.Document_Esito.ID = dbo.Document_Esito_pubblicazioni.idheader
			  and 		Tipo='QUOTIDIANI'

GO
