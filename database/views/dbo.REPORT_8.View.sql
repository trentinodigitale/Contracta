USE [AFLink_TND]
GO
/****** Object:  View [dbo].[REPORT_8]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE View [dbo].[REPORT_8] as 

select Descrizione
     , ProtocolloBando
     , Durata
  from REPORT_8_dati_periodi

union all

select v.Descrizione
     , v.ProtocolloBando
     , avg(v.Durata) as Durata 
  from (
        select Descrizione
             , 'Durata Media' as ProtocolloBando
             , Durata
          from REPORT_8_dati_periodi
       ) v
group by v.Descrizione, v.ProtocolloBando



GO
