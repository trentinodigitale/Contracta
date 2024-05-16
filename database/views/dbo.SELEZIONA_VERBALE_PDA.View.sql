USE [AFLink_TND]
GO
/****** Object:  View [dbo].[SELEZIONA_VERBALE_PDA]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[SELEZIONA_VERBALE_PDA] as
select
	id,
	id as idRow,
	Titolo as Descrizione,
	LinkedDoc,
	Id as IndRow,
	' Descrizione ' as NotEditable,
	'VERBALETEMPLATE' as OPEN_DOC_NAME,
	ProceduraGara,
	CriterioAggiudicazioneGara,
	CriterioFormulazioneOfferte,
	TipoVerbale

	from ctl_doc with(nolock)
		inner join Document_VerbaleGara on IdHeader=id
		where TipoDoc='VERBALETEMPLATE' and Deleted=0 and StatoFunzionale='Pubblicato'
GO
