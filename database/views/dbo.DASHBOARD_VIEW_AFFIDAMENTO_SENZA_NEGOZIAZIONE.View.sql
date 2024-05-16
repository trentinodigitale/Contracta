USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_AFFIDAMENTO_SENZA_NEGOZIAZIONE]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE VIEW [dbo].[DASHBOARD_VIEW_AFFIDAMENTO_SENZA_NEGOZIAZIONE]  AS

	SELECT d.id as IdMsg
			--, CAST(d.IdPfu AS VARCHAR(20)) AS IdPfu
			, d.IdPfu
			, '' as msgIType
			, '' as msgISubType
			, -1 as msgelabwithsuccess
				
			, d.titolo as Name
				
			, d.body as Oggetto
			--, cast( d.body as nvarchar(4000)) as Oggetto
				
			, b.ProtocolloBando as ProtocolloBando
				
			, b.DataScadenzaOfferta as ExpiryDate
				
				
			,case b.ImportoBaseAsta WHEN '0' then NULL
				else b.ImportoBaseAsta
			end as ImportoBaseAsta
			
			,case b.CriterioAggiudicazioneGara WHEN '0'then ''
				else b.CriterioAggiudicazioneGara
			end as CriterioAggiudicazioneGara
				 
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
				when VisualizzaNotifiche = '0'and getdate() < DataScadenzaOfferta then null  ---termine presentazioni offerte presente sul bando		
				else RecivedIstanze
			end as ReceivedOff 


		, case when isnull( TipoProceduraCaratteristica , '' ) = 'RFQ' then 'DOC_RFQ' else d.Tipodoc end as OPEN_DOC_NAME
				
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
		
		,isnull(TipoSceltaContraente,'') as TipoSceltaContraente
		,b.CIG

		,d.idpfu as owner
		,A.pcp_TipoScheda as TipoScheda
		,convert( varchar(10) , d.DataInvio , 121 ) as DataInizio

	from CTL_DOC as d with(nolock)
	--from CTL_DOC as d with(nolock ,index( ICX_CTL_DOC_IdPfu_TipoDoc_LinkedDoc_StatoFunzionale_Deleted) )
	
		inner join document_bando b with(nolock) on d.id = b.idheader
		left outer join Document_Repertorio r with(nolock) on r.ProtocolloBando = b.ProtocolloBando
		left outer join CTL_DOC CT with(nolock) on CT.TipoDoc='BANDO_NON_VIS' and CT.linkedDoc=D.id and CT.jumpcheck=D.TipoDoc
		left join Document_pcp_appalto A on d.Id = A.idHeader
		--vedo tramite parametro se il Cottimo è unificato alle Procedure di gara
		--cross join (select dbo.PARAMETRI('GROUP_Procedura','Cottimo_Gara_Unificato','ATTIVO','NO',-1 ) as Cottimo_Gara_Unificato ) C  

	where d.TipoDoc in ( 'AFFIDAMENTO_SENZA_NEGOZIAZIONE' ) and d.deleted=0


	union
	---PER DARE LA VISIBILITA' DEL DOCUMENTO AL RUP


		SELECT d.id as IdMsg
			--, CAST(d.IdPfu AS VARCHAR(20)) AS IdPfu
			, d.IdPfu
			, '' as msgIType
			, '' as msgISubType
			, -1 as msgelabwithsuccess
				
			, d.titolo as Name
				
			, d.body as Oggetto
			--, cast( d.body as nvarchar(4000)) as Oggetto
				
			, b.ProtocolloBando as ProtocolloBando
				
			, b.DataScadenzaOfferta as ExpiryDate
				
				
			,case b.ImportoBaseAsta WHEN '0' then NULL
				else b.ImportoBaseAsta
			end as ImportoBaseAsta
			
			,case b.CriterioAggiudicazioneGara WHEN '0'then ''
				else b.CriterioAggiudicazioneGara
			end as CriterioAggiudicazioneGara
				 
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
				when VisualizzaNotifiche = '0'and getdate() < DataScadenzaOfferta then null  ---termine presentazioni offerte presente sul bando		
				else RecivedIstanze
			end as ReceivedOff 


		, case when isnull( TipoProceduraCaratteristica , '' ) = 'RFQ' then 'DOC_RFQ' else d.Tipodoc end as OPEN_DOC_NAME
				
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
		
		,isnull(TipoSceltaContraente,'') as TipoSceltaContraente
		,b.CIG

		,CV.Value as owner
		,A.pcp_TipoScheda as TipoScheda
		,convert( varchar(10) , d.DataInvio , 121 ) as DataInizio

	from CTL_DOC as d with(nolock)
	--from CTL_DOC as d with(nolock ,index( ICX_CTL_DOC_IdPfu_TipoDoc_LinkedDoc_StatoFunzionale_Deleted) )
	
		inner join document_bando b with(nolock) on d.id = b.idheader
		left outer join Document_Repertorio r with(nolock) on r.ProtocolloBando = b.ProtocolloBando
		left outer join CTL_DOC CT with(nolock) on CT.TipoDoc='BANDO_NON_VIS' and CT.linkedDoc=D.id and CT.jumpcheck=D.TipoDoc
		
		inner join CTL_DOC_Value CV with(nolock ,index(IX_CTL_DOC_Value_DSE_ID_DZT_Name) ) on CV.DSE_ID='InfoTec_comune' and CV.dzt_name='UserRUP' and CV.IdHeader = d.id
		left join Document_pcp_appalto A on d.Id = A.idHeader
		--vedo tramite parametro se il Cottimo è unificato alle Procedure di gara
		--cross join (select dbo.PARAMETRI('GROUP_Procedura','Cottimo_Gara_Unificato','ATTIVO','NO',-1 ) as Cottimo_Gara_Unificato ) C  

	where d.TipoDoc in ( 'AFFIDAMENTO_SENZA_NEGOZIAZIONE' ) and d.deleted=0

GO
