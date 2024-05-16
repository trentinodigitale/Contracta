USE [AFLink_TND]
GO
/****** Object:  View [dbo].[VIEW_IDPFU_ASSEGNA_A_QUESITI]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VIEW_IDPFU_ASSEGNA_A_QUESITI] as

	select
		  DR.idPfu as idPfu,
		  C.id
	from
		Document_Chiarimenti C with(nolock) 
			inner join CTL_DOC c2 with(nolock) on c2.id=C.ID_ORIGIN
			inner join Document_Bando_Riferimenti  DR   with(nolock) on C2.id=DR.idHeader and DR.RuoloRiferimenti='Quesiti'		


GO
