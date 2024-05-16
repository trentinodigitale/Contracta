USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_ANALISI_LOG_TAB_ANDAMENTALI]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







---------------------------------------------------------------
-- recupera gli andamentali
---------------------------------------------------------------
--@Protocollo = protocollo gara
--@NodoServer = 1,2,3,eccc
--@Step		
--			0 restituisce elenco server
--			1 sessione attive
--			2 richieste server
--			3 tempo speso sul server
CREATE proc [dbo].[OLD2_ANALISI_LOG_TAB_ANDAMENTALI]
(
	@Protocollo  varchar(100) , 
	@NodoServer as int ,
	@Step as int ,
	@DI as datetime = null ,
	@DF as datetime = null 
)
as
begin
	set nocount on 	

	--recupero data scadenza della gara
	declare @DataScadenza as datetime
	declare @DataInizio as datetime
	declare @IpServer as varchar(100)
	set @IpServer =''

	set @DataScadenza = null

	
	if @DI is null and @DF is null
	begin
		--considero per gli andamewntali il giorno della scadenza dell'offerta
		select  
			@DataInizio = convert(varchar(10),DataScadenzaOfferta,121)  
			from 
				CTL_DOC O with (nolock)  
					inner join Document_Bando WITH (NOLOCK) on  O.id = idHeader
			where protocollo=@Protocollo
	
			set @DataScadenza = DATEADD (hour,23,@DataInizio)
			set @DataScadenza = DATEADD (minute,59,@DataScadenza)
			set @DataScadenza = convert(varchar(19),@DataScadenza,121) 
	end
	else
	begin
		--considero le date passate in input
		--set @DataInizio = convert(varchar(19),@DI,121) 
		--set @DataScadenza = convert(varchar(19),@DF,121) 
		set @DataInizio = @DI
		set @DataScadenza = @DF
	end

	--print @DI
	--print @DF
	--return

	if @DataInizio is not null
	begin
		
		if @Step = 0
		begin
			select distinct server into #t0 from CTL_Performance_Monitor with (nolock)

			select   ROW_NUMBER() OVER ( ORDER BY server ASC) AS NodoServer   from #t0
			return
		end

		--recupero il server passato in input
		--se step 1 recupero i server dalla tabella CTL_Performance_Monitor
		if @Step = 1
		begin
			select distinct server into #t from CTL_Performance_Monitor with (nolock)

			select  server, ROW_NUMBER() OVER ( ORDER BY server ASC) AS Row  into #t1 from #t
						
			select @IpServer=server from #t1 where  Row = @NodoServer

			if @IpServer=''
			begin
				select 'Nodo Server Non Esistente' as Esito
				return
			end

		end

		--se step 2 recupero i server dalla tabella ctl_log_utente
		if @Step = 2
		begin
			
			--select @DataInizio
			--select @DataScadenza
			--select 'prima della query'
			--return
			--select Descrizione into #t2 
			--	from CTL_LOG_UTENTE with (nolock) 
			--	where datalog >=@DataInizio and datalog <= @DataScadenza and descrizione is not null
			--			and descrizione like 'IP-SERVER:%'
			--select 'dopo della query'
			--return

			--update #t2
			--	set Descrizione = replace(Descrizione,'IP-SERVER:','')
				
			

			--update #t2
			--	set Descrizione = left ( Descrizione , CHARINDEX ( '-',Descrizione)-1 )
			

			--select distinct Descrizione into #t3 from #t2 where len (Descrizione)>10
			
			--select  Descrizione, ROW_NUMBER() OVER ( ORDER BY Descrizione ASC) AS Row  into #t4 from #t3
						
			--select @IpServer=Descrizione from #t4 where  Row = @NodoServer
			select distinct server into #t_1 from CTL_Performance_Monitor with (nolock)

			select  server, ROW_NUMBER() OVER ( ORDER BY server ASC) AS Row  into #t_2 from #t_1
						
			select @IpServer=server from #t_2 where  Row = @NodoServer

			if @IpServer=''
			begin
				select 'Nodo Server Non Esistente' as Esito
				return
			end
		end

		--select @IpServer
		--select @DataInizio
		--select @DataScadenza
		--select @Step
		--return

		exec GET_LOG_ANDAMENTALI @DataInizio,@DataScadenza,@IpServer,'',@Step

	end
	else
		select 'Gara non Esistente'

end

GO
