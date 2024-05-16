USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_CONTRATTO_GARA_DOCUMENT_VIEW]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
















CREATE VIEW [dbo].[OLD_CONTRATTO_GARA_DOCUMENT_VIEW] as 

	select 
		   c.Id, 
		   C.IdPfu, 
		   C.IdDoc, 
		   C.TipoDoc, 
		   C.StatoDoc, 
		   C.Data, 
		   C.Protocollo, 
		   C.PrevDoc, 
		   C.Deleted, 
		   C.Titolo, 
		   C.Body, 
		   C.Azienda, 
		   C.StrutturaAziendale, 
		   C.DataInvio, 
		   c.DataScadenza, 
		   C.ProtocolloRiferimento, 
		   C.ProtocolloGenerale, 
		   C.Fascicolo, 
		   C.Note, 
		   C.DataProtocolloGenerale, 
		   C.LinkedDoc, 
		   C.SIGN_HASH, 
		   C.SIGN_ATTACH, 
		   C.SIGN_LOCK, 
		   C.JumpCheck, 
		   C.StatoFunzionale, 
		   C.Destinatario_User, 
		   C.Destinatario_Azi, 
		   C.RichiestaFirma, 
		   C.NumeroDocumento, 
		   C.DataDocumento, 
		   C.Versione, 
		   C.VersioneLinkedDoc, 
		   C.GUID, 
		   C.idPfuInCharge, 
		   C.CanaleNotifica, 
		   C.URL_CLIENT, 
		   C.Caption,
		   --ISNULL(c1.value,c20.value) as DataRiferimento,
		   ISNULL(sd.DataBando,/*c20.value*/ sc.DataRiferimento) as DataRiferimento,
		   /*c2.value as */ sd.DataRiferimentoInizio,
		   /*c3.value as */ sd.DataRisposta,
		   /*c4.value as */ sd.DataScadenzaOfferta,
		   /*c5.value as */ sd.ProtocolloOfferta,

		   ISNULL(cs.F1_SIGN_HASH,'') as F1_SIGN_HASH,
		   ISNULL(cs.F1_SIGN_LOCK,'') as F1_SIGN_LOCK,
		   ISNULL(cs.F1_SIGN_ATTACH,'') as  F1_SIGN_ATTACH,
		   ISNULL(cs.F2_SIGN_ATTACH,'') as  F2_SIGN_ATTACH,
		   ISNULL(cs.F2_SIGN_HASH,'') as F2_SIGN_HASH,

		   /*c6.value as */ sc.CodiceIPA,
		   /*c7.value as */ sc.firmatario,
		   /*c8.value as */ sc.CF_FORNITORE,
		   /*c9.value as */ sc.PresenzaListino,
		   /*c10.value as */ sc.FascicoloSecondario,
		   /*C11.value as */ sc.Firmatario_OE,
		   ' CodiceIPA , firmatario , CF_FORNITORE , firmatario_OE DataRiferimento Body ' as NotEditable,
		    ISNULL(/*C15.value*/ sd.FROM_INIZIATIVA ,'0') as CONTRATTO_INIZIATIVA,
			ISNULL(L.DZT_ValueDef,'NO') as MONO_ENTE,
			case 
				when  ISNULL(/*C15.value*/ sd.FROM_INIZIATIVA ,'0') = '1' then '' 
				else ' DataRiferimento Body ' 
			end 
			
			+ 

			case 
				when isnull(sc.idpfu_firmatario,'') <> '' then ' firmatario '
				else '' 
			end 
			as NonEditabili,
			
			case when ISNULL(sys2.DZT_ValueDef,'') <> '' then '1' else '0' end as Check_AIC_Enabled,
			case when ma_id is null then '0' else '1' end as PresenzaAIC,
			case when isnull(sc.DataScadenza,'') = '' then 'no' else 'si' end as FlagScadenza
			, STIP.id as idDocStipulaContratto
			, sc.idpfu_firmatario
			,case when dbo.PARAMETRI('SERVICE_REQUEST','TED','ATTIVO','NO',-1) = 'YES' then 1 else 0 end as ted
			
			
			, --case when sc.datastipula <> '' and P_TED.id is not null then 1 else 0 end as CAN_GESTIONE_GUEE
				case when P_TED.id is not null and GUEE.Id is not null then 1 else 0 end as CAN_GESTIONE_GUEE
			 
	from ctl_doc c with(nolock)
			
			--left join ctl_doc_value c1 with(nolock) on c1.idheader=id and c1.DSE_ID='DOCUMENT' and c1.dzt_name='DataBando' and c1.row=0
			--left join ctl_doc_value c2 with(nolock) on c2.idheader=id and c2.DSE_ID='DOCUMENT' and c2.dzt_name='DataRiferimentoInizio' and c2.row=0
			--left join ctl_doc_value c3 with(nolock) on c3.idheader=id and c3.DSE_ID='DOCUMENT' and c3.dzt_name='DataRisposta' and c3.row=0
			--left join ctl_doc_value c4 with(nolock) on c4.idheader=id and c4.DSE_ID='DOCUMENT' and c4.dzt_name='DataScadenzaOfferta' and c4.row=0
			--left join ctl_doc_value c5 with(nolock) on c5.idheader=id and c5.DSE_ID='DOCUMENT' and c5.dzt_name='ProtocolloOfferta' and c5.row=0
			--left join ctl_doc_value c15 with(nolock) on c15.idheader=id and c15.DSE_ID='DOCUMENT' and c15.dzt_name='FROM_INIZIATIVA'
			
			left join CONTRATTO_GARA_DOCUMENT_VIEW_SUB_DOC sd on sd.idheader = c.id
			left join ctl_doc OFFERTA with (nolock) on OFFERTA.protocollo =  sd.ProtocolloOfferta and OFFERTA.deleted=0 and OFFERTA.tipodoc='OFFERTA'
			left join ctl_doc P_TED with (nolock) on P_TED.linkeddoc = OFFERTA.LinkedDoc and  P_TED.tipodoc='PUBBLICA_GARA_TED' and P_TED.StatoFunzionale ='PubTed' and P_TED.deleted=0
			left join ctl_doc_sign cs with(nolock) on cs.idheader=c.id 

			--left join ctl_doc_value c6 with(nolock)  on c6.idheader=id and c6.DSE_ID='CONTRATTO' and c6.dzt_name='CodiceIPA' 
			--left join ctl_doc_value c7 with(nolock)  on c7.idheader=id and c7.DSE_ID='CONTRATTO' and c7.dzt_name='firmatario' 
			--left join ctl_doc_value c8 with(nolock)  on c8.idheader=id and c8.DSE_ID='CONTRATTO' and c8.dzt_name='CF_FORNITORE' 
			--left join ctl_doc_value c11 with(nolock) on c11.idheader=id and c11.DSE_ID='CONTRATTO' and c11.dzt_name='Firmatario_OE' 
			--left join ctl_doc_value c20 with(nolock) on c20.idheader=id and c20.DSE_ID='CONTRATTO' and c20.dzt_name='DataRiferimento' 
			--left join CTL_DOC_Value c9 with(nolock)  on c9.IdHeader = id and c9.DSE_ID = 'CONTRATTO' and c9.DZT_Name = 'PresenzaListino'
			--left join CTL_DOC_Value c10 with(nolock) on c10.IdHeader = id and c10.DSE_ID = 'CONTRATTO' and c10.DZT_Name = 'FascicoloSecondario'

			left join CONTRATTO_GARA_DOCUMENT_VIEW_SUB_CONTRATTO sc on sc.idheader = c.id
			left join LIB_Dictionary L with(nolock)  on L.DZT_Name='SYS_CLIENTE_MONO_ENTE' 

			 --RECUPERA LA SYS_AIC_URL_PAGE
			left join LIB_Dictionary sys2 with (nolock) on sys2.DZT_Name='SYS_AIC_URL_PAGE'
			-- verifica se nel modello c'è la colonna AIC
			left outer join ctl_doc_section_model x with (nolock) on x.IdHeader = c.id and x.DSE_ID = 'BENI'
			left outer join CTL_ModelAttributes  WITH(INDEX(IX_CTL_ModelAttributes_MA_MOD_ID_MA_DZT_Name_MA_DescML_MA_Pos) nolock)    on MA_MOD_ID = x.MOD_Name and MA_DZT_Name = 'CodiceAIC'
			
			left join ctl_doc STIP with (nolock) on STIP.linkeddoc = c.id and STIP.Tipodoc ='VERBALEGARA' and STIP.deleted=0 and STIP.statofunzionale='InLavorazione'

			left join ctl_doc GUEE with (nolock) on GUEE.linkeddoc = c.id and GUEE.Tipodoc ='GESTIONE_GUUE_F03' and GUEE.deleted=0 

	where c.tipodoc like 'CONTRATTO_GARA%' and c.deleted=0




GO
