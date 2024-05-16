USE [AFLink_TND]
GO
/****** Object:  View [dbo].[BANDO_CONSULTAZIONE_LISTA_RISPOSTE]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[BANDO_CONSULTAZIONE_LISTA_RISPOSTE] as
select 
	ctl_doc.* 
	, tipodoc as OPEN_DOC_NAME
	,aziRagioneSociale
	,D2.vatValore_FT as aziCodiceFiscale
	,aziLocalitaLeg as Comune
	,  aziE_Mail
	,LinkedDoc as idheader
from ctl_doc with(NOLOCK)
	inner join aziende with(NOLOCK) on Azienda=IdAzi
	left join DM_Attributi D2 with(NOLOCK) on D2.lnk=IdAzi and D2.idApp=1 and D2.dztNome='codicefiscale'	
where deleted = 0
	and tipodoc in ('RISPOSTA_CONSULTAZIONE')   and StatoDoc <> 'Saved' 


GO
