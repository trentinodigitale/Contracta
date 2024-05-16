USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_DASHBOARD_VIEW_REGISTRAZIONI_OE]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[OLD2_DASHBOARD_VIEW_REGISTRAZIONI_OE] as
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
inner join aziende on azienda=idazi
where tipoDoc in ( 'VERIFICA_REGISTRAZIONE','VERIFICA_REGISTRAZIONE_FORN')


GO
