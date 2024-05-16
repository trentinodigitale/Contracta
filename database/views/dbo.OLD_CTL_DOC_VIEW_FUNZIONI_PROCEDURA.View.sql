USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_CTL_DOC_VIEW_FUNZIONI_PROCEDURA]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[OLD_CTL_DOC_VIEW_FUNZIONI_PROCEDURA] AS
select 
	C.*,
	
	case
		when 
			Tipodoc = 'BANDO_CONCORSO' then 'no'
			else	dbo.ATTIVA_ELENCO_DEST_PROCEDURA(C.linkeddoc) 
		end as ATTIVO_VIS_DEST 

	from CTL_DOC C with(nolock)
GO
