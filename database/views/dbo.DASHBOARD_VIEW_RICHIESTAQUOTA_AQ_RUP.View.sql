USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_RICHIESTAQUOTA_AQ_RUP]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[DASHBOARD_VIEW_RICHIESTAQUOTA_AQ_RUP]
AS
SELECT    
	C.ID as IdHeader,
	C.ID,
--	C.ID as Idrow, 
	C.IdPfu, 
	C.TipoDoc, 
	C.StatoDoc, 
	C.Data, 
	C.Protocollo, 
	C.PrevDoc, 
	C.Titolo, 
	C.Body, 
	C.Azienda, 
	C.Azienda as AZI_Ente,
	C.StrutturaAziendale, 
	C.DataInvio, 
	C.DataScadenza, 
	C.ProtocolloGenerale, 
	C.Fascicolo, 
	C.Note, 
	C.DataProtocolloGenerale, 
	C.LinkedDoc, 
	C.SIGN_HASH, 
	C.SIGN_ATTACH, 
	C.SIGN_LOCK, 
	C.JumpCheck, 
	C.StatoFunzionale, C.Destinatario_User, C.Destinatario_Azi ,
	Document_Convenzione_Quote.Importo,
	
	Document_Convenzione_Quote.ImportoRichiesto,
	--C.NumOrd,
	AQ.body as BodyContratto,
	DB.importoBaseAsta as Total,
	AQ.protocollo as ProtocolloRiferimento,
	(DB.importoBaseAsta  - ISNULL(S.totQ,0)) as Importo_Residuo_Quote,
	case when C.statofunzionale = 'InApprove' then 'AQ_RICHIESTAQUOTAINTERNA' else 'AQ_RICHIESTAQUOTA' end as OPEN_DOC_NAME,
	Document_Convenzione_Quote.idrow,
	Document_Convenzione_Quote.Motivazione,
	C.idpfu as Owner,
	datascadenzaQ,
	CV.Value as USERRUP
	
FROM         
	ctl_doc C with(nolock)
	inner join Aziende A with(nolock) on Azienda=IdAzi
	inner join document_bando DB  with(nolock) on LinkedDoc=DB.idHeader
	inner join CTL_DOC AQ with(nolock) on AQ.id=DB.idHeader
	inner join CTL_DOC_Value CV with(nolock) on CV.IdHeader=AQ.id and CV.DZT_Name='UserRUP' and CV.DSE_ID='InfoTec_comune'
	left join Document_Convenzione_Quote with(nolock) on Document_Convenzione_Quote.idHeader=C.ID
	left join  (
					select  ctl_doc.linkeddoc, 
						isnull(sum(importo),0) as totQ 
						from Document_Convenzione_Quote,ctl_doc 
					where tipodoc='AQ_QUOTA' and idheader=id and statodoc='Sended' 
					group by linkeddoc

				) S on DB.idHeader=S.linkeddoc

	--inner join ProfiliUtente with(nolock)  on pfuidazi=C.Azienda

where C.TipoDoc='AQ_RICHIESTAQUOTA'
GO
