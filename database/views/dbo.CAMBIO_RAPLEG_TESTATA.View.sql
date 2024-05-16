USE [AFLink_TND]
GO
/****** Object:  View [dbo].[CAMBIO_RAPLEG_TESTATA]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[CAMBIO_RAPLEG_TESTATA] as 

	select IdRow, IdHeader, DSE_ID, Row, DZT_Name, Value from CTL_DOC_Value
	union all 
	select 1 as IdRow, id as IdHeader, 'TESTATA' as DSE_ID, 0 as Row, 'Azienda' as DZT_Name, Azienda as Value from CTL_DOC

GO
