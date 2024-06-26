USE [AFLink_TND]
GO
/****** Object:  View [dbo].[QUOTA_TESTATA_VIEW]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[QUOTA_TESTATA_VIEW] AS
SELECT    

	ctl_doc.id,
	Document_Convenzione_Quote.idHeader as IdRow,
	ctl_doc.Idpfu,
	ctl_doc.StatoDoc,
	ctl_doc.Tipodoc,
	ctl_doc.Titolo,
	ctl_doc.Data,
	ctl_doc.DataInvio,
	ctl_doc.PrevDoc,
	ctl_doc.Deleted,
	ctl_doc.Body,
	ctl_doc.Fascicolo,

--
--	 CASE Document_Convenzione_Quote.Value_tec__Azi
--		WHEN '' THEN ctl_doc.Azienda 
--		WHEN '0' THEN ctl_doc.Azienda 
--		ELSE  Document_Convenzione_Quote.Value_tec__Azi
--	  END  AS 
	ctl_doc.Azienda , 
		  
		
	    
	C.Protocol as ProtocolloRiferimento,
	ctl_doc.Protocollo,
	ctl_doc.LinkedDoc,
	ctl_doc.StatoFunzionale,
	CTL_DOC.ID as IdHeader,
	Descrizione,
	CTL_DOC_ALLEGATI.Allegato,
	Document_Convenzione_Quote.importo,
	C.Total,
	C.NumOrd,
	CON.titolo as BodyContratto,

	(C.Total - ISNULL(S.totQ,0)) as Importo_Residuo_Quote ,
--	isnull( ImportoQuota , 0 ) - isnull( ImportoSpesa , 0 )  as Importo_Residuo_Quote ,

	CTL_DOC.Azienda as AZI_Ente,
	Value_tec__Azi,
	CTL_DOC.JumpCheck,
	ctl_doc.StrutturaAziendale


FROM   
	ctl_doc with(nolock)
	inner join document_convenzione C with(nolock) on ctl_doc.LinkedDoc=C.ID
	left join CTL_DOC CON with(nolock) on CON.Id=C.id
	left join Aziende with(nolock) on ctl_doc.Azienda=IdAzi
	left join Document_Convenzione_Quote with(nolock) on Document_Convenzione_Quote.idHeader=ctl_doc.id
	left join CTL_DOC_ALLEGATI with(nolock) on CTL_DOC_ALLEGATI.idHeader=ctl_doc.id
	--left join Document_Convenzione_Quote_Importo S on S.idHeader = C.ID and S.Azienda = ctl_doc.Azienda
	left join (select  ctl_doc.linkeddoc, 
				isnull(sum(importo),0) as totQ 
					from Document_Convenzione_Quote with(nolock) ,ctl_doc  with(nolock)
						where tipodoc='QUOTA' and idheader=id and statodoc='Sended' group by linkeddoc ) S
	
	on S.linkeddoc=ctl_doc.LinkedDoc

--where TipoDoc='QUOTA'
GO
