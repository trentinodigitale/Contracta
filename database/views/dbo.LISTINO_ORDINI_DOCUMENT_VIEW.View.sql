USE [AFLink_TND]
GO
/****** Object:  View [dbo].[LISTINO_ORDINI_DOCUMENT_VIEW]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








CREATE view [dbo].[LISTINO_ORDINI_DOCUMENT_VIEW] as

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
		DC.Protocol as ProtocolloRiferimento, 
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
		--referente fornitore e azienda fornitore
		--le prendo sempre dalla convenzione
		--in modo che se cambiano le aggiorno 
		DC.ReferenteFornitore  as Destinatario_User, 
		DC.AZI_Dest as Destinatario_Azi, 
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
		C2.titolo as DOC_NAME,
		DescrizioneEstesa,
		case when ISNULL(sys2.DZT_ValueDef,'') <> '' then '1' else '0' end as Check_AIC_Enabled,
		
		case when M.MA_ID is null then '0' else '1' end as PresenzaAIC,

		case
			when C.tipodoc='LISTINO_ORDINI' then 'Saved'
			else 'Inserito'
		end as StatoRiga
		,case when ISNULL(sys3.DZT_ValueDef,'') <> '' then '1' else '0' end as Check_DM_Enabled
		,case 
			--se nel modello presente attributo CODICE_EAN oppure gli attributi CODICE_ARTICOLO_FORNITORE e NumeroRepertorio
			--att.499231 EP agg che ambito deve essere Dispositivi MEdici
			when ( M1.ma_id is not null or (M2.MA_ID is not null and M3.MA_ID is not null) ) 
				  and isnull(DC.Ambito,'') = '2' then '1' 
			else '0' 
		 end as PresenzaDM 

	from ctl_doc C with (nolock)

		inner join Document_Convenzione DC with (nolock) on C.linkeddoc=DC.id
		inner join ctl_doc C2 with (nolock) on C2.id=DC.id
		--RECUPERA LA SYS_AIC_URL_PAGE
		left join LIB_Dictionary sys2 with (nolock) on sys2.DZT_Name='SYS_AIC_URL_PAGE'
		-- verifica se nel modello c'è la colonna AIC
		left outer join ctl_doc_section_model x with (nolock) on x.IdHeader = c.id and x.DSE_ID = 'PRODOTTI'
		left outer join CTL_ModelAttributes M WITH(INDEX(IX_CTL_ModelAttributes_MA_MOD_ID_MA_DZT_Name_MA_DescML_MA_Pos) nolock)    on M.MA_MOD_ID = x.MOD_Name and M.MA_DZT_Name = 'CodiceAIC'
		
		--RECUPERA LA SYS_DM_URL_PAGE
		left join LIB_Dictionary sys3 with (nolock) on sys3.DZT_Name='SYS_DM_URL_PAGE'
		left outer join CTL_ModelAttributes M1 WITH(INDEX(IX_CTL_ModelAttributes_MA_MOD_ID_MA_DZT_Name_MA_DescML_MA_Pos) nolock)    on M1.MA_MOD_ID = x.MOD_Name and M1.MA_DZT_Name = 'CODICE_EAN'
		left outer join CTL_ModelAttributes M2 WITH(INDEX(IX_CTL_ModelAttributes_MA_MOD_ID_MA_DZT_Name_MA_DescML_MA_Pos) nolock)    on M2.MA_MOD_ID = x.MOD_Name and M2.MA_DZT_Name = 'CODICE_ARTICOLO_FORNITORE'
		left outer join CTL_ModelAttributes M3 WITH(INDEX(IX_CTL_ModelAttributes_MA_MOD_ID_MA_DZT_Name_MA_DescML_MA_Pos) nolock)    on M3.MA_MOD_ID = x.MOD_Name and M3.MA_DZT_Name = 'NumeroRepertorio'

	where 
		C.tipodoc in ('LISTINO_ORDINI','LISTINO_ORDINI_OE')
GO
