USE [AFLink_TND]
GO
/****** Object:  View [dbo].[VIEW_CARICA_MACROPRODOTTI]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW
[dbo].[VIEW_CARICA_MACROPRODOTTI]
as

select *, 
	jumpcheck as Ambito 
	, isnull(V.Valore, '' ) as HideColExtra
	from 
		ctl_doc  with (nolock)
			left join ( select valore  from ctl_parametri with (nolock) where contesto='CODIFICA_MACROPRODOTTO' ) V on 1 = 1
	where 
		tipodoc='CARICA_MACROPRODOTTI'
GO
