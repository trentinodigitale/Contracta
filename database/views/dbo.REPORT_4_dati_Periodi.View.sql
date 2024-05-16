USE [AFLink_TND]
GO
/****** Object:  View [dbo].[REPORT_4_dati_Periodi]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE View [dbo].[REPORT_4_dati_Periodi] as 

select Descrizione
     , TipoGara
     , sum(N_Bandi)          as N_Bandi
     , sum(N_Rettifiche)     as N_Rettifiche
     , sum(N_Annullamenti)   as N_Annullamenti
     , sum(N_Ricorsi)        as N_Ricorsi
     , sum(N_Deserte)        as N_Deserte
  from REPORT_4_dati d
     , Document_Report_Periodi 
 where TipoAnalisi = 'REPORT_4' 
   and Used = 1 
   and deleted = 0
   and convert(char(10), DataI, 121) <= Periodo 
   and Periodo <= convert(char(10), DataF, 121)
group by Descrizione, TipoGara

union 

select v.Descrizione
     , v.TipoGara 
     , sum(v.N_Bandi)        as N_Bandi
     , sum(v.N_Rettifiche)   as N_Rettifiche
     , sum(v.N_Annullamenti) as N_Annullamenti
     , sum(v.N_Ricorsi)      as N_Ricorsi
     , sum(v.N_Deserte)      as N_Deserte
  from (select Descrizione
             , ' Totale'  as TipoGara
             , N_Bandi
             , N_Rettifiche
             , N_Annullamenti
             , N_Ricorsi
             , N_Deserte
          from REPORT_4_dati d
             , Document_Report_Periodi 
         where TipoAnalisi = 'REPORT_4' 
           and Used = 1 
           and deleted = 0
           and convert(char(10), DataI, 121) <= Periodo 
           and Periodo <= convert(char(10), DataF, 121)) v
group by  v.Descrizione, v.TipoGara


union 

select v.Descrizione
     , v.TipoGara 
     , sum(v.N_Bandi)                                                 as N_Bandi
     , (sum(cast(v.N_Rettifiche as float))   / sum(v.N_Bandi)) * 100  as N_Rettifiche
     , (sum(cast(v.N_Annullamenti as float)) / sum(v.N_Bandi)) * 100  as N_Annullamenti
     , (sum(cast(v.N_Ricorsi as float))      / sum(v.N_Bandi)) * 100  as N_Ricorsi
     , (sum(cast(v.N_Deserte as float))      / sum(v.N_Bandi)) * 100  as N_Deserte
  from (select Descrizione
             , 'Percentuale su Totale Bandi'  as TipoGara
             , N_Bandi
             , N_Rettifiche
             , N_Annullamenti
             , N_Ricorsi
             , N_Deserte
          from REPORT_4_dati d
             , Document_Report_Periodi 
         where TipoAnalisi = 'REPORT_4' 
           and Used = 1 
           and deleted = 0
           and convert(char(10), DataI, 121) <= Periodo 
           and Periodo <= convert(char(10), DataF, 121)) v
group by  v.Descrizione, v.TipoGara

  





GO
