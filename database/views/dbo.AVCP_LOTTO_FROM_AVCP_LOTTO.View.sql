USE [AFLink_TND]
GO
/****** Object:  View [dbo].[AVCP_LOTTO_FROM_AVCP_LOTTO]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [dbo].[AVCP_LOTTO_FROM_AVCP_LOTTO] as
	select 
	id as ID_FROM,
	Fascicolo,
	Versione,
	id as LinkedDoc,
	id as PrevDoc,	
	Azienda,
	'AVCP_LOTTO' as TipoDoc,
    Anno, 
	Cig, 
	CFprop, 
	Denominazione, 
	Scelta_contraente, 
	ImportoAggiudicazione, 
	DataInizio, 
	Datafine, 
	ImportoSommeLiquidate, 
	Oggetto, 
	DataPubblicazione,
	warning
	

from 
ctl_doc 
inner join document_AVCP_lotti on idheader=id
where tipodoc='AVCP_LOTTO'



GO
