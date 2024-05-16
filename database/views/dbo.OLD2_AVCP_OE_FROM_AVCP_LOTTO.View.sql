USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_AVCP_OE_FROM_AVCP_LOTTO]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[OLD2_AVCP_OE_FROM_AVCP_LOTTO] as
select
	versione as ID_FROM,
	Versione as LinkedDoc,
	id,
	'AVCP-'+Versione as Fascicolo,
	'InLavorazione' as StatoFunzionale
from ctl_doc
where tipodoc in ('AVCP_LOTTO','AVCP_GARA')


GO
