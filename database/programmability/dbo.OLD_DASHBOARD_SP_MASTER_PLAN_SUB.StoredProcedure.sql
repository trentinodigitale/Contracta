USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_DASHBOARD_SP_MASTER_PLAN_SUB]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









CREATE proc [dbo].[OLD_DASHBOARD_SP_MASTER_PLAN_SUB]
(
 @tipoDoc						varchar(8000),
 @IdDoc							int,
 @Filtro						varchar(max),
 @Sort 							varchar(max),
 @IdPfu							int
 )
 as
 begin

 	set nocount on

	declare @SQL_COL	nvarchar(max)
	declare @SQL_COL_V	nvarchar(max)
	
	declare @SQL_JOIN	nvarchar(max)
	declare @ix			int
	declare @vbcrlf		nvarchar(100)
	declare @azienda	nvarchar(100)
	declare	@aziragioneSociale nvarchar(1000)
	declare @nHideMacroConvenzione as int
	
	set @nHideMacroConvenzione=0

	declare @SQL		nvarchar(max)
	

	--recupero da paraemtro se devo nascondere macroconvenzione
	select @nHideMacroConvenzione = dbo.parametri('DASHBOARD_SP_MASTER_PLANGriglia','Macro_Convenzione','HIDE','0',-1)

	set @vbcrlf = '
'
	set @ix = 1
	set @SQL_COL = '' 
	set @SQL_COL_V = '' 
	
	set @SQL_JOIN = '' 

	--print 'passo 1' 

	create table #T_ODC ( totaleeroso float , Azienda varchar(50) COLLATE database_default, LinkedDoc int )

	-------------------------------------------------------------------------
	-- ESTRAZIONE EROSIONE per Convenzione ed Ente
	-------------------------------------------------------------------------
	set @SQL = '
	insert into #T_ODC ( totaleeroso  , Azienda  , LinkedDoc )
	select 
		round( sum( totaleeroso ) , 2 ) as totaleeroso , 

		p.pfuidazi as Azienda , 
		r.LinkedDoc
	 
	from ctl_doc r with(nolock)
		inner join document_odc o with(nolock) on [RDA_ID] = r.id
		inner join ctl_doc c with(nolock) on c.id = r.linkeddoc
		inner join document_convenzione co with(nolock) on c.id = co.id
		INNER JOIN ProfiliUtente P  with(nolock) ON O.RDA_Owner = CAST(P.IdPfu AS VARCHAR)
		inner join Aziende a with(nolock) on p.pfuidazi	 = a.idazi
		left outer join dbo.DM_Attributi d1 with(nolock) on d1.dztNome = ''TIPO_AMM_ER'' and d1.idApp = 1 and d1.lnk = A.idazi
		left outer join LIB_DomainValues with(nolock) on dmv_dm_id=''TIPO_AMM_ER'' and dmv_cod=d1.vatValore_FT
		inner join ProfiliUtente compilatore with(nolock) on compilatore.idpfu = c.idpfu
		inner join ProfiliUtente u with(nolock) on u.pfuidazi = compilatore.pfuidazi
	where r.tipodoc = ''ODC'' and (  ( isnull(o.IdDocRidotto,0) = 0 and r.StatoFunzionale in ( ''Inviato'' , ''Accettato'' ) ) or ( isnull(o.IdDocRidotto,0) > 0 and r.StatoFunzionale in ( ''Accettato'' ) ) )
		and r.deleted = 0 
		and u.IdPfu = ' + cast( @IdPfu as varchar(20)) + '
		'
		+ 
		@Filtro
		+
		'
		-- APPLICCARE I FILTRI RICHIESTI
			--rda_datacreazione, 
			--rda_datascad , 
			-- r.Azienda

	group by  p.pfuidazi , r.LinkedDoc
	


	'


	--print @SQL
	exec ( @SQL )
	--print 'passo 2' 


  	-------------------------------------------------------------------------
	-- Per ogni Cliente si effettua una left join
	-------------------------------------------------------------------------
	declare CurProg Cursor static for 
		select distinct azienda  , aziragioneSociale  from #T_ODC inner join aziende on idazi = Azienda order by aziragioneSociale  
	
	open CurProg

	FETCH NEXT FROM CurProg 	INTO @azienda , @aziragioneSociale
	WHILE @@FETCH_STATUS = 0
	BEGIN


		--set  @SQL_COL = @SQL_COL + @vbcrlf + 'TAB_' + @azienda + '.totaleeroso as [' +  @aziragioneSociale + '] ,' 
		--set  @SQL_JOIN = @SQL_JOIN + 'left outer join #T_ODC as TAB_' + @azienda + ' on TAB_' + @azienda + '.Azienda = ''' + @azienda +  '''  and TAB_' + @azienda + '.LinkedDoc = c.id ' + @vbcrlf

		set  @SQL_COL_V = @SQL_COL_V + @vbcrlf + '[' +  @aziragioneSociale + '] ,' 
		set  @SQL_COL = @SQL_COL + @vbcrlf + ' sum( case when r.Azienda = ' + @azienda +  ' then r.totaleeroso else 0 end ) as [' +  @aziragioneSociale + '] ,' 

		set @ix = @ix + 1
	
		FETCH NEXT FROM CurProg 	INTO @azienda , @aziragioneSociale
	END 
    
	CLOSE CurProg
	DEALLOCATE CurProg



	--print 'passo 3' 

	-------------------------------------------------------------------------
	-- si costruisce lo script per l'estrazione dei dati
	-------------------------------------------------------------------------
	set @SQL = '

	-- determino le convezioni presenti
	select  LinkedDoc ,sum( totaleeroso ) as TotaleRiga into #T_CONV from #T_ODC group by LinkedDoc

	select  LinkedDoc , ' + @SQL_COL + ' 1 as A into #T_AZIENDE from #T_ODC r group by LinkedDoc

	select 

		c.Titolo  as [Descrizione Sintetica Convenzione],
		--co.DOC_Name  as [Descrizione Sintetica Convenzione],
		--dbo.NormString( co.DOC_Name ) as [Descrizione Sintetica Convenzione],


		--co.Ambito as [Categoria Merceologica Prevalente],
		AM.DMV_DescML as [Categoria Merceologica Prevalente],


		--co.IdentificativoIniziativa as [Identificativo dell''iniziativa], 
		INIZ.NumeroDocumento  + '' - '' + isnull( cast( INIZ.Body as nvarchar(max)) , INIZ.Titolo ) as [Identificativo dell''iniziativa], 
		

		--Macro_Convenzione as [Macro Convenzione],
		--MC.DMV_DescML as [Macro Convenzione],
	'
	
	--se devo mostrare macro convenzione lo aggiungo 
	if @nHideMacroConvenzione = '0'
		set @SQL = @SQL + '
			isnull( MCL.ML_Description , MC.DMV_DescML ) as [Macro Convenzione], '

	set @SQL = @SQL + '

		co.NumOrd as [Numero Convenzione],

		 '

		 + @SQL_COL_V + @vbcrlf +

		' 

		r.TotaleRiga as [Totale Valore OdF Eroso]  ,
		--r.sum( totaleeroso ) as [Totale Valore OdF Eroso] 


		co.Total as [Valore Convenzione], 

		round( ( co.TotaleOrdinato / co.Total ) * 100.0 , 2 )  as [Livello Erosione],



		cast( c.id as varchar(10)) as [identity] ,


		--c.StatoFunzionale as [Stato Convenzione],
		ST.DMV_DescML as [Stato Convenzione],

		convert( varchar(10) , co.DataStipulaConvenzione , 105 ) as [Data Pubblicazione],
		convert( varchar(10) , co.DataFine , 105 ) as [Data Scadenza],
		
		--co.TipoScadenzaOrdinativo as [Tipo Scadenza OdF],
		TSO.DMV_DescML as [Tipo Scadenza OdF],
		
		
		co.NumeroMesi as [Numero Mesi OdF],
		convert( varchar(10) , co.DataScadenzaOrdinativo , 105 )  as [Scadenza OdF/ Scadenza MAssima OdF]


		--co.TotaleOrdinato 
	 
		from #T_CONV r
		--from #T_ODC r
			inner join ctl_doc c with(nolock) on r.LinkedDoc = c.id
			inner join document_convenzione co with(nolock) on c.id = co.id
			inner join #T_AZIENDE a on r.LinkedDoc = a.LinkedDoc

			-- decodifica
			left outer join ctl_doc INIZ with(nolock) on  INIZ.StatoDoc = ''Sended'' and INIZ.TipoDoc = ''INIZIATIVA'' and INIZ.Deleted = 0  and isnumeric(INIZ.numerodocumento) = 1 and INIZ.numerodocumento = co.IdentificativoIniziativa
			left outer join LIB_DomainValues MC with(nolock) on MC.DMV_DM_ID = ''Macro_Convenzione'' and MC.DMV_COD = Macro_Convenzione
			left outer join LIB_Multilinguismo MCL with(nolock) on MCL.ML_LNG = ''I'' and MC.DMV_DescML = MCL.ML_KEY
			left outer join LIB_DomainValues AM with(nolock) on AM.DMV_DM_ID = ''Ambito'' and AM.DMV_COD = co.Ambito
			left outer join LIB_DomainValues ST with(nolock) on ST.DMV_DM_ID = ''StatoFunzionale'' and ST.DMV_COD = c.StatoFunzionale
			left outer join LIB_DomainValues TSO with(nolock) on TSO.DMV_DM_ID = ''TipoScadenzaODC'' and TSO.DMV_COD = co.TipoScadenzaOrdinativo
			
			where co.total <> 0
		order by round( ( co.TotaleOrdinato / co.Total ) * 100.0 , 2 ) desc , r.TotaleRiga desc

' 



--+ @SQL_JOIN

	--print 'passo 4' 


	--print @SQL 
	
	exec( @SQL )
	--print 'passo 5' 


--	select @cnt = count(*) from #temp
	--set @cnt = @@rowcount


end










GO
