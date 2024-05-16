USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[GET_LOG_ANDAMENTALI]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





---------------------------------------------------------------
-- stored che controlla l'accessibilita ai documenti presenti nella CTL_DOC
-- per owner
---------------------------------------------------------------
CREATE proc [dbo].[GET_LOG_ANDAMENTALI]
(
	@DI as datetime,
	@DF as datetime,
	@NodoServer1 as varchar(100),
	@NodoServer2 as varchar(100),
	@STEP as int
)
as
begin
	
	SET NOCOUNT ON


	-- genero una tabella con un discriminante temporale costante per avere raffronto andamentale coerente
	--declare @DI datetime
	declare @DC datetime
	--declare @DF datetime
	--set @DI = '2020-03-03 00:00:00'
	--set @DF = '2020-03-03 23:59:59'
 
	DECLARE @Tempo TABLE
	(
		Data datetime, 
		SessioniAttiveNodo1  int default(0),
		SessioniAttiveNodo2  int default(0),
		RichiesteServerNodo1  int default(0),
		RichiesteServerNodo2  int default(0),
		TempoDiElaborazione  int default(0)
	)

	set @DC = @DI
	--select @DC as Data into #Tempo

	while @DC < @DF
	begin
	
		insert into @Tempo ( Data ) values( @DC )
		set @DC = dateadd( minute , 1 , @DC )

	end

	if @STEP=1 or @STEP=0
	BEGIN
		
		--------------------------------------------------------------------------------------------------------------------------------------------
		---------------------------------------3. SESSIONI ATTIVE IN UN INTERVALLO-------------------------------------------------------
		--------------------------------------------------------------------------------------------------------------------------------------------
		--select 'SESSIONI ATTIVE NODO ' + @NodoServer + ' NELL''INTERVALLO DAL ' + convert(varchar(16),@DI,121)+ ' AL ' + convert(varchar(16),@DF,121)
		
		if @NodoServer1 <> ''
		begin
			select  
				convert(varchar(16),data,121) as Data, SUM(totSessioniAttive) as [SessioneAttiveNodo1]
				--into #t
				from 
					CTL_Performance_Monitor with (nolock) 
				where 
					server = @NodoServer1 and data >= @DI and data <= @DF
					group by convert(varchar(16),data,121)
					order by convert(varchar(16),data,121)

			--update 
			--	@Tempo
			--	set SessioniAttiveNodo1 = SessioneAttive
			--	from #t T
			--		inner join @Tempo T1 on T1.Data=T.Data
		end
		
		if @NodoServer2 <> ''
		begin
			select  
				convert(varchar(16),data,121) as Data, SUM(totSessioniAttive) as [SessioneAttiveNodo2]
				--into #t2
				from 
					CTL_Performance_Monitor with (nolock) 
				where 
					server = @NodoServer2 and data >= @DI and data <= @DF
					group by convert(varchar(16),data,121)
					order by convert(varchar(16),data,121)

			--update 
			--	@Tempo
			--	set SessioniAttiveNodo2 = SessioneAttive
			--	from #t2 T
			--		inner join @Tempo T1 on T1.Data=T.Data
		end

	END



	if @STEP = 2 or @STEP=0
	BEGIN
		
		
		IF OBJECT_ID('tempdb..#t1') IS NOT NULL
			DROP TABLE #t1
		
		select * into #t1 from CTL_LOG_UTENTE with (nolock) where datalog >=@DI and datalog <= @DF

		--NUMERO UTENTI TOTALI SUL NODO
		--IF OBJECT_ID('tempdb..#t2') IS NOT NULL
		--	DROP TABLE #t2
		--select distinct idpfu  into #t2 from #t1 where descrizione like '%' + @NodoServer
		--select COUNT (*) as NumeroUtentiNodo from #t2

		--RICHIESTE SERVER PER INTERVALLO nodo 
		--select 'RICHIESTE SERVER NODO ' + @NodoServer + ' NELL''INTERVALLO DAL ' + convert(varchar(16),@DI,121)+ ' AL ' + convert(varchar(16),@DF,121)
		if @NodoServer1 <> ''
		BEGIN
			select  
				convert(varchar(16),datalog,121) as Data, COUNT(*) as [Numero Richieste] ,  @NodoServer1 as 'Nodo'
				--into #t3
				from #t1
					where descrizione like 'IP-SERVER:' + @NodoServer1 + '%'
					group by  convert(varchar(16),datalog,121)
					order by convert(varchar(16),datalog,121)

			--update 
			--		@Tempo
			--		set RichiesteServerNodo1 = RichiesteServer
			--		from #t3 T
			--			inner join @Tempo T1 on T1.Data=T.Data

		END

		if @NodoServer2 <> ''
		BEGIN
			select  
				convert(varchar(16),datalog,121) as Data, COUNT(*) as [RichiesteServerNodo2]
				--into #t4
				from #t1
					where descrizione like 'IP-SERVER:' + @NodoServer2 + '%'
					group by  convert(varchar(16),datalog,121)
					order by convert(varchar(16),datalog,121)

			--update 
			--		@Tempo
			--		set RichiesteServerNodo2 = RichiesteServer
			--		from #t4 T
			--			inner join @Tempo T1 on T1.Data=T.Data

		END

	END

	if @STEP = 3 or @STEP=0
	BEGIN

		
		--------------------------------------------------------------------------------------------------------------------------------------------
		---------------------------------------5. TEMPO DI ELABORAZIONE SUL SERVER IN UN INTERVALLO-------------------------------------------------
		--------------------------------------------------------------------------------------------------------------------------------------------
		--select 'TEMPO DI ELABORAZIONE SUL SERVER DAL ' + convert(varchar(16),@DI,121)+ ' AL ' + convert(varchar(16),@DF,121)
		select  
			convert(varchar(16),DataEsecuzione,121) as Data, SUM(timer)/1000 as [TempoSpeso]
			--into #t5
			from 
				CTL_PROFILER with (nolock) 
			where 
				 DataEsecuzione >= @DI and DataEsecuzione <=@DF
				group by convert(varchar(16),DataEsecuzione,121)
				order by convert(varchar(16),DataEsecuzione,121)
		
		--update 
		--	@Tempo
		--		set TempoDiElaborazione = TempoSpeso
		--		from #t5 T
		--			inner join @Tempo T1 on T1.Data=T.Data
							
	END


	--select * from @Tempo


end








GO
