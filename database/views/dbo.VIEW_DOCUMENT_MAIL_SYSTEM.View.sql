USE [AFLink_TND]
GO
/****** Object:  View [dbo].[VIEW_DOCUMENT_MAIL_SYSTEM]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VIEW_DOCUMENT_MAIL_SYSTEM] as 
select ID,
	   IDDOC,	
	   TypeDoc,
	   MailGuid,
	   MailFrom,
	   MailTo, 
	   MailObject as oggetto, 
	   MailBody, 
	   MailCC, 
	   MailCCn, 
	   MailData, 
	   MailObj, 
	   IdPfuMitt, 
	   IdPfuDest, 
	   Status, 
	   IsFromPec, 
	   IsToPec, 
	   InOut, 
	   deleted
      
    from CTL_Mail_System
GO
