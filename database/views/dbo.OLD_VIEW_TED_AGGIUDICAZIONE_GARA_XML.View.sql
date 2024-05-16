USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_VIEW_TED_AGGIUDICAZIONE_GARA_XML]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[OLD_VIEW_TED_AGGIUDICAZIONE_GARA_XML] AS
	SELECT g.idHeader,
			g.ID_GARA,
			STR(g.TED_VAL_TOTAL, 15,3) AS TED_VAL_TOTAL,
			STR(g.TED_VAL_RANGE_TOTAL_LOW, 15,3) AS TED_VAL_RANGE_TOTAL_LOW,
			STR(g.TED_VAL_RANGE_TOTAL_HIGH, 15,3) as TED_VAL_RANGE_TOTAL_HIGH,
			isnull(g.TED_INFO_SDA,'') as TED_INFO_SDA,
			isnull(g.TED_INFO_AVV_PRE,'') as TED_INFO_AVV_PRE,
			isnull(l.TED_CIG_AGG,'') as TED_CIG --dobbiamo sempre mandare al ted 1 solo cig per volta
		FROM Document_TED_GARA g WITH(NOLOCK)
				left join (
							select idheader, max(a.idRow) as idRow
								from Document_TED_Aggiudicazione a WITH(NOLOCK)
								group by a.idHeader
					) l1 on l1.idHeader = g.idHeader
				left join Document_TED_Aggiudicazione l with(nolock) on l.idRow = l1.idRow
		
	
GO
