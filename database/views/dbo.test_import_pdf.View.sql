USE [AFLink_TND]
GO
/****** Object:  View [dbo].[test_import_pdf]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[test_import_pdf] as 
	
	select '58476' as ID_DOC, 'test_1' as NOME_FILE, '1' as ID_FROM , 'ISTANZA_AlboOperaEco' as TIPO_DOC

	union all

	select '58476' as ID_DOC, 'test_2' as NOME_FILE, '1' as ID_FROM , 'ISTANZA_AlboOperaEco' as TIPO_DOC

	union all

	select '58476' as ID_DOC, 'test_3' as NOME_FILE, '1' as ID_FROM , 'ISTANZA_AlboOperaEco' as TIPO_DOC
	
	union all

	select '58476' as ID_DOC, 'test_4' as NOME_FILE, '1' as ID_FROM , 'ISTANZA_AlboOperaEco' as TIPO_DOC
	
	union all

	select '58476' as ID_DOC, 'test_5' as NOME_FILE, '1' as ID_FROM , 'ISTANZA_AlboOperaEco' as TIPO_DOC
GO
