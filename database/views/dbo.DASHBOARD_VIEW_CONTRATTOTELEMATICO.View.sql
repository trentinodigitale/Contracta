USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_CONTRATTOTELEMATICO]    Script Date: 5/16/2024 2:45:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[DASHBOARD_VIEW_CONTRATTOTELEMATICO] as
--Versione=3&data=2014-05-27&Attvita=57969&Nominativo=Marco
select 
C.*,
A.DirProponente,A.NomeProponente,
case 
	when isnull( E.DataIISeduta , '' ) = '' then  E.DataAperturaOfferte
	else E.DataIISeduta
end as DataVerbale ,
A.NRDeterminazione,A.DataDetermina,
S.DataUltimoInvioCom,
A.importoBaseAsta,A.ImportoAggiudicato,A.ValutazioneEconomica,
A.OneriSic,A.OneriSicE,A.OneriSicI,A.OneriDis,
A.LavoriEconomia,(A.ImportoAggiudicato+A.OneriSic+A.OneriSicE+A.OneriSicI+A.OneriDis+A.LavoriEconomia) as ValoreContratto,
P.Dataindizione,P.NumeroIndizione,
case  when right(a.Protocol, 2) = '07'  and a.Protocol <> '053/2007' then 'Archiviato'
	when isnull( r.StatoRepertorio , '' ) = '' then 'InCorso'
		else r.StatoRepertorio 
	end as StatoRepertorio ,
A.rup
,t.tipoappalto
,t.proceduragara
from 
Document_ContrattoTelematico C ,
Document_EsitoGara E, 
DASHBOARD_VIEW_PDA_LAVORI_CONTRATTO P,
Document_Com_Aggiudicataria A 
left outer join Document_Repertorio R on A.protocol = R.ProtocolloBando
left outer join Document_SchedaPrecontratto S on A.ID_MSG_PDA = S.ID_MSG_PDA
left join tab_messaggi_fields t on idmsg = S.id_msg_bando
where A.ID_MSG_PDA = C.ID_MSG_PDA and A.ID_MSG_PDA = E.ID_MSG_PDA 
and A.ID_MSG_PDA = P.IDMSG


GO
