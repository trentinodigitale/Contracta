USE [AFLink_TND]
GO
/****** Object:  View [dbo].[PREVENTIVO_FORN_IA_VIEW]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

---------------------------------------------------------------------

create view [dbo].[PREVENTIVO_FORN_IA_VIEW] as

select  p.StatoFunzionale as StatoPrecDoc  , d.* from ctl_doc d left outer join ctl_doc p on d.LinkedDoc = p.id



GO
