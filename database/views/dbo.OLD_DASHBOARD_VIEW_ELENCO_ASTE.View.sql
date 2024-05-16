USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_DASHBOARD_VIEW_ELENCO_ASTE]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE VIEW [dbo].[OLD_DASHBOARD_VIEW_ELENCO_ASTE]  AS
	
	--SELECT d.id as IdMsg
	--		, CAST(d.IdPfu AS VARCHAR(20)) AS IdPfu
	--		, '' as msgIType
	--		, '' as msgISubType
	--		, -1 as msgelabwithsuccess
				
	--		, d.titolo as Name
				
	--		, cast( d.body as nvarchar(4000)) as Oggetto
				
	--		, b.ProtocolloBando as ProtocolloBando
				
	--		, b.DataScadenzaOfferta as ExpiryDate
				
				
	--		,case b.ImportoBaseAsta WHEN '0' then NULL
	--			else b.ImportoBaseAsta
	--		end as ImportoBaseAsta
			
	--		,case b.CriterioAggiudicazioneGara WHEN '0'then ''
	--			else b.CriterioAggiudicazioneGara
	--		end as CriterioAggiudicazioneGara
				 
	--		--, SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldStato>', CAST(MSGTEXT AS VARCHAR(8000))) + 18, 1) AS StatoGD
	--		, case d.statoFunzionale 
	--			when 'InLavorazione' then 1 
	--			else '2'
	--		end AS StatoGD
	--		,'' as FaseGara
	--		,d.Data as DataCreazione
	--		,ReceivedQuesiti
	--		,b.tipoappalto
	--		,b.proceduragara


	--	, case 
	--		when isnull( r.StatoRepertorio , '' ) = '' then 'InCorso'
	--		else r.StatoRepertorio 
	--		end as StatoRepertorio 


	--	, case 
	--			when VisualizzaNotifiche = '0'and getdate() < DataAperturaOfferte then null  --dataprimasedutatermine presentazioni offerte
	--			when VisualizzaNotifiche = '1'and getdate() < DataScadenzaOfferta then null  --termine presentazioni offerte
	--			else RecivedIstanze
	--		end as ReceivedOff 


	--	, d.Tipodoc as OPEN_DOC_NAME
				
	--	,
	--	case 
	--		when d.statofunzionale in ('InLavorazione','InApprove') then ''
	--		else
	--			case b.EvidenzaPubblica
	--				when '1' then
	--					case 
	--						when isnull(CT.deleted,1)=1 then '1'
	--						else '0'
	--					end
	--				else '0'
	--			end 
					
	--	end as DocumentoPubblicato
	--	, d.StatoFunzionale
	--	, isnull( TipoProceduraCaratteristica , '' ) as TipoProceduraCaratteristica
	--	, GeneraConvenzione
	--	, d.Protocollo	
	--	,ISNULL(Appalto_Verde,'no') as Appalto_Verde
	--	,ISNULL(Acquisto_Sociale,'no') as Acquisto_Sociale 
	--	,case 
	--			when Appalto_Verde='si' and Acquisto_Sociale='si' then '<img title="Appalto Verde" alt="Appalto Verde" src="../images/Appalto_Verde.png">&nbsp;<img title="Acquisto Sociale" alt="Acquisto Sociale" src="../images/Acquisto_Sociale.png">'  
	--			when Appalto_Verde='si' and Acquisto_Sociale='no' then  '<img title="Appalto Verde" alt="Appalto Verde" src="../images/Appalto_Verde.png">' 
	--			when Appalto_Verde='no' and Acquisto_Sociale='si' then  '<img title="Acquisto Sociale" alt="Acquisto Sociale" src="../images/Acquisto_Sociale.png">' 
	--	end as Bando_Verde_Sociale
		
	--	,isnull(TipoSceltaContraente,'') as TipoSceltaContraente

	--from CTL_DOC as d with(nolock)
	--	inner join document_bando b with(nolock) on d.id = b.idheader
	--	left outer join Document_Repertorio r with(nolock) on r.ProtocolloBando = b.ProtocolloBando
	--	left outer join CTL_DOC CT with(nolock) on CT.TipoDoc='BANDO_NON_VIS' and CT.linkedDoc=D.id and CT.jumpcheck=D.TipoDoc
	--where d.TipoDoc = 'BANDO_ASTA' and d.deleted=0


	--union
	---PER DARE LA VISIBILITA' DEL DOCUMENTO AL RUP

	SELECT d.id as IdMsg
			--, CV.Value AS IdPfu
			, CV.idPfu
			, '' as msgIType
			, '' as msgISubType
			, -1 as msgelabwithsuccess
				
			, d.titolo as Name
				
			, cast( d.body as nvarchar(4000)) as Oggetto
				
			, b.ProtocolloBando as ProtocolloBando
				
			, b.DataScadenzaOfferta as ExpiryDate
				
				
			,case b.ImportoBaseAsta WHEN '0' then NULL
				else b.ImportoBaseAsta
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
				when VisualizzaNotifiche = '0'and getdate() < DataAperturaOfferte then null  --dataprimasedutatermine presentazioni offerte
				when VisualizzaNotifiche = '1'and getdate() < DataScadenzaOfferta then null  --termine presentazioni offerte
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
		, a.StatoAsta
		, isnull( TipoProceduraCaratteristica , '' ) as TipoProceduraCaratteristica
		, GeneraConvenzione
		, d.Protocollo	
		,ISNULL(Appalto_Verde,'no') as Appalto_Verde
		,ISNULL(Acquisto_Sociale,'no') as Acquisto_Sociale 
		,case 
				when Appalto_Verde='si' and Acquisto_Sociale='si' then '<img title="Appalto Verde" alt="Appalto Verde" src="../images/Appalto_Verde.png">&nbsp;<img title="Acquisto Sociale" alt="Acquisto Sociale" src="../images/Acquisto_Sociale.png">'  
				when Appalto_Verde='si' and Acquisto_Sociale='no' then  '<img title="Appalto Verde" alt="Appalto Verde" src="../images/Appalto_Verde.png">' 
				when Appalto_Verde='no' and Acquisto_Sociale='si' then  '<img title="Acquisto Sociale" alt="Acquisto Sociale" src="../images/Acquisto_Sociale.png">' 
		end as Bando_Verde_Sociale
		,isnull(TipoSceltaContraente,'') as TipoSceltaContraente
		,b.DataRiferimentoInizio
		,a.TipoAsta
	from CTL_DOC as d with(nolock)
		inner join document_bando b with(nolock) on d.id = b.idheader
		left outer join Document_Repertorio r with(nolock) on r.ProtocolloBando = b.ProtocolloBando
		left outer join CTL_DOC CT with(nolock) on CT.TipoDoc='BANDO_NON_VIS' and CT.linkedDoc=D.id and CT.jumpcheck=D.TipoDoc
		--CTL_DOC_Value CV with(nolock) on CV.idheader=d.id and CV.DSE_ID='InfoTec_comune' and CV.dzt_name='UserRUP'
		inner join ( 
						select CV.idheader , Value as idpfu from CTL_DOC_Value CV with(nolock) where CV.DSE_ID='InfoTec_comune' and CV.dzt_name='UserRUP' 
						union 
						select id as idheader , cast(idpfu as nvarchar(100))  from ctl_doc  with(nolock) where TipoDoc = 'BANDO_ASTA' and deleted=0

					) as CV on CV.idheader = d.id

		inner join document_Asta a with(nolock)  on a.idheader = d.id

	where d.TipoDoc = 'BANDO_ASTA' and d.deleted=0












GO
