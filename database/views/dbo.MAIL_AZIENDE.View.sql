USE [AFLink_TND]
GO
/****** Object:  View [dbo].[MAIL_AZIENDE]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[MAIL_AZIENDE] AS
	select IdAzi as idDoc,'I' as LNG,  * from Aziende with(nolock)
GO
