USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_MAIL_RUP]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view  [dbo].[OLD_MAIL_RUP] as 


	---CI SERVE PER PRENDERE I RECORD RELATIVI ALLE GARE
	select  
		sic.idRow as IDDOC
		,'I' as LNG
		, pu.pfuNome as nome
		, '' as cognome
		, doc_b.ProtocolloBando as RegNum
		,'' as JSONDetail
		, d.Titolo
		, d.Body as Oggetto
		
		from Services_Integration_Request sic with(nolock)
		inner join Document_Bando doc_b with(nolock) on idHeader = idRichiesta
		inner join ProfiliUtente pu with(nolock) on pu.IdPfu = doc_b.RupProponente
		inner join CTL_DOC d with(nolock) on doc_b.idHeader = d.Id 
	
	UNION ALL
	
		---CI SERVE PER PRENDERE I RECORD RELATIVI ALLE SCHEDE
		select  
		sic.idRow as IDDOC
		,'I' as LNG
		, pu.pfuNome as nome
		, '' as cognome
		, doc_b.ProtocolloBando as RegNum
		,'' as JSONDetail
		, d.Titolo
		, d.Body as Oggetto
		
		from Services_Integration_Request sic with(nolock)
		inner join Document_PCP_Appalto_Schede doc_s with(nolock) on doc_s.idRow = sic.idRichiesta
		inner join Document_Bando doc_b with(nolock) on doc_b.idHeader = doc_s.idheader
		inner join ProfiliUtente pu with(nolock) on pu.IdPfu = doc_b.RupProponente
		inner join CTL_DOC d with(nolock) on doc_b.idHeader = d.Id 

GO
