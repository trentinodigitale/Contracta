USE [AFLink_TND]
GO
/****** Object:  View [dbo].[VIEW_BANDO_RICHIESTA_CODIFICA_DOCUMENT]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[VIEW_BANDO_RICHIESTA_CODIFICA_DOCUMENT] as
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
	dbo.getCampi_Chiave_Codifica() as colonnatecnica ,
	
	isnull( v.value , '' ) as Last_ID_CODIFICA_PRODOTTI ,
	dbo.PARAMETRI ( 'BANDO_GARA' , 'CODIFICA_AUTOMATICA'  ,  'DefaultValue', '0' , -1 )  as CODIFICA_AUTOMATICA

from ctl_doc d with(nolock)
	inner join Document_Bando b with(nolock) on b.idHeader=d.id
	left join CTL_DOC_Value v with(nolock) on v.idheader = d.id and DSE_ID = 'CODIFICA_AUTOMATICA' and DZT_Name = 'Last_ID_CODIFICA_PRODOTTI' 
GO
