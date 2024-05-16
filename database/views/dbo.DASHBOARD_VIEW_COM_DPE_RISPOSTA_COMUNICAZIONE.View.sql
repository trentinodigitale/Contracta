USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_COM_DPE_RISPOSTA_COMUNICAZIONE]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[DASHBOARD_VIEW_COM_DPE_RISPOSTA_COMUNICAZIONE]
AS
SELECT    
	d.id,
	C.IdCom as IdRow,
	d.Idpfu,
	d.StatoDoc,
	d.Titolo,
	d.Tipodoc,
	d.DataInvio,
	d.PrevDoc,
	d.Deleted,
	d.Body,    
	C.Protocollo as ProtocolloRiferimento,
	d.Protocollo,
	d.LinkedDoc,
	d.StatoFunzionale,
	d.ID as IdHeader,
	DataScadenzaCom,
	DataCreazione as DataCompilazione,
	RichiestaRisposta,
	C.DataScadenza,
	NotaCom,
	--CTL_DOC_ALLEGATI.Allegato,
	--CTL_DOC_ALLEGATI.Descrizione
	d.Azienda ,
	Titolo as Name , 
	DataInvio as DataCreazione,
	DataCreazione as DataCreazione1,
	TipoDoc as OPEN_DOC_NAME , 
	pfuNome,
	aziRagioneSociale,
	Owner,
	Tipocomdpe

FROM   ctl_doc d

	--inner join dbo.Document_Com_DPE_Fornitori F on d.LinkedDoc=F.IdComFor
	inner join dbo.Document_Com_DPE  C on LinkedDoc=C.IdCom
	inner join profiliutente p on p.idpfu =d.idpfu
	left outer join aziende a on a.idazi = d.azienda
	--left join CTL_DOC_ALLEGATI on CTL_DOC_ALLEGATI.idHeader=d.id

where TipoDoc like 'COM_DPE_RISPOSTA%'
	and StatoDoc <> 'Saved'



GO
