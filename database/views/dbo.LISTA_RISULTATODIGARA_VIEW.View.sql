USE [AFLink_TND]
GO
/****** Object:  View [dbo].[LISTA_RISULTATODIGARA_VIEW]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[LISTA_RISULTATODIGARA_VIEW] as

select
		Id,
		cast (Body as varchar(8000)) as Body,
		DataInvio,
		Fascicolo,		
		IdPfu,
		JumpCheck,
		LinkedDoc,
		'' as Note,
		PrevDoc,
		Protocollo,
		StatoDoc,
		StatoFunzionale,
		TipoDoc
from ctl_doc
--UNION PER PRENDERE I RECORD DEL DOC GEN CON ID NEGATIVO
union

select
		-IdMsg as Id,
		Object_Cover1 as Body,
		Data as DataInvio,
		ProtocolBg as Fascicolo,		
		IdMittente as IdPfu,
		'' as JumpCheck,
		'' as LinkedDoc,
		'' as Note,
		'' as PrevDoc,
		Protocol as Protocollo,
		Stato as StatoDoc,
		'' as StatoFunzionale,
		'' asTipoDoc
from TAB_MESSAGGI_FIELDS
GO
