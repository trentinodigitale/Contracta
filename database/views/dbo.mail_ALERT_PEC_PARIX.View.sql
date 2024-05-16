USE [AFLink_TND]
GO
/****** Object:  View [dbo].[mail_ALERT_PEC_PARIX]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[mail_ALERT_PEC_PARIX] as 
	select sessionid as IdDoc, valore as NuovaEmail from FormRegistrazione where nome_campo = 'EMail' and isnull(valore,'') <> ''
GO
