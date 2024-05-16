USE [AFLink_TND]
GO
/****** Object:  View [dbo].[MAIL_LISTINO_ORDINI_OE]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[MAIL_LISTINO_ORDINI_OE] 
AS
SELECT 
	 L.id                          AS iddoc 
     , lngSuffisso                     AS LNG 
     , L.body   AS Oggetto
     
     
     , L.Titolo
     , APS_Note
     , CONVERT( varchar(10) , APS_Date , 103 )  as  DataInvio
     , L.Protocollo
	 , Az.Aziragionesociale as RagioneSociale
	 , P.pfuNome
	 , NumOrd 
	 , case 
		when Az.azivenditore <> 0 then 'Operatore Economico'
		when Az.aziacquirente <> 0 then 'Ente'
       end as TipoAzienda
	 , isnull( ML_Description , DOC_DescML ) as TipoDoc

  FROM 
	
	ctl_doc L with (nolock) 
		cross join Lingue with(nolock) 
		
		inner join LIB_Documents  with(nolock,index(IX_LIB_Documents_DOC_ID)) on DOC_ID = TipoDoc	
		
		left outer join LIB_Multilinguismo  with(nolock,index(Index_LIB_Multilinguismo)) on DOC_DescML = ML_KEY and ML_Context = 0 and ML_LNG = lngSuffisso

		inner join document_convenzione C with (nolock) on C.id = L.LinkedDoc
		
		--ultimo passo 
		left outer join CTL_ApprovalSteps with (nolock) on APS_Doc_Type=L.TipoDoc and APS_ID_DOC=L.Id and APS_IsOld=0

		--utente ed azienda ultimo passo
		left outer join profiliutente p with (nolock) on p.idpfu=aps_idpfu 
		left outer join aziende AZ  with (nolock) on p.pfuidazi=AZ.idazi
		
 WHERE 

	L.tipodoc='LISTINO_ORDINI_OE'	and L.deleted=0
	

GO
