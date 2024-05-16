USE [AFLink_TND]
GO
/****** Object:  View [dbo].[ISTANZA_ALBOPROF_TIPOLOGIA_INCARICO_FROM_BANDO]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[ISTANZA_ALBOPROF_TIPOLOGIA_INCARICO_FROM_BANDO] as
select 
	ctl_doc.id as ID_FROM,
	cast(DMV_COD as int) as Num,
	DMV_DescML as Descrizione
from ctl_doc,LIB_DOMAINVALUES
where tipodoc='BANDO' and DMV_DM_ID='TipologiaIncarico'
GO
