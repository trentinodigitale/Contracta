USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_STORICO_VARIAZIONI]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[DASHBOARD_VIEW_STORICO_VARIAZIONI] as 
select
	C.id,
	C.Idpfu,
	C.TipoDoc,
	C.StatoFunzionale,
	C.Protocollo,
	C.Azienda,
	C.DataInvio,
	C.LinkedDoc,
	C.Fascicolo,
	case when C.Tipodoc=('AVCP_ACTION') then '../Domain/NO_Lente.gif'
		else '../Domain/Lente.gif' 
	end as FNZ_OPEN,

	case when C.Tipodoc in ('AVCP_LOTTO','AVCP_GARA') then ML_Description
		 when C.Tipodoc=('AVCP_ACTION') then  C.titolo
	end as Titolo,

	C.Tipodoc as OPEN_DOC_NAME
from
CTL_DOC C 
left join Lib_multilinguismo on C.Tipodoc=ML_KEY and ML_LNG='I'
where C.tipodoc in ('AVCP_LOTTO','AVCP_GARA','AVCP_ACTION') and C.StatoFunzionale in ('Variato','Conclusa')



GO
