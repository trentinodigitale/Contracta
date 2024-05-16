USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_ESPD_REQUEST_XML_TESTATA]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[OLD_ESPD_REQUEST_XML_TESTATA] AS

	select a.id as idProcedura
			--, a.Fascicolo
			, a.Titolo as titoloProcedura
			, a.Body as descrizioneProcedura
			, COALESCE( b2.id_gara, c2.smart_cig, a.fascicolo) as Fascicolo
			, 'OTHER' as ProcedureCode	-- dobbiamo recuperarlo da un campo scelto dall'ente sull'espd
			, 'OTHER' as ProjectType
			, b2.id_gara as numeroGaraSimog
			, a2.CIG as CigTestata
			, case when a2.Divisione_lotti = '0' then 1 else 0 end as monoLotto
			, a3.[Value] as cpv
		from ctl_doc a with(nolock)
				left join Document_Bando a2 with(nolock) on a2.idHeader = a.id
				left join ctl_doc_value a3 with(nolock) on a3.idheader = a.id and a3.dse_id = 'InfoTec_SIMOG' and a3.dzt_name = 'CODICE_CPV' 

				left join ctl_doc b with(nolock) on b.LinkedDoc = a.id and b.tipodoc = 'richiesta_cig' and b.Deleted = 0 and b.StatoFunzionale = 'Inviato' and ( b.JumpCheck is null or b.JumpCheck = ''  )
				left join Document_SIMOG_GARA b2 with(nolock) on b2.idHeader = b.id
				left join ctl_doc c with(nolock) on c.LinkedDoc = a.id and c.tipodoc = 'richiesta_smart_cig' and c.Deleted = 0 and c.StatoFunzionale = 'Inviato' and ( c.JumpCheck is null or c.JumpCheck = ''  )
				left join Document_SIMOG_SMART_CIG c2 with(nolock) on c2.idHeader = c.Id
		--where a.id = 258529

GO
