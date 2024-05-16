USE [AFLink_TND]
GO
/****** Object:  View [dbo].[USER_DOC_VIEW]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

---------------------------------------------------------------
--[OK] vista usata dal documento USER_DOC
---------------------------------------------------------------

CREATE view [dbo].[USER_DOC_VIEW]
as
SELECT 
    IdAzi
   ,IdAzi AS ID_FROM
  ,profiliutente.idpfu as IDDOC
   --,profiliutente.idpfu as ID
   ,CTL_DOC.id as ID
   ,pfuIdAzi as Azienda,
   pfuNome as Titolo,
   pfuLogin as Fascicolo,
   pfuRuoloAziendale ,
   pfuPrefissoProt,
   pfuIdLng as LinguaAll,
   pfuE_Mail,
   pfuprofili + '###' + pfufunzionalita     AS funzionalitautente,
   pfuTel,
   pfuCell,
   pfuCodiceFiscale as CODICEFISCALE,
   CTL_DOC.Protocollo,
   CTL_DOC.Destinatario_User,
   CTL_DOC.StatoFunzionale,
   CTL_DOC.PrevDoc,
   CTL_DOC.Data
   ,pfuDataCreazione
   ,CASE ISNULL(pfudeleted,0)
			when 1 then  'deleted'
			else
			CASE ISNULL(pfustato,'')
				WHEN 'block' THEN 'blocked'
				WHEN  '' THEN 'not-blocked'			
			end 
	END AS StatoUtenti 
   
   
  FROM AZIENDE
  inner join profiliutente on idazi=pfuidazi
  left join CTL_DOC on profiliutente.idpfu=Destinatario_USer
GO
