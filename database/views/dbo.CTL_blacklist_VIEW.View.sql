USE [AFLink_TND]
GO
/****** Object:  View [dbo].[CTL_blacklist_VIEW]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[CTL_blacklist_VIEW] as
select idPfu as IdPfuLog,* from CTL_blacklist with (nolock)
GO
