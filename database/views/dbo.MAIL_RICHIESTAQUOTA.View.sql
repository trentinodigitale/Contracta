USE [AFLink_TND]
GO
/****** Object:  View [dbo].[MAIL_RICHIESTAQUOTA]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

---------------------------------------------------------------
--
---------------------------------------------------------------

CREATE VIEW [dbo].[MAIL_RICHIESTAQUOTA]
AS
SELECT    
CTL_DOC.ID as IdHeader,
CTL_DOC.Id as IDDOC, 
'I' as LNG,
CTL_DOC.IdPfu, 
TipoDoc, 
StatoDoc, 
Data, 
Protocollo, 
PrevDoc, 
Titolo, 
Body, 
Azienda, 
StrutturaAziendale, 
convert( varchar , DataInvio , 103 ) as DataInvio, 
DataScadenza, 
C.Protocol as ProtocolloRiferimento, 
ProtocolloGenerale, 
Fascicolo, 
Note, 
DataProtocolloGenerale, 
LinkedDoc, 
SIGN_HASH, 
SIGN_ATTACH, 
SIGN_LOCK, 
JumpCheck, 
StatoFunzionale, Destinatario_User, Destinatario_Azi ,
Document_Convenzione_Quote.Importo,
Document_Convenzione_Quote.ImportoRichiesto,
Document_Convenzione_Quote.Motivazione,
C.NumOrd,
C.Doc_name as BodyContratto,
C.Total ,
P.pfunome as Nome

FROM         
ctl_doc 
inner join Aziende on Azienda=IdAzi
inner join ProfiliUtente P on P.idpfu=CTL_DOC.idpfu
inner join document_convenzione C on LinkedDoc=C.ID
left join Document_Convenzione_Quote on Document_Convenzione_Quote.idHeader=CTL_DOC.ID
where TipoDoc='RICHIESTAQUOTA' and CTL_DOC.deleted=0 and statodoc='Sended'
GO
