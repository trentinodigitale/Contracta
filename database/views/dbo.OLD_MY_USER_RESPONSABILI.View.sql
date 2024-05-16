USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_MY_USER_RESPONSABILI]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[OLD_MY_USER_RESPONSABILI] as 
select p.idpfu , u.idpfu as idFrom from profiliutente p
									inner join profiliutenteattrib a on p.idpfu = a.idpfu and dztnome = 'UserRole' and attvalue = 'PO'
									inner join profiliutente u on p.pfuidazi = u.pfuidazi										
GO
