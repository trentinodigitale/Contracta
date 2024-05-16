USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_BANDO_ALBO_LISTA_DOCUMENTI]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[OLD2_BANDO_ALBO_LISTA_DOCUMENTI] as
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
	case when DataScadenza = '3000-01-01' then NULL 
		 when DataScadenza = '1900-01-01' then NULL 
	else DataScadenza end as DataScadenza, 
	ProtocolloRiferimento, 
	ProtocolloGenerale, 
	Fascicolo, 
	Note, 
	DataProtocolloGenerale, 
	LinkedDoc, 
	SIGN_HASH, 
	SIGN_ATTACH, 
	SIGN_LOCK, 
	JumpCheck, 
	StatoFunzionale, 
	Destinatario_User, 
	Destinatario_Azi, 
	RichiestaFirma, 
	NumeroDocumento, 
	DataDocumento, 
	Versione, 
	VersioneLinkedDoc, 
	GUID, 
	idPfuInCharge, 
	CanaleNotifica
	, tipodoc as OPEN_DOC_NAME
	,  isnull(az1.aziRagionesociale, az2.aziRagionesociale) as aziRagionesociale

	from ctl_doc with(nolock)
		left outer join  aziende az1 with(nolock) on azienda = az1.idazi
		left outer join  aziende az2 with(nolock) on Destinatario_Azi = az2.idazi

	where deleted = 0
		and (
				( left( tipoDoc , 12 ) = 'ISTANZA_ALBO' and StatoDoc <> 'Saved' )
					or
				left( tipoDoc , 12 ) <> 'ISTANZA_ALBO'
		 )
		and tipoDoc not in ( 'TEMPLATE_CONTEST','AVVISO_GARA')








GO
