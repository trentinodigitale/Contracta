USE [AFLink_TND]
GO
/****** Object:  View [dbo].[PDA_BACK_TEC_FROM_PDA_RIEPILOGO_LOTTO]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [dbo].[PDA_BACK_TEC_FROM_PDA_RIEPILOGO_LOTTO] as
	
		select Lotti.IdLotto as ID_FROM, /*Offerte.IdOfferta*/ Lotti.IDPDA as LinkedDoc, Lotti.Fascicolo,'Tecnica' as jumpcheck,
		/*lotti.idheader*/ IdLotto as IDDOC ,lotti.NumeroLotto as versionelinkeddoc,lotti.Descrizione as note, lotti.StatoRiga
		from 	
		(
			select 
				CTL.id as IDPDA,
				DMD.id as IdLotto ,
				DMD.NumeroLotto,DMD.StatoRiga,DMD.Aggiudicata, CTL.fascicolo,DMD.idheader,dmd.Descrizione
			from 	
				CTL_DOC CTL with(nolock) 
					inner join DOCUMENT_MICROLOTTI_DETTAGLI DMD with(nolock)  on CTL.id=DMD.idheader and DMD.TipoDoc='PDA_MICROLOTTI' and DMD.voce=0
			--where DMD.StatoRiga in ('AggiudicazioneProvv' , 'AggiudicazioneDef','AggiudicazioneCond' ,'Controllato')  --and ctl.id=42227 
		) Lotti
			inner join
				(
				select 
					CTL.id as IDPDA, 
					DMDO.Id as IdOfferta,
					DMDO.NumeroLotto,DMDO.statoriga,DPO.IdAziPartecipante as Aggiudicata,CTL.fascicolo
					from 
						CTL_DOC CTL with(nolock)  
						inner join Document_PDA_OFFERTE DPO with(nolock)  on CTL.id=DPO.idheader and CTL.tipodoc='PDA_MICROLOTTI'
							inner join	DOCUMENT_MICROLOTTI_DETTAGLI DMDO with(nolock)  on DPO.idrow=DMDO.idheader and DMDO.TipoDoc='PDA_OFFERTE' and DMDO.voce=0 
					--where 
					--	ctl.id=42227 
				) Offerte on Lotti.IDPDA=Offerte.IDPDA and  Lotti.NumeroLotto=Offerte.NumeroLotto --and Lotti.Aggiudicata=Offerte.Aggiudicata







GO
