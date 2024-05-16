USE [AFLink_TND]
GO
/****** Object:  View [dbo].[AVCP_OE_FROM_AVCP_OE]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[AVCP_OE_FROM_AVCP_OE] as
select
	id as ID_FROM,
	id as PrevDoc,
	Fascicolo,
	LinkedDoc,
	RagioneSociale,
	
	Aggiudicatario,
	Estero,
	
	Codicefiscale

from ctl_doc 
left join document_avcp_partecipanti on id=idheader

where tipodoc='AVCP_OE'

GO
