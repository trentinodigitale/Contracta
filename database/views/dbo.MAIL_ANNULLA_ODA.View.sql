USE [AFLink_TND]
GO
/****** Object:  View [dbo].[MAIL_ANNULLA_ODA]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





Create VIEW [dbo].[MAIL_ANNULLA_ODA] 
AS
SELECT
		anOda.Id                          AS iddoc 
     , lngSuffisso                     AS LNG 
     , docOda.*
     --, a.Programma                     AS PEG
     , anOda.body   AS Oggetto
     , P.pfuNome
     , Az.Aziragionesociale
     , CONVERT( varchar(10) , anOda.Data , 103 ) as DataCreazioneOrdine
	 ,anOda.Titolo
     , APS_Note
     , CONVERT( varchar(10) , anOda.DataInvio , 103 )  as  DataInvio
     , anOda.Protocollo
	 , AZ.Aziragionesociale as RagSoc
  FROM 
	ctl_doc as oda 
		inner join ctl_doc as anOda on oda.Id = anOda.LinkedDoc
		inner join Document_ODA as docOda on oda.id=idHeader
		left outer join CTL_ApprovalSteps on APS_Doc_Type=anOda.TipoDoc and APS_ID_DOC=anOda.Id and APS_IsOld=0
		left outer join profiliutente p on p.idpfu=aps_idpfu 
		left outer join aziende AZ  on p.pfuidazi=AZ.idazi
		cross join Lingue
 WHERE 
	anOda.tipodoc='ANNULLA_ODA'	
GO
