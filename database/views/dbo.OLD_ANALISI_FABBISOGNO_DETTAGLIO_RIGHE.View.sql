USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_ANALISI_FABBISOGNO_DETTAGLIO_RIGHE]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[OLD_ANALISI_FABBISOGNO_DETTAGLIO_RIGHE]  as 
	select a.aziRagioneSociale , d.*
		from Document_MicroLotti_Dettagli d 
		inner join aziende a on d.Aggiudicata = a.IdAzi

GO
