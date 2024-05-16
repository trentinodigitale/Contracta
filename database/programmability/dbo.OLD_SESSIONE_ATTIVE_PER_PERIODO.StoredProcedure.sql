USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_SESSIONE_ATTIVE_PER_PERIODO]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE procedure [dbo].[OLD_SESSIONE_ATTIVE_PER_PERIODO]( @StartDate as varchar(100), @EndDate as varchar(100), @DataPart as varchar(5))
as
begin
	
	--@StartDate = data di partenza in formato tecnico AAAA-MM-GG HH:MM:SS
	--@EndDate   = data di arrivo in formato tecnico AAAA-MM-GG HH:MM:SS
	--@DataPart  = numero caratteri per identificare HH(13),MM(16),SS(19),ECC

	--select convert( varchar(13) ,getdate(),121  )

	--TRAVASO IN UNA TABELLA TEMPORANEA #t1 LE SESSIONI ATTIVE NELL'INTERVALLO RICHIESTO PER IL DATAPART RICHIESTO (lunghezza caratteri della data)
	declare @strSql as nvarchar (max)

	set @strSql = '
		select convert( varchar(' + @DataPart + ') ,data ,121  ) as PERIODO , max(totSessioniAttive) as NumeroSessioni , 0 as NumeroRichieste,cast(0.0 as float) as Secondi,cast(0.0 as float)as Massimo,cast(0.0 as float)as TempoMedio
			into #t 
			from CTL_Performance_Monitor with (nolock) where data >= ''' + @StartDate + ''' and data <= ''' + @EndDate + ''' 
			group by  convert( varchar(' +  @DataPart + ') ,data ,121  ) 
 
	'

	--select DATEPART ( hh , data ) as PERIODO , max(totSessioniAttive) as NumeroSessioni , 0 as NumeroRichieste,0 as Secondi,0 as Massimo,0 as TempoMedio
	--	into #t 
	--	from CTL_Performance_Monitor with (nolock) where data >='2019-11-15 00:00'and data <='2019-11-15 23:59' 
	--	group by  DATEPART ( hh , data ) 
 
	--drop table #t
	--select * from #t order by 1 

	--TRAVASO LE RICHIESTE IN UNA TABELLA TEMPORANEA #t2 NELL'INTERVALLO RICHIESTO
	set @strSql = @strSql + '
		
		select * into #t1 from  CTL_Profiler with (nolock) where dataesecuzione >= ''' + @StartDate + ''' and dataesecuzione <=''' + @EndDate + '''

		'


	--select * from #t1 order by dataesecuzione

	--TRAVASO LE INFO DELLE RICHIESTE IN UNA TABELLA TEMPORANEA #t2
	--select DATEPART ( hh , dataesecuzione ) PERIODO ,count(*) as NumeroRichieste, sum(Timer)/1000 as Secondi , max(timer) AS Massimo,sum(timer)/count(*)as TempoMedio 
	--	into #t2 
	--	from #t1
	--	group by DATEPART ( hh , dataesecuzione ) order by 1
	
	set @strSql = @strSql + '
		
		select convert( varchar(' + @DataPart + ') ,dataesecuzione ,121  ) PERIODO ,count(*) as NumeroRichieste, sum(Timer)/1000.0 as Secondi , max(timer)/1000.0 AS Massimo, (sum(timer)/count(*)) / 1000.0 as TempoMedio 
			into #t2 
			from #t1
			group by convert( varchar(' + @DataPart + ') ,dataesecuzione ,121  ) 

		update #t 
			set
				NumeroRichieste=#t2.NumeroRichieste,
				Secondi=#t2.Secondi,
				Massimo=#t2.Massimo,
				TempoMedio=#t2.TempoMedio
			from #t A
				inner join #t2 on A.PERIODO = #t2.PERIODO

		select * from #t
		'
	
	exec (@strSql)
	--select * from #t2 order by 1 

	--AGGIORNO LA TABELLA INIZIALE CON LE INFO DELLE RICHIESTE
	
	
end






GO
