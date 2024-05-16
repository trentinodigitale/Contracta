USE [AFLink_TND]
GO
/****** Object:  View [dbo].[MAIL_APPROVAZIONE]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[MAIL_APPROVAZIONE]
AS
SELECT mf.Idmsg                     AS IdDoc
     , lngSuffisso                  AS LNG
     , ProtocolloBando              AS Protocollo
     , CASE isdate(ReceivedDataMsg) WHEN 0 THEN ''
       ELSE convert(varchar(10),cast(ReceivedDataMsg as datetime),103) 
		+ ' ' + convert(varchar(8),cast(ReceivedDataMsg as datetime),108)  
       END as DATA      
    -- convert(varchar(10),cast(ReceivedDataMsg as datetime),103) 
	--	+ ' ' + convert(varchar(8),cast(ReceivedDataMsg as datetime),108)              
	--	  AS Data 
		  , ReceivedDataMsg
     , PfuNome                    
     , Object_cover1                AS Oggetto
  FROM Tab_messaggi_fields mf
     , Tab_utenti_messaggi um
     , Profiliutente
     , Lingue
  WHERE mf.Idmsg = um.umidmsg
    AND um.umIdpfu = Idpfu
   and isubtype  in (167,34,20,48,78,68,24)



GO
