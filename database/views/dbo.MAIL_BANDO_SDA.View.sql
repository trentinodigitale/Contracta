USE [AFLink_TND]
GO
/****** Object:  View [dbo].[MAIL_BANDO_SDA]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[MAIL_BANDO_SDA]
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
P.pfunome as Nome,
ImportoBando as ImportoRichiesto

FROM         
ctl_doc 
inner join Aziende on Azienda=IdAzi
inner join ProfiliUtente P on P.idpfu=CTL_DOC.idpfu
inner join dbo.Document_Bando DB on DB.idHeader=ctl_doc.ID
where TipoDoc='BANDO_SDA' and CTL_DOC.deleted=0 

GO
