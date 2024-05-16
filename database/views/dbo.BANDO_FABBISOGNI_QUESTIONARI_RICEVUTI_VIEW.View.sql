USE [AFLink_TND]
GO
/****** Object:  View [dbo].[BANDO_FABBISOGNI_QUESTIONARI_RICEVUTI_VIEW]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[BANDO_FABBISOGNI_QUESTIONARI_RICEVUTI_VIEW] as 
	select  c.Id,c.IdPfu,c.IdDoc,
			case when c.TipoDoc in (  'PDA_MICROLOTTI' , 'RICHIESTA_CIG' , 'ANNULLA_RICHIESTA_CIG' ) and isnull( c.Caption , '' ) <> '' THEN c.Caption else c.TipoDoc end as TipoDoc,
			c.StatoDoc,c.Data,c.Protocollo,c.PrevDoc,c.Deleted,c.Titolo,c.Body,c.Azienda,
			c.StrutturaAziendale,c.DataInvio,c.DataScadenza,c.ProtocolloRiferimento,c.ProtocolloGenerale,c.Fascicolo,c.Note,
			c.DataProtocolloGenerale,c.LinkedDoc,c.SIGN_HASH,c.SIGN_ATTACH,c.SIGN_LOCK,c.JumpCheck,c.StatoFunzionale,c.Destinatario_User,
			c.Destinatario_Azi,c.RichiestaFirma,c.NumeroDocumento,c.DataDocumento,c.Versione,c.VersioneLinkedDoc,c.GUID,c.idPfuInCharge,
			c.CanaleNotifica,c.URL_CLIENT,c.Caption,c.FascicoloGenerale
			, tipodoc as OPEN_DOC_NAME
			, isnull( az1.aziRagionesociale, az2.aziRagioneSociale) as aziRagioneSociale

		from ctl_doc c with (nolock)
	
			left outer join  aziende az1 with (nolock) on azienda = az1.idazi
			left outer join  aziende az2 with (nolock) on Destinatario_Azi = az2.idazi
			left join document_bando b with(nolock) on b.idHeader = c.id

		where 
			deleted = 0 
			and tipodoc in ( 'QUESTIONARIO_FABBISOGNI' )
			and StatoFunzionale not in ( 'Annullato','InLavorazione')


GO
