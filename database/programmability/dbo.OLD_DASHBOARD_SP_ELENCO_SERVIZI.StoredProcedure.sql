USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_DASHBOARD_SP_ELENCO_SERVIZI]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[OLD_DASHBOARD_SP_ELENCO_SERVIZI]
(@IdPfu							int,
 @AttrName						varchar(8000),
 @AttrValue						varchar(8000),
 @AttrOp 						varchar(8000),
 @Filter                        varchar(8000),
 @Sort                          varchar(8000),
 @Top                           int,
 @Cnt                           int output
)

as
	
	set nocount ON
	
	declare @SRV_Id as int
	declare @SRV_Sql as nvarchar(max)
	declare @NumProcessiInCoda as int

	declare @temp table (Num int)
	
	declare @nPos1 as int
	declare @npos2 as int
	declare @npos3 as int

	if exists (select  * from tempdb.dbo.sysobjects o where o.xtype in ('U') and o.id = object_id(N'tempdb..#t'))
		DROP TABLE #t

	create table #t (
		[SRV_id] [int]  NULL,
		[NumeroProcessiCoda] [int] NULL,
		[NonTrattato] [int] NULL,		
		[srv_sql] NVARCHAR(MAX) NULL
		
	) 

	INSERT INTO #t (SRV_id,NumeroProcessiCoda,NonTrattato,srv_sql)
		select SRV_id,0 as NumeroProcessiCoda, 0 as NonTrattato,srv_sql from lib_services where bDeleted=0

	update #t set NonTrattato=1 where srv_id not in (select SRV_id from lib_services where bDeleted=0 and SRV_SQL not like '%if exists%' and SRV_SQL not like '%NOT EXISTS%' )
	--declare @i int
	--set @i=0
	DECLARE crsServizi CURSOR STATIC FOR 
	select SRV_id,srv_sql  from #t where NonTrattato = 0 --bDeleted=0 and SRV_SQL not like '%if exists%' and SRV_SQL not like '%NOT EXISTS%'

	
	OPEN crsServizi

	FETCH NEXT FROM crsServizi INTO @SRV_Id, @SRV_Sql
	WHILE @@FETCH_STATUS = 0
	BEGIN
		--print @i	
		--nello STATEMENT metto COUNT(*) nella prima clausola tra la SELECT e la FROM
		set @nPos1 = CHARINDEX('select ', @SRV_Sql)
		set @nPos2 = CHARINDEX(' from ', @SRV_Sql)

		if @nPos2 = 0 
		begin
			set @nPos2 = CHARINDEX('from ', @SRV_Sql)
		end
			
		--print @SRV_Sql
		--print '--------------------------------------------------------------------------------------------'


		if @nPos1 > 0 and @npos2 > 0  and CHARINDEX(' declare ',@SRV_Sql ) = 0 and CHARINDEX('declare ',@SRV_Sql ) = 0 and CHARINDEX('declare ',@SRV_Sql ) = 0 

		begin
				
			--tolgo order by e quello che segue
			set @nPos3 = CHARINDEX(' order by ', @SRV_Sql)
			
			if @nPos3 = 0
			begin
				set @nPos3 = CHARINDEX('order by ', @SRV_Sql)
			end

			if @nPos3 > 0
				set @SRV_Sql = SUBSTRING(@SRV_Sql,1,@nPos3-1)
			
			--se lo STATEMENT contiene la clausola distinct allora applico COUNT(*) a tutto lo statement da fuori
			if CHARINDEX(' distinct ', @SRV_Sql) > 0
			begin
				set @SRV_Sql = 'select COUNT(*) from ( ' + @SRV_Sql + ' ) V '
			end
			else
			begin	
				set @SRV_Sql = SUBSTRING(@SRV_Sql,@nPos1,7)
						+ ' COUNT(*) ' + SUBSTRING(@SRV_Sql,@nPos2, LEN(@SRV_Sql) )
			end
			
			
			--eseguo lo STATEMENT in una tabella temp	
			--print cast(@srv_id as varchar(50)) + '------------' + @SRV_Sql
			delete from @temp
			insert into @temp 
			
			exec ( @SRV_Sql )
			--print 	@SRV_Sql
			select  @NumProcessiInCoda=Num from  @temp

			--aggiorno il numero di processi in coda per ogni servizio
			update #t set NumeroProcessiCoda=@NumProcessiInCoda where SRV_id = @SRV_Id


		end
		else
		begin

			update #t set NonTrattato=1 where srv_id=@SRV_Id
		--	print @SRV_Sql
		--	print '--------------------------------------------------------------------------------------------'
		end
		
		--set @i=@i+1

		FETCH NEXT FROM crsServizi INTO  @SRV_Id, @SRV_Sql
	END

	CLOSE crsServizi 
	DEALLOCATE crsServizi 

	--I SERVIZI NON PRESENTI LI INSERISCE
	insert into CTL_MONITOR_LIB_SERVICES ( [SRV_id])
	select 
		S.[SRV_id]				
		from 
			LIB_Services S 			
				left outer join #t N on  S.SRV_id = N.SRV_id  
				left join CTL_MONITOR_LIB_SERVICES CTL on S.SRV_id=CTL.SRV_id
			where S.bDeleted=0 and CTL.SRV_id IS NULL
			order by N.NumeroProcessiCoda desc

	--AGGIORNA I VALORI PER TUTTI I SERVIZI
	update CTL  
		set CTL.NumeroProcessiCoda=N.NumeroProcessiCoda
			,CTL.Descrizione=case 
								when NonTrattato=1 then '[NON TRATTATO] '
								else ''
							end + cast(S.SRV_Description as nvarchar(max))
			,CTL.SRV_SecIntervalEsteso =cast ( SRV_SecInterval / (60*60) AS varchar(2) ) + ' ore,' +
										cast ( (SRV_SecInterval % (60*60)) / 60 AS varchar(2) ) + ' minuti,' +
										cast ( ( (SRV_SecInterval % (60*60)) % 60 ) AS varchar(2) ) + ' secondi' 
		from CTL_MONITOR_LIB_SERVICES CTL
			inner join LIB_Services S  on S.SRV_id=CTL.SRV_id
			left outer join #t N on  S.SRV_id = N.SRV_id  
		where S.bDeleted=0 
		
		

	--select 
	--	S.[SRV_id], 
	--	S.[SRV_Description], S.[SRV_DOC_ID], S.[SRV_DPR_ID], 
	--	S.[SRV_SecInterval], S.[SRV_SQL], S.[SRV_LastExec], 
	--	S.[SRV_Module], S.[bDeleted], S.[SRV_KEY], S.[SRV_PARAM], S.[SRV_SOGLIA],
	--	--S.*, 
	--	N.NumeroProcessiCoda , 
		
	--	case 
	--		when NonTrattato=1 then '[NON TRATTATO] '
	--		else ''
	--	end + cast(SRV_Description as nvarchar(max)) as Descrizione,
		
	--	--SRV_SecInterval / (60*60)   as Ore,
	--	--(SRV_SecInterval % (60*60)) / 60  as Minuti    ,
	--	--( (SRV_SecInterval % (60*60)) % 60 ) as Secondi
	--	cast ( SRV_SecInterval / (60*60) AS varchar(2) ) + ' ore,' +
	--	cast ( (SRV_SecInterval % (60*60)) / 60 AS varchar(2) ) + ' minuti,' +
	--	cast ( ( (SRV_SecInterval % (60*60)) % 60 ) AS varchar(2) ) + ' secondi' as SRV_SecIntervalEsteso


	--	from 
	--		LIB_Services S 
	--			left outer join #t N on  S.SRV_id = N.SRV_id  
	--		where S.bDeleted=0 
	--		order by N.NumeroProcessiCoda desc
	if @IdPfu <> -1
	BEGIN
		select 
			S.*,
			CTL.NumeroProcessiCoda,
			CTL.Descrizione,
			CTL.SRV_SecIntervalEsteso 
			from CTL_MONITOR_LIB_SERVICES CTL
				inner join LIB_Services S on S.SRV_id = CTL.SRV_id
			order by CTL.NumeroProcessiCoda desc
			--select * from #t
	END
	drop table  #t


GO
