USE [AFLink_TND]
GO
/****** Object:  View [dbo].[REPORT_6_Dati_Base]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE View [dbo].[REPORT_6_Dati_Base] as 

select convert(char(10), D.DataInvio, 121)   as Periodo
     , substring(programma,6,len(programma)) as Direzione
     , Cdr_Responsabile                      as Dirigente
	,propro
     , Programma
     , 1                                     as N_Bandi
     , case TipoProcedura
            when '1' then 1
            else 0
       end                                   as N_Aperta
     , case TipoProcedura
            when '2' then 1
            else 0
       end                                   as N_Asta_Tel
     , case TipoProcedura
            when '3' then 1
            else 0
       end                                   as N_Ristretta
     , case TipoProcedura
            when '4' then 1
            else 0
       end                                   as N_Tel_Ap
     , case TipoProcedura
            when '5' then 1
            else 0
       end                                   as N_Tel_EC
     , case TipoProcedura
            when '6' then 1
            else 0
       end                                   as N_Tel_Ris
     , case TipoProcedura
            when '7' then 1
            else 0
       end                                   as N_Gara_Ec
     , case TipoProcedura
            when '8' then 1
            else 0
       end                                   as N_Ric_Prev
     , case TipoProcedura
            when '9' then 1
            else 0
       end                                   as N_Proc_Neg
     , case TipoProcedura
            when '10' then 1
            else 0
       end                                   as N_Tel_Proc_Neg
		,p.IdProgetto
		,ProtocolloBando
  from Document_Progetti p
     , PEG
     , (select LinkModified
             , min(DataInvio) as DataInvio 
          from Document_Progetti ps 
         where ProtocolloBando is not null 
           and ProtocolloBando <> '' 
	 group by LinkModified, ProtocolloBando
	) d
 where d.LinkModified = p.IdProgetto  
   and propro = substring(peg, charindex('#~#', peg) + 3, 10)
   and p.storico = 0 

GO
