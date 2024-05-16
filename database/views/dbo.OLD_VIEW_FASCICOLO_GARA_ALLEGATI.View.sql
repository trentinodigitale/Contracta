USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_VIEW_FASCICOLO_GARA_ALLEGATI]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE view [dbo].[OLD_VIEW_FASCICOLO_GARA_ALLEGATI]

as

	select
			[IdRow],
			[IdHeader],
			[Path], 
			case
				when isnull([Encrypted],0) = 1 then ''
				else [Attach]
			end as 	[Attach]
			, 			
			[NomeFile],
			Document_Fascicolo_Gara_Allegati.[IdDoc],
			[DSE_ID],
			[AreaDiAppartenenza],
			[Esito],
			[NumRetry],
			[Encrypted]
		from Document_Fascicolo_Gara_Allegati with (nolock)
			left outer join ctl_doc fascicolo on Document_Fascicolo_Gara_Allegati.IdDoc = fascicolo.id
		where 
			1 = 1 and
			(
				([Path] <> 'Documenti esterni' and 2 = 2) or
				([Path] = 'Documenti esterni' and StatoFunzionale <> 'Annullato')
			)


GO
