USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_MAIL_ALERT_AFUPDATE]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[OLD_MAIL_ALERT_AFUPDATE] AS
	SELECT 
		contesto,
		data,
		descrizione, 
		CTL_TRACE.id as idDoc,
		'I' as LNG,
		l1.DZT_ValueDef as cliente,
		l2.DZT_ValueDef as ambiente

	FROM CTL_TRACE WITH(NOLOCK),
		LIB_Dictionary l1 WITH(NOLOCK) ,
		LIB_Dictionary l2 WITH(NOLOCK)
	where l1.DZT_Name='SYS_NOMEPORTALE' and l2.DZT_Name='SYS_AFUPDATE_AMBIENTE'
GO
