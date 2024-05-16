USE [AFLink_TND]
GO
/****** Object:  View [dbo].[CONFIGURAZIONE_MONITOR_EVENTI_DETTAGLI_FROM_USER]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[CONFIGURAZIONE_MONITOR_EVENTI_DETTAGLI_FROM_USER] as
select
	p.idpfu as ID_FROM,
	D.*
	
from 
	ctl_doc with (nolock)
		inner join Document_Configurazione_Monitor_Tipologie  D with (nolock) on id=D.idheader and D.deleted=0
		cross join profiliUtente p with (nolock)
where  
		tipodoc='CONFIGURAZIONE_MONITOR_EVENTI' 
		and statofunzionale='confermato'


GO
