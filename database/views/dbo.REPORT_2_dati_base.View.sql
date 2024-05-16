USE [AFLink_TND]
GO
/****** Object:  View [dbo].[REPORT_2_dati_base]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE View [dbo].[REPORT_2_dati_base] as 

select  convert( char(10) ,D.DataInvio,121)as Periodo, P.TipoProcedura , P.Tipologia,  P.Importo , 1 as N_Bandi
from dbo.Document_Progetti as p 

	inner join (
		select LinkModified , /*StatoProgetto ,*/min(DataInvio) as DataInvio  from dbo.Document_Progetti as ps 
		where not ProtocolloBando is null and  ProtocolloBando <> '' --StatoProgetto =  'Compiled'
		group by LinkModified ,ProtocolloBando--, StatoProgetto 	
	) as d on d.LinkModified =p.IdProgetto 

where P.storico =0 
union all
select convert( char(10) ,Periodo,121)as Periodo, TipoProcedura , Tipologia,  Importo , N_Bandi

from dbo.Document_Report_Storico 



GO
