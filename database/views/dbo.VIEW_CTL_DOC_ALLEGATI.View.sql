USE [AFLink_TND]
GO
/****** Object:  View [dbo].[VIEW_CTL_DOC_ALLEGATI]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE view  [dbo].[VIEW_CTL_DOC_ALLEGATI]
as

	select  [idrow], [idHeader], [Descrizione],[Allegato], [DSE_ID], min(atr_datainsert) as atr_datainsert

		from CTL_DOC_ALLEGATI a with (nolock)

			inner join ctl_doc b with (nolock) on a.idHeader = b.id
			inner join ProfiliUtente c with (nolock) on b.Destinatario_Azi = c.pfuidazi and pfuDeleted = 0
			left outer join  CTL_ATTACH_READ v with (nolock) on isnull(allegato,'') <> '' and v.ATR_Hash=dbo.GetPos(allegato,'*',4)
																	and v.ATR_IdPfu = c.IdPfu 
				
		group by [idrow], [idHeader], [Descrizione],[Allegato],[DSE_ID]

			--left outer join 
			--	(
			--		select atr_hash,attr_idpfu, min(atr_datainsert) as atr_datainsert 
			--			from CTL_ATTACH_READ with (nolock)
			--				group by atr_hash,attr_idpfu
			--	) v on isnull(allegato,'') <> '' and v.ATR_Hash=dbo.GetPos(allegato,'*',4) and 

	
GO
