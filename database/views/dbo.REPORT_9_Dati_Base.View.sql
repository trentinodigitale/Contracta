USE [AFLink_TND]
GO
/****** Object:  View [dbo].[REPORT_9_Dati_Base]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE View [dbo].[REPORT_9_Dati_Base] as 

select case when isnull(a.ProtocolloBando, '') <> '' then '  ' + a.ProtocolloBando
            else ' X' + right('00000000' + cast(a.idprogetto as varchar), 8)
       end                                                                  as ProtocolloBando
     , convert(char(10), c.DataAvvioIstr, 121)                              as Periodo
     , case when a.Importo <= 50000 then '<= 50000 €'
            else '>  50000 €'
       end                                                                  as FasciaImporto
     , case 
           when c.DurataIstruttoria is not null then c.DurataIstruttoria
           else abs (datediff(dd, getdate(), c.DataAvvioIstr))              
       end                                                                  as Durata
     , a.IdProgetto                                                         as IdDoc
  from document_progetti a
     , document_progetti_lotti c 
 where a.idprogetto = c.idprogetto
   and a.deleted = 0
   





GO
