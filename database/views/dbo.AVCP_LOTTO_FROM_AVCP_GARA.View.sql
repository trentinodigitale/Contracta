USE [AFLink_TND]
GO
/****** Object:  View [dbo].[AVCP_LOTTO_FROM_AVCP_GARA]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[AVCP_LOTTO_FROM_AVCP_GARA] as 
select 
	id as ID_FROM,
	Fascicolo,
	Versione as LinkedDoc,
	'AVCP_LOTTO' as tipoDoc,
	0 as Versione
from CTL_DOC
where tipodoc='AVCP_GARA'



GO
