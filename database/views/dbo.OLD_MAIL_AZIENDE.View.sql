USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_MAIL_AZIENDE]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[OLD_MAIL_AZIENDE] AS
	select IdAzi as idDoc,'I' as LNG,  * from Aziende with(nolock)

GO
