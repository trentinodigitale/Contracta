USE [AFLink_TND]
GO
/****** Object:  View [dbo].[CANCELLA_ISCRIZIONE_TESTATA_VIEW]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[CANCELLA_ISCRIZIONE_TESTATA_VIEW] as
	select 
		*
	
	from 
		ctl_doc C 
	
	where tipodoc='CANCELLA_ISCRIZIONE'
GO
