USE [AFLink_TND]
GO
/****** Object:  View [dbo].[lista_User_RUP]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[lista_User_RUP] as 
	select 
		r.idpfu as Owner
		,attvalue as idpfu
		from profiliutenteattrib r 
		where dztnome = 'pfuResponsabileUtente'
			
	union 

	select 
		idpfu 	as Owner
		, idpfu
		from profiliutenteattrib 
		where dztnome = 'UserRole' and attvalue = 'PO'

GO
