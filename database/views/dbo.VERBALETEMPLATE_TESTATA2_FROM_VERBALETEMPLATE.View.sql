USE [AFLink_TND]
GO
/****** Object:  View [dbo].[VERBALETEMPLATE_TESTATA2_FROM_VERBALETEMPLATE]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

---------------------------------------------------------------
--nuova vista per visualizzare la lista di template
---------------------------------------------------------------

create VIEW [dbo].[VERBALETEMPLATE_TESTATA2_FROM_VERBALETEMPLATE]
as
select 
	id as ID_FROM, 
	* 
from 
	ctl_doc,Document_VerbaleGara
where
	id=idheader
	and tipodoc='VERBALETEMPLATE'
	and deleted=0

GO
