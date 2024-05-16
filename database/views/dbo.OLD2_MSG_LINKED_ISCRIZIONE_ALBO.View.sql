USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_MSG_LINKED_ISCRIZIONE_ALBO]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[OLD2_MSG_LINKED_ISCRIZIONE_ALBO]  AS
--Versione=2&data=2012-12-17&Attivita=40053&Nominativo=Sabato
--Versione=3&data=2014-02-13&Attivita=50092&Nominativo=Sabato
--Versione=5&data=2014-02-25&Attivita=53377&Nominativo=Enrico
--Versione=6&data=2015-02-26&Attivita=70503&Nominativo=Enrico
--Versione=7&data=2016-01-21&Attivita=97053&Nominativo=Enrico

-----------------------------------------------------
 --aggiunge i nuovi quesiti sui Documenti BANDO E BANDO_SDA
-----------------------------------------------------

  select  
	a.id AS IdMsg
	, az.idpfu
    , '' AS msgIType
	, ''  AS msgISubType
    , a.aziragionesociale as Name
	, 0 as bread
	, a.domanda as Oggetto	
    , a.ProtocolloBando
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
	, '' as TipoBandoGara

 from CHIARIMENTI_PORTALE_BANDO a with(nolock)
	inner join CTL_DOC CT with(nolock) on a.ID_ORIGIN=CT.ID and ct.tipodoc=document
	inner join  profiliutente b with(nolock) on b.idpfu=a.utentedomanda
	inner join  profiliutente az with(nolock) on b.pfuidazi = az.pfuidazi
	left outer join ProfiliUtenteAttrib pa with(nolock) on pa.idpfu = az.idpfu and dztnome = 'Profilo' and attvalue = 'ACCESSO_DOC_OE'
 where 
	CT.idpfu = az.idpfu or CT.idpfuincharge = az.idpfu or pa.idpfu is not null or a.utentedomanda = az.idpfu

-----------------------------------------------------
--aggiunge i nuovi bandi e istanze di iscrizione
-----------------------------------------------------
  union all

  select  
	d.id AS IdMsg
	, p.idpfu
    , '' AS msgIType
	, ''  AS msgISubType
    --, aziragionesociale as Name
   , case 
		when TipoDoc in ('BANDO_SDA' ) then cast(M.ML_DESCRIPTION as nvarchar(4000))
		when TipoDoc = 'BANDO' and isnull(caption,'')='' then cast(M.ML_DESCRIPTION as nvarchar(4000))
		when TipoDoc = 'BANDO' and isnull(caption,'')<>'' then cast(M1.ML_DESCRIPTION as nvarchar(4000))
		else titolo  
     end  as Name
	, 0 as bread
	, cast(d.body as nvarchar(4000)) as Oggetto	
    , case when TipoDoc in ( 'BANDO_SEMPLIFICATO' , 'BANDO_GARA' ) then ProtocolloBando 
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
	, case TipoDoc 
		when 'BANDO_SEMPLIFICATO' then 'BANDO_SEMPLIFICATO_INVITO' 
		else TipoDoc  
		end as DocType
    , 'Received' as  StatoCollegati
	, case TipoDoc 
		when 'BANDO_SEMPLIFICATO' then 'BANDO_SEMPLIFICATO_INVITO' 
		else TipoDoc  
		end as OPEN_DOC_NAME
    , case when TipoDoc in ('BANDO','BANDO_SDA' ,'BANDO_GARA'  , 'BANDO_ASTA' ) then 'BANDO' 
		else TipoDoc  
		end as Folder 
	, '' as TipoBando
	, b.TipoBandoGara

from CTL_DOC d with(nolock)
	inner join CTL_DOC_DESTINATARI with(nolock) on CTL_DOC_DESTINATARI.idheader = d.Id
	inner join profiliutente p with(nolock) on  p.pfuidazi = CTL_DOC_DESTINATARI.IdAzi
	inner join document_bando b with(nolock) on  b.idheader = d.id
	inner join aziende a with(nolock) on a.idazi = d.azienda
	left outer join dbo.LIB_Documents L with(nolock) on L.DOC_ID=d.TipoDoc
	left join LIB_MULTILINGUISMO M with(nolock) on M.ML_KEY=L.DOC_DescML and M.ML_LNG='I' and M.ML_Context=0
	left join LIB_MULTILINGUISMO M1 with(nolock) on M1.ML_KEY=d.caption and M1.ML_LNG='I'and M1.ML_Context=0
where 
	TipoDoc in ('BANDO','BANDO_SDA' , 'BANDO_SEMPLIFICATO' , 'BANDO_GARA' , 'BANDO_ASTA', 'BANDO_CONCORSO') and deleted = 0


-----------------------------------------------------
--aggiunge le nuove istanze di iscrizione
-----------------------------------------------------
  union all

  select  
	  id AS IdMsg
	, u.idpfu
    , '' AS msgIType
	, ''  AS msgISubType
    , Titolo as Name
	, 0 as bread
	, cast(d.body as nvarchar(4000)) as Oggetto	
    , ProtocolloRiferimento AS ProtocolloBando   
	, d.Fascicolo       
    , Protocollo as ProtocolloOfferta
    ,  case statodoc 
		when 'saved' then '1' 
		else '2' 
	  end  as StatoGD
	, '' as AdvancedState
    , convert(varchar(20),d.DataInvio , 20 ) as ReceivedDataMsg
    , d.idpfu  as IdMittente
    , '0' as Cifratura
    , '' as azipartitaiva
    , '' as idAziPartecipante
	, TipoDoc as DocType
    , StatoDoc as  StatoCollegati
    , TipoDoc as OPEN_DOC_NAME
    , case when TipoDoc in ( 'ISTANZA_SDA_FARMACI' ) then 'ISTANZA_SDA_FARMACI' 
		   when TipoDoc in ( 'ISTANZA_SDA_2' ) then 'ISTANZA_SDA_2' 
		   when TipoDoc in ( 'ISTANZA_SDA_3' ) then 'ISTANZA_SDA_3' 
		   when TipoDoc in ( 'ISTANZA_SDA_RP' ) then 'ISTANZA_SDA_RP' 
		   when TipoDoc in ( 'ISTANZA_SDA_IC' ) then 'ISTANZA_SDA_IC' 
		else '12_177' 
		end as Folder
	, '' as TipoBando
	, '' as TipoBandoGara
from CTL_DOC d with(nolock)
		inner join ProfiliUtente p with(nolock) on d.idpfu = p.idpfu
		inner join ProfiliUtente u with(nolock) on u.pfuidazi = p.pfuidazi
		left outer join ProfiliUtenteAttrib pa with(nolock) on pa.idpfu = u.idpfu and dztnome = 'Profilo' and attvalue = 'ACCESSO_DOC_OE'
where  
	(	TipoDoc in ( 'ISTANZA_AlboOperaEco','ISTANZA_SDA_FARMACI','ISTANZA_SDA_2','ISTANZA_SDA_3','ISTANZA_SDA_RP','ISTANZA_SDA_IC' ) 
		or left( TipoDoc,16 ) = 'ISTANZA_AlboProf' or left( TipoDoc,15 ) = 'Istanza_Albo_ME'  or left( TipoDoc,18 ) = 'ISTANZA_AlboLavori'  or left( TipoDoc,21 ) = 'ISTANZA_AlboFornitori'  
	)	
	and ( d.idpfu = u.idpfu or d.idpfuincharge = u.idpfu or pa.idpfu is not null  )
	and deleted = 0
	

-----------------------------------------------------
--aggiunge le nuove comunicazioni alla lista dei documenti collegati
-----------------------------------------------------
  union all

 select 
	[IdMsg], [idpfu], [msgIType], [msgISubType], [Name], [bread], [Oggetto], [ProtocolloBando], [Fascicolo], [ProtocolloOfferta], [StatoGD], [AdvancedState], [ReceivedDataMsg], [IdMittente], [Cifratura], [azipartitaiva], [idAziPartecipante], [DocType], [StatoCollegati], [OPEN_DOC_NAME], [Folder], [TipoBando]
	,[TipoBandoGara]
	from 
	VIEW_OFFERTE_COMUNICAZIONI_CONTRATTI




GO
