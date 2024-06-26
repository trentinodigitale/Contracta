USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_ASTE_CONSULTAZIONE]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [dbo].[DASHBOARD_VIEW_ASTE_CONSULTAZIONE]  AS
	
	SELECT d.id as IdMsg
			, CV.idpfu AS IdPfu
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


		--, case 
		--		when VisualizzaNotifiche = '0'and getdate() < DataAperturaOfferte then null  --dataprimasedutatermine presentazioni offerte
		--		when VisualizzaNotifiche = '1'and getdate() < DataScadenzaOfferta then null  --termine presentazioni offerte
		--		else RecivedIstanze
		--	end as ReceivedOff 
		, case 
				when VisualizzaNotifiche = '0'and getdate() < DataScadenzaOfferta then null  ---termine presentazioni offerte presente sul bando		
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
		inner join document_Asta a with(nolock)  on a.idheader = d.id

		-- PRENDO SOLO QUEI BANDI CHE HANNO NELLA SEZIONE DEI RIFERIMENTI L'UTENTE COLLEGATO SETTATO COME RUOLO 'BANDO'
		--inner joinDocument_Bando_Riferimenti CV with(nolock) on CV.idheader=d.id and RuoloRiferimenti in ( 'Bando' , 'ReferenteTecnico' )
		inner join
			(
			select distinct idheader , idPfu  
				from 
					Document_Bando_Riferimenti with(nolock)
				where RuoloRiferimenti in ( 'Bando' , 'ReferenteTecnico' )
				
			) cv on CV.idheader=d.id

	where d.TipoDoc in ( 'BANDO_ASTA' ) and d.deleted=0





GO
