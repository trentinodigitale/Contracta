USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_MAIL_RUP]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view  [dbo].[OLD2_MAIL_RUP] as 


	---CI SERVE PER PRENDERE I RECORD RELATIVI ALLE GARE
	select  
		sic.idRow as IDDOC
		,'I' as LNG
		, pu.pfuNome as nome
		, '' as cognome
		, doc_b.ProtocolloBando as RegNum
		,'' as JSONDetail
		
		from Services_Integration_Request sic with(nolock)
		inner join Document_Bando doc_b with(nolock) on idHeader = idRichiesta
		inner join ProfiliUtente pu with(nolock) on pu.IdPfu = doc_b.RupProponente
	
	UNION ALL
	
		---CI SERVE PER PRENDERE I RECORD RELATIVI ALLE SCHEDE
		select  
		sic.idRow as IDDOC
		,'I' as LNG
		, pu.pfuNome as nome
		, '' as cognome
		, doc_b.ProtocolloBando as RegNum
		,'' as JSONDetail
		
		from Services_Integration_Request sic with(nolock)
		inner join Document_PCP_Appalto_Schede doc_s with(nolock) on doc_s.idRow = sic.idRichiesta
		inner join Document_Bando doc_b with(nolock) on doc_b.idHeader = doc_s.idheader
		inner join ProfiliUtente pu with(nolock) on pu.IdPfu = doc_b.RupProponente

GO
