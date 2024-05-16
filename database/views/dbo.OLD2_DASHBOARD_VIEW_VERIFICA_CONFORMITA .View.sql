USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_DASHBOARD_VIEW_VERIFICA_CONFORMITA ]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE view [dbo].[OLD2_DASHBOARD_VIEW_VERIFICA_CONFORMITA ] as

--Versione=2&data=2013-08-29&Attvita=43317&Nominativo=enrico
--Versione=3&data=2014-10-24&Attvita=64883&Nominativo=sabato
--Versione=4&data=2014-12-18&Attvita=67491&Nominativo=sabato
--Versione=5&data=2015-05-29&Attvita=75646&Nominativo=sabato

	select 
		a.idpfu as Owner 
		, d.ProtocolloRiferimento as ProtocolloBando
		, d.titolo as Name
	--	,f.NameBG
		,BG.Titolo as NameBG
		, d.* 
	 --   , f.tipoappalto
		--, f.proceduragara
		, B.tipoappalto
		, B.proceduragara
		, TipoProceduraCaratteristica
		, Bg.TipoDoc as TipoDocBando
		from CTL_DOC d
			inner join CTL_DOC_Destinatari a on d.id = a.idHeader
			inner join CTL_DOC as pda on d.LinkedDoc = pda.id and pda.deleted = 0
			--inner join TAB_MESSAGGI_FIELDS f on f.idmsg = pda.LinkedDoc
			left outer join document_bando  B on pda.LinkedDoc = B.idHeader
			left outer join CTL_DOC  BG on pda.LinkedDoc = BG.id


		where d.tipoDoc = 'CONFORMITA_MICROLOTTI' and d.deleted = 0




GO
