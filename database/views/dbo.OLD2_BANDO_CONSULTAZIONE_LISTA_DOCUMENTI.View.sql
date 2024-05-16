USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_BANDO_CONSULTAZIONE_LISTA_DOCUMENTI]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[OLD2_BANDO_CONSULTAZIONE_LISTA_DOCUMENTI] as

	select c.* 
		, tipodoc as OPEN_DOC_NAME
	
	from ctl_doc c with (nolock)
	where deleted = 0
		and TipoDoc in ('RETTIFICA_CONSULTAZIONE','PROROGA_CONSULTAZIONE','PDA_COMUNICAZIONE_GENERICA')
		and StatoFunzionale<>'Annullato'
		and deleted=0

GO
