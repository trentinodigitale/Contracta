USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_Esito_Valutazione_Forn]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[DASHBOARD_VIEW_Esito_Valutazione_Forn]
as

select 
IdCom, Owner, Name, IdAzienda, DataCreazione, Protocollo, StatoCom, Obbligo, DataObbligo, BloccoAccesso, DataScadenzaCom, TipologiaAllegati, Note, TipoComunicazione, Deleted, a.idrow,
IdAzienda as idazi2,aziragionesociale as ragsoc,
'ESITO_QUALIFICAZIONE' as open_doc_name,idcom as idmsg,b.idHeader as idbando,DataCreazione as DataInvio

from Document_Esito_Qualificazione a

inner join aziende on idazi=IdAzienda

left outer join Document_Questionario_Fornitore_Punteggi b on a.idrow=b.idrow

where deleted=0





GO
