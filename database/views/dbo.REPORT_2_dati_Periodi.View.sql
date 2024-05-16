USE [AFLink_TND]
GO
/****** Object:  View [dbo].[REPORT_2_dati_Periodi]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE View [dbo].[REPORT_2_dati_Periodi] as 

select 

	Descrizione, 
	
	--Periodo ,
	TipoProcedura ,
	Tipologia , 
	TipoGara,
	
	sum (Importo) as Importo  , sum( N_Bandi ) as N_Bandi
from (
	select 
		Descrizione, 
		
		--Periodo ,
		TipoProcedura ,
		Tipologia , 
		TipoGara,
		
		d.Importo , N_Bandi


	from REPORT_2_dati as d
		inner join Document_Report_Periodi on TipoAnalisi = 'REPORT_2' and Used = 1 and deleted = 0
	where convert( char(10) ,DataI,121) <= Periodo and Periodo <= convert( char(10) ,DataF,121)
) as a
group by 

	Descrizione, 
	TipoProcedura ,
	Tipologia , 
	TipoGara

union 



select 

	Descrizione, 
	'ZZZZZZTotale' as TipoProcedura ,
	Tipologia , 
	TipoGara,
	
	sum (Importo) as Importo  , sum( N_Bandi ) as N_Bandi
from (
	select 
		Descrizione, 
		TipoProcedura ,
		Tipologia , 
		TipoGara,
		
		d.Importo , N_Bandi


	from REPORT_2_dati as d
		inner join Document_Report_Periodi on TipoAnalisi = 'REPORT_2' and Used = 1 and deleted = 0
	where convert( char(10) ,DataI,121) <= Periodo and Periodo <= convert( char(10) ,DataF,121)
) as a
group by 

	Descrizione, 
	--TipoProcedura ,
	Tipologia , 
	TipoGara


union 

select 

	Descrizione, 
	'ZZZZZZTotale' as TipoProcedura ,
	'ZZZZZZTotale' as Tipologia , 
	TipoGara,
	
	sum (Importo) as Importo  , sum( N_Bandi ) as N_Bandi
from (
	select 
		Descrizione, 
		TipoProcedura ,
		Tipologia , 
		TipoGara,
		
		d.Importo , N_Bandi


	from REPORT_2_dati as d
		inner join Document_Report_Periodi on TipoAnalisi = 'REPORT_2' and Used = 1 and deleted = 0
	where convert( char(10) ,DataI,121) <= Periodo and Periodo <= convert( char(10) ,DataF,121)
) as a
group by 

	Descrizione, 
	--TipoProcedura ,
	--Tipologia , 
	TipoGara


union 

select 

	Descrizione, 
	
	--Periodo ,
	TipoProcedura ,
	'ZZZZZZTotale' as Tipologia , 
	TipoGara,
	
	sum (Importo) as Importo  , sum( N_Bandi ) as N_Bandi
from (
	select 
		Descrizione, 
		
		--Periodo ,
		TipoProcedura ,
		Tipologia , 
		TipoGara,
		
		d.Importo , N_Bandi


	from REPORT_2_dati as d
		inner join Document_Report_Periodi on TipoAnalisi = 'REPORT_2' and Used = 1 and deleted = 0
	where convert( char(10) ,DataI,121) <= Periodo and Periodo <= convert( char(10) ,DataF,121)
) as a
group by 

	Descrizione, 
	TipoProcedura ,
	--Tipologia , 
	TipoGara




GO
