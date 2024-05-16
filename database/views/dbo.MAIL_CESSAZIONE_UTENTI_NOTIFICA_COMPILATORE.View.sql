USE [AFLink_TND]
GO
/****** Object:  View [dbo].[MAIL_CESSAZIONE_UTENTI_NOTIFICA_COMPILATORE]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[MAIL_CESSAZIONE_UTENTI_NOTIFICA_COMPILATORE] 
AS
SELECT 
	   C.id AS iddoc 
     , lngSuffisso                     AS LNG  
	 ,CV2.Value as numgiorni
	 , CONVERT( varchar(10) , CV3.value , 103 )  as  DataUltimoCollegamento
	 , C.protocollo
	 , C.Titolo
	 , CONVERT( varchar(10) , DataInvio , 103 )  as  DataInvio
	 
	 
	 
  FROM 	CTL_DOC C with(nolock)
		inner join CTL_DOC_Value CV2  with(nolock) on CV2.IdHeader=C.id and CV2.DSE_ID='PARAMETRI' and CV2.DZT_Name='NumGiorni'
		inner join CTL_DOC_Value CV3  with(nolock) on CV3.IdHeader=C.id and CV3.DSE_ID='PARAMETRI' and CV3.DZT_Name='DataUltimoCollegamento'
		cross join Lingue with(nolock)
		
				
		
 WHERE 
	C.TipoDoc='CESSAZIONE_UTENTI'
GO
