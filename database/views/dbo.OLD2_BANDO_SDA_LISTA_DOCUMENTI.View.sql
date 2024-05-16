USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_BANDO_SDA_LISTA_DOCUMENTI]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









CREATE view [dbo].[OLD2_BANDO_SDA_LISTA_DOCUMENTI] as

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

		from ctl_doc c with (nolock)
	
				left outer join  aziende az1 with (nolock) on azienda = az1.idazi
				left outer join  aziende az2 with (nolock) on Destinatario_Azi = az2.idazi
				left join document_bando b with(nolock) on b.idHeader = c.id
				left join document_bando Gara with(nolock) on Gara.idHeader = c.linkeddoc  

		where 
			
			c.deleted = 0
			
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
				    TipoDoc not in ( 'COMMISSIONE_PDA','TEMPLATE_CONTEST', 'CONFORMITA_MICROLOTTI_OFF','CONFIG_MODELLI_LOTTI' , 
									'OFFERTA' , 'CONFIG_MODELLI_FABBISOGNI' , 'VERIFICA_ANOMALIA' ,'PDA_VALUTA_LOTTO_TEC' , 
									 'ESITO_LOTTO_ESCLUSA', 'RISULTATODIGARA', 'AVVISO_GARA','NEW_RISULTATODIGARA',
									 'PDA_COMUNICAZIONE_GARA','MANIFESTAZIONE_INTERESSE', 'DOMANDA_PARTECIPAZIONE','RISPOSTA_CONCORSO' , 'OCP_IMPRESE_LOTTO' )
				    
				    or 
				    --prendo tutte le comunicazioni diverse dalle sospensioni
				    (TipoDoc='PDA_COMUNICAZIONE_GARA' and jumpcheck <> '0-SOSPENSIONE_ALBO')
					or 
					--ESCLUSE LE COMMISSIONI RELATIVE A GARE INFORMALI DALLA LISTA DOCUMENTI
					( tipodoc = 'COMMISSIONE_PDA' and ISNULL(VersioneLinkedDoc,'') <> 'GARA_INFORMALE'  ) 

					--includo 'OFFERTA','OFFERTA_ASTA','DOMANDA_PARTECIPAZIONE','MANIFESTAZIONE_INTERESSE'
					--ritornati di solito dalla vista BANDO_SDA_LISTA_OFFERTE
					--se si tratta di AFFIDAMENTO DIRETTO SEMPLIFICATO
					--e datascadenza superata o visualizza notifiche =1
					or
					(
						ISNULL(Gara.TipoProceduraCaratteristica,'') = 'AffidamentoSemplificato'
						AND c.tipodoc in ('OFFERTA','OFFERTA_ASTA','DOMANDA_PARTECIPAZIONE','MANIFESTAZIONE_INTERESSE') 
						AND c.StatoDoc <> 'Saved'
						and ( Gara.VisualizzaNotifiche = '1' or Gara.DataScadenzaOfferta > getdate() )		

					)

				)

			and ( 
					( StatoFunzionale <> 'Annullato' )
					or
					( StatoFunzionale = 'Annullato' and TipoDoc in ( 'RICHIESTA_CIG' , 'ANNULLA_RICHIESTA_CIG', 'DELTA_TED' ) )
				)
			
			and tipodoc not in ('PDA_VALUTA_LOTTO_ECO','NUOVO_RILANCIO_COMPETITIVO', 'SEDUTA_VIRTUALE','COMUNICAZIONE_OE',
								'COMUNICAZIONE_OE_RISP'
								,'QUESTIONARIO_FABBISOGNI' , 'QUESTIONARIO_PROGRAMMAZIONE','RETT_VALORE_ECONOMICO'
								,'SIMOG_REQUISITI' )
			
			and not ( tipodoc = 'BANDO_GARA' and ISNULL(b.TipoProceduraCaratteristica,'') = 'RilancioCompetitivo' and  StatoFunzionale = 'InLavorazione' )
			
			--per togliere i doc di esito legati alla pda
			and TipoDoc not like 'ESITO_%'

			
----------------------------
-- AGGIUNGO AL RISULTATO anche le codifiche dei prodotti
----------------------------
	union all
	select  c.Id,c.IdPfu,c.IdDoc,
			case when isnull( c.Caption , '' ) <> '' THEN c.Caption else c.TipoDoc end as TipoDoc,
			c.StatoDoc,c.Data,c.Protocollo,c.PrevDoc,c.Deleted,c.Titolo,c.Body,c.Azienda,
			c.StrutturaAziendale,c.DataInvio,c.DataScadenza,c.ProtocolloRiferimento,c.ProtocolloGenerale,c.Fascicolo,c.Note,
			c.DataProtocolloGenerale,r.LinkedDoc,c.SIGN_HASH,c.SIGN_ATTACH,c.SIGN_LOCK,c.JumpCheck,
			c.StatoFunzionale
			,c.Destinatario_User,
			c.Destinatario_Azi,c.RichiestaFirma,c.NumeroDocumento,c.DataDocumento,c.Versione,c.VersioneLinkedDoc,c.GUID,c.idPfuInCharge,
			c.CanaleNotifica,c.URL_CLIENT,c.Caption,c.FascicoloGenerale
			, c.tipodoc as OPEN_DOC_NAME
			, isnull( az1.aziRagionesociale, '' ) as aziRagioneSociale

		from ctl_doc r with (nolock)
			inner join ctl_doc c with (nolock) on r.id = c.LinkedDoc and c.TipoDoc = 'CODIFICA_PRODOTTI' and c.JumpCheck = 'CODIFICA_AUTOMATICA'
	
			left outer join  aziende az1 with (nolock) on c.azienda = az1.idazi

		where 
			r.deleted = 0
			and r.TipoDoc = 'RICHIESTA_CODIFICA_PRODOTTI'

--AGGIUNGO I DOCUMENTI DI TIPO SUBENTRO_AZI	

	union all
	select  
			S.Id,S.IdPfu,S.IdDoc,
			case when isnull( S.Caption , '' ) <> '' THEN S.Caption else S.TipoDoc end as TipoDoc,
			S.StatoDoc,S.Data,S.Protocollo,S.PrevDoc,S.Deleted,S.Titolo,S.Body,S.Azienda,
			S.StrutturaAziendale,S.DataInvio,S.DataScadenza,S.ProtocolloRiferimento,S.ProtocolloGenerale,S.Fascicolo,S.Note,
			S.DataProtocolloGenerale,
			SD.Value as LinkedDoc,
			S.SIGN_HASH,S.SIGN_ATTACH,S.SIGN_LOCK,S.JumpCheck,
			S.StatoFunzionale
			,S.Destinatario_User,
			S.Destinatario_Azi,S.RichiestaFirma,S.NumeroDocumento,S.DataDocumento,S.Versione,S.VersioneLinkedDoc,S.GUID,S.idPfuInCharge,
			S.CanaleNotifica,S.URL_CLIENT,S.Caption,S.FascicoloGenerale
			, S.tipodoc as OPEN_DOC_NAME
			, isnull( az1.aziRagionesociale, '' ) as aziRagioneSociale
			
		from ctl_doc S with (nolock)
				
				inner join CTL_DOC_Value SD with (nolock) on SD.IdHeader = S.id and SD.DSE_ID='LISTA' and SD.DZT_Name='idrow'
				left outer join  aziende az1 with (nolock) on S.azienda = az1.idazi

		where 
			S.TipoDoc = 'SUBENTRO_AZI' AND S.StatoFunzionale='Inviato' and S.deleted = 0

	


GO
