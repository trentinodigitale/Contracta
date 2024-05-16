USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_VIEW_DOCUMENT_MAIL_A_SISTEMA]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[OLD2_VIEW_DOCUMENT_MAIL_A_SISTEMA] AS
select 
		*,
		MailData as DataDA ,
		MailData as DataA ,
		TypeDoc as DocType,
		IdDoc as IdProgetto
	from CTL_Mail_System with(nolock)
GO
