USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_document_pda_offerte_anomalie_view]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[OLD_document_pda_offerte_anomalie_view]
as
	select * from document_pda_offerte_anomalie
		inner join Aziende on idfornitore=idazi
GO
