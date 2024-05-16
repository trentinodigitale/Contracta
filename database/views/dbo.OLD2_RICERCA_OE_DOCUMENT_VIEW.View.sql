USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_RICERCA_OE_DOCUMENT_VIEW]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE VIEW [dbo].[OLD2_RICERCA_OE_DOCUMENT_VIEW] as

  select
	C1.id,
	C1.IdPfu,
	C1.TipoDoc,
	C1.Data,
	C1.Protocollo,
	C1.PrevDoc,
	C1.DataInvio,
	C1.LinkedDoc,
	C1.StatoFunzionale,
	C1.StatoDoc,
	
	-- i campi presi da .C2 e da .D dovranno essere recuperati così : 
	--	se presenti queste informazioni 
	-- sul bando nuovo o vecchio ( in funzione di jumpCheck ) e della presenza
	-- della relazione con un bando.. prenderemo queste informazioni,
	-- così poi da renderli persistenti sul documento nel successivo salvataggio
	-- del documento ricerca_oe_document
	-- altrimenti se la relazione manca o le info sul bando sono vuote recupero
	-- questi valori dal documento stesso.
	-- la relazione con il bando è sempre in linkeddoc a prescindere se nuovo o vecchio
	

	CASE 
	   WHEN isnull(C2.Azienda,'') <> ''  THEN C2.Azienda
	   WHEN isnull(P.pfuIdAzi,'') <> ''  THEN P.pfuIdAzi
	   WHEN isnull(P1.pfuIdAzi,'') <> '' THEN P1.pfuIdAzi
	   ELSE (select mpIdAziMaster from marketplace where mpLog = 'PA')
	END AS Azienda,

	-- coalesce(null, null,(select mpIdAziMaster from marketplace where mpLog = 'PA')) AS Azienda,

	CASE 
	   WHEN isnull(C2.Fascicolo,'') <> '' THEN C2.Fascicolo
	   WHEN isnull(CC2.protocolbg,'') <> '' THEN CC2.protocolbg
	   ELSE V4.Value
	END AS Fascicolo,

	CASE 
	   WHEN isnull(C2.DataProtocolloGenerale,'') <> '' THEN C2.DataProtocolloGenerale
	   WHEN not CC2.DataProtocolloInformaticoUscita is null and CC2.DataProtocolloInformaticoUscita <> '' THEN CC2.DataProtocolloInformaticoUscita
	   ELSE V5.Value
	END AS DataProtocolloGenerale,

	CASE 
	   WHEN isnull(C2.ProtocolloGenerale,'') <> '' THEN C2.ProtocolloGenerale
	   WHEN isnull(CC2.ProtocolloInformaticoUscita,'') <> '' THEN CC2.ProtocolloInformaticoUscita
	   ELSE V6.Value
	END AS ProtocolloGenerale,

	CASE 
	   WHEN isnull(D.ProtocolloBando,'') <> '' THEN D.ProtocolloBando
	   ELSE V7.Value
	END AS ProtocolloBando,

	CASE 
	   WHEN isnull(D.DataProtocolloBando,'') <> '' THEN D.DataProtocolloBando
	   ELSE V8.Value
	END AS DataProtocolloBando,

	CASE 
	   WHEN isnull(C2.Titolo,'') <> '' THEN C2.Titolo
	   WHEN isnull(CC2.Name,'') <> '' THEN CC2.Name
	   ELSE V1.Value
	END AS Titolo,

	CASE 
	   WHEN isnull(cast(C2.Body as varchar(8000)),'') <> '' THEN cast(C2.Body as varchar(8000))
	   WHEN isnull(CC2.object_cover1,'') <> '' THEN CC2.object_cover1
	   ELSE cast(C1.Body as varchar(8000))
	END AS Body,

	CASE 
	   WHEN isnull(D.cig,'') <> '' THEN D.cig
	   WHEN isnull(CC2.cig,'') <> '' THEN CC2.cig
	   ELSE V9.Value
	END AS CIG,

	-- se presente linkedDoc ( quindi il documento è associato a un bando )
	-- notEditable conterrà tutte le colonne recuperate dal bando.. così da renderle
	-- non editabili. altrimenti sarà vuoto e queste colonne diventeranno editabili (che è il
	-- default sul modello, così da non richiedere una customizzazione del modello )   

	CASE 
	   WHEN isnull(C1.LinkedDoc,0) <> 0 THEN ' Azienda Fascicolo DataProtocolloGenerale ProtocolloGenerale ProtocolloBando DataProtocolloBando Titolo Body CIG '
	   ELSE ''
	END AS NotEditable,

	case 
		WHEN isnull(C2.id,'') <> ''  and c2.tipodoc <> 'BANDO_FABBISOGNI' THEN 'BANDO_GARA'
		WHEN isnull(C2.id,'') <> ''  and c2.tipodoc = 'BANDO_FABBISOGNI' THEN 'BANDO_FABBISOGNI'
		else ''
	END as VersioneLinkedDoc ,
	
	isnull( D.ClasseIscriz , '' ) as ClasseIscriz , 
	isnull( D.TipoProceduraCaratteristica , '' ) as TipoProceduraCaratteristica,
	isnull( D.ListaAlbi , '' ) as ListaAlbi

	, ISNULL(V10.Value,100) as MaxNumeroIniziative

	,dbo.GetCategoriePrevalenteBando(C2.id) as CategoriaSOA
	,ISNULL(V11.Value,'') as NumeroOperatoridaInvitare
	,ISNULL(V12.Value,'') as TipoSelezioneSoggetti
	,cast( ISNULL(V13.Value,'') as int) as NumRighe
	,C1.Note
	,D.TipoAppaltoGara
	,D.ProceduraGara
	,D.TipoBandoGara
	, case 
		when isnull( d1.TipoBandoGara , '' ) = '1' then 1
		else 0
	  end 	as invitoDaAvviso

from ctl_doc C1
    
     -- Join per il bando nuovo
	left join ctl_doc C2 with (nolock) on C1.LinkedDoc=C2.Id and C2.tipodoc in ('BANDO_FABBISOGNI','BANDO_GARA') and ISNULL(C1.Jumpcheck,'')=''
	left join Document_Bando D with (nolock) on C2.id=D.idheader

	left join Document_Bando D1 with (nolock) on D1.idHeader = C2.LinkedDoc

	left join ProfiliUtente P1 with (nolock) ON P1.idpfu = C1.IdPfu

	-- join per il documento vecchio
	left join tab_messaggi_fields CC2 on C1.LinkedDoc=CC2.Idmsg and C1.Jumpcheck='DOCUMENTOGENERICO'
	left join tab_utenti_messaggi on CC2.idmsg=umidmsg
	left join profiliutente P on P.idpfu=umidpfu

	-- join per il recupero degli attributi del documento ricerca_oe in scrittura verticale
	left join ctl_doc_value V1 ON V1.idheader = C1.id and V1.DSE_ID = 'SAVE' and V1.DZT_Name = 'Titolo'
	-- left join ctl_doc_value V2 ON V2.idheader = C1.id and V2.DSE_ID = 'SAVE' and V2.DZT_Name = 'Descrizione'
	left join ctl_doc_value V3 ON V3.idheader = C1.id and V3.DSE_ID = 'SAVE' and V3.DZT_Name = 'Azienda'
	left join ctl_doc_value V4 ON V4.idheader = C1.id and V4.DSE_ID = 'SAVE' and V4.DZT_Name = 'Fascicolo'
	left join ctl_doc_value V5 ON V5.idheader = C1.id and V5.DSE_ID = 'SAVE' and V5.DZT_Name = 'DataProtocolloGenerale'
	left join ctl_doc_value V6 ON V6.idheader = C1.id and V6.DSE_ID = 'SAVE' and V6.DZT_Name = 'ProtocolloGenerale'
	left join ctl_doc_value V7 ON V7.idheader = C1.id and V7.DSE_ID = 'SAVE' and V7.DZT_Name = 'ProtocolloBando'
	left join ctl_doc_value V8 ON V8.idheader = C1.id and V8.DSE_ID = 'SAVE' and V8.DZT_Name = 'DataProtocolloBando'
	left join ctl_doc_value V9 ON V9.idheader = C1.id and V9.DSE_ID = 'SAVE' and V9.DZT_Name = 'CIG'
	left join ctl_doc_value V10 ON V10.idheader = C1.id and V10.DSE_ID = 'BOTTONE' and V10.DZT_Name = 'MaxNumeroIniziative'
	--cross join marketplace ON mpLog = 'PA' 

	left join ctl_doc_value V11 ON V11.idheader = C1.id and V11.DSE_ID = 'BOTTONE' and V11.DZT_Name = 'NumeroOperatoridaInvitare'
	left join ctl_doc_value V12 ON V12.idheader = C1.id and V12.DSE_ID = 'BOTTONE' and V12.DZT_Name = 'TipoSelezioneSoggetti'
	left join ctl_doc_value V13 ON V13.idheader = C1.id and V13.DSE_ID = 'BOTTONE' and V13.DZT_Name = 'NumRighe'


where C1.tipodoc in ( 'RICERCA_OE' ,'RICERCA_ENTI' ) --and C1.deleted = 0

GO
