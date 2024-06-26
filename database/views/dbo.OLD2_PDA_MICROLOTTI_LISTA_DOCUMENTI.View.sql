USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_PDA_MICROLOTTI_LISTA_DOCUMENTI]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








CREATE view [dbo].[OLD2_PDA_MICROLOTTI_LISTA_DOCUMENTI] as 
    
     
	select Id, IdPfu, IdDoc, TipoDoc, StatoDoc, Data, Protocollo, PrevDoc, Deleted, Titolo, Body, Azienda, StrutturaAziendale, DataInvio, DataScadenza, ProtocolloRiferimento, ProtocolloGenerale, Fascicolo, Note, DataProtocolloGenerale,  SIGN_HASH, SIGN_ATTACH, SIGN_LOCK, JumpCheck, StatoFunzionale, Destinatario_User, Destinatario_Azi, RichiestaFirma, NumeroDocumento, DataDocumento, Versione, VersioneLinkedDoc, GUID, idPfuInCharge, CanaleNotifica, URL_CLIENT, Caption, FascicoloGenerale 
		, tipodoc as OPEN_DOC_NAME
		,LinkedDoc
			from ctl_doc with(nolock)
			where deleted = 0
				--i doc di VERIFICA_ANOMALIA vengono tolti perchè il linkeddoc deve essere la PDA ed invece è id del lotto (della document_microlotti_dettagli)
				and tipoDoc not in ( 'PDA_VALUTA_LOTTO_TEC','VERIFICA_ANOMALIA', 'OFFERTA_PARTECIPANTI','ESITO_LOTTO_AMMESSA',
				'ESITO_LOTTO_ANNULLA','ESITO_LOTTO_ESCLUSA','ESITO_LOTTO_SCIOGLI_RISERVA','ESITO_LOTTO_VERIFICA','ESITO_RIAMMISSIONE',
				'ESITO_VERIFICA','ESITO_AMMESSA','ESITO_AMMESSA_CON_RISERVA','ESITO_ANNULLA','ESITO_ECO_LOTTO_AMMESSA',
				'ESITO_ECO_LOTTO_ANNULLA','ESITO_ECO_LOTTO_ESCLUSA','ESITO_ECO_LOTTO_VERIFICA','ESITO_ESCLUSA',
				'ESITO_ESCLUSA_MANIFESTAZIONE_INTERESSE','RETT_VALORE_ECONOMICO','RETT_VALORE_LOTTO_AGG',
				'PDA_VALUTA_LOTTO_ECO'
				) 

				and isnull(JumpCheck,'') not in ('0-SOSPENSIONE_ALBO')

	union all


	select vo.Id, vo.IdPfu, vo.IdDoc, vo.TipoDoc, vo.StatoDoc, vo.Data, vo.Protocollo, vo.PrevDoc, vo.Deleted, vo.Titolo, vo.Body, vo.Azienda, vo.StrutturaAziendale, vo.DataInvio, vo.DataScadenza, vo.ProtocolloRiferimento, vo.ProtocolloGenerale, vo.Fascicolo, vo.Note, vo.DataProtocolloGenerale, vo. SIGN_HASH, vo.SIGN_ATTACH, vo.SIGN_LOCK, vo.JumpCheck, vo.StatoFunzionale, vo.Destinatario_User, vo.Destinatario_Azi, vo.RichiestaFirma, vo.NumeroDocumento, vo.DataDocumento, vo.Versione, vo.VersioneLinkedDoc, vo.GUID, vo.idPfuInCharge, vo.CanaleNotifica, vo.URL_CLIENT, vo.Caption, vo.FascicoloGenerale 
		, vo.tipodoc as OPEN_DOC_NAME
		,o.IdHeader as LinkedDoc		
		from ctl_doc vo with(nolock)
			inner join Document_Microlotto_PunteggioLotto p with(nolock) on  p.idRow = vo.LinkedDoc
			inner join Document_MicroLotti_Dettagli l with(nolock) on l.id = p.idHeaderLottoOff
			inner join Document_PDA_OFFERTE o with(nolock) on o.IdRow = l.IdHeader
			inner join ctl_doc pda on o.idheader = pda.id and pda.fascicolo = vo.Fascicolo				
			where vo.deleted = 0 and vo.statofunzionale <> 'InLavorazione'
				and vo.tipodoc in ( 'CAMBIA_OFFERTA' )


     union all

	--doc di verifica anomalia
	select vo.Id, vo.IdPfu, vo.IdDoc, vo.TipoDoc, vo.StatoDoc, vo.Data, vo.Protocollo, vo.PrevDoc, vo.Deleted, 
	     case  isnull(B.Divisione_lotti,'0') 
		  when '0' then  vo.Titolo + ' Lotto ' 
		  else vo.Titolo + ' Lotto ' + l.NumeroLotto 
	     end as titolo, 
		vo.Body, vo.Azienda, vo.StrutturaAziendale, vo.DataInvio, vo.DataScadenza, vo.ProtocolloRiferimento, vo.ProtocolloGenerale, vo.Fascicolo, vo.Note, vo.DataProtocolloGenerale, vo. SIGN_HASH, vo.SIGN_ATTACH, vo.SIGN_LOCK, vo.JumpCheck, vo.StatoFunzionale, vo.Destinatario_User, vo.Destinatario_Azi, vo.RichiestaFirma, vo.NumeroDocumento, vo.DataDocumento, vo.Versione, vo.VersioneLinkedDoc, vo.GUID, vo.idPfuInCharge, vo.CanaleNotifica, vo.URL_CLIENT, vo.Caption, vo.FascicoloGenerale 
		, vo.tipodoc as OPEN_DOC_NAME
		,pda.id as LinkedDoc
		from ctl_doc vo with(nolock)
			inner join Document_MicroLotti_Dettagli l with(nolock) on l.id = vo.linkeddoc and l.tipodoc='PDA_MICROLOTTI'
			inner join ctl_doc pda  with(nolock) on pda.id = l.idheader 
			inner join document_bando B  with(nolock) on B.idheader = pda.linkeddoc 
			where vo.deleted = 0 --and vo.statofunzionale <> 'InLavorazione'
				and vo.tipodoc in ( 'VERIFICA_ANOMALIA','PDA_GRADUATORIA_AGGIUDICAZIONE' )
	
	
	union all

	--doc di subentro azienda
	select 
		vo.Id, vo.IdPfu, vo.IdDoc, vo.TipoDoc, vo.StatoDoc, vo.Data, vo.Protocollo, vo.PrevDoc, vo.Deleted, vo.titolo, 
		vo.Body, vo.Azienda, vo.StrutturaAziendale, vo.DataInvio, vo.DataScadenza, vo.ProtocolloRiferimento, vo.ProtocolloGenerale, vo.Fascicolo, vo.Note, vo.DataProtocolloGenerale, vo. SIGN_HASH, vo.SIGN_ATTACH, vo.SIGN_LOCK, vo.JumpCheck, vo.StatoFunzionale, vo.Destinatario_User, vo.Destinatario_Azi, vo.RichiestaFirma, vo.NumeroDocumento, vo.DataDocumento, vo.Versione, vo.VersioneLinkedDoc, vo.GUID, vo.idPfuInCharge, vo.CanaleNotifica, vo.URL_CLIENT, vo.Caption, vo.FascicoloGenerale 
		, vo.tipodoc as OPEN_DOC_NAME
		,pda.id as LinkedDoc

		from ctl_doc vo with(nolock)
			inner join CTL_DOC_Value SD with (nolock) on SD.IdHeader = vo.id and SD.DSE_ID='LISTA' and SD.DZT_Name='idrow'
			inner join ctl_doc pda  with(nolock) on pda.LinkedDoc = sd.value and pda.TipoDoc='PDA_MICROLOTTI' and pda.Deleted=0
			--inner join document_bando B  with(nolock) on B.idheader = pda.linkeddoc 
			where 
				vo.deleted = 0 and vo.statofunzionale = 'Inviato'
				and vo.tipodoc in ( 'SUBENTRO_AZI' )		

GO
