USE [AFLink_TND]
GO
/****** Object:  View [dbo].[hd_ws_allegato_view]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[hd_ws_allegato_view] as
	select ATT_IdRow as id, URL_CLIENT from ctl_attach
GO
