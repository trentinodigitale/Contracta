USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OFFERTA_DOC_FROM_BANDO_GARA]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  view [dbo].[OFFERTA_DOC_FROM_BANDO_GARA] as
select 
	d.id as ID_FROM ,

	case when ProceduraGara = '15477' and TipoBandoGara = '2'   then 'Domanda di partecipazione'
		else ''
		end as CaptionDoc
from CTL_DOC d 
	inner join Document_Bando  b on d.id = b.idHeader
	cross join profiliutente p 
where Deleted = 0



GO
