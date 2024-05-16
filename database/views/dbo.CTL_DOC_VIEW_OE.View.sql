USE [AFLink_TND]
GO
/****** Object:  View [dbo].[CTL_DOC_VIEW_OE]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[CTL_DOC_VIEW_OE] as 
select 
	C.*,
	c1.StatoFunzionale as StatoFunzionaleGara
from CTL_DOC C
		inner join CTL_DOC C1 on cast(C1.Versione as varchar(10)) = cast(C.LinkedDoc as varchar(10))
where isnumeric(C1.versione) = 1 and not C1.versione is null and C.tipodoc in ('AVCP_OE','AVCP_GRUPPO')


GO
