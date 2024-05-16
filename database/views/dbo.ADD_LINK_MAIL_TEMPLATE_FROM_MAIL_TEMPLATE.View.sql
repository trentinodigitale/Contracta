USE [AFLink_TND]
GO
/****** Object:  View [dbo].[ADD_LINK_MAIL_TEMPLATE_FROM_MAIL_TEMPLATE]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[ADD_LINK_MAIL_TEMPLATE_FROM_MAIL_TEMPLATE] as
select 

	CTL_DOC.id as ID_FROM,
	ViewName

from 
CTL_DOC
inner join dbo.CTL_Mail_Template on JumpCheck=ML_KEY
where tipodoc='MAIL_TEMPLATE'
GO
