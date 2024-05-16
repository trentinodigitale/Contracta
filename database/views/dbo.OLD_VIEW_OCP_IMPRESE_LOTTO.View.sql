USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_VIEW_OCP_IMPRESE_LOTTO]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[OLD_VIEW_OCP_IMPRESE_LOTTO] AS

	select i.*,
			l.[CFTIM], 
			l.[COGTIM], 
			l.[NOMETIM]
		from Document_OCP_IMPRESE_GARA  i with(nolock)
				left join Document_OCP_LEGALI_RAPPRESENTANTI l with(nolock) ON l.idHeader = -i.idRow-- and l.idAzi = i.idAzi 
				--questa join per il momento non tornerà record in quanto i rap leg non sono più gestiti. in futuro se ce ne dovessero essere N avremo l'impresa replicata per ogni rap leg
GO
