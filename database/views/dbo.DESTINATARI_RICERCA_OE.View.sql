USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DESTINATARI_RICERCA_OE]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[DESTINATARI_RICERCA_OE] as
select 
	C.linkeddoc,CD.*,A.aziiddscformasoc as NaGi
from 
	CTL_DOC C inner join CTL_DOC_DESTINATARI CD on id=idheader
	inner join aziende A on A.idazi=CD.idazi
where 
	tipodoc='RICERCA_OE'
	and statofunzionale='Pubblicato'
	and seleziona='includi'

GO
