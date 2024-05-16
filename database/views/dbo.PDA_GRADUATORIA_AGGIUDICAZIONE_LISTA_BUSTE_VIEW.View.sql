USE [AFLink_TND]
GO
/****** Object:  View [dbo].[PDA_GRADUATORIA_AGGIUDICAZIONE_LISTA_BUSTE_VIEW]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [dbo].[PDA_GRADUATORIA_AGGIUDICAZIONE_LISTA_BUSTE_VIEW] as


	select idHeader, d.id , d.TipoDoc ,  idHeaderLotto , Aggiudicata , Posizione , Graduatoria , Sorteggio , ValoreOfferta , NumeroLotto , Voce , PercAgg  , aziRagioneSociale
			, case when g.jumpcheck = 'MonoRound' then ' Posizione ' else ' PercAgg ' end as NotEditable 
			, ValoreImportoLotto 
		from Document_microlotti_dettagli d
			inner join aziende a with(nolock) on d.Aggiudicata = a.idazi
			inner join CTL_DOC g on g.id = d.IdHeader
		where d.TipoDoc = 'PDA_GRADUATORIA_AGGIUDICAZIONE' 


GO
