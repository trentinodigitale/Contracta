USE [AFLink_TND]
GO
/****** Object:  View [dbo].[ISTANZA_SDA_FARMACI_VIEW]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE  view [dbo].[ISTANZA_SDA_FARMACI_VIEW] as

	select   
		--d.*
		[Id], [IdPfu], [IdDoc], [TipoDoc], [StatoDoc], [Data], [Protocollo], [PrevDoc], [Deleted], [Titolo], [Body], [Azienda], [StrutturaAziendale], [DataInvio], [DataScadenza], [ProtocolloRiferimento], [ProtocolloGenerale], [Fascicolo], [Note], [DataProtocolloGenerale], [LinkedDoc], [SIGN_HASH], [SIGN_ATTACH], [SIGN_LOCK], [JumpCheck],
		 [Destinatario_User], [Destinatario_Azi], [RichiestaFirma], [NumeroDocumento], [DataDocumento], [Versione], [VersioneLinkedDoc], [GUID], 
		 [idPfuInCharge], [CanaleNotifica], [URL_CLIENT], [Caption], [FascicoloGenerale]
		
		,isnull( p.value ,[StatoFunzionale] ) as StatoFunzionale, 
		
		DSE_ID='DISPLAY_FIRMA',d.id as idheader
		,SIGN_ATTACH as Attach
		,TipoBando
		, v.Value as DataScadenzaIstanza
		, dbo.Get_PIVA_Obbligatoria(azienda) as PIVA_Obbligatoria

		, d.BANDO_SCADUTO --questa colonna era stata omessa per errore (credo), ma è utilizzata nelle condizioni della toolbar. quindi è stata introdotta di nuovo.
							-- nella versione vb6 non dava errore mentre in quella c# si

		from CTL_DOC_VIEW d
				inner join Document_Bando with(nolock) on linkedDoc = idHeader
				left outer join CTL_DOC_VALUE v with(nolock) on d.id = v.IdHeader and DSE_ID = 'SCADENZA_ISTANZA' and v.DZT_Name = 'DataScadenzaIstanza'
				left outer join CTL_DOC_VALUE P with(nolock) on d.id = p.IdHeader and p.DSE_ID = 'PROROGA' and p.DZT_Name = 'StatoFunzionale'
		where tipodoc like 'ISTANZA_%'
			


GO
