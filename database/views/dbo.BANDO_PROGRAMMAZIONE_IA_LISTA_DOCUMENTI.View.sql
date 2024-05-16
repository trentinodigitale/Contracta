USE [AFLink_TND]
GO
/****** Object:  View [dbo].[BANDO_PROGRAMMAZIONE_IA_LISTA_DOCUMENTI]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[BANDO_PROGRAMMAZIONE_IA_LISTA_DOCUMENTI] as 


	select d.idrow , 
		[Id], doc.IdPfu, [IdDoc], case when DOC.TipoDoc = 'PROROGA_PROG' then 'PROROGA_PROG_IA' else doc.TipoDoc end as TipoDoc , [StatoDoc], [Data], [Protocollo], [PrevDoc], [Deleted], [Titolo], [Body], [Azienda], [StrutturaAziendale], [DataInvio], [DataScadenza], [ProtocolloRiferimento], [ProtocolloGenerale], [Fascicolo], [Note], [DataProtocolloGenerale], [LinkedDoc], [SIGN_HASH], [SIGN_ATTACH], [SIGN_LOCK], [JumpCheck], [StatoFunzionale], [Destinatario_User], [Destinatario_Azi], [RichiestaFirma], [NumeroDocumento], [DataDocumento], [Versione], [VersioneLinkedDoc], [GUID], [idPfuInCharge], [CanaleNotifica], [URL_CLIENT], [Caption], [FascicoloGenerale], case when DOC.OPEN_DOC_NAME = 'PROROGA_FABB' then 'PROROGA_FABB_IA' else doc.OPEN_DOC_NAME end as [OPEN_DOC_NAME], doc.aziRagioneSociale

		from CTL_DOC_Destinatari d with(nolock) 
			inner join BANDO_SDA_LISTA_DOCUMENTI doc on doc.LinkedDoc = d.idheader 

		where tipoDoc = 'PROROGA_PROG'  AND DOC.StatoFunzionale <> 'InLavorazione'
	
	
GO
