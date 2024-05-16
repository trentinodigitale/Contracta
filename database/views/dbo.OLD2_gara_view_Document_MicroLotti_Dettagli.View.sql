USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_gara_view_Document_MicroLotti_Dettagli]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[OLD2_gara_view_Document_MicroLotti_Dettagli] as
	SELECT  a.*,
			case when b.RichiestaCigSimog = 'si' then ' CIG ' else '' end as NotEditable
	FROM Document_MicroLotti_Dettagli a with(nolock)
			left join Document_Bando b with(nolock) on b.idHeader = a.IdHeader



GO
