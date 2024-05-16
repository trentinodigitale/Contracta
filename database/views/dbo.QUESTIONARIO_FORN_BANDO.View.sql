USE [AFLink_TND]
GO
/****** Object:  View [dbo].[QUESTIONARIO_FORN_BANDO]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[QUESTIONARIO_FORN_BANDO]  AS

select 

a.id ,
isnull(b.body,'') as body



from CTL_DOC a
left outer join ctl_doc b on  b.id=a.LinkedDoc and b.tipodoc='bando_qf'
where a.TipoDoc='QUESTIONARIO_FORNITORE'
and a.deleted=0













GO
