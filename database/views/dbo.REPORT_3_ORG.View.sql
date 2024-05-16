USE [AFLink_TND]
GO
/****** Object:  View [dbo].[REPORT_3_ORG]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



create View [dbo].[REPORT_3_ORG] as 

select a.Descrizione, a.TipoGara  , 
	case when a.Importo = 0 or a.Importo is null then 999
		when b.Importo = 0 or b.Importo is null then -999
		else (b.Importo / a.Importo )-1 
	end
	as Importo ,

	case when a.N_Bandi = 0 or a.N_Bandi is null then 999
	     when b.N_Bandi = 0 or b.N_Bandi is null then -999
	     else (cast(b.N_Bandi as float) / cast(a.N_Bandi as float))-1  
	end
	as N_Bandi

from 


	(
		select 

			Descrizione, 
			
			TipoGara,
			
			sum (Importo) as Importo  , sum( N_Bandi ) as N_Bandi
		from (
			select 
				Descrizione, 
				
				TipoGara,
				
				d.Importo , N_Bandi


			from REPORT_2_dati as d
				inner join Document_Report_Periodi on TipoAnalisi = 'REPORT_3' and Used = 1 and deleted = 0
			where convert( char(10) ,DataI,121) <= Periodo and Periodo <= convert( char(10) ,DataF,121)
		) as a

		group by 

			Descrizione, 
			TipoGara
	) as a

	left outer join 
		(
			select 

				Descrizione, 
				
				TipoGara,
				
				sum (Importo) as Importo  , sum( N_Bandi ) as N_Bandi
			from (
				select 
					Descrizione, 
					TipoGara,
					
					d.Importo , N_Bandi


				from REPORT_2_dati as d
					inner join Document_Report_Periodi on TipoAnalisi = 'REPORT_3' and Used = 1 and deleted = 0
				where convert( char(10) ,DataI2,121) <= Periodo and Periodo <= convert( char(10) ,DataF2,121)
			) as a
			group by 

				Descrizione, 
				TipoGara

		) as b on a.Descrizione = b.Descrizione and a.TipoGara = b.TipoGara

union 

select b.Descrizione, b.TipoGara  , 
	case when a.Importo = 0 or a.Importo is null then 999
		when b.Importo = 0 or b.Importo is null then -999
		else (b.Importo / a.Importo )-1 
	end
	as Importo ,  

	case when a.N_Bandi = 0 or a.N_Bandi is null then 999
		when b.N_Bandi = 0 or b.N_Bandi is null then -999
      	     else (cast(b.N_Bandi as float) / cast(a.N_Bandi as float))-1  
	end
	as N_Bandi

from 


	(
		select 

			Descrizione, 
			
			TipoGara,
			
			sum (Importo) as Importo  , sum( N_Bandi ) as N_Bandi
		from (
			select 
				Descrizione, 
				
				TipoGara,
				
				d.Importo , N_Bandi


			from REPORT_2_dati as d
				inner join Document_Report_Periodi on TipoAnalisi = 'REPORT_3' and Used = 1 and deleted = 0
			where convert( char(10) ,DataI,121) <= Periodo and Periodo <= convert( char(10) ,DataF,121)
		) as a

		group by 

			Descrizione, 
			TipoGara
	) as a

	right outer join 
		(
			select 

				Descrizione, 
				
				TipoGara,
				
				sum (Importo) as Importo  , sum( N_Bandi ) as N_Bandi
			from (
				select 
					Descrizione, 
					TipoGara,
					
					d.Importo , N_Bandi


				from REPORT_2_dati as d
					inner join Document_Report_Periodi on TipoAnalisi = 'REPORT_3' and Used = 1 and deleted = 0
				where convert( char(10) ,DataI2,121) <= Periodo and Periodo <= convert( char(10) ,DataF2,121)
			) as a
			group by 

				Descrizione, 
				TipoGara

		) as b on a.Descrizione = b.Descrizione and a.TipoGara = b.TipoGara


GO
