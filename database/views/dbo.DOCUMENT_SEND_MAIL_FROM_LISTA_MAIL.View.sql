USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DOCUMENT_SEND_MAIL_FROM_LISTA_MAIL]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[DOCUMENT_SEND_MAIL_FROM_LISTA_MAIL] as 

select 
	   ID ,
       MailTo  as SIGN_HASH,
      'I: ' + substring(MailObject,0,(CHARINDEX('GUID', MailObject))) as  Titolo,
       MailBody as Body ,
       id as ID_FROM,
       ID as LinkedDoc,
       MailObj as SIGN_ATTACH ,
       'DOCUMENT_MAIL_INOLTRO' as TipoDoc
       
from
CTL_Mail_System



GO
