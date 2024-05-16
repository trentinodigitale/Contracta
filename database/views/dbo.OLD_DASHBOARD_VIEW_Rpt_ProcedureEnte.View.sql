USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_DASHBOARD_VIEW_Rpt_ProcedureEnte]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE  view [dbo].[OLD_DASHBOARD_VIEW_Rpt_ProcedureEnte] as

SELECT t.tPeriodo as Periodo
      ,SUM(t.tImporto) as Importo
      ,t.tTipoProcedura as TipoProcedura_KPI
      ,cast(t.tTipologia as int) as Tipologia_KPI
	  ,SUM(t.tQta) as Qta
	, cast(SUM(t.tQta) as float)/ cast((SELECT count(*) FROM tab_messaggi_fields WHERE  
				isubtype in (24, 34, 48, 68) AND
				idmsg in (select umidmsg from tab_utenti_messaggi where  uminput = 1)) as float) as PercN_Bandi				 
FROM 
(	
SELECT substring(ReceivedDataMsg, 1, 7) as tPeriodo,  --- il formato di ReceivedDataMsg è 2011-10-20T16:47:47
                       CASE isubtype 
                               WHEN 68 THEN CAST(dbo.TAB_MESSAGGI_FIELDS.ImportoBaseAsta2 AS float) 
                               WHEN 48 THEN CAST(dbo.TAB_MESSAGGI_FIELDS.ImportoBaseAsta2 AS float) 
                               ELSE CAST(dbo.TAB_MESSAGGI_FIELDS.ImportoBaseAsta AS float) 
                        END AS tImporto,

		--	cast (ImportoBaseAsta2 as float) as tImporto,
				CASE ProceduraGara 
					WHEN 15476
						THEN 24
					WHEN 15478
						THEN 48
					WHEN 15479
						THEN 68
					ELSE
						dbo.TAB_MESSAGGI_FIELDS.iSubType	
					END AS tTipoProcedura,
			tipoappalto as tTipologia,	-- 14494 = Servizi, 14495 = Forniture
			1 as tQta
FROM         dbo.TAB_MESSAGGI_FIELDS with(nolock) 
            INNER JOIN TAB_UTENTI_MESSAGGI tt on TAB_MESSAGGI_FIELDS.IdMsg=tt.umIdMsg     and ProtocolloBando not like 'demo%'      
WHERE      
			(
			(dbo.TAB_MESSAGGI_FIELDS.iSubType IN (24, 48, 68) AND tt.umInput = 1)	-- negoziate, RDP
				AND 
					ProtocolBG not in 
							(
                            select ProtocolBG from dbo.TAB_MESSAGGI_FIELDS
							  where 
							  isubtype = 76		--- annullato
							  and Stato = 2		--- inviato
                            )
            )
			OR
			(
			((dbo.TAB_MESSAGGI_FIELDS.iSubType = 167 AND ProceduraGara = 15478 AND TipoBando = 3 and stato <> 1) -- proc.unica/negoziate diverso da salvata
				OR (dbo.TAB_MESSAGGI_FIELDS.iSubType = 167 AND ProceduraGara = 15476 and stato <> 1) -- proc.unica/aperta diverso da salvata 10/01/2013
				OR (dbo.TAB_MESSAGGI_FIELDS.iSubType = 167 AND ProceduraGara = 15479 and stato <> 1 ) ) -- proc.unica/RDP
					AND tt.umInput = 0
					AND umStato = 0
			)     
			
UNION ALL

SELECT 
		substring(convert( varchar(19) , d.DataInvio , 126 ), 1, 7) as tPeriodo,
--		b.ImportoBaseAsta2 as tImporto,
		b.ImportoBaseAsta as tImporto,
		CASE ProceduraGara 
					WHEN '15476'
						THEN '24'
					WHEN '15478'
						THEN '48'
					WHEN '15479'
						THEN '68'
					WHEN '15477'
						THEN '34'
					END AS tTipoProcedura,
		CASE b.tipoappaltoGara 
					when '1' then '15495'
					when '2' then '15496'
					when '3' then '15494'
				end  AS tTipologia, 
			1 as tQta
	from CTL_DOC d
		inner join Document_bando b on d.id = b.idheader
		inner join ( select count(*) as NumLotti , idheader from Document_MicroLotti_Dettagli where tipodoc = 'BANDO_GARA' and Voce = 0 group by idheader ) as nl on nl.idheader = d.id
		left outer join  ctl_doc_value r on r. idHeader = d.id and r.DSE_ID = 'InfoTec_comune' and r.dzt_name = 'USerRUP'
		left outer join  profiliutente rup on rup.idpfu = r.value
		left outer join ( select count(*) as NumInviti , idheader from CTL_DOC_Destinatari group by idheader ) as ni on ni.idheader = d.id

	where tipodoc = 'BANDO_GARA' 
		and deleted = 0 
		and Statofunzionale in ( 'InEsame','InRettifica','Pubblicato')
) as t
GROUP BY t.tPeriodo, t.tTipoProcedura, t.tTipologia







GO
