USE [AFLink_TND]
GO
/****** Object:  View [dbo].[RICHIESTA_CODIFICA_PRODOTTI_VIEW]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[RICHIESTA_CODIFICA_PRODOTTI_VIEW] as
select
	*,
	ISNULL(value,'') as TipoBando
from 
ctl_doc 
left join CTL_DOC_Value on IdHeader=id and DSE_ID='TESTATA_PRODOTTI' and DZT_Name='TipoBando'

GO
