USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_DASHBOARD_VIEW_COM_DPE_ENTI]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








CREATE VIEW [dbo].[OLD2_DASHBOARD_VIEW_COM_DPE_ENTI]
AS
SELECT   
	distinct 
		C.IdCom
     ,  IdComEnte
     , Name
     , PR.IdPfu AS owner
     , DataCreazione
     , Protocollo
     , StatoCom
     , StatoCom as StatoComFor
     , Obbligo
     , DataObbligo
     , TipologiaAllegati
     , BloccoAccesso
     , DataScadenzaCom
     , convert(varchar(100),DataScadenza,120) as DataScadenza
	 , convert(varchar(100),GetDate(),120) as DataCurr
	 , RichiestaRisposta
     --, StatoComDir as StatoComFor
     , '' as Accetta
     --, DataAccettazioneDir as DataAccettazione
     ,null as Rimanda
     ,null as Allegato
     , Notacom
     , 'COM_DPE_ENTE_APP' as OPEN_DOC_NAME
	 , p1.pfuIdAzi as azi_ente
	 , a.aziRagioneSociale as enteappaltante 
	 , case when isnull( ENTIGrid_ID_DOC , 0 ) <> 0 then 1 else 0 end Scrittura 
	 , ce.idazi 
  FROM Document_Com_DPE C with (nolock)
		inner join ProfiliUtente p1 with (nolock) on C.Owner = p1.IdPfu 
		inner join aziende a with (nolock) on a.IdAzi = p1.pfuIdAzi
		inner join Document_Com_DPE_Enti CE with (nolock) on CE.IdCom = C.IdCom
		inner join profiliutente P with (nolock) on p.pfuIdAzi = ce.idazi 
		inner  join profiliutenteattrib PR with (nolock) on PR.IdPfu = P.IdPfu and PR.dztnome='profilo' 
				--prendo tutti gli utenti che hanno un profilo tra quelli selezionati
				--oppure se nessun profilo stato selezionato tutti gli utenti
				and  
				( 
					( --'###' + PR.attValue +'###' like C.ProfiloUtentiCom 
					CHARINDEX('###' + PR.attValue +'###', C.ProfiloUtentiCom )>0
					)
					or 
					(C.ProfiloUtentiCom='')
				)					   

 WHERE 
	StatoCom <> 'Salvato'  
	AND Deleted = 0

	union

	--utenti delle aziende che non hanno nessun profilo tra quelli selezionati sulla comunicazione
	SELECT   
	distinct 
		C.IdCom
     ,  IdComEnte
     , Name
     , p2.IdPfu AS owner
     , DataCreazione
     , Protocollo
     , StatoCom
     , StatoCom as StatoComFor
     , Obbligo
     , DataObbligo
     , TipologiaAllegati
     , BloccoAccesso
     , DataScadenzaCom
     , convert(varchar(100),DataScadenza,120) as DataScadenza
	 , convert(varchar(100),GetDate(),120) as DataCurr
	 , RichiestaRisposta
     --, StatoComDir as StatoComFor
     , '' as Accetta
     --, DataAccettazioneDir as DataAccettazione
     ,null as Rimanda
     ,null as Allegato
     , Notacom
     , 'COM_DPE_ENTE_APP' as OPEN_DOC_NAME
	 , p1.pfuIdAzi as azi_ente
	 , a.aziRagioneSociale as enteappaltante 
	 , case when isnull( ENTIGrid_ID_DOC , 0 ) <> 0 then 1 else 0 end Scrittura 
	 , ce.idazi 
  FROM Document_Com_DPE C with (nolock)
		inner join ProfiliUtente p1 with (nolock) on C.Owner = p1.IdPfu 
		inner join aziende a with (nolock) on a.IdAzi = p1.pfuIdAzi
		inner join Document_Com_DPE_Enti CE with (nolock) on CE.IdCom = C.IdCom
		inner join ctl_attivita P with (nolock) on CE.IdComEnte = ATV_IdDoc and ATV_DocumentName ='COM_DPE_ENTE' and ATV_IdAzi is not null
		inner join ProfiliUtente p2 with (nolock) on p2.pfuIdAzi = ATV_IdAzi 
			
								   

 WHERE 
	StatoCom <> 'Salvato'  
	AND Deleted = 0


	--aggiungo tutti gli utenti delle aziende che non hanno utenti con i profili selezionati


GO
