USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_BANDO_GARA_MODELLO_PRODOTTI_VIEW]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


create view [dbo].[OLD2_BANDO_GARA_MODELLO_PRODOTTI_VIEW]	as



select 
    IdHeader as ID, value as MODELLO
    from 
	   ctl_doc iner join 
		  ctl_doc_value on id=idheader and tipodoc like 'bando_%'
	where dse_id='TESTATA_PRODOTTI' and dzt_name='TipoBandoScelta'
	





GO
