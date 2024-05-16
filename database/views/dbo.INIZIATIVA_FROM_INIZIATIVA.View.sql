USE [AFLink_TND]
GO
/****** Object:  View [dbo].[INIZIATIVA_FROM_INIZIATIVA]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[INIZIATIVA_FROM_INIZIATIVA]
AS
select 
	id,
	tipodoc,
	numerodocumento,
	id as ID_FROM,
	Body,
	' numerodocumento ' as NotEditable,
	id as PrevDoc
from ctl_doc with(NOLOCK)
where TipoDoc = 'INIZIATIVA'

GO
