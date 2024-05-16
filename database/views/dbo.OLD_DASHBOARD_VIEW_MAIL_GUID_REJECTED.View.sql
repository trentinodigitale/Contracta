USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_DASHBOARD_VIEW_MAIL_GUID_REJECTED]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE view [dbo].[OLD_DASHBOARD_VIEW_MAIL_GUID_REJECTED] as 
select 
       ID,
       TypeDoc,
       --isnull(b.mfidmsg,CTL_Mail_System.iddoc) as IdDoc,
       IdDoc,
       MailGuid, 
       MailFrom, 
       MailTo, 
       MailObject as Oggetto , 
       MailBody, 
       MailCC, 
       MailCCn, 
       MailData, 
       MailObj, 
       IdPfuMitt, 
       IdPfuDest, 
       [Status], 
       IsFromPec, 
       IsToPec, 
       InOut, 
       aziRagioneSociale,
       case when idAziDest is not null then idAziDest else  idazi end as idazi,
       idpfu,
       'DOCUMENT_MAIL_SYSTEM' as OPEN_DOC_NAME
       
from dbo.CTL_Mail_System  
		left join  ProfiliUtente on IdPfuDest=IdPfu
		left join  aziende on pfuIdAzi=idazi or idAziDest = idazi	
		--left outer join messagefields a on a.mfidmsg=CTL_Mail_System.iddoc and a.mfFieldName='IdDoc'
		--left outer join messagefields b on  b.mfFieldName='IdDoc' and a.mfFieldValue=b.mfFieldValue
--where TypeDoc <> 'MAIL_REJECTED' and TypeDoc <> 'MAIL_REJECTED_REPLY'
where deleted=0








GO
