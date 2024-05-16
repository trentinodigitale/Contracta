USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_MAIL_RITIRA_OFFERTA]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE  view [dbo].[OLD2_MAIL_RITIRA_OFFERTA] as
select
	
	d.id as iddoc
	,lngSuffisso as LNG
	, a.aziRagionesociale as RagioneSociale
	, isnull( ML_Description , DOC_DescML ) as TipoDoc

	
	, d.TipoDoc as TipoDocumento

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

	,p.pfuNome
	,p.pfuE_mail
	,d.Titolo	
	, d.[GUID]
	, A2.aziRagionesociale as Fornitore
	, A3.aziRagionesociale as fornitoreistanza
	, B.ProtocolloBando
	   
	, A2.aziRagionesociale as AziendaMitt
	, d.note as Testocomuicazione
	, d.Titolo as Oggettogara

	, DMV_DescML as StatoFunzionale
	, d.note
	, A3.aziRagioneSociale as RagioneSocialeDestinatario
	, case 
			when A3.azivenditore <> 0 then 'Operatore Economico'
			when A3.aziacquirente <> 0 then 'Ente'
	  end as TipoAziendaDestinatario
     
	, b.cig
	, '' as Attach_Grid
	,case 
         when A.azivenditore <> 0 then 'Operatore Economico'
         when A.aziacquirente <> 0 then 'Ente'
     end as TipoAziendaMittente
from ctl_doc d
	cross join Lingue
	left join profiliutente p on p.idpfu = d.idpfu
	left join aziende a on a.idazi = p.pfuidazi
	inner join LIB_Documents on DOC_ID = TipoDoc
	left outer join LIB_Multilinguismo on DOC_DescML = ML_KEY and ML_Context = 0 and ML_LNG = lngSuffisso
	left outer join peg on '35152001#\0000\0000\00' + CodProgramma = StrutturaAziendale
	left outer join AZ_STRUTTURA az on cast( idaz as varchar ) + '#' + Path = StrutturaAziendale
	left join aziende A2 on d.azienda=A2.idazi
	left join aziende A3 on d.Destinatario_azi=A3.idazi
	left join LIB_DomainValues on d.statofunzionale=DMV_Cod and DMV_DM_ID='StatoFunzionale'
	--vado inleft join sul bando
	left join ctl_doc d2 on d2.id=d.LinkedDoc
	left join document_bando B on B.idheader=d2.linkeddoc
	   






GO
