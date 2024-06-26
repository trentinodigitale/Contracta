USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_VIEW_CONVENZIONE_DOCUMENTI]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[OLD2_VIEW_CONVENZIONE_DOCUMENTI] 
AS
SELECT 
	C.Id, 
	C.IdPfu, C.IdDoc, C.TipoDoc, C.StatoDoc, C.Data, C.Protocollo, C.PrevDoc, C.Deleted, 
	C.Titolo, C.Body, C.Azienda, C.StrutturaAziendale, C.DataInvio, C.DataScadenza, C.ProtocolloRiferimento, 
	C.Fascicolo, C.Note,  C.LinkedDoc, C.SIGN_HASH, 
	C.SIGN_ATTACH, C.SIGN_LOCK, C.JumpCheck, C.StatoFunzionale, C.Destinatario_User, C.Destinatario_Azi, 
	C.RichiestaFirma, C.NumeroDocumento, C.DataDocumento, C.Versione, C.VersioneLinkedDoc, C.GUID, C.idPfuInCharge, C.CanaleNotifica, C.URL_CLIENT, 
	C.Caption
	,DC.NumOrd
	,CC.ProtocolloGenerale
	,CC.DataProtocolloGenerale
	,DC.DataFine
	,DC.TipoConvenzione
	,DC.ConAccessori

	, case when ISNULL(sys2.DZT_ValueDef,'') <> '' then '1' else '0' end as Check_AIC_Enabled
	, case when ma_id is null then '0' else '1' end as PresenzaAIC

	, case 
		when DC.GestioneQuote <> 'senzaquote' and CL.IdConv is not null then '1' else '0'
	   end as Show_AggiornaQuote
	, Lo.id as idDocListinoOrdini

	from ctl_doc C with (nolock)
		 	inner join document_convenzione DC with (nolock) on C.linkeddoc=DC.id
				inner join ctl_doc CC with (nolock) on DC.id=CC.id	

				 --RECUPERA LA SYS_AIC_URL_PAGE
				left join LIB_Dictionary sys2 with (nolock) on sys2.DZT_Name='SYS_AIC_URL_PAGE'
				-- verifica se nel modello c'è la colonna AIC
				left outer join ctl_doc_section_model x with (nolock) on x.IdHeader = cc.id and x.DSE_ID = 'PRODOTTI'
				left outer join CTL_ModelAttributes  WITH(INDEX(IX_CTL_ModelAttributes_MA_MOD_ID_MA_DZT_Name_MA_DescML_MA_Pos) nolock)    on MA_MOD_ID = x.MOD_Name and MA_DZT_Name = 'CodiceAIC'
	
				left join
				 ( select distinct  idHeader as IdConv from document_convenzione_lotti with (nolock) ) 
					CL on cl.IdConv = dc.id

				left join ctl_doc LO with (nolock) on LO.LinkedDoc = CC.id and LO.TipoDoc = 'LISTINO_ORDINI' 
														and LO.Deleted = 0 and LO.StatoFunzionale ='Confermato'

	where C.tipodoc like ('CONVENZIONE%')

GO
