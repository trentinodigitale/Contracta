USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_DASHBOARD_VIEW_VALUTAZIONEGARE]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE VIEW [dbo].[OLD2_DASHBOARD_VIEW_VALUTAZIONEGARE]  AS

--Versione=2&data=2014-10-24&Attvita=64883&Nominativo=sabato
--Versione=3&data=2015-11-24&Attvita=91608&Nominativo=Enrico
--select 
--	DC.UtenteCommissione as Owner,
--	p.* 
--	,case 
--	    when isnull( r.StatoRepertorio , '' ) = '' then 'InCorso'

--        else r.StatoRepertorio 

--	end as StatoRepertorio 

--    ,case t.visualizzanotifiche
--		when '1' then t.ReceivedOff
--        when '0' then
--			case 
--				when getdate() > t.DataAperturaOfferte then t.ReceivedOff
--				else ''
--            end
--	end as ReceivedOff   

--    ,'DOCUMENTO_GENERICO' as OPEN_DOC_NAME

--	,case t.stato
--		when '2' then
--			case t.EvidenzaPubblica
--				when '1' then
--					case 
--						when isnull(CT.deleted,1)=1 then '1'
--						else '0'
--					end
--				else '0'
--			end 
--		else
--			''	
--	end as DocumentoPubblicato
--	,'DOCUMENTO_GENERICO#=#IdDoc_Bando#' + p.IdDocBando + '#55#169#167,168,169@@@ProtocolBG@@@FaseGara;6~0'  as MAKE_DOC_NAME
--	, '' as TipoProceduraCaratteristica
--	, '' as Tipodoc
--FROM 
--	(
--		SELECT z.IdMsg
--			 , umIdPfu AS IdPfu
--			 , cast( msgIType as varchar(10)) as msgIType
--			 , msgISubType
--			 , msgelabwithsuccess
			
--			 ,t.Name
			
--			 ,cast( t.Object_Cover1 as nvarchar(4000)) as Oggetto
			
--			 ,t.ProtocolloBando
			
--			 ,t.ExpiryDate
			
			
--			 ,case t.ImportoBaseAsta WHEN '0' then ''
--			        else t.ImportoBaseAsta
--			   end as ImportoBaseAsta
			
--			 ,case t.CriterioAggiudicazioneGara WHEN '0'then ''
--			        else t.CriterioAggiudicazioneGara
--			   end as CriterioAggiudicazioneGara
			 
--			 , t.Stato AS StatoGD
--			 ,t.FaseGara
--			 ,Data as DataCreazione
--			 ,t.ReceivedQuesiti
--			 ,t.tipoappalto
--			 ,t.proceduragara
--			 ,t.IdDoc as IdDocBando

--		  FROM TAB_MESSAGGI as z with(nolock)
--			 , TAB_UTENTI_MESSAGGI with(nolock)
--			 ,TAB_MESSAGGI_FIELDS as t with(nolock)
			
--		 WHERE z.IdMsg = umIdMsg
--		   AND msgItype = 55
--		   AND msgisubtype = 167
--		   AND umInput = 0
--		   AND umStato = 0
--		   AND umIdPfu <> -10
--		    and T.IdMsg = z.IdMsg 
--	) as p
--		left outer join Document_Repertorio r with(nolock) on r.ProtocolloBando = p.ProtocolloBando
--			inner join TAB_MESSAGGI_FIELDS t  with(nolock) on p.idmsg=t.idmsg
--				inner join CTL_DOC CTL with(nolock) on p.idmsg=CTL.linkeddoc and CTL.TIPODOC='COMMISSIONE_PDA' and CTL.StatoFunzionale='Pubblicato' and CTL.jumpcheck = '55;167' and CTL.deleted=0
--					inner join Document_CommissionePda_Utenti DC on CTL.id= DC.idheader and DC.RuoloCommissione='15548'
--						left outer join CTL_DOC CT with(nolock) on CT.TipoDoc='BANDO_NON_VIS' and CT.linkedDoc=t.idmsg and CT.jumpcheck=t.iddoc 

--union 

SELECT 
	distinct
	DC.UtenteCommissione as Owner
	,d.id as IdMsg
	, d.IdPfu AS IdPfu
	, '' as msgIType
	, '' as msgISubType
	, -1 as msgelabwithsuccess
	, d.titolo as Name
	, cast( d.body as nvarchar(4000)) as Oggetto
	, b.ProtocolloBando as ProtocolloBando
	, b.DataScadenzaOfferta as ExpiryDate
	,case b.ImportoBaseAsta WHEN '0' then ''
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
	 ,'' as IdDocBando	
	 ,PDA.StatoFunzionale
	, case 
		when isnull( r.StatoRepertorio , '' ) = '' then 'InCorso'
		else r.StatoRepertorio 
	  end as StatoRepertorio 


	, case 
		--when VisualizzaNotifiche = '0' and getdate() < DataAperturaOfferte then null
		when VisualizzaNotifiche = '0' and getdate() < DataScadenzaOfferta then null		
		else RecivedIstanze
	  end as ReceivedOff 


	, case 
		when d.Tipodoc  in ('BANDO_GARA','BANDO_SEMPLIFICATO') then 'BANDO_SEMPLIFICATO'
		else d.Tipodoc 
	end	as OPEN_DOC_NAME
	
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

	,'PDA_MICROLOTTI' as MAKE_DOC_NAME
	, isnull(TipoProceduraCaratteristica,'') as TipoProceduraCaratteristica 
	, d.Tipodoc 
	, isnull(TipoSceltaContraente,'') as TipoSceltaContraente
from CTL_DOC as d with(nolock)
	inner join document_bando b with(nolock) on d.id = b.idheader
		inner join CTL_DOC CTL with(nolock) on d.id=CTL.linkeddoc and CTL.TIPODOC='COMMISSIONE_PDA' and CTL.StatoFunzionale='Pubblicato' and CTL.jumpcheck <> '55;167' and ctl.deleted=0
			inner join Document_CommissionePda_Utenti DC on CTL.id= DC.idheader --and DC.RuoloCommissione='15548'
				left outer join Document_Repertorio r with(nolock) on r.ProtocolloBando = b.ProtocolloBando
					left outer join CTL_DOC CT with(nolock) on CT.TipoDoc='BANDO_NON_VIS' and CT.linkedDoc=D.id and CT.jumpcheck=D.TipoDoc
						left outer join ctl_doc PDA with(nolock) on PDA.TipoDoc='PDA_MICROLOTTI' and PDA.linkedDoc=D.id and PDA.jumpcheck=D.TipoDoc and PDA.deleted=0
where d.TipoDoc in ('BANDO_GARA','BANDO_SEMPLIFICATO') and d.deleted=0


GO
