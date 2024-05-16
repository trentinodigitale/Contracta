USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DOCUMENT_PEG_PRODUCT]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[DOCUMENT_PEG_PRODUCT]
AS
select idrow,idheader,valuta,Quotidiani as CopiaQuotidiani,
			'35152001' as KeyEnte,
			'01' AS KeyArea,'10' AS KeyCDR, '10' AS KeyUAC ,'10' AS KeyPegCDC, '1326' AS Keycapitolo, 
            '1001' AS KeyProgetto, 
            '03' AS KeyCodintervento,
			(datacreazione) as rdp_dataprevcons,
					document_esito_pubblicazioni.InBudget as 	RDP_InBudget,
					id as RDP_RDA_ID,
					BDD_ID as RDP_BDD_ID,
					idrow as RDP_idRow,
					importo as RDP_Importo,
					1 as RDP_QT,
					importo ,
					tiketbudget as RDP_TiketBudget,
					document_esito_pubblicazioni.ResidualBudget as RDP_ResidualBudget
from document_esito,document_esito_pubblicazioni 
where tipo='QUOTIDIANI' and idheader=id

GO
