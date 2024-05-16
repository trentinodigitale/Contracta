USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_DASHBOARD_VIEW_Rpt_ProcNeg]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[OLD_DASHBOARD_VIEW_Rpt_ProcNeg] as
SELECT	
-- TOP 100 PERCENT
		IdMsg as ID,
--				NumRiga as Prog,
				CASE ProceduraGara 
					WHEN '15476'
						THEN '24'
					WHEN '15478'
						THEN '48'
					WHEN '15479'
						THEN '68'
					ELSE
						dbo.TAB_MESSAGGI_FIELDS.iSubType	
					END AS TipoProcedura_KPI,
					CASE 
					WHEN (TAB_MESSAGGI_FIELDS.iSubType = '167' AND ListaModelliMicrolotti <> '')
					THEN 'SI' ELSE ''
					END AS DivisioneInLotti,
					(select max(cast(NumeroLotto as int)) 
					       from Document_MicroLotti_Dettagli
                                               where idheader=TAB_MESSAGGI_FIELDS.IdMsg 
                                               and  ISNUMERIC(NumeroLotto) = 1
                                             ) as NumLotti, 
					  dbo.TAB_MESSAGGI_FIELDS.tipoappalto AS Tipologia_KPI, 
                      dbo.TAB_MESSAGGI_FIELDS.ProtocolBG AS Fascicolo, 
                      dbo.TAB_MESSAGGI_FIELDS.Name AS Name, 
                      dbo.TAB_MESSAGGI_FIELDS.Object_Cover1 AS Oggetto, 
                      dbo.TAB_MESSAGGI_FIELDS.CIG, 
                      dbo.TAB_MESSAGGI_FIELDS.ProtocolloBando as ProtocolloBando, 
                      dbo.TAB_MESSAGGI_FIELDS.RagSoc AS RUP, 
                      dbo.ProfiliUtente.pfuIdAzi AS AZI_Ente2, 
                      dbo.ProfiliUtente.pfuE_Mail AS pfuE_Mail, 
                      dbo.ProfiliUtente.pfuNome AS pfuNome, 
                      dbo.TAB_MESSAGGI_FIELDS.ReceivedDataMsg AS DataPubblicazioneBando, 
                      dbo.TAB_MESSAGGI_FIELDS.ExpiryDate AS ExpiryDate, 
                      dbo.TAB_MESSAGGI_FIELDS.ExpiryDate AS ExpiryDateAl, 
                      dbo.TAB_MESSAGGI_FIELDS.DataAperturaOfferte AS DataAperturaOfferte, 
                      dbo.TAB_MESSAGGI_FIELDS.DataAperturaOfferte AS DataAperturaOfferteAl, 
                      
                        CASE isubtype 
                               WHEN 68 THEN CAST(dbo.TAB_MESSAGGI_FIELDS.ImportoBaseAsta2 AS float) 
                               WHEN 48 THEN CAST(dbo.TAB_MESSAGGI_FIELDS.ImportoBaseAsta2 AS float) 
                               ELSE CAST(dbo.TAB_MESSAGGI_FIELDS.ImportoBaseAsta AS float) 
                        END AS importoBaseAsta,
                                              
--                      dbo.TAB_MESSAGGI_FIELDS.ProtocolBG,
                      (select count(distinct IdDestinatario) from TAB_MESSAGGI_FIELDS as t 
							where TAB_MESSAGGI_FIELDS.ProtocolBG = t. ProtocolBG
							and t.iSubType IN ('49', '69', '168')) as QtaAziInvitate,     -- 168 per procedura unica
                      (select count(IdDestinatario) from TAB_MESSAGGI_FIELDS as tt 
							where TAB_MESSAGGI_FIELDS.ProtocolBG = tt. ProtocolBG
							and tt.iSubType IN ('71', '55', '171')) as QtaOffRicevute,         -- 171 per procedura unica
							
                       CASE WHEN ISDATE	(TAB_MESSAGGI_FIELDS.ExpiryDate) = 1
                            THEN						
                                CASE WHEN CAST(SUBSTRING(TAB_MESSAGGI_FIELDS.ExpiryDate, 1, 10) AS DATETIME) > GETDATE() 
                                        THEN DATEDIFF(day, CAST(SUBSTRING(TAB_MESSAGGI_FIELDS.ExpiryDate, 1, 10) AS DATETIME),GETDATE()) 	         
                                        ELSE NULL
                                END 					
		            ELSE NULL 
		       END AS Num
/*
					CASE 
					WHEN cast (REPLACE(SUBSTRING(dbo.TAB_MESSAGGI_FIELDS.ExpiryDate, 1, 10), 'T10:00:00', '') as datetime) > getdate() 
						THEN DATEDIFF(day, cast (REPLACE(SUBSTRING(dbo.TAB_MESSAGGI_FIELDS.ExpiryDate, 1, 10), 'T10:00:00', '') as datetime),getdate()) 	         
					ELSE NULL
					END AS Num					
*/
FROM         dbo.TAB_MESSAGGI_FIELDS with(nolock) 
			-- INNER JOIN [dummy_row]() ON TAB_MESSAGGI_FIELDS.IdMsg=IdMsgDummy
			INNER JOIN dbo.ProfiliUtente ON dbo.ProfiliUtente.IdPfu = CAST(dbo.TAB_MESSAGGI_FIELDS.IdMittente AS int) AND ProtocolloBando NOT LIKE 'DEMO%'
            INNER JOIN TAB_UTENTI_MESSAGGI tt on TAB_MESSAGGI_FIELDS.IdMsg=tt.umIdMsg       
                      
WHERE  (    
			(
			(dbo.TAB_MESSAGGI_FIELDS.iSubType IN ('48', '68') AND tt.umInput = 1)	-- negoziate, RDP
				AND 
				
					ProtocolBG not in 
							(
                            select ProtocolBG from dbo.TAB_MESSAGGI_FIELDS
							  where 
							  isubtype = '76'		--- annullato
							  and Stato = '2'		--- inviato
                            )
            )
			OR
			(
			((dbo.TAB_MESSAGGI_FIELDS.iSubType = '167' AND ProceduraGara = '15478' AND TipoBando = '3' and stato <> '1') -- proc.unica/negoziate diverso da salvata
				OR (dbo.TAB_MESSAGGI_FIELDS.iSubType = '167' AND ProceduraGara = '15476' and stato <> '1') -- proc.unica/aperta diverso da salvata 10/01/2013
				OR (dbo.TAB_MESSAGGI_FIELDS.iSubType = '167' AND ProceduraGara = '15479')) -- proc.unica/RDP
					AND tt.umInput = 0
					AND umStato = 0
			)  )                          

and TAB_MESSAGGI_FIELDS.Stato = '2'

union all


SELECT	
		d.id as ID,
				CASE ProceduraGara 
					WHEN '15476'
						THEN '24'
					WHEN '15478'
						THEN '48'
					WHEN '15479'
						THEN '68'
					WHEN '15477'
						THEN '34'
					END AS TipoProcedura_KPI,
					
					
				CASE 
					WHEN Divisione_Lotti <> '0'
					THEN 'SI' ELSE ''
					END AS DivisioneInLotti,

				
				nl.NumLotti, 

                                             
				case b.tipoappaltoGara 
					when '1' then '15495'
					when '2' then '15496'
					when '3' then '15494'
				end  AS Tipologia_KPI, 
				d.Fascicolo, 
				d.Titolo AS Name, 
				d.Body AS Oggetto, 
				b.CIG, 
				b.ProtocolloBando, 
				rup.pfuNome AS RUP, 
				rup.pfuIdAzi AS AZI_Ente2, 
				rup.pfuE_Mail AS pfuE_Mail, 
				rup.pfuNome AS pfuNome, 
				
				convert( varchar , d.DataInvio , 126 ) AS DataPubblicazioneBando, 
				convert( varchar , b.DataScadenzaOfferta , 126 )  AS ExpiryDate, 
				convert( varchar , b.DataScadenzaOfferta , 126 )  AS ExpiryDateAl, 
				convert( varchar , b.DataAperturaOfferte , 126 )  AS DataAperturaOfferte , 
				convert( varchar , b.DataAperturaOfferte , 126 )  AS DataAperturaOfferteAl, 
				b.ImportoBaseAsta ,
				
				case when b.TipoBandogara = '3' 
					then ni.NumInviti
					else null
				end  as QtaAziInvitate,     
					
				b.RecivedIstanze as QtaOffRicevute,        
					
								
				CASE WHEN b.DataAperturaOfferte > GETDATE() 
						THEN DATEDIFF(day, b.DataAperturaOfferte ,GETDATE()) 	         
						ELSE NULL
				END AS Num

	from CTL_DOC d
		inner join Document_bando b on d.id = b.idheader
		left join ( select count(*) as NumLotti , idheader from Document_MicroLotti_Dettagli where tipodoc = 'BANDO_GARA' and Voce = 0 group by idheader ) as nl on nl.idheader = d.id
		left outer join  ctl_doc_value r on r. idHeader = d.id and r.DSE_ID = 'InfoTec_comune' and r.dzt_name = 'USerRUP'
		left outer join  profiliutente rup on rup.idpfu = r.value
		left outer join ( select count(*) as NumInviti , idheader from CTL_DOC_Destinatari group by idheader ) as ni on ni.idheader = d.id

	where tipodoc = 'BANDO_GARA' 
		and deleted = 0 
		and Statofunzionale in ( 'InEsame','InRettifica','Pubblicato')








GO
