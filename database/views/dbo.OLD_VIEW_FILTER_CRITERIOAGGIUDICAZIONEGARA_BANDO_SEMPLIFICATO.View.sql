USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_VIEW_FILTER_CRITERIOAGGIUDICAZIONEGARA_BANDO_SEMPLIFICATO]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[OLD_VIEW_FILTER_CRITERIOAGGIUDICAZIONEGARA_BANDO_SEMPLIFICATO] as 

	select Codice , '15531' as CriterioAggiudicazioneGara 
		from Document_Modelli_MicroLotti 
		where CriterioAggiudicazioneGara like '%###15531###%' and deleted=0

	union

	select Codice , '15532' as CriterioAggiudicazioneGara 
		from Document_Modelli_MicroLotti 
		where CriterioAggiudicazioneGara like '%###15532###%' and deleted=0
GO
