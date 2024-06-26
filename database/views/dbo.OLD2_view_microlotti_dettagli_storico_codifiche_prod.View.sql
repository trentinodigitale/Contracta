USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_view_microlotti_dettagli_storico_codifiche_prod]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[OLD2_view_microlotti_dettagli_storico_codifiche_prod]  as
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
				inner join ctl_doc b with(nolock) ON b.tipoDoc = prod.TipoDoc and b.id = prod.IdHeader and b.Deleted = 0 
						and ( 
								b.TipoDoc in ('CODIFICA_PRODOTTO_DOC','CODIFICA_PRODOTTO_ELIMINA', 'CODIFICA_PRODOTTO_RIPRISTINA') 
									OR
								( b.TipoDoc in ('CODIFICA_PRODOTTI') and prod.StatoRiga = 'New_Codificato' )
							)
		where b.StatoDoc <> 'saved'


GO
