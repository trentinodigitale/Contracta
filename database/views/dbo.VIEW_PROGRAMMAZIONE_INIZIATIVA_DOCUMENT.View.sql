USE [AFLink_TND]
GO
/****** Object:  View [dbo].[VIEW_PROGRAMMAZIONE_INIZIATIVA_DOCUMENT]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[VIEW_PROGRAMMAZIONE_INIZIATIVA_DOCUMENT] as 

	SELECT
		C.*
		, P.*
		, isnull(R.REL_ValueOutput, '') as NotEditable
	FROM ctl_doc C with(NOLOCK)
		left join Document_programmazione_iniziativa P with (nolock) on C.Id = P.idheader
		left join CTL_Relations R with (nolock) on R.REL_ValueInput = C.statofunzionale
			and R.REL_Type = 'DOC_PROG_INIZIATIVA_NOT_EDITABLE_TESTATA_For_Stato'
	WHERE TipoDoc = 'PROGRAMMAZIONE_INIZIATIVA'

GO
