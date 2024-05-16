USE [AFLink_TND]
GO
/****** Object:  View [dbo].[MAIL_ODA]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [dbo].[MAIL_ODA] 
AS
SELECT
		Id                          AS iddoc 
     , lngSuffisso                     AS LNG 
     , Document_ODA.*
     --, a.Programma                     AS PEG
     , C1.body   AS Oggetto
     , P.pfuNome
     , Az.Aziragionesociale
     , CONVERT( varchar(10) , Data , 103 ) as DataCreazioneOrdine
	 ,C1.Titolo
     , APS_Note
     , CONVERT( varchar(10) , C1.DataInvio , 103 )  as  DataInvio
     , C1.Protocollo
	 , AZ.Aziragionesociale as RagSoc
  FROM 
	ctl_doc C1 
		inner join Document_ODA on C1.id=idHeader
		left outer join CTL_ApprovalSteps on APS_Doc_Type=C1.TipoDoc and APS_ID_DOC=C1.Id and APS_IsOld=0
		left outer join profiliutente p on p.idpfu=aps_idpfu 
		left outer join aziende AZ  on p.pfuidazi=AZ.idazi
		cross join Lingue
 WHERE 
	tipodoc='ODA'
	
GO
