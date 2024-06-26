USE [AFLink_TND]
GO
/****** Object:  View [dbo].[MAIL_CHAT]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[MAIL_CHAT] 
AS
SELECT 
	 C1.id
	,C2.protocollo as ProtocolloLinked
	,isnull( ML_Description , DOC_DescML ) as TipoDocLinked
	,c1.id as iddoc
	,lngSuffisso as LNG
	,p.pfuNome + ' ' + p.pfuCognome as  Nome_Cognome
	,a.aziRagionesociale as EnteUtente
	, convert( varchar , CA.APS_Date , 103 ) + ' ' + convert( varchar , CA.APS_Date , 108 ) as Data_Inserimento
	,CA.APS_Note as Nuovo_MSG
	,dbo.Get_Tabella_Conversazione_CHAT(C1.LinkedDoc) as tabella_conversazione

  FROM 	
	ctl_doc C1 
	inner join profiliutente p on p.idpfu = c1.idpfu
	inner join aziende a on a.idazi = p.pfuidazi
	inner join ctl_doc C2 on C1.LinkedDoc=C2.id
	cross join Lingue
	inner join LIB_Documents on DOC_ID = C2.TipoDoc
	left outer join LIB_Multilinguismo on DOC_DescML = ML_KEY and ML_Context = 0 and ML_LNG = lngSuffisso
	left join CTL_ApprovalSteps CA on APS_APC_Cod_Node=c1.id and ISNULL(APS_IsOld,0) <> 1
	
 WHERE 
	C1.tipodoc='CHAT'
GO
