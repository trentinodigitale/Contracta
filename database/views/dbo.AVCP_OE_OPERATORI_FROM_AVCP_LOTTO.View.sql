USE [AFLink_TND]
GO
/****** Object:  View [dbo].[AVCP_OE_OPERATORI_FROM_AVCP_LOTTO]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[AVCP_OE_OPERATORI_FROM_AVCP_LOTTO] as
select 
	'' as ID_FROM
	from ctl_doc
where tipodoc in ('AVCP_LOTTO','AVCP_GARA')

GO
