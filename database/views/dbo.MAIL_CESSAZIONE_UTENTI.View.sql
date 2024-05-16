USE [AFLink_TND]
GO
/****** Object:  View [dbo].[MAIL_CESSAZIONE_UTENTI]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[MAIL_CESSAZIONE_UTENTI] 
AS
SELECT 
	   CV.IdRow AS iddoc 
     , lngSuffisso                     AS LNG 
	 ,ISNULL(pfunomeutente,'') + ' ' + ISNULL(pfuCognome,'') as  NomeCognome
     ,AZ.aziLog as azilog
	 ,p.pfuLogin as pfulogin
	 , CONVERT( varchar(10) , pfulastlogin , 103 )  as  pfulastlogin
	 ,CV2.Value as numgiorni
	 
  FROM 
		CTL_DOC_Value CV with(nolock)
		inner join profiliutente p with(nolock) on p.idpfu=CV.Value 
		inner join aziende AZ  with(nolock) on p.pfuidazi=AZ.idazi		
		inner join CTL_DOC_Value CV2  with(nolock) on CV2.IdHeader=CV.IdHeader and CV2.DSE_ID='PARAMETRI' and CV2.DZT_Name='NumGiorni'
		cross join Lingue with(nolock)
 WHERE 
	CV.DSE_ID='ESITI' and CV.DZT_Name='Idpfu'
	
GO
