USE [AFLink_TND]
GO
/****** Object:  View [dbo].[config_modelli_lotti_view]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[config_modelli_lotti_view] AS
select 
	C.*,
	G.Idpfu as COMPILATORE_GARA,
	dbo.PARAMETRI('ATTIVA_MODULO','attestazione_di_partecipazione','ATTIVA','YES',-1) as VIS_att_partecipazione

from CTL_DOC C with(nolock)
	left join ctl_doc G with(nolock) on G.id=C.linkeddoc
GO
