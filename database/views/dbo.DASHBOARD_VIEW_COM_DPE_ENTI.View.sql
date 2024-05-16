USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_COM_DPE_ENTI]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









CREATE VIEW [dbo].[DASHBOARD_VIEW_COM_DPE_ENTI]
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


	union

	-- Comunicazioni della RETTIFICA Offerta Tecnica ed Economica
	select
	   COM.id as IdCom
     , COM.id as IdComEnte
     , COM.Titolo as Name
     , P.idpfu AS owner
     , COM.[Data] as DataCreazione
     , COM.Protocollo
     , COM.StatoFunzionale as StatoCom
     , COM.StatoFunzionale as StatoComFor
     , null as Obbligo
     , null as DataObbligo
     , null as TipologiaAllegati
     , null as BloccoAccesso
     , null as DataScadenzaCom
     , null as DataScadenza
	 , convert(varchar(100),GetDate(),120) as DataCurr
	 , 'no' as RichiestaRisposta
     --, StatoComDir as StatoComFor
     , '' as Accetta
     --, DataAccettazioneDir as DataAccettazione
     , null as Rimanda
     , null as Allegato
     , null as Notacom
     , 'PDA_COMUNICAZIONE_GARA' as OPEN_DOC_NAME
	 , AZI.idazi as azi_ente
	 , AZI.aziRagioneSociale as enteappaltante
	 , null as Scrittura 
	 , COM.azienda as idazi
	from 
		CTL_DOC COM with (nolock)
		inner join Aziende AZI with(nolock) on AZI.idazi = COM.Destinatario_Azi
		inner join ProfiliUtente P with(nolock) on P.pfuidazi = AZI.Idazi
	where SUBSTRING(JumpCheck, 3, LEN(JumpCheck)) in('RETTIFICA_ECONOMICA_OFFERTA','RETTIFICA_TECNICA_OFFERTA') 
	and statofunzionale = 'Inviato'
	and deleted <> 1


	--aggiungo tutti gli utenti delle aziende che non hanno utenti con i profili selezionati


GO
