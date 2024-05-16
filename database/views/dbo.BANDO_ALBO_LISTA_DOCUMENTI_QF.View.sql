USE [AFLink_TND]
GO
/****** Object:  View [dbo].[BANDO_ALBO_LISTA_DOCUMENTI_QF]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE view [dbo].[BANDO_ALBO_LISTA_DOCUMENTI_QF] as

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
		cast(Body as nvarchar(max)) as body, 
		Azienda, 
		StrutturaAziendale, 
		DataInvio, 
		case when DataScadenza = '3000-01-01' then NULL 
			 when DataScadenza = '1900-01-01' then NULL 
		else DataScadenza end as DataScadenza, 
		ProtocolloRiferimento, 
		ProtocolloGenerale, 
		Fascicolo, 
		cast(Note as nvarchar(max)) as note, 
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
		
			and (	 TipoDoc = 'QUESTIONARIO_FORNITORE' )

	union

	select 
		Id, 
		IdPfu, 
		IdDoc, 
		jumpcheck as TipoDoc, 
		StatoDoc, 
		Data, 
		Protocollo, 
		0 as PrevDoc , 
		Deleted, 
		Titolo, 
		cast(Body as nvarchar(max)) as body, 
		Azienda, 
		StrutturaAziendale, 
		DataInvio, 
		case when DataScadenza = '3000-01-01' then NULL 
			 when DataScadenza = '1900-01-01' then NULL 
		else DataScadenza end as DataScadenza, 
		ProtocolloRiferimento, 
		ProtocolloGenerale, 
		Fascicolo, 
		cast(Note as nvarchar(max)) as note, 
		DataProtocolloGenerale, 
		--LinkedDoc, 
		prevdoc as linkeddoc,
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

		where deleted = 1 
		
			and 	TipoDoc = 'BANDO_QF' 
			and JumpCheck in ( 'Variazione_QF' , 'Copy_QF' )
GO
