USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_VIEW_CONFIG_MODELLI_TESTATA]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[OLD2_VIEW_CONFIG_MODELLI_TESTATA] as
	Select d.* 
			,case when ISNULL(d.Protocollo,'') <> '' or N.id is not null then ' Titolo ' else '' end as NotEditable
		from CTL_DOC  D
				left join CTL_DOC N with(nolock) on N.tipodoc = D.TipoDoc and N.id = D.PrevDoc and N.deleted = 0 
		where d.tipodoc in ('CONFIG_MODELLI_FABBISOGNI','CONFIG_MODELLI')


GO
