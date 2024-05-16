USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_MAIL_ISCRIZIONE_ISTANZA_ALBOOperaEco]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[OLD_MAIL_ISCRIZIONE_ISTANZA_ALBOOperaEco]
AS
SELECT    
CTL_DOC.ID as IdHeader,
CTL_DOC.Id as IDDOC, 
'I' as LNG,
CTL_DOC.IdPfu, 
case when ISNULL(convert(nvarchar(2000),ML_DESCRIPTION),'')='' then TipoDoc else ML_DESCRIPTION end as TipoDoc, 
StatoDoc, 
Data, 
Titolo, 
Body, 
Azienda, 
convert( varchar , DataInvio , 103 ) as DataInvio, 
Fascicolo, 
Note, 
DataProtocolloGenerale, 
LinkedDoc, 
SIGN_HASH, 
SIGN_ATTACH, 
SIGN_LOCK, 
JumpCheck, 
StatoFunzionale, Destinatario_User, Destinatario_Azi ,
aziragionesociale,
APS_NOTE

FROM         
ctl_doc 
inner join ProfiliUtente P on P.idpfu=CTL_DOC.idpfu
left join Aziende on Destinatario_Azi=IdAzi
left join dbo.LIB_Multilinguismo on TipoDoc=Ml_Key
left join (select A.APS_NOTE,A.APS_ID_DOC from CTL_APPROVALSteps A, (Select MAX(APS_ID_ROW) as APS_ID_ROW,APS_ID_DOC from CTL_APPROVALSteps where APS_State <> 'Sent' group by APS_ID_DOC )B where A.APS_ID_ROW=B.APS_ID_ROW) C on ctl_doc.ID=C.APS_ID_DOC  
where CTL_DOC.deleted=0 




GO
