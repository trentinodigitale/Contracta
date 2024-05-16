USE [AFLink_TND]
GO
/****** Object:  View [dbo].[RICHIESTA_CODIFICA_PRODOTTI_TESTATA_VIEW]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[RICHIESTA_CODIFICA_PRODOTTI_TESTATA_VIEW] as 

select 
	d.* 
	,b.value as MacroAreaMerc
	
	
from CTL_DOC d
	left join CTL_DOC_Value b on d.id = b.idheader and b.DSE_ID='TESTATA_PRODOTTI' and b.DZT_Name='MacroAreaMerc'


GO
