USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_TABULATO]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[DASHBOARD_VIEW_TABULATO]  AS
select 
	p.* ,
	case  when (RIGHT(p.ProtocolloBando, 2) = '07'  and p.ProtocolloBando <> '053/2007') or p.ProtocolloBando = '006/2008'  THEN 'Archiviato'
                       when isnull( r.StatoRepertorio , '' ) = '' then 'InCorso'
		else r.StatoRepertorio 
	end as StatoRepertorio 
	, case when left(DataIISeduta2,1) = 'T' then ''else DataIISeduta2 end as DataIISeduta

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
				 , CASE CHARINDEX ('<AFLinkFieldNameBG>', CAST(MSGTEXT AS VARCHAR(8000))) 
						WHEN 0 THEN ''
						ELSE dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldNameBG>', CAST(MSGTEXT AS VARCHAR(8000))) + 19, 400)) 
				   END AS NameBG
				 , CASE CHARINDEX ('<AFLinkFieldProtocolloBando>', CAST(MSGTEXT AS VARCHAR(8000)))
						WHEN 0 THEN ''
						ELSE dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldProtocolloBando>', CAST(MSGTEXT AS VARCHAR(8000))) + 28, 20)) 
				   END AS ProtocolloBando
				 , CASE CHARINDEX ('<AFLinkFieldDataAperturaOfferte>', CAST(MSGTEXT AS VARCHAR(8000)))
						WHEN 0 THEN ''
						ELSE dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldDataAperturaOfferte>', CAST(MSGTEXT AS VARCHAR(8000))) + 32, 25)) 
				   END AS DataAperturaOfferte
				 , CASE CHARINDEX ('<AFLinkFieldDataIISeduta>', CAST(MSGTEXT AS VARCHAR(8000)))
						WHEN 0 THEN ''
						ELSE dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldDataIISeduta>', CAST(MSGTEXT AS VARCHAR(8000))) + 25, 25)) 
				   END AS DataIISeduta2
				 , SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldStato>', CAST(MSGTEXT AS VARCHAR(8000))) + 18, 1) AS StatoGD
				 ,dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldtipoappalto>', CAST(MSGTEXT AS VARCHAR(8000))) + 24, 25)) as  tipoappalto
				 ,dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldProceduraGara>', CAST(MSGTEXT AS VARCHAR(8000))) + 26, 25)) as ProceduraGara 				 
				 


			  FROM TAB_MESSAGGI
				 , TAB_UTENTI_MESSAGGI
			 WHERE IdMsg = umIdMsg
			   AND msgItype = 55
			   AND msgisubtype = 170
			   AND umInput = 0
			   AND umStato = 0
			   AND umIdPfu <> -10

		) as p
				left outer join Document_Repertorio r on r.ProtocolloBando = p.ProtocolloBando
GO
