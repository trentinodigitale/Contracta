USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_Rpt_Registrazioni_Iscrizioni]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[DASHBOARD_VIEW_Rpt_Registrazioni_Iscrizioni]
as

select PeriodoReg ,TipoUtente , sum( Qta ) as Qta from 
(
	select r1.PeriodoReg , r1.TipoUtente , r2.Qta from 
		DASHBOARD_VIEW_Rpt_Registrazioni_Iscrizioni_base r1
			inner join DASHBOARD_VIEW_Rpt_Registrazioni_Iscrizioni_base r2 
				on r1.PeriodoReg >= r2.PeriodoReg and r1.TipoUtente = r2.TipoUtente
--			WHERE r1.TipoUtente = 'Fornitori-iscritti'
--
--			order by 2 , 1


) AS A 

WHERE TipoUtente <>  'Buyer-iscritti'
GROUP BY PeriodoReg ,TipoUtente





GO
