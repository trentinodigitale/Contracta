USE [AFLink_TND]
GO
/****** Object:  View [dbo].[PDA_CONCORSO_VALUTA_LOTTO_TEC_TESTATA_VIEW]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE view [dbo].[PDA_CONCORSO_VALUTA_LOTTO_TEC_TESTATA_VIEW] as

	select 
			--d.*
			 d.Id
			,d.IdPfu
			,d.IdDoc
			,d.TipoDoc
			,d.StatoDoc
			,d.Data
			,d.Protocollo
			,d.PrevDoc
			,d.Deleted
			,d.Titolo
			,d.Body
			,case 
				when isnull(AN.Value,'0') = 0 
					then '' 
				else d.Azienda 
				end as Azienda  
			,d.StrutturaAziendale
			,d.DataInvio
			,d.DataScadenza
			,d.ProtocolloRiferimento
			,d.ProtocolloGenerale
			,d.Fascicolo
			,d.Note
			,d.DataProtocolloGenerale
			,d.LinkedDoc
			,d.SIGN_HASH
			,d.SIGN_ATTACH
			,d.SIGN_LOCK
			,d.JumpCheck
			,d.StatoFunzionale
			,d.Destinatario_User
			,d.Destinatario_Azi
			,d.RichiestaFirma
			,d.NumeroDocumento
			,d.DataDocumento
			,d.Versione
			,d.VersioneLinkedDoc
			,d.GUID
			,d.idPfuInCharge
			,d.CanaleNotifica
			,d.URL_CLIENT
			,d.Caption
			,d.FascicoloGenerale
			,d.CRYPT_VER
			,l.CIG 
			,l.NumeroLotto 
			,l.Descrizione
			,TipoGiudizioTecnico
			,PunteggioTEC_100
			,PunteggioTEC_TipoRip
			,criteri.ModAttribPunteggio
			,isnull(DCU.UtenteCommissione,0) as Pres_Tec
			,dbo.Get_Utenti_Commissione_Ext (Comm.Id, RU.Ruoli,'G') as UtentiAbilitati
			,R.Titolo as Progressivo_Risposta

		from CTL_DOC d with(nolock)
			inner join Document_MicroLotti_Dettagli l with(nolock) on l.id = d.LinkedDoc
			left join document_pda_offerte O with(nolock) on O.idrow=l.idheader
			left join ctl_doc P with(nolock) on P.id=O.idheader
			left join document_bando B with(nolock) on B.idheader=P.linkeddoc

			--salgo sulla risposta per prendere il titolo
			inner join ctl_doc R  with(nolock) on O.IdMsgFornitore = R.id

			--Da P vado in left join nella CTL_DOC_VALUE per recuperarmi dalla PDA il flag sull'anonimato
			left join CTL_DOC_VALUE AN on AN.idheader = P.id and DSE_ID = 'ANONIMATO' and DZT_name = 'DATI_IN_CHIARO'

			--left outer join CTL_DOC_Value v1 on P.Linkeddoc = v1.idheader and v1.DSE_ID = 'CRITERI_ECO' and v1.DZT_Name = 'PunteggioTEC_100'
			--left outer join CTL_DOC_Value v2 on P.Linkeddoc = v2.idheader and v2.DSE_ID = 'CRITERI_ECO' and v2.DZT_Name = 'PunteggioTEC_TipoRip'

			left join BANDO_GARA_CRITERI_VALUTAZIONE_PER_LOTTO criteri on criteri.idBando = P.LinkedDoc and ( criteri.N_Lotto = l.NumeroLotto or criteri.N_Lotto is null ) 
			LEFT join  ctl_doc Comm with(nolock) on comm.deleted=0 and comm.linkedDoc=B.idHeader and comm.tipodoc='COMMISSIONE_PDA' and comm.statofunzionale='pubblicato'  
			LEFT JOIN  Document_CommissionePda_Utenti DCU with(nolock) on DCU.IdHeader=Comm.Id and DCU.ruolocommissione='15548' and TipoCommissione='G'
			
			cross join ( select dbo.PARAMETRI('PDA_CONCORSO_VALUTA_LOTTO_TEC','UtentiAbilitati', 'DefaultValue' , '15548',-1) as Ruoli ) RU
			
GO
