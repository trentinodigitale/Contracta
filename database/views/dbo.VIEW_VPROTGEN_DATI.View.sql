USE [AFLink_TND]
GO
/****** Object:  View [dbo].[VIEW_VPROTGEN_DATI]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VIEW_VPROTGEN_DATI] AS
	select  IdRow,
			IdHeader,
			DZT_Name as [Object],
			[Value] as CampoTesto,
			[data]
		from v_protgen_dati with(nolock)
GO
