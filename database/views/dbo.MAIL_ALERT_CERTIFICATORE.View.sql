USE [AFLink_TND]
GO
/****** Object:  View [dbo].[MAIL_ALERT_CERTIFICATORE]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[MAIL_ALERT_CERTIFICATORE] as 
    select id, id as iddoc, Parametri as Certificatore, 'I' as LNG
	   from ctl_log_proc 
	    where proc_name = 'ALERT_CERTIFICATORE'
               and DOC_NAME = 'CIVETTA'
GO
