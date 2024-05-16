USE [AFLink_TND]
GO
/****** Object:  View [dbo].[CESSAZIONE_UTENTI_DOCUMENT_VIEW]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[CESSAZIONE_UTENTI_DOCUMENT_VIEW] AS 
select 
	C.*
	--CONSENTE LA CESSAZIONE EFFETTIVA SE (data invio + numero giorni attesa) è superata
	, case when dateadd(d,cast(CV2.Value as int),C.DataInvio) < getdate() then '1' else '0' end AS CAN_CESSAZIONE
	from CTL_DOC C with(nolock)
		left join CTL_DOC_Value CV2  with(nolock) on CV2.IdHeader=C.id and CV2.DSE_ID='PARAMETRI' and CV2.DZT_Name='NumGiorni'
	where C.TipoDoc='CESSAZIONE_UTENTI'
	
GO
