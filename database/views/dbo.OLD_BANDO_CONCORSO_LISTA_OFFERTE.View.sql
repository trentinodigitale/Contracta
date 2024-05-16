USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_BANDO_CONCORSO_LISTA_OFFERTE]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO












CREATE view [dbo].[OLD_BANDO_CONCORSO_LISTA_OFFERTE] as

	select  o.Id, o.IdPfu, o.IdDoc, o.TipoDoc, 
			case when o.StatoFunzionale='Ritirata' then 'Ritirata' else o.StatoDoc end as StatoDoc
			, o.Data, 
			o.PrevDoc, o.Deleted, o.Titolo , o.Body, o.Azienda, o.StrutturaAziendale, 
			o.DataScadenza, o.ProtocolloRiferimento, o.ProtocolloGenerale, 
			o.Fascicolo, o.Note, o.DataProtocolloGenerale, o.LinkedDoc, o.SIGN_HASH, o.SIGN_ATTACH, 
			o.SIGN_LOCK, o.JumpCheck, o.StatoFunzionale, o.Destinatario_User,o. Destinatario_Azi, 
			o.RichiestaFirma, o.NumeroDocumento, o.DataDocumento, o.Versione, o.VersioneLinkedDoc, 
			o.GUID, o.idPfuInCharge, o.CanaleNotifica, o.URL_CLIENT, o.Caption, o.FascicoloGenerale
			, o.tipodoc as OPEN_DOC_NAME
			, o.LinkedDoc as idHeader
			
			 
			
			, case
				
				--i dati sono in chiaro sulle risposte
				when isnull(O_AN.Value,'') = '1'   then o.Protocollo
				
				--i dati NON sono ancora in chiaro sulle risposte
				else '' 

			end AS Protocollo


			, 
			case
				
				--i dati sono in chiaro sulle risposte
				when isnull(O_AN.Value,'') = '1'   then isnull(p1.[Value], az.aziRagioneSociale) 
				
				--i dati NON sono ancora in chiaro sulle risposte
				else '' 

			end AS aziRagioneSociale

			, 
			case
				
				--i dati sono in chiaro sulle risposte
				when isnull(O_AN.Value,'') = '1'   then isnull(dm1.vatValore_FT, '') 
				
				--i dati NON sono ancora in chiaro sulle risposte
				else '' 

			end AS codicefiscale
			
			, 
			case
				
				--i dati sono in chiaro sulle risposte
				when isnull(O_AN.Value,'') = '1'   then isnull(az.aziPartitaIVA, '') 
				
				--i dati NON sono ancora in chiaro sulle risposte
				else '' 

			end AS aziPartitaIVA

			, 
			case
				
				--i dati sono in chiaro sulle risposte
				when isnull(O_AN.Value,'') = '1'   then isnull(az.aziLocalitaLeg, '') 
				
				--i dati NON sono ancora in chiaro sulle risposte
				else '' 

			end AS aziLocalitaLeg
			, 
			case
				
				--i dati sono in chiaro sulle risposte
				when isnull(O_AN.Value,'') = '1'   then isnull(az.aziE_Mail, '') 
				
				--i dati NON sono ancora in chiaro sulle risposte
				else '' 

			end AS aziE_Mail
			, 
			case
				
				--i dati sono in chiaro sulle risposte
				when isnull(O_AN.Value,'') = '1'   then isnull(o.DataInvio, '') 
				
				--i dati NON sono ancora in chiaro sulle risposte
				else null

			end AS DataInvio

			--, dm1.vatValore_FT as codicefiscale
			--, az.aziPartitaIVA
			--, az.aziLocalitaLeg
			--, az.aziE_Mail
			
			--, dbo.GetListaLottiOfferti( o.id ) as lottiOfferti

			, o.Titolo as Progressivo_Risposta -- Aggiunto per tenerne traccia e garantirne l'anonimato

		from ctl_doc o with(nolock)

				--DSE_ID=’ANONIMATO’ ,  DZT_NAME=“DATI_IN_CHIARO”  e row=0
				left join ctl_doc_value O_AN with(nolock) on O_AN.idheader = o.id and O_AN.DSE_ID = 'ANONIMATO' and O_AN.DZT_Name = 'DATI_IN_CHIARO'  and O_AN.Row=0

				left join CTL_DOC p with(nolock) on p.LinkedDoc = o.id and p.TipoDoc = 'OFFERTA_PARTECIPANTI' and p.StatoFunzionale = 'Pubblicato' and p.deleted = 0
				left join ctl_doc_value p1 with(nolock) on p1.idheader = p.id and p1.DSE_ID = 'TESTATA_RTI' and p1.DZT_Name = 'DenominazioneATI' and isnull(p1.value,'') <> ''
				left join document_offerta_partecipanti p2 with(nolock) ON p2.idheader = p.id and p2.Ruolo_Impresa = 'Mandataria' and p2.tiporiferimento='RTI'

				inner join aziende az with(nolock) on isnull(p2.IdAzi,o.Azienda) = az.IdAzi --Mandataria o azienda partecipante se non è in RTI
				inner join DM_Attributi dm1 with(nolock) ON dm1.lnk = az.idazi and dm1.dztNome = 'codicefiscale'
				

		where 
				
				o.tipodoc in ('RISPOSTA_CONCORSO') and o.StatoDoc <> 'Saved'
				and o.deleted = 0






				

GO
