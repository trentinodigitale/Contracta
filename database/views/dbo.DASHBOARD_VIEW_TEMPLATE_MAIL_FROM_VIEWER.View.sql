USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_TEMPLATE_MAIL_FROM_VIEWER]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[DASHBOARD_VIEW_TEMPLATE_MAIL_FROM_VIEWER] as
select 
	CT.id,
	CT.id as ID_FROM, 
	ML_KEY, 
	CT.Titolo, 
	ML_KEY as JumpCheck,
	Descrizione as body, 
	DataUltimaMod, 
	ViewName, 
	Multi_Doc, 
	'InLavorazione' as StatoFunzionale,
	ISNULL(IDMAX,0) as PrevDoc
	
	
from dbo.CTL_Mail_Template CT
left join ( select MAX(id) as IDMAX, JumpCheck from CTL_DOC where TipoDOc='MAIL_TEMPLATE' group by JumpCheck)as Z on Z.jumpCheck=CT.ML_kEY
where CT.deleted=0

GO
