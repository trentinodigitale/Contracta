USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_ANALISI_FABBISOGNI_TESTATA]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[OLD_ANALISI_FABBISOGNI_TESTATA] as 

	select 
		b.* 
		, d.Azienda 
		, d.richiestafirma
		, d.Body
		, a.id
	
	from CTL_DOC a
		inner join CTL_DOC d on a.linkeddoc = d.id and d.deleted=0
		inner join Document_Bando b on d.id = b.idheader

	--where d.tipodoc='BANDO_FABBISOGNI' 



GO
