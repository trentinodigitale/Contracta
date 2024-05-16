USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_ESCLUDI_LOTTI_DOC_VIEW]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[OLD_ESCLUDI_LOTTI_DOC_VIEW] AS
Select 
	C.*,
	Case when C2.StatoFunzionale='VERIFICA_AMMINISTRATIVA' and C.StatoFunzionale='Confermato' then 1 else 0 end as CAN_ANNULLA

from ctl_doc C
	inner join ctl_doc C2 on C2.id=C.IdDoc and C2.TipoDoc='PDA_MICROLOTTI'
where C.TipoDoc='ESCLUDI_LOTTI'
GO
