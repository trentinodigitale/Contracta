USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_AQ_QUOTA_VIEW]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[DASHBOARD_VIEW_AQ_QUOTA_VIEW] AS
SELECT    
	Q.id,
	Document_Convenzione_Quote.idHeader as IdRow,
	Q.Idpfu,
	Q.StatoDoc,
	Q.Tipodoc,
	Q.Titolo,
	Q.Data,
	Q.DataInvio,
	Q.PrevDoc,
	Q.Deleted,
	Q.Body,
	Q.Fascicolo,


	 CASE Document_Convenzione_Quote.Value_tec__Azi
		WHEN '' THEN Q.Azienda 
		WHEN '0' THEN Q.Azienda 
		ELSE  Document_Convenzione_Quote.Value_tec__Azi
	  END  AS Azienda , 
		  
		
	    
	AQ.Protocollo as ProtocolloRiferimento,
	Q.Protocollo,
	Q.LinkedDoc,
	Q.StatoFunzionale,
	Q.ID as IdHeader,
	--Descrizione,
	--CTL_DOC_ALLEGATI.Allegato,
	Document_Convenzione_Quote.importo,
	C.importoBaseAsta as Total,
	--C.NumOrd,
	AQ.Body as BodyContratto,

	--(C.Total - ISNULL(S.totQ,0)) as Importo_Residuo_Quote ,
	isnull( ImportoQuota , 0 ) - isnull( ImportoSpesa , 0 )  as Importo_Residuo_Quote ,

	Q.Azienda as AZI_Ente,
	Value_tec__Azi,
	Importo_Allocato_Prec

FROM   
	ctl_doc Q with(nolock)
	inner join Document_Bando C with(nolock) on Q.LinkedDoc=C.idHeader
	inner join CTL_DOC AQ with(nolock) on AQ.Id=Q.LinkedDoc
	left join Aziende with(nolock) on Q.Azienda=IdAzi
	left join Document_Convenzione_Quote with(nolock) on Document_Convenzione_Quote.idHeader=Q.id
	--left join CTL_DOC_ALLEGATI on CTL_DOC_ALLEGATI.idHeader=ctl_doc.id
	left join Document_Convenzione_Quote_Importo S  with(nolock) on S.idHeader = C.idHeader and S.Azienda = Q.Azienda
	--left join (select  ctl_doc.linkeddoc, 
	--			isnull(sum(importo),0) as totQ 
	--				from Document_Convenzione_Quote,ctl_doc 
	--					where tipodoc='QUOTA' and idheader=id and statodoc='Sended' group by linkeddoc ) S
	--
	--on S.linkeddoc=ctl_doc.LinkedDoc

where  Q.TipoDoc='AQ_QUOTA' and Q.deleted=0


GO
