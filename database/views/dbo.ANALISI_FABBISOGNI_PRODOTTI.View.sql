USE [AFLink_TND]
GO
/****** Object:  View [dbo].[ANALISI_FABBISOGNI_PRODOTTI]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[ANALISI_FABBISOGNI_PRODOTTI] as 
	
	select 'ANALISI_FABBISOGNO_DETTAGLIO' as OPEN_DOC_NAME , * from Document_MicroLotti_Dettagli


GO
