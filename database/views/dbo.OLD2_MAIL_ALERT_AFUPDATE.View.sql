USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_MAIL_ALERT_AFUPDATE]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[OLD2_MAIL_ALERT_AFUPDATE] AS
	SELECT contesto,data,descrizione, id as idDoc, 'I' as LNG
	FROM CTL_TRACE WITH(NOLOCK)
GO
