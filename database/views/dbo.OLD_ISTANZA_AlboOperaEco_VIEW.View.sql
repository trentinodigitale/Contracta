USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_ISTANZA_AlboOperaEco_VIEW]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE  view [dbo].[OLD_ISTANZA_AlboOperaEco_VIEW] as
	select   
		--d.*,
	[Id], [IdPfu], [IdDoc], [TipoDoc], [StatoDoc], [Data], [Protocollo], [PrevDoc], [deleted], [Titolo], [Body], [Azienda], [StrutturaAziendale], [DataInvio], [DataScadenza], [ProtocolloRiferimento], [ProtocolloGenerale], [Fascicolo], [Note], [DataProtocolloGenerale], [LinkedDoc], [SIGN_HASH], [SIGN_ATTACH], [SIGN_LOCK], [JumpCheck], 
	
	isnull( p.value ,[StatoFunzionale] ) as StatoFunzionale, 
	
	[Destinatario_User], [Destinatario_Azi], [DATACORRENTE], [RichiestaFirma], [NumeroDocumento], [DataDocumento], [Versione], [VersioneLinkedDoc], [GUID], [idPfuInCharge], [ResponsabileProcedimento], [CanaleNotifica], [BANDO_SCADUTO], [CAN_CONFERMA], [UserRUP], [SCADENZA_INVIO_OFFERTE], [Caption], [BANDO_REVOCATO], [FascicoloGenerale], [URL_CLIENT], [Anagrafica_Master], [DISATTIVA_DATI_PARIX], [numrisposte], [ATTIVA_MODULO_CONTROLLI_OE], [FreqControlli]	
		
		
		
		,'DISPLAY_FIRMA' as DSE_ID,d.id as idheader
		,SIGN_ATTACH as Attach
		, v.Value as DataScadenzaIstanza
		, dbo.Get_PIVA_Obbligatoria(azienda) as PIVA_Obbligatoria
	from CTL_DOC_VIEW d
		left outer join CTL_DOC_VALUE v on d.id = v.IdHeader and v.DSE_ID = 'SCADENZA_ISTANZA' and v.DZT_Name = 'DataScadenzaIstanza'
		left outer join CTL_DOC_VALUE P on d.id = p.IdHeader and p.DSE_ID = 'PROROGA' and p.DZT_Name = 'StatoFunzionale'

GO
