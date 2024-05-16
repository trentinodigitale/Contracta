USE [AFLink_TND]
GO
/****** Object:  View [dbo].[BANDO_FABBISOGNI_LISTA_DOCUMENTI]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[BANDO_FABBISOGNI_LISTA_DOCUMENTI] as

	select  c.Id,c.IdPfu,c.IdDoc,
			case when c.TipoDoc in (  'PDA_MICROLOTTI' , 'RICHIESTA_CIG' , 'ANNULLA_RICHIESTA_CIG' ) and isnull( c.Caption , '' ) <> '' THEN c.Caption else c.TipoDoc end as TipoDoc,
			c.StatoDoc,c.Data,c.Protocollo,c.PrevDoc,c.Deleted,c.Titolo,c.Body,c.Azienda,
			c.StrutturaAziendale,c.DataInvio,c.DataScadenza,c.ProtocolloRiferimento,c.ProtocolloGenerale,c.Fascicolo,c.Note,
			c.DataProtocolloGenerale,c.LinkedDoc,c.SIGN_HASH,c.SIGN_ATTACH,c.SIGN_LOCK,c.JumpCheck,
			case when C.tipodoc= 'RICHIESTA_ATTI_GARA' then c.StatoDoc else c.StatoFunzionale end as StatoFunzionale
			,c.Destinatario_User,
			c.Destinatario_Azi,c.RichiestaFirma,c.NumeroDocumento,c.DataDocumento,c.Versione,c.VersioneLinkedDoc,c.GUID,c.idPfuInCharge,
			c.CanaleNotifica,c.URL_CLIENT,c.Caption,c.FascicoloGenerale
			, tipodoc as OPEN_DOC_NAME
			, isnull( az1.aziRagionesociale, az2.aziRagioneSociale) as aziRagioneSociale

			, isnull( m.ML_Description, doc.doc_descml) as Tipo

		from ctl_doc c with (nolock)
	
			left outer join  aziende az1 with (nolock) on azienda = az1.idazi
			left outer join  aziende az2 with (nolock) on Destinatario_Azi = az2.idazi
			left join document_bando b with(nolock) on b.idHeader = c.id

			inner join LIB_Documents doc on doc.DOC_ID = c.TipoDoc
			left  join LIB_Multilinguismo m with(nolock) on m.ML_LNG = 'I' and m.ML_KEY = doc.DOC_DescML

		where 
			deleted = 0
			
			and (
					( left( tipoDoc , 11 ) in ( 'ISTANZA_SDA' , 'OFFERTA' ) and StatoDoc <> 'Saved' )
					or
					(
					   left( tipoDoc , 11 ) not in ( 'ISTANZA_SDA' , 'OFFERTA' ) and  tipoDoc <> 'RICHIESTA_ATTI_GARA' 
					)
					or 		
					(  tipoDoc = 'RICHIESTA_ATTI_GARA'  and StatoDoc <> 'Saved' )
				)
			--and TipoDoc <> 'CONFIG_MODELLI_LOTTI' and tipodoc <> 'OFFERTA' and TipoDoc <> 'CONFIG_MODELLI_FABBISOGNI'
			and 
				( 
				    TipoDoc not in ( 'COMMISSIONE_PDA','TEMPLATE_CONTEST', 'CONFORMITA_MICROLOTTI_OFF','CONFIG_MODELLI_LOTTI' , 'OFFERTA' , 'CONFIG_MODELLI_FABBISOGNI' , 'VERIFICA_ANOMALIA' ,'PDA_VALUTA_LOTTO_TEC' , 'ESITO_LOTTO_ESCLUSA', 'RISULTATODIGARA', 'AVVISO_GARA','NEW_RISULTATODIGARA','PDA_COMUNICAZIONE_GARA','MANIFESTAZIONE_INTERESSE', 'DOMANDA_PARTECIPAZIONE' )
				    
				    or 
				    --prendo tutte le comunicazioni diverse dalle sospensioni
				    (TipoDoc='PDA_COMUNICAZIONE_GARA' and jumpcheck <> '0-SOSPENSIONE_ALBO')
					or 
					--ESCLUSE LE COMMISSIONI RELATIVE A GARE INFORMALI DALLA LISTA DOCUMENTI
					( tipodoc = 'COMMISSIONE_PDA' and ISNULL(VersioneLinkedDoc,'') <> 'GARA_INFORMALE'  ) 

				)

			and ( 
					( StatoFunzionale <> 'Annullato' )
					or
					( StatoFunzionale = 'Annullato' and TipoDoc in ( 'RICHIESTA_CIG' , 'ANNULLA_RICHIESTA_CIG' ) )
				)
			
			and tipodoc not in ('PDA_VALUTA_LOTTO_ECO','NUOVO_RILANCIO_COMPETITIVO', 'SEDUTA_VIRTUALE','COMUNICAZIONE_OE','COMUNICAZIONE_OE_RISP','QUESTIONARIO_FABBISOGNI' , 'QUESTIONARIO_PROGRAMMAZIONE')
			
			and not ( tipodoc = 'BANDO_GARA' and ISNULL(TipoProceduraCaratteristica,'') = 'RilancioCompetitivo' and  StatoFunzionale = 'InLavorazione' )
			
			--per togliere i doc di esito legati alla pda
			and TipoDoc not like 'ESITO_%'


	UNION ALL -- aggiungiamo le risposte alle comunicazioni 

		select r.[Id], r.[IdPfu], r.[IdDoc], r.[TipoDoc], r.[StatoDoc], r.[Data], r.[Protocollo], r.[PrevDoc], r.[Deleted], r.[Titolo], r.[Body], 
				r.[Azienda], r.[StrutturaAziendale], r.[DataInvio], r.[DataScadenza], r.[ProtocolloRiferimento], r.[ProtocolloGenerale], r.[Fascicolo],
				r.[Note], r.[DataProtocolloGenerale], 
				c.[LinkedDoc], 
				r.[SIGN_HASH], r.[SIGN_ATTACH], r.[SIGN_LOCK], r.[JumpCheck], r.[StatoFunzionale], 
				r.[Destinatario_User], r.[Destinatario_Azi], r.[RichiestaFirma], r.[NumeroDocumento], r.[DataDocumento], r.[Versione], r.[VersioneLinkedDoc], 
				r.[GUID], r.[idPfuInCharge], r.[CanaleNotifica], r.[URL_CLIENT], r.[Caption], r.[FascicoloGenerale]
			, r.tipodoc as OPEN_DOC_NAME
			, '' as aziRagioneSociale
			, dbo.CNV('FABBISOGNI_COMUNICAZIONE_GENERICA','I') as Tipo

		from ctl_doc c with (nolock)
				inner join ctl_doc g with(nolock) on g.LinkedDoc = c.id and g.tipodoc = 'PDA_COMUNICAZIONE_GARA' and g.Deleted = 0
				inner join ctl_doc r with(nolock) on r.LinkedDoc = g.Id and r.TipoDoc = 'PDA_COMUNICAZIONE_RISP' and r.Deleted = 0
		WHERE C.TipoDoc = 'PDA_COMUNICAZIONE_GENERICA' and c.JumpCheck = '1-FABBISOGNI_COMUNICAZIONE_GENERICA' and c.StatoFunzionale<>'Annullato' and c.deleted=0



GO
