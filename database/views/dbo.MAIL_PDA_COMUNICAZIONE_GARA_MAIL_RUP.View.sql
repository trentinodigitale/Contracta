USE [AFLink_TND]
GO
/****** Object:  View [dbo].[MAIL_PDA_COMUNICAZIONE_GARA_MAIL_RUP]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[MAIL_PDA_COMUNICAZIONE_GARA_MAIL_RUP] as
select
	
	d.id as iddoc
	, lngSuffisso as LNG
	, a.aziRagionesociale as RagioneSociale
	, case when d.TipoDoc = 'PDA_COMUNICAZIONE_RISP' then d.Titolo else isnull( ML_Description , DOC_DescML ) end as TipoDoc

	--, case when jumpcheck='0-VERIFICA_REGISTRAZIONE_FORN' then 'VERIFICA_REGISTRAZIONE' else TipoDoc end as TipoDocumento
	, 'PDA_COMUNICAZIONE_GARA_MAIL_RUP' as TipoDocumento

	, ISNULL(d.Body,d.note) as body
	--, Body as Object_Cover1
	, d.Protocollo
	, convert( varchar , d.DataInvio , 103 ) as DataInvio
	, convert( varchar , d.DataInvio , 108 ) as OraInvio

	, D.ProtocolloRiferimento
	, d.Fascicolo
	, SUBSTRING(Programma, 5, 500) as StrutturaAziendale
	, convert( varchar , getdate() , 103 ) as DataOperazione
	, Descrizione as DescrizioneStruttura 

	, p.pfuNome
	, p.pfuE_mail
	, d.Titolo	
	, d.GUID
	, A2.aziRagionesociale as Fornitore
	, A3.aziRagionesociale as fornitoreistanza
	--, isnull(COM_CAPOGRUPPO.ProtocolloRiferimento,'') as ProtocolloBando
	, coalesce( ba.Protocollo, COM_CAPOGRUPPO.ProtocolloRiferimento ,'') as ProtocolloBando
	, A2.aziRagionesociale as AziendaMitt
	, d.note as Testocomuicazione
	--, case when isnull( cast(COM_CAPOGRUPPO.Body as varchar(max)),'') <> '' then isnull(COM_CAPOGRUPPO.Body,'')
	, case when coalesce( cast(ba.Body as varchar(max)),cast(COM_CAPOGRUPPO.Body as varchar(max)),'') <> '' then isnull(ba.Body,'')
		else d.Titolo
	  end  as Oggettogara
	, DMV_DescML as StatoFunzionale
	, d.note
	, A3.aziRagioneSociale as RagioneSocialeDestinatario
	, case 
			when A3.azivenditore <> 0 then 'Operatore Economico'
			when A3.aziacquirente <> 0 then 'Ente'
	  end as TipoAziendaDestinatario

	  , b.cig

	, case 
			when A2.azivenditore <> 0 then 'Operatore Economico'
			when A2.aziacquirente <> 0 then 'Ente'
	  end as TipoAziendaMittente
	, '' as Attach_Grid

from ctl_doc d with(nolock) 
	cross join Lingue with(nolock) 
	left outer join profiliutente p  with(nolock) on p.idpfu = d.idpfu
	left outer join aziende a  with(nolock) on a.idazi = p.pfuidazi
	inner join LIB_Documents  with(nolock) on DOC_ID = TipoDoc
	left outer join LIB_Multilinguismo  with(nolock) on DOC_DescML = ML_KEY and ML_Context = 0 and ML_LNG = lngSuffisso
	left outer join peg  with(nolock) on '35152001#\0000\0000\00' + CodProgramma = StrutturaAziendale
	left outer join AZ_STRUTTURA az  with(nolock) on cast( idaz as varchar ) + '#' + Path = StrutturaAziendale
	left outer join aziende A2  with(nolock) on d.azienda=A2.idazi
	left outer join aziende A3  with(nolock) on d.Destinatario_azi=A3.idazi
	left outer join LIB_DomainValues  with(nolock) on d.statofunzionale=DMV_Cod and DMV_DM_ID='StatoFunzionale'

	--per aggiungere per le nuove comunicazioni PDA_COMUNICAZIONE_GARA il protocollobando 
	--che sta sulla capogruppo in protocolloriferimento
	--left outer join (
	--	select id,protocolloriferimento,Body, Titolo  from ctl_doc  with(nolock) where tipodoc in ('PDA_COMUNICAZIONE','PROROGA_GARA','PDA_COMUNICAZIONE_GENERICA')
	--) COM_CAPOGRUPPO on COM_CAPOGRUPPO.id=D.linkeddoc and D.tipodoc='PDA_COMUNICAZIONE_GARA'

	left outer join ctl_doc  COM_CAPOGRUPPO with(nolock) on COM_CAPOGRUPPO.tipodoc in ('PDA_COMUNICAZIONE','PROROGA_GARA','PDA_COMUNICAZIONE_GENERICA')
															and COM_CAPOGRUPPO.id=D.linkeddoc and D.tipodoc='PDA_COMUNICAZIONE_GARA'


	--vado inleft join sul bando per le offerte
	--left join document_bando B on B.idheader=d.linkeddoc and d.tipodoc in ( 'OFFERTA', 'MANIFESTAZIONE_INTERESSE' )

	-- salgo sul bando dal fascicolo per rendere più generico l'utilizzo
	left outer join CTL_DOC ba with(nolock) on ba.Fascicolo = d.Fascicolo and ba.Deleted = 0 and ba.TipoDoc in ( 'BANDO' , 'BANDO_SDA' , 'BANDO_GARA' , 'BANDO_SEMPIFICATO' , 'BANDO_ASTA' )
	left outer join document_bando B on B.idheader=ba.id








GO
