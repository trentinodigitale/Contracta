USE [AFLink_TND]
GO
/****** Object:  View [dbo].[view_vprotgen_offerte]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create view [dbo].[view_vprotgen_offerte] as

	select appl_id_evento as ID_DOC_OFFERTA, * from v_protgen




GO
