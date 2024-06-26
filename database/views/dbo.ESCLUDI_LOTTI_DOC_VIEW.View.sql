USE [AFLink_TND]
GO
/****** Object:  View [dbo].[ESCLUDI_LOTTI_DOC_VIEW]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[ESCLUDI_LOTTI_DOC_VIEW] AS
Select 
	C.*,
	Case when C2.StatoFunzionale='VERIFICA_AMMINISTRATIVA' and C.StatoFunzionale='Confermato' then 1 else 0 end as CAN_ANNULLA
	--, B.InversioneBuste
	, O.StatoPDA
from ctl_doc C
	inner join ctl_doc C2 on C2.id=C.IdDoc and C2.TipoDoc='PDA_MICROLOTTI'
	inner join Document_PDA_OFFERTE o with(nolock) on o.idmsg = c.LinkedDoc and o.idheader = c.iddoc
	--inner join ctl_doc P with(nolock) on  P.id = o.idheader
	--inner join document_bando B with(nolock) on  B.idheader = P.LinkedDoc

where C.TipoDoc='ESCLUDI_LOTTI'
GO
