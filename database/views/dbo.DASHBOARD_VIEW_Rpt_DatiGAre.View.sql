USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_Rpt_DatiGAre]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [dbo].[DASHBOARD_VIEW_Rpt_DatiGAre] as


	select 
			 Periodo ,
			 --TIPO_AMM_ER ,
			 --ProceduraGara ,
			 --TipoAppaltoGara ,
			 sum( Qta ) as NumeroLotti ,
			 sum( Num ) as LottiAggiudicati ,
			 sum( NumGarePubb ) as NumGarePubb,
			 sum( ImportoAggiudicato ) as ImportoAggiudicato ,
			 sum( ValoreImportoLotto ) as ValoreImportoLotto 
			 
		from 
		(
			SELECT   left(  Periodo , 4 ) as Periodo,
			
					 Qta ,
					 Num ,
					 NumGarePubb,
					 ValoreImportoLotto ,
					
					ImportoAggiudicato
		 
				FROM [dbo].[DASHBOARD_VIEW_Rpt_ProcedureEnte_2]
		) as a
		group by
			--id ,
			Periodo
			--TIPO_AMM_ER 
			--ProceduraGara ,
			--TipoAppaltoGara 

GO
