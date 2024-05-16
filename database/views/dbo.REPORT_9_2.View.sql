USE [AFLink_TND]
GO
/****** Object:  View [dbo].[REPORT_9_2]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE View [dbo].[REPORT_9_2] as 

select Descrizione
     , ProtocolloBando
     , Durata
     , IdDoc
  from REPORT_9_dati_periodi
 where FasciaImporto = '>  50000 €'
union all

select v.Descrizione
     , v.ProtocolloBando
     , avg(v.Durata) as Durata 
     , IdDoc
  from (
        select Descrizione
             , 'Durata Media' as ProtocolloBando
             , Durata
             , -1 as IdDoc
          from REPORT_9_dati_periodi
         where FasciaImporto = '>  50000 €'
       ) v
group by v.Descrizione, v.ProtocolloBando, v.IdDoc





GO
