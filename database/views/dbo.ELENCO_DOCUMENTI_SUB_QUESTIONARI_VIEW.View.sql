USE [AFLink_TND]
GO
/****** Object:  View [dbo].[ELENCO_DOCUMENTI_SUB_QUESTIONARI_VIEW]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[ELENCO_DOCUMENTI_SUB_QUESTIONARI_VIEW] as
select 
	CA.*,
	c1.id as linkeddoc
from ctl_doc c1
inner join ctl_doc c2 on c2.id=c1.linkeddoc
inner join CTL_DOC_ALLEGATI CA on c2.id=CA.idheader
GO
