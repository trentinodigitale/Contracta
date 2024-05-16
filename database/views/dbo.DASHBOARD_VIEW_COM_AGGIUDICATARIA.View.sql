USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_COM_AGGIUDICATARIA]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[DASHBOARD_VIEW_COM_AGGIUDICATARIA] as
--Versione=2&data=2013-08-29&Attvita=43317&Nominativo=enrico
select a.*, (ImportoAggiudicato+OneriSic+OneriSicE+OneriSicI+OneriDis+LavoriEconomia) as ValoreContratto,
case  when right(a.Protocol, 2) = '07'  and a.Protocol <> '053/2007' then 'Archiviato'
	when isnull( r.StatoRepertorio , '' ) = '' then 'InCorso'
		else r.StatoRepertorio 
	end as StatoRepertorio
	,t.tipoappalto
	,t.proceduragara 
 from Document_Com_Aggiudicataria a left join tab_messaggi_fields t on idmsg=id_msg_bando
			left outer join Document_Repertorio r on r.ProtocolloBando = a.Protocol and r.idaggiudicatrice = a.idaggiudicatrice
GO
