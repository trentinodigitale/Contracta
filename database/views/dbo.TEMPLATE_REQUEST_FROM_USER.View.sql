USE [AFLink_TND]
GO
/****** Object:  View [dbo].[TEMPLATE_REQUEST_FROM_USER]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE  view [dbo].[TEMPLATE_REQUEST_FROM_USER]
as

select 
	u.idpfu as ID_FROM
	,u.IdPfu as idpfu
	,u.IdPfu as idpfuinCharge
	,'DGUE' as Jumpcheck
	,'TEMPLATE_REQUEST' as TipoDoc
	,'InLavorazione' as Statofunzionale


	from profiliutente u
		left outer join CTL_DOC d on d.tipodoc = 'TEMPLATE_REQUEST' and d.deleted = 0 and d.StatoFunzionale = 'Confermato' 







GO
