USE [AFLink_TND]
GO
/****** Object:  View [dbo].[ESITO_GET_ROWS_FOR_CHECK_BUDGET]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[ESITO_GET_ROWS_FOR_CHECK_BUDGET] as
select idheader,valuta,
		id as RDP_RDA_ID,BDD_ID as RDP_BDD_ID,
		SUM(importo ) as importo,
			'35152001' as KeyEnte,
			'01' AS KeyArea,'10' AS KeyCDR, '10' AS KeyUAC ,'10' AS KeyPegCDC, '1326' AS Keycapitolo, 
            '1001' AS KeyProgetto, 
            '03' AS KeyCodintervento,
			year(datacreazione) as rdp_dataprevcons
					
from document_esito,document_esito_pubblicazioni 
where tipo='QUOTIDIANI' and idheader=id
GROUP BY 
idheader,valuta,id,BDD_ID,year(datacreazione)

GO
