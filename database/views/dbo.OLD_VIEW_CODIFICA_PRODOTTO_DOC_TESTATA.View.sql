USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_VIEW_CODIFICA_PRODOTTO_DOC_TESTATA]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[OLD_VIEW_CODIFICA_PRODOTTO_DOC_TESTATA] AS
	select *
		,Posizione as MacroAreaMerc 
	from Document_MicroLotti_Dettagli WITH(NOLOCK)
	--where tipodoc = 'CODIFICA_PRODOTTO_DOC'




GO
