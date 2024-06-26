USE [AFLink_TND]
GO
/****** Object:  View [dbo].[REPORT_2]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE View [dbo].[REPORT_2] as 
select D.* , D.Importo / T.Importo as PercImporto , cast(D.N_Bandi as float)/ cast(T.N_Bandi as float) as PercN_Bandi 
from REPORT_2_dati_Periodi as D
	inner join (
		select 

			Descrizione, 
			sum (Importo) as Importo  , sum( N_Bandi ) as N_Bandi

		 from REPORT_2_dati_Periodi
		where 	'ZZZZZZTotale' <> TipoProcedura and   Tipologia <> 'ZZZZZZTotale'
		group by Descrizione
	) as T on D.Descrizione = T.Descrizione



GO
