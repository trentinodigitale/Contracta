USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_REPORT_RDO]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[DASHBOARD_VIEW_REPORT_RDO]  AS


			SELECT d.id
				 , d.IdPfu AS IdPfu
				
				 , d.titolo as Name
				
				 , cast( d.body as nvarchar(4000)) as Oggetto
				
				 , b.ProtocolloBando as ProtocolloBando
				
				 , b.DataScadenzaOfferta as ExpiryDate
				
				
				 ,case b.ImportoBaseAsta WHEN '0' then ''
				        else cast(b.ImportoBaseAsta as varchar(20))
				   end as ImportoBaseAsta
				
				 ,case b.CriterioAggiudicazioneGara WHEN '0'then ''
				        else b.CriterioAggiudicazioneGara
				   end as CriterioAggiudicazioneGara
				 
				 --, SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldStato>', CAST(MSGTEXT AS VARCHAR(8000))) + 18, 1) AS StatoGD
				 , case d.statoFunzionale 
						when 'InLavorazione' then 1 
						else '2'
					end AS StatoGD
				 ,'' as FaseGara
				 ,d.Data as DataCreazione
				 ,ReceivedQuesiti
				 ,b.tipoappalto
				 ,b.proceduragara


				, case 
					when isnull( r.StatoRepertorio , '' ) = '' then 'InCorso'
					else r.StatoRepertorio 
				  end as StatoRepertorio 


				, case 
					when VisualizzaNotifiche = '0' 
						and getdate() < DataAperturaOfferte
					then null
					else RecivedIstanze
				  end as ReceivedOff 


				, d.Tipodoc as OPEN_DOC_NAME
				
				,
				case 
					when d.statofunzionale in ('InLavorazione','InApprove') then ''
					else
						case b.EvidenzaPubblica
							when '1' then
								case 
									when isnull(CT.deleted,1)=1 then '1'
									else '0'
								end
							else '0'
						end 
					
				end as DocumentoPubblicato
			   , d.StatoFunzionale
			   , isnull( TipoProceduraCaratteristica , '' ) as TipoProceduraCaratteristica
			   , GeneraConvenzione
			   , d.Protocollo	
			   , b.TipoAppaltoGara
			   --,b.CriterioAggiudicazioneGara
			   ,b.CriterioFormulazioneOfferte
			   , d.fascicolo
			   ,b.DataScadenzaOfferta as DataDa
			   ,b.DataScadenzaOfferta as DataA
			from CTL_DOC as d with(nolock)
				inner join document_bando b with(nolock) on d.id = b.idheader
				left outer join Document_Repertorio r with(nolock) on r.ProtocolloBando = b.ProtocolloBando
				left outer join CTL_DOC CT with(nolock) on CT.TipoDoc='BANDO_NON_VIS' and CT.linkedDoc=D.id and CT.jumpcheck=D.TipoDoc
			where d.TipoDoc = 'BANDO_GARA' and d.deleted=0

			and TipoProceduraCaratteristica = 'RDO'


GO
