USE [AFLink_TND]
GO
/****** Object:  View [dbo].[MAIL_BANDO_QF]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[MAIL_BANDO_QF]
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
,APS_NOTE

FROM         
ctl_doc 
inner join Aziende on Azienda=IdAzi
inner join ProfiliUtente P on P.idpfu=CTL_DOC.idpfu
inner join dbo.Document_Bando DB on DB.idHeader=ctl_doc.ID
left join (select A.APS_NOTE,A.APS_ID_DOC from CTL_APPROVALSteps A, (Select MAX(APS_ID_ROW) as APS_ID_ROW,APS_ID_DOC from CTL_APPROVALSteps where APS_State <> 'Sent' group by APS_ID_DOC )B where A.APS_ID_ROW=B.APS_ID_ROW) C on ctl_doc.ID=C.APS_ID_DOC  
where TipoDoc='BANDO_QF' and CTL_DOC.deleted=0 


GO
