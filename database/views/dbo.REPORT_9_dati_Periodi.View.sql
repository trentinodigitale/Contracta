USE [AFLink_TND]
GO
/****** Object:  View [dbo].[REPORT_9_dati_Periodi]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE View [dbo].[REPORT_9_dati_Periodi] as 

select Descrizione
     , FasciaImporto
     , ProtocolloBando
     , Durata
     , IdDoc
  from REPORT_9_dati_base d
     , Document_Report_Periodi 
 where TipoAnalisi = 'REPORT_9' 
   and Used = 1 
   and deleted = 0
   and convert(char(10), DataI, 121) <= Periodo 
   and Periodo <= convert(char(10), DataF, 121)





GO
