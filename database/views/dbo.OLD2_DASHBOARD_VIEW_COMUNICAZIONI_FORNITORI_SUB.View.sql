USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_DASHBOARD_VIEW_COMUNICAZIONI_FORNITORI_SUB]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[OLD2_DASHBOARD_VIEW_COMUNICAZIONI_FORNITORI_SUB]
AS
SELECT Document_Com_DPE_Fornitori.IdComFor
				 , Name
				  ,'' as Fascicolo
				 , 0 as bRead 
				 , a1.IdPfu                           AS owner
				 , DataCreazione
				 , Protocollo
				 , 'COM_DPE_FORNITORE_APP' as OPEN_DOC_NAME
			     , '2' AS StatoGD
			     , '1' as OpenDettaglio

				 , RichiestaRisposta	 
				 , case when isnull( FORNITORIGrid_ID_DOC , 0 ) <> 0 then 1 else 0 end Scrittura ,

				 b2.aziRagioneSociale as EnteAppaltante,
				 b2.idazi as AZI_Ente
			  
			  FROM Document_Com_DPE  with (nolock)
				 inner join Document_Com_DPE_Fornitori  with (nolock) on Document_Com_DPE_Fornitori.IdCom = Document_Com_DPE.IdCom
				 inner join Aziende  a2 with (nolock) on Document_Com_DPE_Fornitori.IdAzi = a2.IdAzi
				 inner join ProfiliUtente a1  with (nolock)	 on a1.pfuIdAzi = a2.IdAzi			 
				 left outer join ProfiliUtente b1  with (nolock) on Document_Com_DPE.Owner = b1.IdPfu 
				 left outer join Aziende  b2 with (nolock) on b1.pfuIdAzi = b2.idazi and b2.aziAcquirente = 3

			 WHERE 
			    StatoCom not in ('Salvato' ,'Richiamata','InProtocollazione') 
					AND Deleted = 0
			   

			union 

			SELECT   distinct Document_Com_DPE.IdCom
				 , Name
				  ,'' as Fascicolo
				 , 0 as bRead 
				 , a1.IdPfu AS owner
				 , DataCreazione
				 , Protocollo
				 , 'COM_DPE_FORNITORE_APP' as OPEN_DOC_NAME
			     , '2' AS StatoGD
				 , '1' as OpenDettaglio
				 
				 , RichiestaRisposta	 
				 , case when isnull( PLANTGrid_ID_DOC , 0 ) <> 0 then 1 else 0 end Scrittura ,

					b2.aziRagioneSociale as EnteAppaltante,
					b2.idazi as AZI_Ente
				 
			  FROM Document_Com_DPE  with (nolock)
					inner join Document_Com_DPE_Plant  with (nolock) on Document_Com_DPE_Plant.IdCom = Document_Com_DPE.IdCom
					inner join profiliutenteattrib a1 with (nolock) on  a1.dztnome='Filtropeg'  and a1.attvalue=Document_Com_DPE_Plant.plant

					left outer  join ProfiliUtente b1  with (nolock) on Document_Com_DPE.Owner = b1.IdPfu 
					left outer join Aziende  b2 with (nolock) on b1.pfuIdAzi = b2.idazi and b2.aziAcquirente = 3
			 
			 WHERE 
			     StatoCom not in ('Salvato' ,'Richiamata','InProtocollazione') 
					AND Deleted = 0			   
			   

			union
			

			SELECT IdMsg as IdCom
			  , Name
			  , ProtocolBG AS Fascicolo  
			  , [Read] as  bRead  
			  , umIdPfu  AS owner
			  , ReceivedDataMsg AS DataCreazione
			  , ProtocolloOfferta AS Protocollo
			  , '' as OPEN_DOC_NAME
			  , '2' AS StatoGD
			  , '1' as OpenDettaglio

			  , 'no' as RichiestaRisposta	 
			  , 0 as Scrittura ,

			  b2.aziRagioneSociale as EnteAppaltante,
					b2.idazi as AZI_Ente
			  
			FROM 
				tab_utenti_messaggi  with (nolock) 
				inner join tab_messaggi_fields  with (nolock) on umIdMsg = IdMsg
				left outer join ProfiliUtente b1  with (nolock) on tab_messaggi_fields.IdMittente = b1.IdPfu 
				left outer join Aziende  b2 with (nolock) on b2.IdAzi = b1.pfuIdAzi  and b2.aziAcquirente = 3

			WHERE    
					 ISubType in ( '109' ,'162' , '182' , '117' , '119' , '129' , '121' ,
									'134' , '97' , '84' , '99' , '87' , '73' ,  '82' , '164' , '138' , '143' , '145' , 
									'157' , '147' ,'176' ,'15','17','31','47','110','53','3', '164', '184')
						and uminput=0
						and umstato=0
					
			

			union 

			SELECT idrow as IdCom
				 , dbo.CNV('ML_DASHBOARD_VIEW_COMUNICAZIONI_FORNITORI_Comunicazione su Bando','I' ) + ' ' + Protocol as Name
				 ,'' as Fascicolo
				 ,  0 as bRead 
				 , p.idpfu AS owner
				 , DataInvio as DataCreazione
				 , case isnull(DCF.ProtocolloGenerale,'') 
			 when '' then  DC.ProtocolloGenerale 
			 else DCF.ProtocolloGenerale 
			 end   as  Protocollo
				 , 'COM_GENERICA_FORNITORE' as OPEN_DOC_NAME
			  , '2' AS StatoGD
			  , '1' as OpenDettaglio

			  , 'no' as RichiestaRisposta	 
			  , 0 as Scrittura ,

			  '' as EnteAppaltante,
					-1 as AZI_Ente		  


				  FROM 
					 Document_Comunicazione DC    with (nolock)
						inner join Document_Comunicazione_Fornitori  DCF  with (nolock) 	on dc.id=idheader
						inner join CTL_DOC_READ DR   with (nolock) on DCF.idrow=DR.id_doc									  
						inner join ProfiliUtente P  with (nolock) on P.pfuIdAzi = Fornitore
				     
				 
				 WHERE  Stato = 'Sended'  
				

				


			UNION

			SELECT idrow as IdCom
				 , dbo.CNV('ML_DASHBOARD_VIEW_COMUNICAZIONI_FORNITORI_Comunicazione su Bando','I' ) + ' ' + Protocol as Name
				 ,'' as Fascicolo
				 ,  1 as bRead 
				 , p.idpfu AS owner
				 , DataInvio as DataCreazione
				 , case isnull(DCF.ProtocolloGenerale,'') 
			 when '' then  DC.ProtocolloGenerale 
			 else DCF.ProtocolloGenerale 
			 end   as  Protocollo
				 , 'COM_GENERICA_FORNITORE' as OPEN_DOC_NAME
			  , '2' AS StatoGD
			  , '1' as OpenDettaglio


			  , 'no' as RichiestaRisposta	 
			  , 0 as Scrittura ,

			  '' as EnteAppaltante,
					-1 as AZI_Ente

			  FROM 
					 Document_Comunicazione DC    with (nolock)
						inner join Document_Comunicazione_Fornitori  DCF  with (nolock) on dc.id=idheader						  
						inner join ProfiliUtente P  with (nolock) on P.pfuIdAzi = Fornitore
				     
				 
				 WHERE 
				
				 Stato = 'Sended'  				
					and DCF.idrow not in ( select distinct id_doc from ctl_doc_read /*where DR.DOC_NAME like 'COM_GENERICA_FORNITORE' */)


			UNION


			SELECT C.ID as IdCom
				 , C.Titolo as Name
				 , C.Fascicolo
				 , case when r.id is null then 1 else 0 end as bRead 
			--     , 0 as bRead 
				 , P.IdPfu                           AS owner
				 , C.DataInvio as DataCreazione
				 , C.Protocollo
				 ,TipoDoc as OPEN_DOC_NAME
			  , '2' AS StatoGD
			  , '1' as OpenDettaglio
			  
			 --, 'no' as RichiestaRisposta	 

			  , case when LEFT( C.jumpcheck ,1) = '1' then 'si'
					else 'no'
				end as RichiestaRisposta

			  --, 0 as Scrittura 
			  , case when w.LinkedDoc is not null then 1 else 0 end as Scrittura ,
				
				case when isnull(b2.aziAcquirente,-1) = 3 then b2.aziRagioneSociale
					else c2.aziRagioneSociale end  as EnteAppaltante,

				case when isnull(b2.aziAcquirente,-1) = 3 then b2.idazi
					else c2.idazi end  as AZI_Ente
				


			  FROM CTL_DOC C  with (nolock)
				inner join ProfiliUtente P  with (nolock) on C.Destinatario_azi=P.pfuIdazi
				left outer join ctl_doc_read r  with (nolock) on c.id = r.id_doc 
												and DOC_NAME in ('PDA_COMUNICAZIONE_GARA','PDA_COMUNICAZIONE_OFFERTA','CONFERMA_ISCRIZIONE_SDA','CONFERMA_ISCRIZIONE', 'SCARTO_ISCRIZIONE','SCARTO_ISCRIZIONE_SDA', 'INTEGRA_ISCRIZIONE','INTEGRA_ISCRIZIONE_SDA', 'INTEGRA_ISCRIZIONE_RIS','INTEGRA_ISCRIZIONE_RIS_SDA','CONFERMA_ISCRIZIONE_LAVORI')
												and r.idpfu = p.idpfu
				left join ( select linkeddoc from ctl_doc  with (nolock) where LinkedDoc is not null group by LinkedDoc ) as w on w.LinkedDoc=c.id
			     
				  --left outer join ProfiliUtente b1  with (nolock) on b1.idpfu = c.IdPfu 
				  left outer join Aziende  b2 with (nolock) on c.Azienda  = b2.idazi and b2.aziAcquirente = 3
				  left outer join Aziende  c2 with (nolock) on c.Destinatario_Azi   = c2.idazi and c2.aziAcquirente = 3

			 WHERE 
				--C.StatoDoc <> 'Saved'  
				C.StatoFunzionale not in ('InLavorazione','InProtocollazione')
			   AND C.Deleted = 0 and TipoDoc in ('PDA_COMUNICAZIONE_GARA','PDA_COMUNICAZIONE_OFFERTA','CONFERMA_ISCRIZIONE_SDA','CONFERMA_ISCRIZIONE', 'SCARTO_ISCRIZIONE','SCARTO_ISCRIZIONE_SDA', 'INTEGRA_ISCRIZIONE','INTEGRA_ISCRIZIONE_SDA', 'INTEGRA_ISCRIZIONE_RIS','INTEGRA_ISCRIZIONE_RIS_SDA','CONFERMA_ISCRIZIONE_LAVORI')
				


			UNION
			--le comunicazioni di esito e svincolo
			SELECT C.IDROW as IdCom
				 , C.Titolo as Name
				 , '' as Fascicolo
				 , case when r.id is null then 1 else 0 end as bRead 
				 , P.IdPfu                           AS owner
				 , C.DataInvio as DataCreazione
				 , C.Protocollo
				 , 'COM_ESITO_GARA_FORNITORE' as OPEN_DOC_NAME
				 , '2' AS StatoGD
				 , '1' as OpenDettaglio
			  
			  , 'no' as RichiestaRisposta	 
			  , 0 as Scrittura ,
			  b2.aziRagioneSociale as EnteAppaltante,
					b2.idazi as AZI_Ente

			  FROM Document_EsitoGara_Fornitori C  with (nolock)
				inner join ProfiliUtente P  with (nolock) on C.Fornitore=P.pfuIdazi
				left outer join ctl_doc_read r  with (nolock) on c.idrow = r.id_doc 
												and DOC_NAME in ('COM_ESITO_GARA_FORNITORE')
												and r.idpfu = p.idpfu

			     left outer join ProfiliUtente b1  with (nolock) on b1.idpfu = c.IdPfu 
				  left outer join Aziende  b2 with (nolock) on b1.pfuIdAzi = b2.idazi and b2.aziAcquirente = 3

			 WHERE 
				C.Stato = 'Sended'
			
			UNION
			--le comunicazioni di aggiudicazione flusso unico
			SELECT A.ID as IdCom
				 , A.Titolo as Name
				 , '' as Fascicolo
				 , case when r.id is null then 1 else 0 end as bRead 
				 , P.IdPfu                           AS owner
				 , A.DataInvio as DataCreazione
				 , A.Protocollo
				 , 'COM_AGGIUDICATARIA' as OPEN_DOC_NAME
				 , '2' AS StatoGD
				 , '1' as OpenDettaglio

			  , 'no' as RichiestaRisposta	 
			  , 0 as Scrittura ,
			  b2.aziRagioneSociale as EnteAppaltante,
					b2.idazi as AZI_Ente
			  
			  FROM Document_Com_Aggiudicataria A  with (nolock) 
				inner join ProfiliUtente P  with (nolock) on A.idAggiudicatrice=P.pfuIdazi
				left outer join ctl_doc_read r with (nolock)  on A.id = r.id_doc 
												and DOC_NAME in ('COM_AGGIUDICATARIA')
												and r.idpfu = p.idpfu

				left outer join ProfiliUtente b1  with (nolock) on b1.idpfu = a.IdPfu 
				  left outer join Aziende  b2 with (nolock) on b1.pfuIdAzi = b2.idazi and b2.aziAcquirente = 3

			     
			 WHERE 
				A.Stato = 'Sended'

				UNION
                 --per recuperare le risposte agli atti di gara
                        SELECT C.ID as IdCom
				 , C.Titolo as Name
				 , C.Fascicolo
				 , case when r.id is null then 1 else 0 end as bRead 
			--     , 0 as bRead 
				 , C1.IdPfu                           AS owner
				 , C.DataInvio as DataCreazione
				 , C.Protocollo
				 ,'INVIO_ATTI_GARA_IA' as OPEN_DOC_NAME
			  , '2' AS StatoGD
			  , '1' as OpenDettaglio
			    , 'no' as RichiestaRisposta	 
			  , 0 as Scrittura ,
			  b2.aziRagioneSociale as EnteAppaltante,
					b2.idazi as AZI_Ente


			  FROM CTL_DOC C  with (nolock) 
                    inner join CTL_DOC AS C1  with (nolock) ON C.linkeddoc = C1.id AND C1.tipodoc = 'RICHIESTA_ATTI_GARA'
					left outer join ctl_doc_read r  with (nolock) on c.id = r.id_doc and DOC_NAME in ('INVIO_ATTI_GARA') and r.idpfu = C1.idpfu
					left outer join ProfiliUtente b1  with (nolock) on b1.idpfu = c.IdPfu 
				  left outer join Aziende  b2 with (nolock) on b1.pfuIdAzi = b2.idazi and b2.aziAcquirente = 3
			 WHERE 
				C.StatoDoc <> 'Saved'  
			   AND C.Deleted = 0 and C.TipoDoc in ('INVIO_ATTI_GARA')











GO
