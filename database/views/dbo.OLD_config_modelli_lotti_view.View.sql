USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_config_modelli_lotti_view]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[OLD_config_modelli_lotti_view] AS
select 
	C.*,
	G.Idpfu as COMPILATORE_GARA
from CTL_DOC C with(nolock)
	left join ctl_doc G with(nolock) on G.id=C.linkeddoc
GO
