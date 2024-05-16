USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_COPIA_BANDO_SEMPLIFICATO]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[DASHBOARD_VIEW_COPIA_BANDO_SEMPLIFICATO]  AS
	
	SELECT d.id as IdMsg
			, CAST(d.IdPfu AS VARCHAR(20)) AS IdPfu
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

			, case d.statoFunzionale 
				when 'InLavorazione' then 1 
				else '2'
			end AS StatoGD

			,'' as FaseGara
			,d.Data as DataCreazione
			,ReceivedQuesiti
			,b.tipoappalto
			,b.proceduragara

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

	from CTL_DOC as d with(nolock)
		inner join document_bando b with(nolock) on d.id = b.idheader
	where d.TipoDoc in ( 'BANDO_SEMPLIFICATO' ) and d.deleted=0











GO
