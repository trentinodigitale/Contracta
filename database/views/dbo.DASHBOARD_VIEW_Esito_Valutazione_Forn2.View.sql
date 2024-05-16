USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_Esito_Valutazione_Forn2]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[DASHBOARD_VIEW_Esito_Valutazione_Forn2]
as

select 
IdCom, Owner, Name, IdAzienda, DataCreazione, Protocollo, StatoCom, Obbligo, DataObbligo, BloccoAccesso, DataScadenzaCom, TipologiaAllegati, Note, TipoComunicazione, Deleted, a.idrow,
IdAzienda as idazi2,aziragionesociale as ragsoc,
'ESITO_QUALIFICAZIONE' as open_doc_name,idcom as idmsg,
ProfiliUtente.idpfu,
b.idHeader as idbando,DataCreazione as DataInvio

,case when l.DOC_NAME is not null then '0' else '1'end as bRead 

from Document_Esito_Qualificazione a

inner join aziende on idazi=IdAzienda
inner join ProfiliUtente on pfuidazi=idazi

left outer join Document_Questionario_Fornitore_Punteggi b on a.idrow=b.idrow

left outer join CTL_DOC_READ as l  with(NOLOCK) on profiliutente.idpfu=l.idpfu and idcom=l.id_Doc 
		and l.DOC_NAME = 'ESITO_QUALIFICAZIONE'

where deleted=0



GO
