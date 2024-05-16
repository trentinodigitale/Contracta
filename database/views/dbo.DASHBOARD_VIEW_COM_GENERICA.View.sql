USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_COM_GENERICA]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[DASHBOARD_VIEW_COM_GENERICA] as
--Versione=2&data=2013-08-29&Attvita=43317&Nominativo=enrico
select 	e.* 
,	case when (RIGHT(e.Protocol, 2) = '07'  and e.Protocol <> '053/2007') or e.Protocol = '006/2008' then  'Archiviato' 
		when isnull( r.StatoRepertorio , '' ) = '' then 'InCorso'
		else r.StatoRepertorio 
	end as StatoRepertorio 
	, t.tipoappalto
	,t.proceduragara
from Document_Comunicazione e left join tab_messaggi_fields T on id_msg_bando=idmsg
			left outer join Document_Repertorio r on r.ProtocolloBando = e.Protocol
GO
