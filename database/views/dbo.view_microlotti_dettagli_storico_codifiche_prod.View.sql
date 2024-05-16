USE [AFLink_TND]
GO
/****** Object:  View [dbo].[view_microlotti_dettagli_storico_codifiche_prod]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE view [dbo].[view_microlotti_dettagli_storico_codifiche_prod]  as
	select 
		b.Id, 
		IdPfu, 
		IdDoc, 
		isnull(b.caption,b.TipoDoc) as TipoDoc,
		StatoDoc, 
		Data, 
		Protocollo, 
		PrevDoc, 
		Deleted, 
		Titolo, 
		Body, 
		Azienda, 
		StrutturaAziendale, 
		DataInvio, 
		DataScadenza, 
		ProtocolloRiferimento, 
		ProtocolloGenerale, 
		Fascicolo, 
		Note, 
		DataProtocolloGenerale, 
		LinkedDoc, 
		SIGN_HASH, 
		SIGN_ATTACH, 
		SIGN_LOCK, 
		JumpCheck, 
		StatoFunzionale, 
		Destinatario_User, 
		Destinatario_Azi, 
		RichiestaFirma, 
		NumeroDocumento, 
		DataDocumento, 
		Versione, 
		VersioneLinkedDoc, 
		GUID, 
		idPfuInCharge, 
		CanaleNotifica, 
		URL_CLIENT, 
		Caption, 
		FascicoloGenerale,
		a.id as idProdotto, 
		case when b.TipoDoc = 'CODIFICA_PRODOTTO_RIPRISTINA' then '' else b.TipoDoc end as OPEN_DOC_NAME

		from Document_MicroLotti_Dettagli a WITH(NOLOCK) 
				inner join Document_MicroLotti_Dettagli prod WITH(NOLOCK) ON prod.CODICE_REGIONALE = a.CODICE_REGIONALE 
				inner join ctl_doc b with(nolock) ON 
						
						( 
							b.tipoDoc = prod.TipoDoc and b.id = prod.IdHeader and b.Deleted = 0 
							and ( 
									b.TipoDoc in ('CODIFICA_PRODOTTO_DOC','CODIFICA_PRODOTTO_ELIMINA', 'CODIFICA_PRODOTTO_RIPRISTINA') 
										OR
									( b.TipoDoc in ('CODIFICA_PRODOTTI') and prod.StatoRiga = 'New_Codificato' )
										OR
									( b.TipoDoc in ('CARICA_MACROPRODOTTI') and prod.StatoRiga = 'New_Codificato' and a.idHeaderLotto =  prod.id )
								)
							
						)
								
		where b.StatoDoc <> 'saved'


		union all 
		--collego i documenti di tipo AGGIORNA_CODIFICHE
		select 
			DOC.Id, 
			IdPfu, 
			IdDoc, 
			DOC.TipoDoc,
			StatoDoc, 
			Data, 
			Protocollo, 
			PrevDoc, 
			Deleted, 
			Titolo, 
			Body, 
			Azienda, 
			StrutturaAziendale, 
			DataInvio, 
			DataScadenza, 
			ProtocolloRiferimento, 
			ProtocolloGenerale, 
			Fascicolo, 
			Note, 
			DataProtocolloGenerale, 
			LinkedDoc, 
			SIGN_HASH, 
			SIGN_ATTACH, 
			SIGN_LOCK, 
			JumpCheck, 
			StatoFunzionale, 
			Destinatario_User, 
			Destinatario_Azi, 
			RichiestaFirma, 
			NumeroDocumento, 
			DataDocumento, 
			Versione, 
			VersioneLinkedDoc, 
			GUID, 
			idPfuInCharge, 
			CanaleNotifica, 
			URL_CLIENT, 
			Caption, 
			FascicoloGenerale,
			PROD.id as idProdotto, 
			DOC.TipoDoc as OPEN_DOC_NAME
			from Document_MicroLotti_Dettagli PROD WITH(NOLOCK)
					inner join ctl_doc_value AGG_COD WITH(NOLOCK) on AGG_COD.dse_id='PRODOTTI_AGGIORNATI' and AGG_COD.DZT_Name ='IdProdotto' and AGG_COD.value = PROD.id
					inner join ctl_doc DOC WITH(NOLOCK) on doc.Tipodoc='AGGIORNA_CODIFICHE' and doc.id =AGG_COD.idheader 
			where DOC.statofunzionale='Confermato' and doc.deleted=0

GO
