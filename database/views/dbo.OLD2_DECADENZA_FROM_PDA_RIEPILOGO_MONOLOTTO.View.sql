USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_DECADENZA_FROM_PDA_RIEPILOGO_MONOLOTTO]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


create view [dbo].[OLD2_DECADENZA_FROM_PDA_RIEPILOGO_MONOLOTTO] as
	
		select   Lotti.IDPDA  /*Lotti.IdLotto */ as ID_FROM, Offerte.IdOfferta as LinkedDoc, Lotti.Fascicolo 
		from 	
		(
			select 
				CTL.id as IDPDA,
				DMD.id as IdLotto ,
				DMD.NumeroLotto,DMD.StatoRiga,DMD.Aggiudicata, CTL.fascicolo
			from 	
				CTL_DOC CTL 
					inner join DOCUMENT_MICROLOTTI_DETTAGLI DMD on CTL.id=DMD.idheader and DMD.TipoDoc='PDA_MICROLOTTI' and DMD.voce=0 and NumeroLotto = '1'

			where DMD.StatoRiga in ('AggiudicazioneProvv' , 'AggiudicazioneDef')  --and ctl.id=42227 
			
		) Lotti
			inner join
				(
				select 
					CTL.id as IDPDA, 
					DMDO.Id as IdOfferta,
					DMDO.NumeroLotto,DMDO.statoriga,DPO.IdAziPartecipante as Aggiudicata,CTL.fascicolo
					from 
						CTL_DOC CTL inner join Document_PDA_OFFERTE DPO on CTL.id=DPO.idheader and CTL.tipodoc='PDA_MICROLOTTI'
							inner join	DOCUMENT_MICROLOTTI_DETTAGLI DMDO on DPO.idrow=DMDO.idheader and DMDO.TipoDoc='PDA_OFFERTE' and DMDO.voce=0 
					--where 
					--	ctl.id=42227 
				) Offerte on Lotti.IDPDA=Offerte.IDPDA and  Lotti.NumeroLotto=Offerte.NumeroLotto and Lotti.Aggiudicata=Offerte.Aggiudicata


GO
