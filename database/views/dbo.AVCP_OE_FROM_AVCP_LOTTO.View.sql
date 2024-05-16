USE [AFLink_TND]
GO
/****** Object:  View [dbo].[AVCP_OE_FROM_AVCP_LOTTO]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[AVCP_OE_FROM_AVCP_LOTTO] as
	select
		id,
		cast( versione as int ) as ID_FROM,
		cast( versione as int ) as LinkedDoc,
		'AVCP-' + cast(Versione as varchar(100)) as Fascicolo,
		'InLavorazione' as StatoFunzionale
	from ctl_doc with(nolock) 
	where isnumeric(versione) = 1 and not versione is null and tipodoc in ('AVCP_LOTTO','AVCP_GARA') 


GO
