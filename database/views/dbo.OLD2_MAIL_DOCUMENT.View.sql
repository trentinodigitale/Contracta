USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_MAIL_DOCUMENT]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE view [dbo].[OLD2_MAIL_DOCUMENT] as
select
       
       d.id as iddoc
       , lngSuffisso as LNG
       , a.aziRagionesociale as RagioneSociale
       , case 
			when d.TipoDoc = 'PDA_COMUNICAZIONE_RISP' then d.Titolo 
			when d.TipoDoc = 'MANIFESTAZIONE_INTERESSE' and b.ProceduraGara = '15583' and b.TipoBandoGara in ('4','5') then dbo.cnv('Risposta Avviso','I')
			else isnull( ML_Description , DOC_DescML ) 
		 end as TipoDoc

       --, case when jumpcheck='0-VERIFICA_REGISTRAZIONE_FORN' then 'VERIFICA_REGISTRAZIONE' else TipoDoc end as TipoDocumento
       , case 
                    when d.TipoDoc='VERIFICA_REGISTRAZIONE_FORN' then 'VERIFICA_REGISTRAZIONE' 
                    when d.TipoDoc='PDA_COMUNICAZIONE_RISP' and ba.id is not null and COM_LINKED.Id IS NULL then 'PDA_COMUNICAZIONE_RISP_BANDO'
                    when d.TipoDoc='PDA_COMUNICAZIONE_RISP' and COM_LINKED.Id IS NOT NULL then 'PDA_COMUNICAZIONE_RISP_1_GENERICA'
                    else d.TipoDoc 

             end as TipoDocumento

       , ISNULL(d.Body,d.note) as body
       --, Body as Object_Cover1
	   -- ANONIMATO SULLA GESTIONE DEI CONCORSI DI IDEE E PROGETTAZIONE
	   , CASE 
			WHEN ISNULL(ba.TipoDoc,'') <> 'BANDO_CONCORSO'
				THEN d.Protocollo
			ELSE 'Anonimo' 
		END as Protocollo
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
	   -- ANONIMATO SULLA GESTIONE DEI CONCORSI DI IDEE E PROGETTAZIONE
	   , CASE 
			WHEN ISNULL(ba.TipoDoc,'') <> 'BANDO_CONCORSO'
				THEN coalesce( ba.Protocollo, COM_CAPOGRUPPO.ProtocolloRiferimento ,'')
			ELSE 'Anonimo' 
		END as ProtocolloBando
		-- ANONIMATO SULLA GESTIONE DEI CONCORSI DI IDEE E PROGETTAZIONE
       , 
	   --CASE 
		--	WHEN ISNULL(ba.TipoDoc,'') <> 'BANDO_CONCORSO'
		--		THEN A2.aziRagionesociale 
		--	ELSE 'Anonimo' 
		--END as AziendaMitt
		A2.aziRagionesociale  as AziendaMitt
       , d.note as Testocomuicazione
       --, case when isnull( cast(COM_CAPOGRUPPO.Body as varchar(max)),'') <> '' then isnull(COM_CAPOGRUPPO.Body,'')
       , case when coalesce( cast(ba.Body as varchar(max)),cast(COM_CAPOGRUPPO.Body as varchar(max)),'') <> '' then isnull(ba.Body,'')
             else d.Titolo
         end  as Oggettogara
       , DMV_DescML as StatoFunzionale
       , d.note
	   -- ANONIMATO SULLA GESTIONE DEI CONCORSI DI IDEE E PROGETTAZIONE
	   , CASE 
			WHEN ISNULL(ba.TipoDoc,'') <> 'BANDO_CONCORSO'
				THEN A3.aziRagioneSociale
			ELSE 'Anonimo' 
		END as RagioneSocialeDestinatario

       , case 
                    when A3.azivenditore <> 0 then 'Operatore Economico'
                    when A3.aziacquirente <> 0 then 'Ente'
         end as TipoAziendaDestinatario

         , b.cig

       , case 
                    when A2.azivenditore <> 0 then 'Operatore Economico'
                    when A2.aziacquirente <> 0 then 'Ente'
         end as TipoAziendaMittente
         , ba.Titolo as TitoloBando
         , ba.body as OggettoBando
         , case when d.tipodoc in ('PDA_COMUNICAZIONE_GARA') then  dbo.GetGridAttachHtml(d.id,d.TipoDoc ) else '' end as Attach_Grid
		-- , ba.TipoDoc as TipodocSource

from ctl_doc d with(nolock ,index(ICX_CTL_DOC_id )) 
       cross join Lingue with(nolock) 
       left outer join profiliutente p  with(nolock,index(IX_ProfiliUtente)) on p.idpfu = d.idpfu
       left outer join aziende a  with(nolock,index(IX_Aziende_IdAzi)) on a.idazi = p.pfuidazi
       inner join LIB_Documents  with(nolock,index(IX_LIB_Documents_DOC_ID)) on DOC_ID = TipoDoc
       left outer join LIB_Multilinguismo  with(nolock,index(Index_LIB_Multilinguismo)) on DOC_DescML = ML_KEY and ML_Context = 0 and ML_LNG = lngSuffisso
       left outer join peg  with(nolock) on '35152001#\0000\0000\00' + CodProgramma = d.StrutturaAziendale
       left outer join AZ_STRUTTURA az  with(nolock,index(IX_AZ_STRUTTURA_1)) on idaz = dbo.getPos( StrutturaAziendale , '#' , 1 ) and  cast( idaz as varchar ) + '#' + Path = StrutturaAziendale
       left outer join aziende A2  with(nolock,index(IX_Aziende_IdAzi)) on d.azienda=A2.idazi

       left join profiliutente pd with(nolock,index(IX_ProfiliUtente)) on pd.IdPfu = d.Destinatario_User
       
       left outer join aziende A3  with(nolock,index(IX_Aziende_IdAzi)) on d.Destinatario_azi=A3.idazi or ( isnull( d.Destinatario_azi , 0 ) = 0 and pd.pfuIdAzi = A3.IdAzi )
       left outer join LIB_DomainValues  with(nolock,index(IX_LIB_DomainValues_DMV_DM_ID_DMV_COD_DMV_DescML)) on d.statofunzionale=DMV_Cod and DMV_DM_ID='StatoFunzionale'

       --per aggiungere per le nuove comunicazioni PDA_COMUNICAZIONE_GARA il protocollobando 
       --che sta sulla capogruppo in protocolloriferimento
       --left outer join (
       --     select id,protocolloriferimento,Body, Titolo  from ctl_doc  with(nolock) where tipodoc in ('PDA_COMUNICAZIONE','PROROGA_GARA','PDA_COMUNICAZIONE_GENERICA')
       --) COM_CAPOGRUPPO on COM_CAPOGRUPPO.id=D.linkeddoc and D.tipodoc='PDA_COMUNICAZIONE_GARA'

       left outer join ctl_doc  COM_CAPOGRUPPO with(nolock,index(ICX_CTL_DOC_id )) on COM_CAPOGRUPPO.tipodoc in ('PDA_COMUNICAZIONE','PROROGA_GARA','PDA_COMUNICAZIONE_GENERICA')
                                                                                                     and COM_CAPOGRUPPO.id=D.linkeddoc and D.tipodoc='PDA_COMUNICAZIONE_GARA'


       --vado inleft join sul bando per le offerte
       --left join document_bando B on B.idheader=d.linkeddoc and d.tipodoc in ( 'OFFERTA', 'MANIFESTAZIONE_INTERESSE' )

       -- salgo sul bando dal fascicolo per rendere più generico l'utilizzo
       left outer join CTL_DOC ba with(nolock,index(icx_CTL_DOC_FASCICOLO)) on ba.Fascicolo = d.Fascicolo 
		and ba.Deleted = 0 
		and ba.TipoDoc in ( 
							'BANDO' ,
							'BANDO_SDA' ,
							'BANDO_GARA',
							'TEMPLATE_GARA',
							'BANDO_SEMPLIFICATO' ,
							'BANDO_ASTA', 
							'BANDO_FABBISOGNI', 
							'BANDO_CONCORSO' -- AGGIUNTO IL NUOVO TIPODOC SULLA GESTIONE DEI CONCORSI DI IDEE E PROGETTAZIONE
						  )
		and ISNULL(d.Fascicolo,'') <> ''

       left outer join document_bando B with(nolock,index(ICX_Document_Bando_IdHeader)) on B.idheader=ba.id
       left outer join ctl_doc COM_LINKED with(nolock,index(ICX_CTL_DOC_id )) on COM_LINKED.id=D.linkeddoc and D.tipodoc='PDA_COMUNICAZIONE_RISP' and COM_LINKED.JumpCheck='1-GENERICA'
GO
