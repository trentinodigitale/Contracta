USE [AFLink_TND]
GO
/****** Object:  View [dbo].[BANDO_GARA_TESTATA_PRODOTTI_VIEW]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[BANDO_GARA_TESTATA_PRODOTTI_VIEW]	as

select 
	IdRow, IdHeader, DSE_ID, Row, DZT_Name, Value 
from 
	CTL_DOC_Value

union all


select 
	IdRow, IdHeader, 'TESTATA_PRODOTTI' as DSE_ID, 0 as Row, 'TipoBando' as DZT_Name, TipoBando as Value
from 
	Document_Bando 
	

union all

select 
	IdRow, IdHeader, 'TESTATA_PRODOTTI' as DSE_ID, 0 as Row, 'Help_Bando' as DZT_Name, Help_bando as Value
from 
	Document_Bando 
		left outer join document_modelli_microlotti on TipoBando=codice and deleted=0 

union all

select 
	IdRow, IdHeader, 'TESTATA_PRODOTTI' as DSE_ID, 0 as Row, 'TipoBandoSceltaOLD' as DZT_Name,  Value
from 
	CTL_DOC_Value
	where DSE_ID='InfoTec_comune' and DZT_Name='TipoBandoSceltaOLD'


GO
