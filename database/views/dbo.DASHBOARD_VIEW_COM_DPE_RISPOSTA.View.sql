USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_COM_DPE_RISPOSTA]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[DASHBOARD_VIEW_COM_DPE_RISPOSTA]
AS
SELECT    
	ctl_doc.id,
	C.IdCom as IdRow,
	ctl_doc.Idpfu,
	ctl_doc.StatoDoc,
	ctl_doc.Titolo,
	ctl_doc.Tipodoc,
	ctl_doc.DataInvio,
	ctl_doc.PrevDoc,
	ctl_doc.Deleted,
	ctl_doc.Body,    
	C.Protocollo as ProtocolloRiferimento,
	ctl_doc.Protocollo,
	ctl_doc.LinkedDoc,
	ctl_doc.StatoFunzionale,
	CTL_DOC.ID as IdHeader,
	DataScadenzaCom,
	DataCreazione as DataCompilazione,
	RichiestaRisposta,
	C.DataScadenza,
	NotaCom,
	CTL_DOC.Azienda ,
	Titolo as Name , 
	DataInvio as DataCreazione,
	DataCreazione as DataCreazione1,
	TipoDoc as OPEN_DOC_NAME,
	ProtocolloGenerale,
	DataProtocolloGenerale,
	CTL_DOC.Destinatario_User,
	CTL_DOC.JumpCheck

	

FROM   ctl_doc 

	
	inner join dbo.Document_Com_DPE  C on LinkedDoc=C.IdCom

	

where TipoDoc like 'COM_DPE_RISPOSTA%'


GO
