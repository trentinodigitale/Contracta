USE [AFLink_TND]
GO
/****** Object:  View [dbo].[PDA_COMUNICAZIONE_GARA_TESTATA_VIEW]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[PDA_COMUNICAZIONE_GARA_TESTATA_VIEW] as
Select C1.Id, 
C1.IdPfu, 
C1.IdDoc, 
C1.TipoDoc, 
C1.StatoDoc, 
C1.Data, 
C1.Protocollo, 
C1.PrevDoc, 
C1.Deleted, 
C1.Titolo, 
C1.Body, 
C1.Azienda, 
C1.StrutturaAziendale, 
C1.DataInvio, 
C2.DataScadenza,
C1.ProtocolloRiferimento, 
C1.ProtocolloGenerale, 
C1.Fascicolo, 
C1.Note, 
C1.DataProtocolloGenerale, 
C1.LinkedDoc, 
C1.SIGN_HASH, 
C1.SIGN_ATTACH, 
C1.SIGN_LOCK, 
C1.JumpCheck, 
C1.StatoFunzionale, 
C1.Destinatario_User, 
C1.Destinatario_Azi, 
C1.RichiestaFirma, 
C1.NumeroDocumento,
C1.DataDocumento, 
C1.Versione, 
C1.VersioneLinkedDoc, 
C1.[GUID]

from CTL_DOC C1
inner join CTL_DOC C2 on C1.LinkedDoc=C2.id
where C1.tipodoc like '%PDA_COMUNICAZIONE_GARA%'
GO
