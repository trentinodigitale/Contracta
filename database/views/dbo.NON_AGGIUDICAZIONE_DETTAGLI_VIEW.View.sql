USE [AFLink_TND]
GO
/****** Object:  View [dbo].[NON_AGGIUDICAZIONE_DETTAGLI_VIEW]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[NON_AGGIUDICAZIONE_DETTAGLI_VIEW] as
	select *, selRow as Seleziona_deleted from Document_MicroLotti_Dettagli where TipoDoc = 'NON_AGGIUDICAZIONE'
GO
