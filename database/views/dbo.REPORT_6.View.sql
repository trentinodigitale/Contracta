USE [AFLink_TND]
GO
/****** Object:  View [dbo].[REPORT_6]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE View [dbo].[REPORT_6] as 

select Descrizione 
     , Direzione + ' - ' + Dirigente as DirezioneRep
     --, propro as DirezioneRep
     , sum(N_Bandi)                  as N_Bandi
     , sum(N_Aperta)                 as N_Aperta
     , sum(N_Asta_Tel)               as N_Asta_Tel
     , sum(N_Ristretta)              as N_Ristretta
     , sum(N_Tel_Ap)                 as N_Tel_Ap
     , sum(N_Tel_EC)                 as N_Tel_EC
     , sum(N_Tel_Ris)                as N_Tel_Ris
     , sum(N_Gara_Ec)                as N_Gara_Ec
     , sum(N_Ric_Prev)               as N_Ric_Prev
     , sum(N_Proc_Neg)               as N_Proc_Neg
     , sum(N_Tel_Proc_Neg)           as N_Tel_Proc_Neg
  from REPORT_6_Dati_Base d
     , Document_Report_Periodi 
 where TipoAnalisi = 'REPORT_6' 
   and Used = 1 
   and deleted = 0
   and convert(char(10), DataI, 121) <= Periodo 
   and Periodo <= convert(char(10), DataF, 121)
group by Descrizione, Direzione, Dirigente --,propro

union all

select v.Descrizione
     , v.DirezioneRep
     , sum(N_Bandi)                  as N_Bandi
     , sum(N_Aperta)                 as N_Aperta
     , sum(N_Asta_Tel)               as N_Asta_Tel
     , sum(N_Ristretta)              as N_Ristretta
     , sum(N_Tel_Ap)                 as N_Tel_Ap
     , sum(N_Tel_EC)                 as N_Tel_EC
     , sum(N_Tel_Ris)                as N_Tel_Ris
     , sum(N_Gara_Ec)                as N_Gara_Ec
     , sum(N_Ric_Prev)               as N_Ric_Prev
     , sum(N_Proc_Neg)               as N_Proc_Neg
     , sum(N_Tel_Proc_Neg)           as N_Tel_Proc_Neg
  from (
         select Descrizione 
              , 'ZZZZZZTotale'	                    as DirezioneRep
              , isnull(N_Bandi, 0)                  as N_Bandi
              , isnull(N_Aperta, 0)                 as N_Aperta
              , isnull(N_Asta_Tel, 0)               as N_Asta_Tel
              , isnull(N_Ristretta, 0)              as N_Ristretta
              , isnull(N_Tel_Ap, 0)                 as N_Tel_Ap
              , isnull(N_Tel_EC, 0)                 as N_Tel_EC
              , isnull(N_Tel_Ris, 0)                as N_Tel_Ris
              , isnull(N_Gara_Ec, 0)                as N_Gara_Ec
              , isnull(N_Ric_Prev, 0)               as N_Ric_Prev
              , isnull(N_Proc_Neg, 0)               as N_Proc_Neg
              , isnull(N_Tel_Proc_Neg, 0)           as N_Tel_Proc_Neg
           from REPORT_6_Dati_Base d
              , Document_Report_Periodi  
          where TipoAnalisi = 'REPORT_6' 
            and Used = 1 
            and deleted = 0
            and convert(char(10), DataI, 121) <= Periodo 
            and Periodo <= convert(char(10), DataF, 121)
       ) v
group by v.Descrizione, v.DirezioneRep





GO
