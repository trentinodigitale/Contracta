USE [AFLink_TND]
GO
/****** Object:  View [dbo].[BANDO_GARA_MODELLO_PRODOTTI_VIEW]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[BANDO_GARA_MODELLO_PRODOTTI_VIEW]	as

select 
    IdHeader as ID, value as MODELLO
    from 
	   ctl_doc with (nolock)  inner join 
		  ctl_doc_value with (nolock) on id=idheader and (tipodoc like 'bando_%' OR tipodoc = 'TEMPLATE_GARA')
	where dse_id='TESTATA_PRODOTTI' and dzt_name='TipoBandoScelta'
GO
