USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_MSG_LINKED_COMUNICAZIONI_ALBO]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE  view [dbo].[OLD_MSG_LINKED_COMUNICAZIONI_ALBO] as
select  
	  a.id 
	, p.idpfu
    , '' AS msgIType
	, ''  AS msgISubType
    , Titolo as Name
--	, 0 as bread
	,case when r.DOC_NAME is not null then '0' else '1'end as bRead 
	, cast(a.body as nvarchar(4000)) as Oggetto	
    , ProtocolloRiferimento AS ProtocolloBando   
	, a.Fascicolo       
    , Protocollo as ProtocolloOfferta
    ,  case statodoc 
		when 'saved' then '1' 
		else '2' 
	  end  as StatoGD
	, '' as AdvancedState
    , convert(varchar(20),a.DataInvio , 20 ) as ReceivedDataMsg
    , a.idpfu  as IdMittente
    , '0' as Cifratura
    , '' as azipartitaiva
    , '' as idAziPartecipante
	, TipoDoc as DocType
    , StatoDoc as  StatoCollegati
    , TipoDoc as OPEN_DOC_NAME
	,DataInvio
 
from ctl_doc as a
	inner join profiliutente p on p.pfuidazi = a.Destinatario_Azi or a.idpfu = p.idpfu 
	left outer join CTL_DOC_READ r on  DOC_NAME = a.tipoDoc  and id_Doc = a.Id   and p.idPfu = r.idPfu --and a.idpfu <> p.idpfu
where TipoDoc in ( 'CONFERMA_ISCRIZIONE' , 'SCARTO_ISCRIZIONE' , 'INTEGRA_ISCRIZIONE' , 'INTEGRA_ISCRIZIONE_RIS','CONFERMA_ISCRIZIONE_SDA','INTEGRA_ISCRIZIONE_SDA'
					,'INTEGRA_ISCRIZIONE_RIS_SDA','SCARTO_ISCRIZIONE_SDA','PDA_COMUNICAZIONE_GARA','CONFERMA_ISCRIZIONE_LAVORI','SCARTO_ISCRIZIONE_LAVORI')
	and ( a.Statodoc <> 'Saved' or TipoDoc in ( 'INTEGRA_ISCRIZIONE_RIS','INTEGRA_ISCRIZIONE_RIS_SDA' ))



GO
