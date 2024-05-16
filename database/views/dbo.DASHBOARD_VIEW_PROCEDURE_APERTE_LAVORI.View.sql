USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_PROCEDURE_APERTE_LAVORI]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[DASHBOARD_VIEW_PROCEDURE_APERTE_LAVORI]  AS

select 
	p.* ,
	case when (RIGHT(p.ProtocolloBando, 2) = '07'  and p.ProtocolloBando <> '053/2007') or p.ProtocolloBando = '006/2008'  THEN 'Archiviato'
                      when isnull( r.StatoRepertorio , '' ) = '' then 'InCorso'
                      
		else r.StatoRepertorio 
	end as StatoRepertorio 

from 
		(

			SELECT IdMsg
				 , umIdPfu AS IdPfu
				 , msgIType
				 , msgISubType
				 , msgelabwithsuccess
				 , CASE CHARINDEX ('<AFLinkFieldName>', CAST(MSGTEXT AS VARCHAR(8000))) 
						WHEN 0 THEN ''
						ELSE dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldName>', CAST(MSGTEXT AS VARCHAR(8000))) + 17, 400)) 
				   END AS Name
				 ,CASE CHARINDEX ('<AFLinkFieldObject_Cover1>', CAST(MSGTEXT AS VARCHAR(8000))) 
						WHEN 0 THEN ''
						ELSE dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldObject_Cover1>', CAST(MSGTEXT AS VARCHAR(8000))) + 26, 400)) 
				   END AS Oggetto
				 , CASE CHARINDEX ('<AFLinkFieldProtocolloBando>', CAST(MSGTEXT AS VARCHAR(8000)))
						WHEN 0 THEN ''
						ELSE dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldProtocolloBando>', CAST(MSGTEXT AS VARCHAR(8000))) + 28, 20)) 
				   END AS ProtocolloBando
				 , CASE CHARINDEX ('<AFLinkFieldExpiryDate>', CAST(MSGTEXT AS VARCHAR(8000)))
						WHEN 0 THEN ''
						ELSE dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldExpiryDate>', CAST(MSGTEXT AS VARCHAR(8000))) + 23, 25)) 
				   END AS ExpiryDate
				 , CASE CHARINDEX ('<AFLinkFieldImportoBaseAsta>', CAST(MSGTEXT AS VARCHAR(8000)))
						WHEN 0 THEN ''
						ELSE dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldImportoBaseAsta>', CAST(MSGTEXT AS VARCHAR(8000))) + 28, 20)) 
				   END AS ImportoBaseAsta
				 , CASE CHARINDEX ('<AFLinkFieldCriterioAggiudicazioneGara>', CAST(MSGTEXT AS VARCHAR(8000)))
						WHEN 0 THEN ''
						ELSE REPLACE(REPLACE(dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldCriterioAggiudicazioneGara>', CAST(MSGTEXT AS VARCHAR(8000))) + 39, 20)), '15531', '1'), '15532', '2')
				   END AS CriterioAggiudicazione
				 , SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldStato>', CAST(MSGTEXT AS VARCHAR(8000))) + 18, 1) AS StatoGD
			  FROM TAB_MESSAGGI
				 , TAB_UTENTI_MESSAGGI
			 WHERE IdMsg = umIdMsg
			   AND msgItype = 55
			   AND msgisubtype = 167
			   AND umInput = 0
			   AND umStato = 0
			   AND umIdPfu <> -10

		) as p
				left outer join Document_Repertorio r on r.ProtocolloBando = p.ProtocolloBando







GO
