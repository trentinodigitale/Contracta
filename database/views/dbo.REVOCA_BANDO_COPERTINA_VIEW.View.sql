USE [AFLink_TND]
GO
/****** Object:  View [dbo].[REVOCA_BANDO_COPERTINA_VIEW]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[REVOCA_BANDO_COPERTINA_VIEW] as
select 
	id,
	id as IDDOC,
	id as IdHeader,
	Row as IdRow,
	Body,
	Value as Allegato,
	'COPERTINA' as DSE_ID


from CTL_DOC 
inner join CTL_DOC_VALUE on idheader=id and DSE_ID='COPERTINA' and Dzt_NAME='Allegato'
where tipodoc='REVOCA_BANDO'
GO
