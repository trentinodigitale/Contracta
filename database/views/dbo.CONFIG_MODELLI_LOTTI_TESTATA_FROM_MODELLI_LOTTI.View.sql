USE [AFLink_TND]
GO
/****** Object:  View [dbo].[CONFIG_MODELLI_LOTTI_TESTATA_FROM_MODELLI_LOTTI]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[CONFIG_MODELLI_LOTTI_TESTATA_FROM_MODELLI_LOTTI] as
select 
	C.Id as ID_FROM,
	C.Id as IdRow,
	C.Id,
	'TESTATA' as DSE_ID,
	0 as Row,
	'Titolo' as DZT_NAME,
	'Copiadi'+ Replace(C.Titolo,' ','') as Value
	
from CTL_DOC C
where C.tipodoc='CONFIG_MODELLI_LOTTI' 


GO
