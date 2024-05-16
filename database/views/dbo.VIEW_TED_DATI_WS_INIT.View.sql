USE [AFLink_TND]
GO
/****** Object:  View [dbo].[VIEW_TED_DATI_WS_INIT]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[VIEW_TED_DATI_WS_INIT] AS
	select a.Id, --chiave di ingresso
			upper(p1.pfuCodiceFiscale) as [LOGIN],
			g.id_gara,
			sg.ID_STAZIONE_APPALTANTE,
			a.LinkedDoc,
			isnull(g.TED_VER_PUB_NO_DOC_OJS,'') as NO_DOC_OJS,
			isnull(g.TED_MOTIVO_RETTIFICA,'') as MOTIVO_RETTIFICA,
			isnull(g.TED_INFO_ADD_MODIFICA,'') as INFO_ADD_MODIFICA
		from CTL_DOC a with(nolock) --documento ted
				inner join Document_TED_GARA g with(nolock) on g.idHeader = a.id
				inner join (
								select max(id) as id, LinkedDoc 
									from ctl_doc s with(nolock) 
											inner join Document_SIMOG_GARA sg with(nolock) on sg.idHeader = s.id  
									where s.deleted = 0 and s.TipoDoc = 'RICHIESTA_CIG' and S.StatoFunzionale <> 'Annullato' and sg.ID_STAZIONE_APPALTANTE <> ''
									group by s.LinkedDoc
							) s on s.LinkedDoc = a.LinkedDoc
				inner join Document_SIMOG_GARA sg with(nolock) on sg.idHeader = s.id 
				inner join ctl_doc_value c1 with(nolock) on c1.idheader = a.LinkedDoc and dse_id = 'InfoTec_comune' and dzt_name = 'UserRUP' 
				inner join ProfiliUtente p1 with(nolock) on p1.IdPfu = c1.Value
GO
