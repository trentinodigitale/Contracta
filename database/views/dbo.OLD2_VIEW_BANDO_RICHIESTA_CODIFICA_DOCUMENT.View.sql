USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_VIEW_BANDO_RICHIESTA_CODIFICA_DOCUMENT]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[OLD2_VIEW_BANDO_RICHIESTA_CODIFICA_DOCUMENT] as
select
	Id, 
	IdPfu, 
	IdDoc, 
	TipoDoc, 
	StatoDoc, 
	Data, 
	Protocollo, 
	PrevDoc, 
	Deleted, 
	Titolo, 
	Body, 
	Azienda, 
	StrutturaAziendale, 
	DataInvio, 
	DataScadenza, 
	ProtocolloRiferimento, 
	ProtocolloGenerale, 
	Fascicolo, 
	Note, 
	DataProtocolloGenerale, 
	LinkedDoc, 
	JumpCheck, 
	StatoFunzionale, 
	Destinatario_User, 
	Destinatario_Azi, 
	RichiestaFirma, 
	NumeroDocumento, 
	DataDocumento, 
	Versione, 
	[GUID], 
	idPfuInCharge, 
	CanaleNotifica, 
	URL_CLIENT, 
	Caption, 
	FascicoloGenerale,
	Divisione_lotti,
	ISNULL(Complex,0) as Complex,
	tipodoc as versionelinkeddoc,
	dbo.getCampi_Chiave_Codifica() as colonnatecnica
from ctl_doc
inner join Document_Bando on idHeader=id

GO
