USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_Rpt_Registrazioni_Iscrizioni_dummy]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


create view [dbo].[DASHBOARD_VIEW_Rpt_Registrazioni_Iscrizioni_dummy] as 
	SELECT TipoUtente , PeriodoReg , SUM ( qTA ) AS Qta 
	from 
	(
			select TipoUtente, PeriodoReg, Qta FROM dummyuserbymonth ('Fornitori iscritti al Portale')
			union
			select TipoUtente, PeriodoReg, Qta FROM dummyuserbymonth ('Fornitori iscritti in Albo')
			union
			select TipoUtente, PeriodoReg, Qta FROM dummyuserbymonth ('Buyer')
			union
			select TipoUtente, PeriodoReg, Qta FROM dummyuserbymonth ('Buyer-iscritti')
			union
			-- 16ott.2012 query di tutti gli enti
			select TipoUtente, PeriodoReg, Qta FROM dummyuserbymonth ('Unità Organizzative Enti Aderenti')
	) as a
	group by TipoUtente , PeriodoReg



GO
