USE [AFLink_TND]
GO
/****** Object:  View [dbo].[MAIL_RITIRA_RISPOSTA_CONCORSO]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









CREATE view [dbo].[MAIL_RITIRA_RISPOSTA_CONCORSO] as
select
	
	d.id as iddoc
	,lngSuffisso as LNG

	--, a.aziRagionesociale as RagioneSociale
	,case
		when isnull(AN.Value,'0') = '1'
			then a.aziRagionesociale
		else
			'ANONIMO'
	 end as RagioneSociale

	, isnull( ML_Description , DOC_DescML ) as TipoDoc
	
	, d.TipoDoc as TipoDocumento

	, ISNULL(d.Body,d.note) as body

	--, d.Protocollo
	,case
		when isnull(AN.Value,'0') = '1'
			then d.Protocollo
		else
			'ANONIMO'
	 end as Protocollo

	, convert( varchar , d.DataInvio , 103 ) as DataInvio
	, convert( varchar , d.DataInvio , 108 ) as OraInvio

	, D.ProtocolloRiferimento
	--,case
	--	when isnull(AN.Value,'0') = '1'
	--		then D.ProtocolloRiferimento
	--	else
	--		null
	-- end as ProtocolloRiferimento

	, d.Fascicolo
	, SUBSTRING(Programma, 5, 500) as StrutturaAziendale
	, convert( varchar , getdate() , 103 ) as DataOperazione
	, Descrizione as DescrizioneStruttura 

	,p.pfuNome
	,p.pfuE_mail

	,
	
	case
		when isnull(AN.Value,'0') = '1'
			then d.Titolo
		else
			'ANONIMO'
	 end as Titolo
	--d.Titolo
	

	, d.[GUID]

	--, A2.aziRagionesociale as Fornitore
	,case
		when isnull(AN.Value,'0') = '1'
			then A2.aziRagionesociale
		else
			'ANONIMO'
	 end as Fornitore

	, A3.aziRagionesociale as fornitoreistanza
	--,case
	--	when isnull(AN.Value,'0') = '1'
	--		then A3.aziRagionesociale
	--	else
	--		null
	-- end as fornitoreistanza

	, B.ProtocolloBando
	--,case
	--	when isnull(AN.Value,'0') = '1'
	--		then B.ProtocolloBando
	--	else
	--		null
	-- end as ProtocolloBando
	   
	, A2.aziRagionesociale as AziendaMitt
	--,case
	--	when isnull(AN.Value,'0') = '1'
	--		then A2.aziRagionesociale
	--	else
	--		null
	-- end as AziendaMitt

	, d.note as Testocomuicazione
	
	
	--, d.Titolo as Oggettogara

	,case
		when isnull(AN.Value,'0') = '1'
			then d.Titolo
		else
			'ANONIMO'
	 end as Oggettogara

	, DMV_DescML as StatoFunzionale
	, d.note

	, A3.aziRagioneSociale as RagioneSocialeDestinatario
	--,case
	--	when isnull(AN.Value,'0') = '1'
	--		then A3.aziRagionesociale
	--	else
	--		null
	-- end as RagioneSocialeDestinatario

	, case 
			when A3.azivenditore <> 0 then 'Operatore Economico'
			when A3.aziacquirente <> 0 then 'Ente'
	  end as TipoAziendaDestinatario
    
	,
	case 
			when A2.azivenditore <> 0 then 'Operatore Economico'
			when A2.aziacquirente <> 0 then 'Ente'
	  end as TipoAziendaMittente
	


	, b.cig
	, '' as Attach_Grid

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

	--recupero dal bando il flag sull'anonimato
	left join CTL_DOC_VALUE AN on d2.id = AN.idheader and DSE_ID = 'ANONIMATO' and DZT_Name = 'DATI_IN_CHIARO'
	   






GO
