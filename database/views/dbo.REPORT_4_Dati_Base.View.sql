USE [AFLink_TND]
GO
/****** Object:  View [dbo].[REPORT_4_Dati_Base]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE View [dbo].[REPORT_4_Dati_Base] as 

select convert(char(10), D.DataInvio, 121) as Periodo
     , p.TipoProcedura 
     , P.Tipologia
     , 1                                   as N_Bandi
     , case Rettifica 
            when 'si' then 1 
            else 0
       end as N_Rettifiche
     , case Annullamento 
            when 'si' then 1 
            else 0
       end as N_Annullamenti
     , case Ricorso 
            when 'si' then 1 
            else 0
       end as N_Ricorsi
     , case Deserta_MaiIndetta 
            when '1' then 1 
            --when '2' then 1 
            else 0
       end as N_Deserte
  from dbo.Document_Progetti p
     , Document_Progetti_Lotti l
     , (select LinkModified
             , min(DataInvio) as DataInvio 
          from dbo.Document_Progetti ps 
         where ProtocolloBando is not null 
           and ProtocolloBando <> '' 
	 group by LinkModified, ProtocolloBando
	) d
 where d.LinkModified = p.IdProgetto  
   and l.IdProgetto = p.IdProgetto
   and p.storico = 0 
union 
select convert(char(10), Periodo, 121) as Periodo
     , TipoProcedura 
     , Tipologia
     , N_Bandi
     , N_Rettifiche
     , N_Annullamenti
     , N_Ricorsi
     , N_Deserte
  from dbo.Document_Report_Storico 

GO
