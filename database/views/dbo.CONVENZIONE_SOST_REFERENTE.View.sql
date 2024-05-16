USE [AFLink_TND]
GO
/****** Object:  View [dbo].[CONVENZIONE_SOST_REFERENTE]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[CONVENZIONE_SOST_REFERENTE]
AS
	SELECT    A.Id ,
			  A.IdPfu ,
			  A.IdDoc ,
			  A.TipoDoc ,
			  A.StatoDoc ,
			  A.Data ,
			  A.Protocollo ,
			  A.PrevDoc ,
			  A.Deleted ,
			  A.Titolo ,
			  A.Azienda ,
			  A.StrutturaAziendale ,
			  A.DataInvio ,
			  A.DataScadenza ,
			  A.Fascicolo ,
			  A.Note ,
			  A.LinkedDoc ,
			  A.SIGN_HASH ,
			  A.SIGN_ATTACH ,
			  A.SIGN_LOCK ,
			  A.JumpCheck ,
			  A.StatoFunzionale ,
			  A.Destinatario_User ,
			  A.Destinatario_Azi ,
			  A.RichiestaFirma ,
			  A.NumeroDocumento ,
			  A.DataDocumento ,
			  A.Versione ,
			  A.VersioneLinkedDoc ,
			  A.GUID ,
			  A.idPfuInCharge ,
			  A.CanaleNotifica ,
			  A.URL_CLIENT ,
			  A.Caption ,
			  DC.NumOrd ,
			  CC.ProtocolloGenerale ,
			  CC.DataProtocolloGenerale ,
			  DC.DataFine ,
			  DC.TipoConvenzione ,
			  DC.ConAccessori, 
			  dc.DescrizioneEstesa as body,
			  cc.Protocollo as ProtocolloRiferimento
		FROM ctl_doc A with(nolock)
				INNER JOIN document_convenzione DC ON A.linkeddoc = DC.id
				INNER JOIN ctl_doc CC ON DC.id = CC.id
		WHERE A.tipodoc = 'CONV_SOSTITUZIONE_REF'




GO
