USE [AFLink_TND]
GO
/****** Object:  View [dbo].[AVCP_CONFIG_FROM_AVCP_CONFIG]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[AVCP_CONFIG_FROM_AVCP_CONFIG] as
select
	D.id as ID_FROM,
	D.id,
	D.Body,
	'InLavorazione' as StatoFunzionale,
	D.TipoDoc,
	D.id as PrevDoc,
	D.Azienda,
	C.idheader, 
	C.URL_CLIENT, 
	C.FileNameIndice, 
	C.PercorsoDiRete, 
	C.FTP, 
	C.Porta, 
	C.Login, 
	C.PasswordFtp,
	C.Metodo

from
	CTL_DOC D
	inner join DOCUMENT_AVCP_CONFIG C on C.idheader=D.id
	where D.tipodoc='AVCP_CONFIG' and D.StatoFunzionale='Pubblicato'
GO
