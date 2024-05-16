USE [AFLink_TND]
GO
/****** Object:  View [dbo].[VIEW_COMMISSIONE_LOTTO_PDA]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VIEW_COMMISSIONE_LOTTO_PDA] AS

	SELECT pl.Id as IdHeader
			,cm.DSE_ID
			,cm.DZT_Name
			,cm.Value
			,cm.Row
		FROM CTL_DOC pda WITH (NOLOCK) 
				INNER JOIN Document_Microlotti_Dettagli pl WITH (NOLOCK) ON pl.IdHeader = pda.Id and pda.tipodoc = pl.Tipodoc and pl.voce = 0
				INNER JOIN CTL_DOC_Value cm WITH(NOLOCK) ON cm.IdHeader = pda.id
		WHERE pda.TipoDoc = 'PDA_MICROLOTTI' and pda.deleted = 0


GO
