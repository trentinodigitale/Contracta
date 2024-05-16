USE [AFLink_TND]
GO
/****** Object:  View [dbo].[VIEW_SIMOG_TEST_LOGIN_RPNT]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VIEW_SIMOG_TEST_LOGIN_RPNT] AS 
	select a.id,
			c.pfuCodiceFiscale as USR_LOGINRPNT,
			d.Value as PWD_LOGINRPNT 
		from ctl_doc a with(nolock)
				inner join ctl_doc_value b with(nolock) on b.IdHeader = a.id and b.DSE_ID = 'DATI' and b.DZT_Name = 'UserRUP'
				inner join profiliutente c with(nolock) on c.idpfu = b.Value
				inner join ctl_doc_value d with(nolock) on d.IdHeader = a.id and d.DSE_ID = 'DATI' and d.DZT_Name = 'Password'
		where a.tipodoc = 'SIMOG_RPNT'
GO
