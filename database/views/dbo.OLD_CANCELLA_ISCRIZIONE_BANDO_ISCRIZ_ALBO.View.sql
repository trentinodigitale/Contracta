USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_CANCELLA_ISCRIZIONE_BANDO_ISCRIZ_ALBO]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [dbo].[OLD_CANCELLA_ISCRIZIONE_BANDO_ISCRIZ_ALBO] as
	select 
		C.id as linkeddoc,
		C.Protocollo as Protocolloriferimento,
		C.body, 
		CD.*, idrow as ID_FROM, 
		'Cancella Iscrizione' as titolo,
		CD.Idazi as Destinatario_Azi
	
	from 
		ctl_doc C inner join ctl_doc_destinatari CD on id=idheader
	
	where tipodoc='BANDO'



GO
