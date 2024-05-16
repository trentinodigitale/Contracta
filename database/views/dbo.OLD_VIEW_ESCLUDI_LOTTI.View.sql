USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_VIEW_ESCLUDI_LOTTI]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


create view [dbo].[OLD_VIEW_ESCLUDI_LOTTI] as
select 
	C.*
	, C1.Value as ProtocolloBando
	from ctl_doc C left outer join ctl_doc_value C1 on C.id=C1.idheader
where tipodoc='ESCLUDI_LOTTI'


GO
