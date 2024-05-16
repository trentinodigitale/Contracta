USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OFFERTA_AMPIEZZA_DI_GAMMA_DOCUMENT_VIEW]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








CREATE view [dbo].[OFFERTA_AMPIEZZA_DI_GAMMA_DOCUMENT_VIEW] as

	select 
		C.Id, 
		C.IdPfu, 
		C.TipoDoc, 
		C.StatoDoc, 
		C.Data, 
		C.Protocollo, 
		C.PrevDoc, 
		C.Deleted, 
		C.Titolo, 
		C.Body as Descrizione, 
		C.Azienda, 
		C.StrutturaAziendale, 
		C.DataInvio, 
		C.DataScadenza, 	
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
		(select top 1 items from dbo.Split( C.VersioneLinkedDoc, '-') order by ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) asc) as Lotto,
		(select top 1 items  from dbo.Split( C.VersioneLinkedDoc, '-') order by ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) desc) as Voce

		,case when ISNULL(sys3.DZT_ValueDef,'') <> '' then '1' else '0' end as Check_DM_Enabled
		,case 
			--se nel modello presente attributo CODICE_EAN oppure gli attributi CODICE_ARTICOLO_FORNITORE e NumeroRepertorio
			when ( M2.ma_id is not null  )
					and isnull(pp.Valore ,'') = '1' 
						then '1' 
			else '0' 
		 end as PresenzaDM ,

		 case when ISNULL(sys2.DZT_ValueDef,'') <> '' then '1' else '0' end as Check_AIC_Enabled,

		 case when m1.ma_id is null then '0' else '1' end as PresenzaAIC,

		 case when ISNULL(dm.id, '') = '' then '0' else '1' end as Check_DM_Elaborato,

		 case when ISNULL(aic.id, '') = '' then '0' else '1' end as Check_AIC_Elaborato

			from ctl_doc C with (nolock)		
				
				--left outer join ctl_doc d with (nolock) on d.Id = C.LinkedDoc and d.Deleted = 0 and d.TipoDoc = 'OFFERTA'

				left join LIB_Dictionary sys3 with (nolock) on sys3.DZT_Name='SYS_DM_URL_PAGE'
				-- modello dinamico offerta
				--left outer join ctl_doc_section_model x with (nolock) on x.IdHeader = d.id and x.DSE_ID = 'PRODOTTI'			
				left outer join ctl_doc_section_model x with (nolock) on x.IdHeader = c.id and x.DSE_ID = 'PRODOTTI'	
				left outer join CTL_ModelAttributes M2  WITH(INDEX(IX_CTL_ModelAttributes_MA_MOD_ID_MA_DZT_Name_MA_DescML_MA_Pos) nolock)    on m2.MA_MOD_ID = x.MOD_Name and m2.MA_DZT_Name = 'NumeroRepertorio' -- in ( 'CODICE_REGIONALE' ,'NumeroRepertorio')
				left outer join CTL_ModelAttributes M1  WITH(INDEX(IX_CTL_ModelAttributes_MA_MOD_ID_MA_DZT_Name_MA_DescML_MA_Pos) nolock)    on m1.MA_MOD_ID = x.MOD_Name and m1.MA_DZT_Name = 'CodiceAIC'


				left join CTL_Parametri pp with (nolock) on Contesto = 'OFFERTA' and Oggetto = 'PRODOTTI' and Proprieta = 'DM_ACTIVE'

				left join LIB_Dictionary sys2 with (nolock) on sys2.DZT_Name='SYS_AIC_URL_PAGE'

				left join CTL_DOC as dm with (nolock) on dm.LinkedDoc = C.Id and dm.TipoDoc = 'DM_POPOLAMENTO' and dm.JumpCheck = 'OFFERTA_AMPIEZZA_DI_GAMMA' and dm.StatoFunzionale = 'Completato'
				
				left join CTL_DOC as aic with (nolock) on aic.LinkedDoc = C.Id and aic.TipoDoc = 'AIC_POPOLAMENTO' and aic.JumpCheck = 'OFFERTA_AMPIEZZA_DI_GAMMA' and aic.StatoFunzionale = 'Completato'
				
					where C.tipodoc in ('OFFERTA','OFFERTA_AMPIEZZA_DI_GAMMA', 'OFFERTA_AMPIEZZA_DI_GAMMA_TEC', 'OFFERTA_AMPIEZZA_DI_GAMMA_ECO')
GO
