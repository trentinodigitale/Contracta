USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_RICHIESTAQUOTA]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[DASHBOARD_VIEW_RICHIESTAQUOTA]
AS
SELECT    
	CTL_DOC.ID as IdHeader,
	CTL_DOC.ID,
	ProfiliUtente.IdPfu, 
	TipoDoc, 
	StatoDoc, 
	Data, 
	Protocollo, 
	PrevDoc, 
	Titolo, 
	Body, 
	Azienda, 
	CTL_DOC.Azienda as AZI_Ente,
	StrutturaAziendale, 
	DataInvio, 
	DataScadenza, 
	ProtocolloGenerale, 
	Fascicolo, 
	Note, 
	DataProtocolloGenerale, 
	ctl_doc.LinkedDoc, 
	SIGN_HASH, 
	SIGN_ATTACH, 
	SIGN_LOCK, 
	JumpCheck, 
	StatoFunzionale, Destinatario_User, Destinatario_Azi ,
	Document_Convenzione_Quote.Importo,
	Document_Convenzione_Quote.ImportoRichiesto,
	C.NumOrd,
	C.Doc_name as BodyContratto,
	C.Total,
	C.protocol as ProtocolloRiferimento,
	(C.Total - ISNULL(S.totQ,0)) as Importo_Residuo_Quote,
	case when statofunzionale = 'InApprove' then 'RICHIESTAQUOTAINTERNA' else 'RICHIESTAQUOTA' end as OPEN_DOC_NAME,
	Document_Convenzione_Quote.idrow,
	Document_Convenzione_Quote.Motivazione,
	CTL_DOC.idpfu as Owner
	
FROM         
	ctl_doc 
	inner join Aziende on Azienda=IdAzi

	inner join document_convenzione C on LinkedDoc=C.ID
	left join Document_Convenzione_Quote on Document_Convenzione_Quote.idHeader=CTL_DOC.ID
	left join  (
					select  ctl_doc.linkeddoc, 
						isnull(sum(importo),0) as totQ 
						from Document_Convenzione_Quote,ctl_doc 
					where tipodoc='QUOTA' and idheader=id and statodoc='Sended' 
					group by linkeddoc

				) S on C.id=S.linkeddoc

	inner join ProfiliUtente on pfuidazi=Azienda

where TipoDoc='RICHIESTAQUOTA'
GO
