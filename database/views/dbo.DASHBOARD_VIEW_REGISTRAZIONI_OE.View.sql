USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_REGISTRAZIONI_OE]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE view [dbo].[DASHBOARD_VIEW_REGISTRAZIONI_OE] as
select 
		id,
		idpfu,
		case when idpfuIncharge = 0 then null else idpfuIncharge end as idpfuIncharge,
		Protocollo,
		DataInvio,
		Statofunzionale,
		aziragionesociale ,
		titolo,
		JumpCheck
from CTL_DOC
	inner join aziende on azienda=idazi and isnull(daValutare,0) <= 1 and aziDeleted = 0
where tipoDoc in ( 'VERIFICA_REGISTRAZIONE','VERIFICA_REGISTRAZIONE_FORN')




GO
