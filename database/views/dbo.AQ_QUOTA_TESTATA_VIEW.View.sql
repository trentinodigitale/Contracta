USE [AFLink_TND]
GO
/****** Object:  View [dbo].[AQ_QUOTA_TESTATA_VIEW]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[AQ_QUOTA_TESTATA_VIEW] AS
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

--
--	 CASE Document_Convenzione_Quote.Value_tec__Azi
--		WHEN '' THEN ctl_doc.Azienda 
--		WHEN '0' THEN ctl_doc.Azienda 
--		ELSE  Document_Convenzione_Quote.Value_tec__Azi
--	  END  AS 
	Q.Azienda , 
		  
		
	    
	AQ.Protocollo as ProtocolloRiferimento,
	Q.Protocollo,
	Q.LinkedDoc,
	Q.StatoFunzionale,
	Q.ID as IdHeader,
	Descrizione,
	CTL_DOC_ALLEGATI.Allegato,
	Document_Convenzione_Quote.importo,
	DB.importoBaseAsta as Total,	
	AQ.Body as BodyContratto,

	(DB.importoBaseAsta - ISNULL(S.totQ,0)) as Importo_Residuo_Quote ,
--	isnull( ImportoQuota , 0 ) - isnull( ImportoSpesa , 0 )  as Importo_Residuo_Quote ,

	Q.Azienda as AZI_Ente,
	Value_tec__Azi,
	DB.CIG

FROM   
	ctl_doc Q with(nolock)
	inner join document_bando DB with(nolock) on Q.LinkedDoc=DB.IDHEADER
	inner join CTL_DOC AQ with(nolock) on AQ.id=DB.IDHEADER
	left join Aziende with(nolock) on Q.Azienda=IdAzi
	left join Document_Convenzione_Quote with(nolock) on Document_Convenzione_Quote.idHeader=Q.id
	left join CTL_DOC_ALLEGATI with(nolock) on CTL_DOC_ALLEGATI.idHeader=Q.id
	--left join Document_Convenzione_Quote_Importo S on S.idHeader = C.ID and S.Azienda = ctl_doc.Azienda
	left join (select  ctl_doc.linkeddoc, 
				isnull(sum(importo),0) as totQ 
					from Document_Convenzione_Quote,ctl_doc 
						where tipodoc='AQ_QUOTA' and idheader=id and statodoc='Sended' group by linkeddoc ) S
	
	on S.linkeddoc=Q.LinkedDoc

--where TipoDoc='QUOTA'
GO
