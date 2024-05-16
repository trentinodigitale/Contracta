USE [AFLink_TND]
GO
/****** Object:  View [dbo].[AVCP_OE_OPERATORI_FROM_AVCP_GRUPPO]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create view [dbo].[AVCP_OE_OPERATORI_FROM_AVCP_GRUPPO] as
select 
	id as ID_FROM,
	document_avcp_partecipanti.*
from CTL_DOC
	left join document_avcp_partecipanti on id=idheader
 where tipodoc='AVCP_GRUPPO'

GO
