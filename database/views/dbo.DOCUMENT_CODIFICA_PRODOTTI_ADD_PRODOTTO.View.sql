USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DOCUMENT_CODIFICA_PRODOTTI_ADD_PRODOTTO]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  view [dbo].[DOCUMENT_CODIFICA_PRODOTTI_ADD_PRODOTTO] as 

select 
	id 
	, id as indRow
	, 'CODIFICA_PRODOTTI' as TipoDoc
	
	from CTL_DOC
G
GO
