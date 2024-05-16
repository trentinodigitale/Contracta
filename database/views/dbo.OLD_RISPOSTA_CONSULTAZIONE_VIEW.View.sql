USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_RISPOSTA_CONSULTAZIONE_VIEW]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[OLD_RISPOSTA_CONSULTAZIONE_VIEW] as 
select 
	d.*,
	case 
		when getdate() <= DataScadenzaOfferta and d.StatoFunzionale = 'InLavorazione' and d.StatoDoc = 'Saved' 	then '1'
		else '0'
	end as CAN_SEND,
	case when getdate() > DataScadenzaOfferta  then '1' else '0' end as DATA_INVIO_SUPERATA 
	from CTL_DOC D
		left outer join Document_Bando  b on d.LinkedDoc = b.idHeader

GO
