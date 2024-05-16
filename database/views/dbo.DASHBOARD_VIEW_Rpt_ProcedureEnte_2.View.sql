USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_Rpt_ProcedureEnte_2]    Script Date: 5/16/2024 2:45:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE  view [dbo].[DASHBOARD_VIEW_Rpt_ProcedureEnte_2] as


	select 
			 
			 substring(Periodo,0,5) Annoda ,
			 substring(Periodo,0,5) Annoa ,
			 Periodo,
			 TIPO_AMM_ER ,
			 ProceduraGara ,
			 TipoAppaltoGara ,
			 sum( Qta ) as Qta ,
			 sum( Num ) as Num ,
			 sum( ImportoAggiudicato ) as ImportoAggiudicato ,
			 sum( ValoreImportoLotto ) as ValoreImportoLotto ,
			 1 as NumGarePubb
		from 
		(
			SELECT   CONVERT( VARCHAR(7) , DataInvio , 121) AS Periodo ,
					 TIPO_AMM_ER ,
					 ProceduraGara  ,
					 TipoAppaltoGara ,
					 1 AS Qta ,
					 IsAggiudicato AS Num ,
					 ValoreImportoLotto ,
					 id ,
					 CASE
						 WHEN IsAggiudicato = 1
						 THEN ImportoAggiudicato
						 ELSE 0
					 END AS ImportoAggiudicato
		 
				FROM DASHBOARD_VIEW_REPORT_LISTA_PROCEDURE
		) as a
		group by
			id ,
			Periodo ,
			TIPO_AMM_ER ,
			ProceduraGara ,
			TipoAppaltoGara 

GO
