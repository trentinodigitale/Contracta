USE [AFLink_TND]
GO
/****** Object:  View [dbo].[MAIL_ODC]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE VIEW [dbo].[MAIL_ODC] 
AS
SELECT RDA_Id                          AS iddoc 
     , lngSuffisso                     AS LNG 
     , Document_ODC.*
     --, a.Programma                     AS PEG
     , C1.body   AS Oggetto
     , P.pfuNome
     , Az.Aziragionesociale
     , CONVERT( varchar(10) , RDA_DataCreazione , 103 ) as DataCreazioneOrdine
	 ,C1.Titolo
     , APS_Note
     , CONVERT( varchar(10) , C1.DataInvio , 103 )  as  DataInvio
     , C1.Protocollo
	 , AZ.Aziragionesociale as RagSoc
	 --, P1.pfunome as Destinatario
  FROM 
	ctl_doc C1 
		inner join Document_ODC on C1.id=rda_id
		
		--ultimo passo
		left outer join CTL_ApprovalSteps on APS_Doc_Type=C1.TipoDoc and APS_ID_DOC=C1.Id and APS_IsOld=0

		--utente ed azienda ultimo passo
		left outer join profiliutente p on p.idpfu=aps_idpfu 
		left outer join aziende AZ  on p.pfuidazi=AZ.idazi
		
		--utenti azienda OE che effettua ultimo passo
		--inner join profiliutente p1 on P1.pfuidazi=Destinatario_Azi and p1.idpfu=aps_idpfu 
		--inner join aziende AZ1  on AZ1.idazi=Destinatario_Azi	
		

	--, profiliutente P1
	--, aziende AZ1

		cross join Lingue
 WHERE 
	tipodoc='ODC'
	
GO
