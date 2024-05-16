USE [AFLink_TND]
GO
/****** Object:  View [dbo].[RUOLI_PROFILI_FROM_RUOLI_PROFILI]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

	CREATE VIEW [dbo].[RUOLI_PROFILI_FROM_RUOLI_PROFILI] AS
	select 
		V.id,		
		V.ID as ID_FROM,
		ISNULL( LB.ML_Description,V.dmv_descML) as titolo,
		V.dmv_cod as JumpCheck,
		V.id as idheader,
		items as profilo

		from DASHBOARD_VIEW_RUOLI_PROFILI V
			left join LIB_Multilinguismo  LB with(nolock) on LB.ml_key=V.dmv_descML and LB.ML_LNG='I'
			cross apply ( select items from dbo.Split( v.profilo,'###') )as P
GO
