USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_VIEW_FASCICOLO_GARA_ALLEGATI]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [dbo].[OLD2_VIEW_FASCICOLO_GARA_ALLEGATI]

as

	select 
		[IdRow], [IdHeader], [Path], 
		case
			when isnull([Encrypted],0) = 1 then ''
			else [Attach]
		end as 	[Attach]
			, 
			
		[NomeFile], [IdDoc], [DSE_ID], [AreaDiAppartenenza], [Esito], [NumRetry], [Encrypted]
		from 
		Document_Fascicolo_Gara_Allegati with (nolock)


GO
