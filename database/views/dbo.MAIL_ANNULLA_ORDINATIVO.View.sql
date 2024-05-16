USE [AFLink_TND]
GO
/****** Object:  View [dbo].[MAIL_ANNULLA_ORDINATIVO]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[MAIL_ANNULLA_ORDINATIVO] 
AS
SELECT 
	   c1.Id                          AS iddoc 
     , lngSuffisso                     AS LNG 
     , Document_ODC.*
     , P.pfuNome
     , Az.Aziragionesociale
     , CONVERT( varchar(10) , RDA_DataCreazione , 103 ) as DataCreazioneOrdine
	 , APS_Note
     , CONVERT( varchar(10) , C1.DataInvio , 103 )  as  DataInvio
     ,C1.Protocollo
	 ,C1.ProtocolloRiferimento	
	 ,C1.Titolo 

	 ,conv.titolo as nomeConvenzione
	 ,comp.pfunome as compilatore

  FROM 
	ctl_doc C1 
		inner join Document_ODC on C1.linkeddoc=rda_id
		
		--ultimo passo
		left outer join CTL_ApprovalSteps on APS_Doc_Type=C1.TipoDoc and APS_ID_DOC=C1.Id and APS_IsOld=0 and Aps_State in ('InCharge','Denied')

		--utente ed azienda ultimo passo
		left outer join profiliutente p on p.idpfu=aps_idpfu 

		--left outer join aziende AZ  on p.pfuidazi=AZ.idazi
		left outer join aziende AZ  on c1.azienda=AZ.idazi
		
		cross join Lingue

		-- recupero i dati della convenzione
		inner join ctl_doc odc on c1.linkeddoc = odc.id     --odc 
		inner join ctl_doc conv on odc.linkeddoc = conv.id  --convenzione
		--recupero il compilatore
		left outer join profiliutente comp on odc.idpfu = comp.idpfu 

 WHERE 
	c1.tipodoc='ANNULLA_ORDINATIVO'



GO
