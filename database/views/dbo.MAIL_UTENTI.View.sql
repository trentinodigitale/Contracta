USE [AFLink_TND]
GO
/****** Object:  View [dbo].[MAIL_UTENTI]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[MAIL_UTENTI] AS
	select IdPfu as idDoc,'I' as LNG, * from ProfiliUtente with(nolock)
GO
