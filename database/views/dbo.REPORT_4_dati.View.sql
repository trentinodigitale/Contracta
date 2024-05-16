USE [AFLink_TND]
GO
/****** Object:  View [dbo].[REPORT_4_dati]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[REPORT_4_dati] as 

select Periodo 
     , isnull(REL_ValueOutput, TipoProcedura) as TipoProcedura 
     , Tipologia 
     , case 
           when REL_Type is null then '  Tradizionali' 
           else '  Telematiche' 
       end as TipoGara
     , N_Bandi
     , isnull(N_Rettifiche, 0) as N_Rettifiche
     , isnull(N_Annullamenti, 0) as N_Annullamenti
     , isnull(N_Ricorsi, 0) as N_Ricorsi
     , isnull(N_Deserte, 0) as N_Deserte
  from REPORT_4_dati_base
        LEFT OUTER JOIN  CTL_Relations ON REL_Type = 'GARE_TELEMATICHE' AND TipoProcedura = REL_ValueInput








GO
