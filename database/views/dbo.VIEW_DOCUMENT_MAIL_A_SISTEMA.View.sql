USE [AFLink_TND]
GO
/****** Object:  View [dbo].[VIEW_DOCUMENT_MAIL_A_SISTEMA]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VIEW_DOCUMENT_MAIL_A_SISTEMA] AS
select 
		
		
		ID, TypeDoc, IdDoc, MailGuid, MailFrom, MailTo, MailObject, 
		[dbo].[StripHTML]( MailBody ) as MailBody, MailCC, MailCCn, MailData,
		 MailObj , 
		 
		 IdPfuMitt, IdPfuDest, Status, IsFromPec, IsToPec, InOut, deleted, DescrError, DataUpdate, NumRetry, idAziDest, DataSent,
		
		MailData as DataDA ,
		MailData as DataA ,
		TypeDoc as DocType,
		IdDoc as IdProgetto


	from CTL_Mail_System with(nolock)
GO
