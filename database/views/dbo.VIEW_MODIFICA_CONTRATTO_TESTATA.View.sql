USE [AFLink_TND]
GO
/****** Object:  View [dbo].[VIEW_MODIFICA_CONTRATTO_TESTATA]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[VIEW_MODIFICA_CONTRATTO_TESTATA]
as

select 
	[Id], [IdPfu], [IdDoc], [TipoDoc], [StatoDoc], [Data], [Protocollo], [PrevDoc], [Deleted], [Titolo], [Body], [Azienda], [StrutturaAziendale], [DataInvio],  [ProtocolloRiferimento], [ProtocolloGenerale], [Fascicolo], [Note], [DataProtocolloGenerale], [LinkedDoc], [SIGN_HASH], [SIGN_ATTACH], [SIGN_LOCK], [JumpCheck], [StatoFunzionale], [Destinatario_User], [Destinatario_Azi], [RichiestaFirma], [NumeroDocumento], [DataDocumento], [Versione], [VersioneLinkedDoc], [GUID], [idPfuInCharge], [CanaleNotifica], [URL_CLIENT], [Caption], [FascicoloGenerale], [CRYPT_VER]
	,
	MD.Value as DataStipula,
	MD1.Value as DataScadenza
	from 
		CTL_DOC M with (nolock)
		left join CTL_DOC_Value MD with (nolock) on MD.IdHeader = M.Id  and MD.DZT_Name ='DataStipula'
		left join CTL_DOC_Value MD1 with (nolock) on MD1.IdHeader = M.Id  and MD1.DZT_Name ='DataScadenza'

	where M.TipoDoc='MODIFICA_CONTRATTO'
GO
