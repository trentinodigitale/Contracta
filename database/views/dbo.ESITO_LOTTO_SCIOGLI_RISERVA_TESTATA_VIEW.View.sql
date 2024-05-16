USE [AFLink_TND]
GO
/****** Object:  View [dbo].[ESITO_LOTTO_SCIOGLI_RISERVA_TESTATA_VIEW]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[ESITO_LOTTO_SCIOGLI_RISERVA_TESTATA_VIEW] as 
select 
	*,
	ISNULL(CV.value,'') as EsitoRiserva
from ctl_doc C
	left join CTL_DOC_Value CV on CV.idheader=C.id and cv.DSE_ID='SAVE' and CV.DZT_Name='EsitoRiserva'

GO
