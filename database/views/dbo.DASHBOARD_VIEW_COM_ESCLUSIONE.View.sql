USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_COM_ESCLUSIONE]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE view [dbo].[DASHBOARD_VIEW_COM_ESCLUSIONE] as
--Versione=3&data=2013-09-18&Attvita=45654&Nominativo=enrico
select 
	e.id, convert( varchar(19) , e.DataCreazione , 126 ) as DataCreazione , e.ID_MSG_PDA, e.ID_MSG_BANDO, e.StatoEsclusione, convert(nvarchar(4000) ,e.Oggetto) as Oggetto  , 
	convert( varchar(19) , e.DataAperturaOfferte , 126 ) as DataAperturaOfferte , 
	convert( varchar(19) , e.DataIISeduta , 126 ) as DataIISeduta, e.Segretario, e.Protocol, e.StatoGara, e.Versione, e.Fascicolo,
	case  when RIGHT(e.Protocol, 2) = '07'  and e.Protocol <> '053/2007' then 'Archiviato'
                       when isnull( r.StatoRepertorio , '' ) = '' then 'InCorso'
		else r.StatoRepertorio 
	end as StatoRepertorio ,
	'ESCLUSI_BANDO' as OPEN_DOC_NAME
	,t.tipoappalto
	,t.proceduragara
from Document_Esclusione e left join tab_messaggi_fields t on idmsg=id_msg_bando
	left outer join Document_Repertorio r on r.ProtocolloBando = e.Protocol
  

union all
--tutti i bandi per cui esiste una com di esclusione non invalidata
select 
	CD.linkeddoc, 
	TMF.Data as DataCreazione,
	CD.LinkedDoc as ID_MSG_PDA,
	0 as ID_MSG_BANDO,
	CD.statodoc as StatoEsclusione, 
	TMF.Object_Cover1 as Oggetto,
	TMF.DataAperturaOfferte,
	TMF.DataIISeduta,
	'' as Segretario,
	TMF.ProtocolloBando , 
	'' as StatoGara, 
	'' as Versione, 
	TMF.ProtocolBG as Fascicolo,
	case  
		when RIGHT(TMF.ProtocolloBando, 2) = '07'  and TMF.ProtocolloBando <> '053/2007' then 'Archiviato'
        when isnull( r.StatoRepertorio , '' ) = '' then 'InCorso'
		else r.StatoRepertorio 
	end as StatoRepertorio,
	'CheckTypeViewer.asp?AreaFiltro=no&Table=DASHBOARD_VIEW_COMUNICAZIONI_ENTE&OWNER=&IDENTITY=IdCom&TOOLBAR=DASHBOARD_VIEW_COMUNICAZIONI_ENTE_TOOLBAR&DOCUMENT=PDA_COMUNICAZIONE&PATHTOOLBAR=&AreaAdd=no&Caption=Lista Comunicazioni PDA&Height=120,100*,210&numRowForPag=20&Sort=DataCreazione&SortOrder=desc&FilterHide=jumpcheck like ''%25-ESCLUSIONE%25'' and linkeddoc=' + convert(varchar,CD.linkeddoc) + '&ACTIVESEL=1&Exit=si&JScriptSingleViewer=OpenDocSingleViewer' as OPEN_DOC_NAME
	,TMF.tipoappalto
	,TMF.proceduragara
from 
	tab_messaggi_fields TMF 
		inner join  ( select distinct statodoc,fascicolo,linkeddoc from ctl_doc where tipodoc='PDA_COMUNICAZIONE' and jumpcheck like '%ESCLUSIONE' and statodoc<>'Invalidate') CD
			on TMF.idmsg=CD.linkeddoc 
		left outer join Document_Repertorio r on r.ProtocolloBando = TMF.Protocollobando
GO
