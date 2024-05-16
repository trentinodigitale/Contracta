USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_DASHBOARD_VIEW_QUOTA_VIEW]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[OLD_DASHBOARD_VIEW_QUOTA_VIEW] AS
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


	 CASE Document_Convenzione_Quote.Value_tec__Azi
		WHEN '' THEN ctl_doc.Azienda 
		WHEN '0' THEN ctl_doc.Azienda 
		ELSE  Document_Convenzione_Quote.Value_tec__Azi
	  END  AS Azienda , 
		  
		
	    
	C.Protocol as ProtocolloRiferimento,
	ctl_doc.Protocollo,
	ctl_doc.LinkedDoc,
	ctl_doc.StatoFunzionale,
	CTL_DOC.ID as IdHeader,
	--Descrizione,
	--CTL_DOC_ALLEGATI.Allegato,
	Document_Convenzione_Quote.importo,
	C.Total,
	C.NumOrd,
	C.Doc_Name as BodyContratto,

	--(C.Total - ISNULL(S.totQ,0)) as Importo_Residuo_Quote ,
	isnull( ImportoQuota , 0 ) - isnull( ImportoSpesa , 0 )  as Importo_Residuo_Quote ,

	CTL_DOC.Azienda as AZI_Ente,
	Value_tec__Azi

FROM   
	ctl_doc 
	inner join document_convenzione C on ctl_doc.LinkedDoc=C.ID
	left join Aziende on ctl_doc.Azienda=IdAzi
	left join Document_Convenzione_Quote on Document_Convenzione_Quote.idHeader=ctl_doc.id
	--left join CTL_DOC_ALLEGATI on CTL_DOC_ALLEGATI.idHeader=ctl_doc.id
	left join Document_Convenzione_Quote_Importo S on S.idHeader = C.ID and S.Azienda = ctl_doc.Azienda
	--left join (select  ctl_doc.linkeddoc, 
	--			isnull(sum(importo),0) as totQ 
	--				from Document_Convenzione_Quote,ctl_doc 
	--					where tipodoc='QUOTA' and idheader=id and statodoc='Sended' group by linkeddoc ) S
	--
	--on S.linkeddoc=ctl_doc.LinkedDoc

where  ctl_doc.TipoDoc='QUOTA' and ctl_doc.deleted=0



GO
