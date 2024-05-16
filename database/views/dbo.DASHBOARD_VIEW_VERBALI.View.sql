USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_VERBALI]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
---------------------------------------------------------------
--vista per visualizzare il folder dei verbali creati.
---------------------------------------------------------------

CREATE view [dbo].[DASHBOARD_VIEW_VERBALI]
as
select * from ctl_doc,dbo.Document_VerbaleGara
where id=idheader and tipodoc='VERBALEGARA'

GO
