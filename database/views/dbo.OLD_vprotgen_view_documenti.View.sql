USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_vprotgen_view_documenti]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[OLD_vprotgen_view_documenti] as
	select  id,
			cast( appl_id_evento as INT) as ID_DOC_DA_PROTOCOLLARE
	from v_protgen where ISNUMERIC(appl_id_evento) = 1 and flag_annullato = 0
GO
