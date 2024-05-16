USE [AFLink_TND]
GO
/****** Object:  View [dbo].[CATALOGO_MEA_DOCUMENT_VIEW]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE view [dbo].[CATALOGO_MEA_DOCUMENT_VIEW] as

	select 
		C.Id, 
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
		C.DataScadenza, 
		--DC.Protocollo as 
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
		c.FascicoloGenerale,
		DC.titolo as DOC_NAME,
		DC.Body as DescrizioneEstesa,
		case when ISNULL(sys2.DZT_ValueDef,'') <> '' then '1' else '0' end as Check_AIC_Enabled,
		case when ma_id is null then '0' else '1' end as PresenzaAIC

	from ctl_doc C with (nolock)

		inner join CTL_DOC DC with (nolock) on C.linkeddoc=DC.id -- ALBO
		--inner join ctl_doc C2 with (nolock) on C2.id=DC.id
		  --RECUPERA LA SYS_AIC_URL_PAGE
		left join LIB_Dictionary sys2 with (nolock) on sys2.DZT_Name='SYS_AIC_URL_PAGE'
		-- verifica se nel modello c'è la colonna AIC
		left outer join ctl_doc_section_model x with (nolock) on x.IdHeader = c.id and x.DSE_ID = 'PRODOTTI'
		left outer join CTL_ModelAttributes  WITH(INDEX(IX_CTL_ModelAttributes_MA_MOD_ID_MA_DZT_Name_MA_DescML_MA_Pos) nolock)    on MA_MOD_ID = x.MOD_Name and MA_DZT_Name = 'CodiceAIC'
		-- ambito

	--	where C.tipodoc='LISTINO_CONVENZIONE'
GO
