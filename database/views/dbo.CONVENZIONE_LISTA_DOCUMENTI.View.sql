USE [AFLink_TND]
GO
/****** Object:  View [dbo].[CONVENZIONE_LISTA_DOCUMENTI]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE view [dbo].[CONVENZIONE_LISTA_DOCUMENTI] as


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
	from ctl_doc 
		
		where deleted = 0 -- and TipoDoc <> 'CONFIG_MODELLI'
		--and  	right( tipoDoc , 11 ) = 'CONVENZIONE' and 
		and TipoDoc in (
						'CONVENZIONE_PRZ_PRODOTTI',
						'CAMBIO_REFERENTE',
						'RICHIESTAQUOTA',
						'CONVENZIONE_PROROGA',
						'CONVENZIONE_UPD_PRODOTTI',
						'CONVENZIONE_MOVE_LOTTI',
						'LISTINO_CONVENZIONE',
						'PDA_COMUNICAZIONE_GARA',
						'CONV_SOSTITUZIONE_REF',
						'QUOTA',
						'CONVENZIONE_DEL_PRODOTTI',
						'CONTRATTO_CONVENZIONE',
						'CONVENZIONE',
						'CONVENZIONE_VALORE',
						'ODC',
						'CONTRATTO_PDF',
						'RETTIFICA_CONVENZIONE',
						'CLAUSOLE_PDF',
						'CONVENZIONE_DECURTAZIONE',
						'CONVENZIONE_ADD_PRODOTTI',
						'RIFERIMENTI',
						'CONVENZIONE_UPD_ENTI',
						'LISTINO_ORDINI_OE'
						)


union all 

select 
	[ID_ROW] as Id, 
	owner as IdPfu, 
	[ID_ROW] as IdDoc, 
	case when [TipoEstensione] is null then 'CONVENZIONE_CHIUDI' else '' end as TipoDoc, 
	stato as StatoDoc, 
	datains as Data, 
	protocol as Protocollo, 
	0 as PrevDoc, 
	0 as Deleted, 
	cast( Motivazione as nvarchar( 200) ) as Titolo, 
	Motivazione aS Body, 
	Azienda, 
	'' as StrutturaAziendale, 
	datains as DataInvio, 
	null as  DataScadenza, 
	c.Protocollo as ProtocolloRiferimento, 
	'' as ProtocolloGenerale, 
	c.Fascicolo, 
	null as Note, 
	null as DataProtocolloGenerale, 
	c.id as LinkedDoc, 
	null as SIGN_HASH, 
	null as SIGN_ATTACH, 
	null as SIGN_LOCK, 
	null as JumpCheck, 
	'Confermato' as StatoFunzionale, 
	0 as Destinatario_User, 
	0 as Destinatario_Azi, 
	'' as RichiestaFirma, 
	'' as NumeroDocumento, 
	datains as  DataDocumento, 
	'' as Versione, 
	'' as VersioneLinkedDoc, 
	null as GUID, 
	owner as idPfuInCharge, 
	'' as CanaleNotifica
	, case when [TipoEstensione] is null then 'CONVENZIONE_CHIUDI' else '' end as  OPEN_DOC_NAME

	from document_convenzione_azioni  a
		inner join ctl_doc c on c.id = a.idheader and c.TipoDoc = 'CONVENZIONE'
	where Stato = 'Eseguito' and  [TipoEstensione] is null





GO
