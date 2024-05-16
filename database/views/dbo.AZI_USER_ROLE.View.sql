USE [AFLink_TND]
GO
/****** Object:  View [dbo].[AZI_USER_ROLE]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[AZI_USER_ROLE] as
	
	select 
		 
		p.idpfu 
		, u.idpfu as idFrom 	
		, u.pfuidazi as idAzi
		, attvalue as UserRole
		from profiliutente p
			inner join profiliutenteattrib a on p.idpfu = a.idpfu and dztnome = 'UserRole' --and attvalue in ( 'PO' , 'RUP' , 'RUP_PDG' )
			inner join profiliutente u on p.pfuidazi = u.pfuidazi										
GO
