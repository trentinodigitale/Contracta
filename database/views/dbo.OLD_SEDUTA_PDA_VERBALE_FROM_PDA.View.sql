USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_SEDUTA_PDA_VERBALE_FROM_PDA]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[OLD_SEDUTA_PDA_VERBALE_FROM_PDA] as 

select p.id as ID_FROM , d.id ,d.GUID , d.Titolo   
	from ctl_doc d with (nolock)
		inner join dbo.Document_VerbaleGara with (nolock) on idheader = id and TipoSorgente = 2
		cross join ctl_doc p with (nolock)

	where d.tipodoc = 'VERBALETEMPLATE' and d.deleted = 0
			and p.tipodoc = 'PDA_MICROLOTTI' and p.deleted = 0



GO
