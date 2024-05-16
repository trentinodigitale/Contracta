USE [AFLink_TND]
GO
/****** Object:  View [dbo].[BANDO_SDA_LISTA_OFFERTE]    Script Date: 5/16/2024 2:45:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








CREATE view [dbo].[BANDO_SDA_LISTA_OFFERTE] as

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
			--, isnull(p1.[Value], az.aziRagioneSociale) as aziRagioneSociale
			,
			 case
				when DETT_GARA.DataScadenzaOfferta < getdate() then isnull(p1.[Value], az.aziRagioneSociale)
				else 
					case 
						when charindex(',aziRagioneSociale,' , ',' + HideCol_Bando_Gara_Lista_Offerte +',' ) > 0 then ''
						else isnull(p1.[Value], az.aziRagioneSociale)
					end 
			  end as aziRagioneSociale

			--, dm1.vatValore_FT as codicefiscale
			,case
				when DETT_GARA.DataScadenzaOfferta < getdate() then dm1.vatValore_FT 
				else 
					case 
						when charindex(',codicefiscale,' , ',' + HideCol_Bando_Gara_Lista_Offerte +',' ) > 0 then ''
						else dm1.vatValore_FT 
					end 
			  end as codicefiscale

			--, az.aziPartitaIVA
			,case
				when DETT_GARA.DataScadenzaOfferta < getdate() then aziPartitaIVA
				else 
					case 
						when charindex(',aziPartitaIVA,' , ',' + HideCol_Bando_Gara_Lista_Offerte +',' ) > 0 then ''
						else aziPartitaIVA 
					end 
			  end as aziPartitaIVA

			--, az.aziLocalitaLeg
			,case
				when DETT_GARA.DataScadenzaOfferta < getdate() then aziLocalitaLeg
				else 
					case 
						when charindex(',aziLocalitaLeg,' , ',' + HideCol_Bando_Gara_Lista_Offerte +',' ) > 0 then ''
						else aziLocalitaLeg 
					end 
			  end as aziLocalitaLeg

			--, az.aziE_Mail

			,case
				when DETT_GARA.DataScadenzaOfferta < getdate() then aziE_Mail
				else 
					case 
						when charindex(',aziE_Mail,' , ',' + HideCol_Bando_Gara_Lista_Offerte +',' ) > 0 then ''
						else aziE_Mail 
					end 
			  end as aziE_Mail

			, dbo.GetListaLottiOfferti( o.id ) as lottiOfferti


		from ctl_doc o with(nolock)
				inner join document_bando DETT_GARA with (nolock) on DETT_GARA.idHeader = o.LinkedDoc 
				left join CTL_DOC p with(nolock) on p.LinkedDoc = o.id and p.TipoDoc = 'OFFERTA_PARTECIPANTI' and p.StatoFunzionale = 'Pubblicato' and p.deleted = 0
				left join ctl_doc_value p1 with(nolock) on p1.idheader = p.id and p1.DSE_ID = 'TESTATA_RTI' and p1.DZT_Name = 'DenominazioneATI' and isnull(p1.value,'') <> ''
				left join document_offerta_partecipanti p2 with(nolock) ON p2.idheader = p.id and p2.Ruolo_Impresa = 'Mandataria' and p2.tiporiferimento='RTI'

				inner join aziende az with(nolock) on isnull(p2.IdAzi,o.Azienda) = az.IdAzi --Mandataria o azienda partecipante se non è in RTI
				inner join DM_Attributi dm1 with(nolock) ON dm1.lnk = az.idazi and dm1.dztNome = 'codicefiscale'
			
			    --vado sui parametri a recuperare la lista delle colonne da nascondere su LISTA_OFFERTE
			    cross join ( select dbo.parametri('BANDO_GARA','LISTA_OFFERTE','HIDECOL','',-1) as HideCol_Bando_Gara_Lista_Offerte ) as H

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
