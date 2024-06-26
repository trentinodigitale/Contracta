USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_BANDO_FABBISOGNI_IA_TESTATA_PRODOTTI_VIEW]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[OLD_BANDO_FABBISOGNI_IA_TESTATA_PRODOTTI_VIEW] AS
Select
		CV.IdRow, CD.idrow as IdHeader, DSE_ID, Row, DZT_Name, Value
from
CTL_DOC_Destinatari CD  
inner join ctl_doc C on C.id=CD.idHeader and tipodoc='BANDO_FABBISOGNI'
inner join CTL_DOC_Value  CV on CV.IdHeader=CD.idHeader and DSE_ID='TESTATA_PRODOTTI'
GO
