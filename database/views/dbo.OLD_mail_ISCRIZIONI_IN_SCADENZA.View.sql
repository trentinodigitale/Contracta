USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_mail_ISCRIZIONI_IN_SCADENZA]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [dbo].[OLD_mail_ISCRIZIONI_IN_SCADENZA]
AS
	SELECT   -- g.*,
		p.IdHeader,
		p.IdRow as IDDOC, 
		'I' as LNG,
		
		case 
			
			when b.TipoDoc = 'BANDO' and  isnull(b.JumpCheck,'')='' then 'al Mercato Elettronico'
			when b.TipoDoc = 'BANDO' and  isnull(b.JumpCheck,'')='BANDO_ALBO_LAVORI' then 'al Bando Istitutivo Lavori Pubblici'
			when b.TipoDoc = 'BANDO_SDA' then 'al Sistema Dinamico di Acquisizione'
			else 'al Bando'

		end as TipoBando,
		
		case when StatoIscrizione = 'Iscritto' then 'in scadenza' else 'scaduta' end as  StatoScadenza ,
		convert( varchar , DataScadenzaIscrizione , 103 ) as DataScadenzaIscrizione , 
		
		case 
			when b.TipoDoc = 'BANDO' then  b.ProtocolloGenerale
			when b.TipoDoc = 'BANDO_SDA' then g.ProtocolloBando
			else ''
		end as ProtocolloBando ,
		isnull( d.Protocollo ,'' ) as Protocollo ,
		isnull( convert( varchar , d.DataInvio , 103 ) , '' )  as DataInvio, 
		b.Body as Titolo ,
		
		case 
			when b.TipoDoc = 'BANDO' then  'abilitazione'
			when b.TipoDoc = 'BANDO_SDA' then 'abilitazione'
			else 'iscrizione'
		end as registrazione

		--, p.aziRagioneSociale

		, isnull(a.aziRagioneSociale,p.aziRagioneSociale) as  aziRagioneSociale

		, case when b.TipoDoc = 'BANDO_SDA' 	then b.TipoDoc

				else --PER L'ALBO. TIPO DOC 'BANDO'

						case when isnull( b.JumpCheck,'') = 'BANDO_ALBO_FORNITORI' then b.JumpCheck 
							 when isnull( b.JumpCheck,'') = 'BANDO_ALBO_LAVORI' then b.JumpCheck 
							 when isnull( b.JumpCheck,'') = 'BANDO_ALBO_PROFESSIONISTI' then b.JumpCheck 
							 else 'BANDO_ME'
						end

		  end as TipoDocumento

	from CTL_DOC_Destinatari p with(nolock)
		  left outer join aziende a on a.idazi=p.idazi
			left outer join CTL_DOC d with(nolock) on d.id = p.id_doc
			inner join CTL_DOC b with(nolock) on b.id = p.idheader
			inner join document_bando g with(nolock) on g.idheader = b.id



GO
