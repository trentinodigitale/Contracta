USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_MSG_LINKED_CONSULTAZIONE_BANDO]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[OLD_MSG_LINKED_CONSULTAZIONE_BANDO]  AS




-----------------------------------------------------
 --aggiunge i nuovi quesiti sui Documenti BANDO
-----------------------------------------------------
 
  select  
	a.id AS IdMsg
	, b.idpfu
    , '' AS msgIType
	, ''  AS msgISubType
    , a.aziragionesociale as Name
	, 0 as bread
	, a.domanda as Oggetto	
    , CT.Protocollo as ProtocolloBando
	, a.Fascicolo       
    , Protocol as ProtocolloOfferta
    , '2' as StatoGD
	, '' as AdvancedState
    , convert(varchar(20),a.DataCreazione , 20 ) as ReceivedDataMsg
    , ''  as IdMittente
    , '0' as Cifratura
    , '' as azipartitaiva
    , '' as idAziPartecipante
	, 'DETAIL_CHIARIMENTI' as DocType
    , 'Sended' as  StatoCollegati
    --, 'NUOVIQUESITI' as tipo 
    , 'CHIARIMENTI_COLLEGATI' as OPEN_DOC_NAME
    , '' as Folder 
	, '' as TipoBando
 from Document_Chiarimenti a with (nolock) 
    inner join CTL_DOC CT with (nolock) on a.ID_ORIGIN=CT.ID
    inner join  profiliutente b with (nolock) on b.idpfu=a.utentedomanda
 

-----------------------------------------------------
--aggiunge i nuovi bandi_CONSULTAZIONE
-----------------------------------------------------
  union all

  select  
	d.id AS IdMsg
	, p.idpfu
    , '' AS msgIType
	, ''  AS msgISubType
    --, aziragionesociale as Name
   --, case when TipoDoc in ('BANDO_CONSULTAZIONE' ) then cast(M.ML_DESCRIPTION as nvarchar(4000))
	--	else titolo  
     --end  as Name
	, cast(M.ML_DESCRIPTION as nvarchar(max)) as Name
	, 0 as bread
	, cast(d.body as nvarchar(4000)) as Oggetto	
    , case when TipoDoc in ( 'BANDO_CONSULTAZIONE'  ) then Protocollo 
		else ProtocolloGenerale 
		end AS ProtocolloBando   
	, d.Fascicolo       
    , Protocollo as ProtocolloOfferta
    , '2' as StatoGD
	, '' as AdvancedState
    , convert(varchar(20),d.DataInvio , 20 ) as ReceivedDataMsg
    , d.idpfu  as IdMittente
    , '0' as Cifratura
    , '' as azipartitaiva
    , '' as idAziPartecipante
	,  TipoDoc as DocType
    , 'Received' as  StatoCollegati
	,  TipoDoc as OPEN_DOC_NAME
    ,  TipoDoc  as Folder 
	, '' as TipoBando
from CTL_DOC d  with (nolock) 
	inner join CTL_DOC_DESTINATARI  with (nolock) on CTL_DOC_DESTINATARI.idheader = d.Id
	inner join profiliutente p  with (nolock) on  p.pfuidazi = CTL_DOC_DESTINATARI.IdAzi
	inner join document_bando b  with (nolock) on  b.idheader = d.id
	inner join aziende a  with (nolock) on a.idazi = d.azienda
	left outer join dbo.LIB_Documents L  with (nolock) on L.DOC_ID=d.TipoDoc
	left join LIB_MULTILINGUISMO M  with (nolock) on M.ML_KEY=L.DOC_DescML and ML_LNG='I'
    where TipoDoc in ('BANDO_CONSULTAZIONE' ) and deleted = 0



-----------------------------------------------------
--aggiunge i nuovi documenti risposte consultazioni
-----------------------------------------------------
  union all

  select  
	  id AS IdMsg
	, ctl_doc.idpfu
    , '' AS msgIType
	, ''  AS msgISubType
    , Titolo as Name
	, 0 as bread
	, cast(CTL_DOC.body as nvarchar(4000)) as Oggetto	
    , ProtocolloRiferimento AS ProtocolloBando   
	, CTL_DOC.Fascicolo       
    , Protocollo as ProtocolloOfferta
    ,  case statodoc 
		when 'saved' then '1' 
		else '2' 
	  end  as StatoGD
	, '' as AdvancedState
    , convert(varchar(20),CTL_DOC.DataInvio , 20 ) as ReceivedDataMsg
    , ctl_doc.idpfu  as IdMittente
    , '0' as Cifratura
    , '' as azipartitaiva
    , '' as idAziPartecipante
	, TipoDoc as DocType
    , StatoDoc as  StatoCollegati
    , TipoDoc as OPEN_DOC_NAME
    , TipoDoc as Folder
	, '' as TipoBando

from CTL_DOC with (nolock) 
    where  TipoDoc in ( 'RISPOSTA_CONSULTAZIONE')
		  and deleted = 0
	


-----------------------------------------------------
--aggiunge le comunicazioni alla lista dei documenti collegati
-----------------------------------------------------
  union all

  select  
	 C.id AS IdMsg
	, ProfiliUtente.idpfu
	--,42745 as IdPfu
   , '' AS msgIType
	, ''  AS msgISubType
    , C.Titolo as Name
	, 0 as bread
	, cast(C.body as nvarchar(4000)) as Oggetto	
    , C.ProtocolloRiferimento AS ProtocolloBando   
	, C.Fascicolo       
    , C.Protocollo as ProtocolloOfferta
    ,  case C.statodoc 
		when 'saved' then '1' 
		else '2' 
	  end  as StatoGD
	, '' as AdvancedState
    , convert(varchar(20),C.DataInvio , 20 ) as ReceivedDataMsg
    , C.idpfu  as IdMittente
    , '0' as Cifratura
    , '' as azipartitaiva
    , '' as idAziPartecipante
	, C.TipoDoc as DocType
    , C.StatoDoc as StatoCollegati		
    , C.TipoDoc as OPEN_DOC_NAME
	,  C.TipoDoc  as Folder
	, '' as TipoBando
from CTL_DOC C with (nolock) 
	 inner join CTL_DOC R with (nolock) on R.Id=C.LinkedDoc and R.TipoDoc='RISPOSTA_CONSULTAZIONE'
     inner join ProfiliUtente  with (nolock) on ( C.Destinatario_azi=pfuidazi or C.azienda = pfuidazi ) 
    where ( C.TipoDoc in ( 'PDA_COMUNICAZIONE_GARA' ) and C.StatoDoc='Sended' )	
	    and C.deleted = 0


GO
