USE [AFLink_TND]
GO
/****** Object:  View [dbo].[document_pda_offerte_anomalie_view]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[document_pda_offerte_anomalie_view]
as
	select 
		* 
	from document_pda_offerte_anomalie
		left join Aziende on idfornitore=idazi
GO
