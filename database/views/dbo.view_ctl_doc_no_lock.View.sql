USE [AFLink_TND]
GO
/****** Object:  View [dbo].[view_ctl_doc_no_lock]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[view_ctl_doc_no_lock] as
	-- NON CAMBIARE QUESTA VISTA!
	-- LASCIARE SOLO UNA SELECT CON LA WITH(NOLOCK)
	-- UTILIZZARE CON ATTENZIONE
	select * from ctl_doc with(nolock)
GO
