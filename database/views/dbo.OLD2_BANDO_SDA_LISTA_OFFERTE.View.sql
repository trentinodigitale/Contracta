USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_BANDO_SDA_LISTA_OFFERTE]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE view [dbo].[OLD2_BANDO_SDA_LISTA_OFFERTE] as

	select  o.Id, o.IdPfu, o.IdDoc, o.TipoDoc, 
			case when o.StatoFunzionale='Ritirata' then 'Ritirata' else o.StatoDoc end as StatoDoc
			, o.Data, o.Protocollo, 
			o.PrevDoc, o.Deleted, o.Titolo, o.Body, o.Azienda, o.StrutturaAziendale, 
			o.DataInvio, o.DataScadenza, o.ProtocolloRiferimento, o.ProtocolloGenerale, 
			o.Fascicolo, o.Note, o.DataProtocolloGenerale, o.LinkedDoc, o.SIGN_HASH, o.SIGN_ATTACH, 
			o.SIGN_LOCK, o.JumpCheck, o.StatoFunzionale, o.Destinatario_User,o. Destinatario_Azi, 
			o.RichiestaFirma, o.NumeroDocumento, o.DataDocumento, o.Versione, o.VersioneLinkedDoc, 
			o.GUID, o.idPfuInCharge, o.CanaleNotifica, o.URL_CLIENT, o.Caption, o.FascicoloGenerale
			, o.tipodoc as OPEN_DOC_NAME
			, o.LinkedDoc as idHeader
			, isnull(p1.[Value], az.aziRagioneSociale) as aziRagioneSociale
			, dm1.vatValore_FT as codicefiscale
			, az.aziPartitaIVA
			, az.aziLocalitaLeg
			, az.aziE_Mail

			, dbo.GetListaLottiOfferti( o.id ) as lottiOfferti

		from ctl_doc o with(nolock)

				left join CTL_DOC p with(nolock) on p.LinkedDoc = o.id and p.TipoDoc = 'OFFERTA_PARTECIPANTI' and p.StatoFunzionale = 'Pubblicato' and p.deleted = 0
				left join ctl_doc_value p1 with(nolock) on p1.idheader = p.id and p1.DSE_ID = 'TESTATA_RTI' and p1.DZT_Name = 'DenominazioneATI' and isnull(p1.value,'') <> ''
				left join document_offerta_partecipanti p2 with(nolock) ON p2.idheader = p.id and p2.Ruolo_Impresa = 'Mandataria' and p2.tiporiferimento='RTI'

				inner join aziende az with(nolock) on isnull(p2.IdAzi,o.Azienda) = az.IdAzi --Mandataria o azienda partecipante se non è in RTI
				inner join DM_Attributi dm1 with(nolock) ON dm1.lnk = az.idazi and dm1.dztNome = 'codicefiscale'

		where 
				
				--commentata perchè and successivo non faceva uscire cmq le ISTANZA_SDA
				--and (
				--		( left( o.tipoDoc , 11 ) in ( 'ISTANZA_SDA' , 'OFFERTA' ) and o.StatoDoc <> 'Saved' )
						
				--		or
				--			(left( o.tipoDoc , 11 ) not in ( 'ISTANZA_SDA' , 'OFFERTA' ) )			
				--	)

				o.tipodoc in ('OFFERTA','OFFERTA_ASTA','DOMANDA_PARTECIPAZIONE','MANIFESTAZIONE_INTERESSE') and o.StatoDoc <> 'Saved'
				and o.deleted = 0






				


GO
