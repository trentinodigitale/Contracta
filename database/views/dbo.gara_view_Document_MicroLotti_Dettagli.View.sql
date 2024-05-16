USE [AFLink_TND]
GO
/****** Object:  View [dbo].[gara_view_Document_MicroLotti_Dettagli]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[gara_view_Document_MicroLotti_Dettagli] as
	SELECT  a.*,
			case when b.RichiestaCigSimog = 'si' or dbo.attivo_INTEROP_Gara(b.idHeader)=1  then ' CIG ' else '' end as NotEditable
	FROM Document_MicroLotti_Dettagli a with(nolock)
			left join Document_Bando b with(nolock) on b.idHeader = a.IdHeader


GO
