USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_ESITO]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[DASHBOARD_VIEW_ESITO] as
--Versione=2&data=2013-08-29&Attvita=43317&Nominativo=enrico
select d.*,
case when isnull( r.StatoRepertorio , '' ) = '' then 'InCorso'
		else r.StatoRepertorio 
	end as StatoRepertorio 
	,t.tipoappalto
	,t.proceduragara
from Document_Esito d
left outer join Document_Repertorio r on r.ProtocolloBando = Protocol
left join tab_messaggi_fields t on idmsg=id_msg_bando
GO
