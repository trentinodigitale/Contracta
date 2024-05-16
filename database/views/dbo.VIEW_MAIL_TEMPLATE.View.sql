USE [AFLink_TND]
GO
/****** Object:  View [dbo].[VIEW_MAIL_TEMPLATE]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VIEW_MAIL_TEMPLATE] as 
select 
	id, 
	ML_KEY, 
	Titolo, 
	Descrizione as body, 
	DataUltimaMod, 
	ViewName, 
	Multi_Doc, 
	deleted
	
from dbo.CTL_Mail_Template
where deleted=0
GO
